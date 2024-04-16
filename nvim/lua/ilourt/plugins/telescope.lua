return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("telescope").setup{
        defaults = {
          mappings = {
            n = {
              ['<c-d>'] = require('telescope.actions').delete_buffer
            }, -- n
            i = {
              ["<C-h>"] = "which_key",
              ['<c-d>'] = require('telescope.actions').delete_buffer
            } -- i
          } -- mappings
        }, -- defaults
      }
    end,
}
