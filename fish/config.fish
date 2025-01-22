if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path "/opt/homebrew/bin/"

# Configure zoxide (an improvement over cd)
zoxide init --cmd s fish | source

# Configure fzf
fzf --fish | source

# Update the path to include local/bin
set -gx PATH $PATH $HOME/.local/bin
