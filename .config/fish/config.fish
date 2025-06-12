# ~/.config/fish/config.fish

# Run only in interactive shells
if status is-interactive
    set -U fish_greeting ""
    # Initialize Oh My Posh with your custom theme
    oh-my-posh init fish --config $HOME/.config/ohmyposh/EDM115-newline.omp.json | source

    fastfetch --config examples/13

    # Simple aliases for quick commands
    alias c "clear"
    alias ff "fastfetch"
    alias ls "eza -a --icons=always"
    alias ll "eza -al --icons=always"
    alias lt "eza -a --tree --level=1 --icons=always"
    alias shutdown "systemctl poweroff"
    alias cleanup "~/.config/ml4w/scripts/arch/cleanup.sh"
    alias ada "ssh qscheetz@ada.cs.pdx.edu"
    alias v "nvim"
    alias vim "nvim"

    # Functions for complex or multi-command aliases
    function pull
        rsync -rzP qscheetz@ada.cs.pdx.edu:~/CS/ ~/Sync/CS/
    end

    function push
        rsync -rzP ~/Sync/CS/ qscheetz@ada.cs.pdx.edu:~/CS/
    end

    function sevtech-start
        cd ~/Sync/SevTech_Ages_Server_3.2.3
        ./ServerStart.sh
    end

    # Set your editor aliases only if EDITOR is set

end

