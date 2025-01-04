return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim"
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local lga_actions = require("telescope-live-grep-args.actions")

    telescope.setup {
      defaults = {
        mappings = {
          n = {
            ['<c-d>'] = actions.delete_buffer
          }, -- n
          i = {
            ["<C-h>"] = "which_key",
            ['<c-d>'] = actions.delete_buffer
          } -- i
        }   -- mappings
      },    -- defaults
      extensions = {
        live_grep_args = {
          mappings = {
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              -- freeze the current list and start a fuzzy search in the frozen list
              ["<C-space>"] = actions.to_fuzzy_refine, -- i
            }                                          -- mappings
          }
        }
      }
    }

    -- load extensions
    telescope.load_extension('live_grep_args')
  end,
}
