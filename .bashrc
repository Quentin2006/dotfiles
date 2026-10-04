# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
# History lives in the synced repo (Syncthing), shared across machines.
export HISTFILE="$HOME/dotfiles/.bash_history"

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Ported from fish dotfiles (~/dotfiles/.config/fish/config.fish)
alias ls='eza --icons --group-directories-first -1'
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias v='nvim'
alias p3='python3'
alias lg='lazygit'

if [ -z "$TMUX" ] && [ -n "$PS1" ]; then
  tmux attach-session -t Work || tmux new-session -s Work
fi

# if [[ -z "$HERDR_ENV" && -n "$PS1" ]]; then
#   exec herdr
# fi

[[ -r "$HOME/.cargo/env" ]] &&
  [[ -r "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

. "$HOME/.cargo/env"

. "$HOME/.local/share/../bin/env"
