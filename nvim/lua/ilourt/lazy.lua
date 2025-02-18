require("lazy").setup({
  { import = "ilourt.plugins" },

  "folke/which-key.nvim",
  { 'nvim-treesitter/nvim-treesitter',            build = ':TSUpdate' },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  {
    'numToStr/Comment.nvim',
    lazy = false,
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring' },

  { 'mbbill/undotree' },

  -- Git management
  { 'tpope/vim-fugitive' },
  {
    "kdheepak/lazygit.nvim",
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  { "f-person/git-blame.nvim" },

  -- Multi cursor
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      'smoka7/hydra.nvim',
    },
    opts = {},
    cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
    keys = {
      {
        mode = { 'v', 'n' },
        '<Leader>m',
        '<cmd>MCstart<cr>',
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
  },

  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      --- Uncomment these if you want to manage LSP servers from neovim
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'L3MON4D3/LuaSnip' },
    }
  },

  -- Manage outline
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
    end,
  },

  -- Display lsp errors in a bottom panel
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup {
        --
        -- use_diagnostic_signs = true,
      }
    end,
  },

  {
    "rebelot/heirline.nvim",
    dependencies = {
      {
        "lewis6991/gitsigns.nvim",
        config = function()
          require('gitsigns').setup()
        end
      }
    },
    config = function()
      require("ilourt.plugins-setup.heirline")
    end,
  },

  -- copilot
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-j>",
            next = "<C-l>",
            previous = "<C-k>",
          }
        },
        panel = { enabled = false },
      })
    end
  },

  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end
  }
})
