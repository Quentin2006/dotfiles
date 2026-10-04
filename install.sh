#!/usr/bin/env bash
# Install these dotfiles by symlinking managed paths into $HOME.
#
# Idempotent: re-running is a no-op. Conflicts are preserved as
# $path.installbak (second run drops the stale backup and relinks).
#
# Managed set: the entries below plus every .config child except the
# Syncthing-transported Chromium flags file (transport is Syncthing, not
# a link — see .gitignore's "Syncthing-synced, git-unmanaged" section).
#
# Usage: install.sh [--dry-run] [--ada-mount]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME="${HOME%/}"

# This script symlinks managed paths into $HOME. Under sudo, $HOME becomes
# /root, so the whole manifest lands in root's home instead — including
# /root/.ssh, which then makes root's own ssh fail ("Bad owner or
# permissions"), breaking anything that shells out to ssh as root. Refuse
# outright rather than try to guess whose home we were meant to touch.
if [ "$(id -u)" -eq 0 ]; then
	echo "error: refusing to run as root; run as your normal user" >&2
	exit 1
fi
if [ -z "$HOME" ] || [ ! -d "$HOME" ]; then
	echo "error: \$HOME is not a usable directory: '${HOME}'" >&2
	exit 1
fi
if [ "$(id -un)" != "$(stat -c '%U' "$HOME")" ]; then
	echo "error: \$HOME ($HOME) is not owned by $(id -un)" >&2
	exit 1
fi

# Paths under $HOME that this repo manages, relative to both $HOME and repo
# root. .bashrc/.bash_history are files; the rest are directories.
#
# .ssh is linked whole, key included, and is deliberately absent from
# .stignore: every device holding this repo is trusted (same decision as
# bwtool below in .stignore). .gitignore still keeps .ssh/ out of git.
MANIFEST="
.bashrc
.bash_history
.ssh
.agents
.pi
.local/bin/bwtool
.local/share/applications
.local/share/icons
"

# Syncthing-transported paths inside .config that must NOT be linked.
SYNC_ONLY=".config/chromium-flags.conf"

# .config/herdr links through the generic loop below; only config.toml is
# user config. herdr's runtime files (logs, sockets, session.json,
# .plugins.lock) live in the same dir but are machine-local and
# Syncthing-ignored — see .stignore.

DRY_RUN=0
ADA_MOUNT=0
for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=1 ;;
	--ada-mount) ADA_MOUNT=1 ;;
	*) echo "error: unknown argument: $arg" >&2; exit 1 ;;
	esac
done

installed=0
skipped=0
backed=0
missing=0

link_item() {
	local p="$1"
	local src="$DOTFILES/$p"
	local dst="$HOME/$p"
	local rel resolved

	if [ ! -e "$src" ] && [ ! -L "$src" ]; then
		# A manifest entry with nothing behind it is drift (typo, or a path
		# that is not Syncthing-transported to this machine). Warn and carry on
		# rather than abort: the rest of the set is still worth linking, and a
		# hard exit here left a fresh machine with a half-installed $HOME.
		echo "warn  $p (missing from dotfiles -- manifest drift, skipped)"
		missing=$((missing + 1))
		return
	fi
	mkdir -p "$(dirname "$dst")"

	if [ -e "$dst" ] || [ -L "$dst" ]; then
		if [ -L "$dst" ]; then
			resolved="$(readlink -f "$dst" 2>/dev/null || true)"
			if [ "$resolved" = "$(readlink -f "$src")" ]; then
				echo "skip  $p (already linked)"
				skipped=$((skipped + 1))
				return
			fi
			case "$resolved" in
				"$DOTFILES"/*)
					echo "stale $p (dangling dotfiles link)"
					[ "$DRY_RUN" -eq 1 ] || rm -f "$dst"
					;;
				*)
					echo "backup foreign symlink $dst -> $dst.installbak"
					[ "$DRY_RUN" -eq 1 ] || {
						mv "$dst" "$dst.installbak"
						backed=$((backed + 1))
					}
					;;
			esac
		elif [ -e "$dst.installbak" ]; then
			echo "conflict $p (old backup exists; dropping previous target)"
			[ "$DRY_RUN" -eq 1 ] || rm -rf "$dst"
		else
			echo "backup $dst -> $dst.installbak"
			[ "$DRY_RUN" -eq 1 ] || {
				mv "$dst" "$dst.installbak"
				backed=$((backed + 1))
			}
		fi
	fi

	if [ "$DRY_RUN" -eq 1 ]; then
		echo "link   $p (dry-run)"
	else
		rel="$(realpath --relative-to="$(dirname "$dst")" "$src")"
		ln -s "$rel" "$dst"
		echo "link   $dst -> $rel"
		installed=$((installed + 1))
	fi
}

# Optional, machine-specific: lazy sshfs mount of the CS cluster's shared
# home (ada's ~/CS) at ~/Documents/ada-CS. Opt in with --ada-mount.
#
# Not part of the default run, for two reasons. This repo is
# Syncthing-transported, so install.sh also runs on the laptop, the Steam
# Deck and friends, where an ada mount means nothing. And this needs root,
# installs a package and writes to /etc, none of which belong in a script
# whose contract is "symlink managed paths into $HOME".
#
# Implementation notes:
#   - autofs is not packaged for this system, and a user-level .automount
#     cannot work at all: the user manager has no CAP_SYS_ADMIN and only
#     fails with a bare "result: resources". Systemd implements automount
#     natively, so this is a system unit pair instead of an /etc/fstab
#     entry. A unit also sidesteps fstab needing to escape the '#' in
#     sshfs#host:/path.
#   - the mount is made by root, so the unit names the identity files
#     explicitly (root has no ~/.ssh/config). They are read back out of that
#     config for the ada host rather than hardcoded, so the Host ada block
#     stays the one place that lists them. They go in as separate options
#     because systemd splits Options= on whitespace, which tears an
#     `ssh_command=ssh -F ...` into unusable pieces.
#   - user_allow_other in /etc/fuse.conf is required or nobody but root can
#     traverse the mount; the stock file ships it commented out.
install_ada_mount() {
	local mount="$HOME/Documents/ada-CS"
	local host="$USER@ada.cs.pdx.edu"
	local remote="/u/qscheetz/CS"
	local mount_unit automount_unit tmp idents

	command -v systemd-escape >/dev/null || {
		echo "error: systemd-escape not found" >&2
		exit 1
	}

	mount_unit="$(systemd-escape --path "$mount" --suffix=mount)"
	automount_unit="$(systemd-escape --path "$mount" --suffix=automount)"

	# IdentityFiles for ada, exactly as ssh resolves them.
	idents="$(ssh -G ada 2>/dev/null | awk -v home="$HOME" '
		/^identityfile /{
			p = $2
			if (substr(p, 1, 1) == "~") p = home substr(p, 2)
			printf "IdentityFile=%s,", p
		}')"

	if [ "$DRY_RUN" -eq 1 ]; then
		echo "ada   would install sshfs and lazily mount $mount from $host:$remote"
		return
	fi

	# Prompt once, up front. The steps below make four separate sudo calls and
	# without a cached timestamp sudo asks for the password on every one.
	sudo -v

	sudo pacman -S --needed --noconfirm sshfs

	if ! grep -qE '^[[:space:]]*user_allow_other[[:space:]]*$' /etc/fuse.conf 2>/dev/null; then
		if grep -q 'user_allow_other' /etc/fuse.conf 2>/dev/null; then
			sudo sed -i 's/^#[[:space:]]*user_allow_other[[:space:]]*$/user_allow_other/' /etc/fuse.conf
		else
			printf '\nuser_allow_other\n' | sudo tee -a /etc/fuse.conf >/dev/null
		fi
	fi

	tmp="$(mktemp -d)"

	cat > "$tmp/$automount_unit" <<EOF
[Unit]
Description=Automount ada CS coursework over SSH
Documentation=man:sshfs(1)

[Automount]
Where=$mount
# Unmount when idle so a dropped connection never leaves a stale mount.
TimeoutIdleSec=10min

[Install]
WantedBy=multi-user.target
EOF

	cat > "$tmp/$mount_unit" <<EOF
[Unit]
Description=ada CS coursework over SSH (fuse.sshfs)
Documentation=man:sshfs(1)
# Fail fast instead of hanging whatever touched the mountpoint when the
# CS network is unreachable.
JobRunningTimeoutSec=15s

[Mount]
What=$host:$remote
Where=$mount
Type=fuse.sshfs
Options=_netdev,allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,${idents}IdentitiesOnly=yes,StrictHostKeyChecking=accept-new,uid=$(id -u),gid=$(id -g),follow_symlinks

[Install]
WantedBy=multi-user.target
EOF

	sudo install -m 644 "$tmp/$automount_unit" "/etc/systemd/system/$automount_unit"
	sudo install -m 644 "$tmp/$mount_unit" "/etc/systemd/system/$mount_unit"
	rm -rf "$tmp"

	mkdir -p "$mount"
	# sshfs refuses chown on a live mount root, so only touch the mountpoint
	# when the real filesystem is not mounted on top of it. Check the fstype
	# rather than mountpoint -q, which is also true for a bare automount
	# trigger. The unit's uid/gid give the files themselves the right owner
	# either way, so a failure here is cosmetic.
	if [ "$(findmnt -n -o FSTYPE --target "$mount" 2>/dev/null || true)" != "fuse.sshfs" ]; then
		sudo chown "$(id -u):$(id -g)" "$mount" ||
			echo "warn  could not chown $mount (cosmetic)" >&2
	fi

	sudo systemctl daemon-reload
	sudo systemctl enable --now "$automount_unit"

	echo "ada   $mount (lazy; unmounts after 10 idle minutes)"
}

for p in $MANIFEST; do
	link_item "$p"
done

# .config/*: every child except the Syncthing-only entries, so a real
# ~/.config with unrelated app config is never replaced wholesale.
for src in "$DOTFILES"/.config/* "$DOTFILES"/.config/.[!.]*; do
	[ -e "$src" ] || continue
	name="$(basename "$src")"
	case " $SYNC_ONLY " in
		*" .config/$name "*) continue ;;
	esac
	link_item ".config/$name"
done

[ "$ADA_MOUNT" -eq 1 ] && install_ada_mount

if [ "$missing" -gt 0 ]; then
	if [ "$missing" -eq 1 ]; then
		echo "note  1 manifest entry had nothing in dotfiles and was skipped"
	else
		echo "note  $missing manifest entries had nothing in dotfiles and were skipped"
	fi
fi
echo "done: $installed linked, $skipped skipped, $backed backed up, $missing missing"
