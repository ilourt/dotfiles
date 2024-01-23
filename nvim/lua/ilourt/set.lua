vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/vim/undodir"
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Fold
vim.opt.foldmethod = "expr" -- Treesitter folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Treesitter folding
vim.opt.foldenable = false -- Disable folding by default

vim.g.mapleader  = " "

-- Enable global status line
vim.opt.laststatus = 3
