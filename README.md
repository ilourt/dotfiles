# Dotfiles

Contains the different config files for my PDE (Personnal development environment)

## Getting started

1. `./scripts/install`

## Dotfile manager

Use `scripts/dotman.py` to adopt, link, and audit config symlinks.

- Dry run old-layout migration: `./scripts/dotman.py migrate-layout --dry-run`
- Run migration: `./scripts/dotman.py migrate-layout`
- Adopt local config into repo: `./scripts/dotman.py adopt opencode --dry-run`
- Create and link new config dir: `./scripts/dotman.py create starlink`
- Audit symlink health: `./scripts/dotman.py doctor`

## Nvim

My neovim configuration

### For copilot chat 
https://github.com/CopilotC-Nvim/CopilotChat.nvim

1. `pip install python-dotenv requests pynvim==0.5.0 prompt-toolkit`
2. `pip install tiktoken` (optional for displaying prompt token counts)

## Wezterm 
My terminal configuration with wezterm

## Tmux

Install plugin manager: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
