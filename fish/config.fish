if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path "/opt/homebrew/bin/"

# Configure zoxide (an improvement over cd)
zoxide init --cmd s fish | source
