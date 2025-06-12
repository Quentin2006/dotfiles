#!/bin/sh
#
# watch-wall.sh — Efficiently monitor ~/.current.wall for symlink target changes
#

TARGET="$HOME/.current.wall"

if [ ! -L "$TARGET" ]; then
    echo "Error: $TARGET is not a symlink." >&2
    exit 1
fi

# Get the initial symlink target
prev_target="$(readlink "$TARGET")"

echo "Watching $TARGET for changes..."

while true; do
    # Wait for an attribute change or move to the symlink
    inotifywait -e attrib -e move -e create -e delete "$(dirname "$TARGET")" >/dev/null 2>&1

    # Check if the symlink target changed
    current_target="$(readlink "$TARGET")"
    if [ "$current_target" != "$prev_target" ]; then
        prev_target="$current_target"
        echo "Symlink changed. Running: wallust run $TARGET"
        /home/qscheetz/.cargo/bin/wallust run "$TARGET"
    fi
done
