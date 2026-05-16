return {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v3.x',
  dependencies = {
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'L3MON4D3/LuaSnip' },
  },
  config = function()
    local lsp_zero = require('lsp-zero')

    lsp_zero.on_attach(function(_, bufnr)
      lsp_zero.default_keymaps({ buffer = bufnr, remap = false })

      local opts = { buffer = bufnr, remap = false }
      vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
      vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
      vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
      vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
      vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
      vim.keymap.set("n", "gr", function() require 'telescope.builtin'.lsp_references() end, opts)
      vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
      vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end)

    lsp_zero.set_sign_icons({
      error = '',
      warn = '',
      hint = '',
      info = ''
    })

    lsp_zero.format_on_save({
      format_opts = {
        async = false,
        timeout_ms = 10000,
      },
      servers = {
        ['lua_format'] = { 'lua' },
        ['biome'] = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue' },
        ['lexical'] = { 'elixir' },
        ['elixirls'] = { 'elixir' },
        ['lua_ls'] = { 'lua' },
        ['pylsp'] = { 'python' },
      }
    })

    require('mason').setup({})

    require('mason-lspconfig').setup({
      ensure_installed = {
        'ts_ls',
        'lua_ls',
      },
      handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
          local lua_opts = lsp_zero.nvim_lua_ls()
          require('lspconfig').lua_ls.setup(lua_opts)
        end,
        ts_ls = function()
          require('lspconfig').ts_ls.setup({
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
          })
        end,
        pylsp = function()
          local function extra_args()
            local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
            return { "--python-executable", virtual .. "/bin/python3", true }
          end

          local pylsp_opts = {
            plugins = {
              black = { enabled = true },
              rope_autoimport = { enabled = true, completions = { enabled = true } },
              pylsp_mypy = {
                enabled = true,
                overrides = extra_args(),
                report_progress = true,
                live_mode = true,
              },
            }
          }

          require('lspconfig').pylsp.setup({ settings = { pylsp = pylsp_opts } })
        end,
        tailwindcss = function()
          require('lspconfig').tailwindcss.setup({
            init_options = {
              userLanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
              },
            },
          })
        end
      }
    })

    local cmp = require('cmp')
    local cmp_format = lsp_zero.cmp_format()

    cmp.setup({
      sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' }
      },
      formatting = cmp_format,
      mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-y>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.confirm({ select = true }),
        ['<C-d>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-f>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      }),
    })
  end,
}
