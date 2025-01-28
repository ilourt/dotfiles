local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
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

-- set the sign icons
lsp_zero.set_sign_icons({
  error = '',
  warn = '',
  hint = '',
  info = ''
})

-- Manage format on save
lsp_zero.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['lua_format'] = { 'lua' },
    -- ['ts_ls'] = { 'javascript', 'typescript' },
    ['biome'] = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue' },
    ['efm'] = { 'lua', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'json', 'yaml' },
    ['lexical'] = { 'elixir' },
    ['lua_ls'] = { 'lua' },
    ['pylsp'] = { 'python' },
  }
})

require('mason').setup({
  -- formatters = {
  --   prettier = {
  --     command = 'prettier',
  --     args = { '--stdin-filepath', vim.api.nvim_buf_get_name(0) },
  --     rootPatterns = {
  --       '.prettierrc',
  --       '.prettierrc.json',
  --       '.prettierrc.toml',
  --       '.prettierrc.json',
  --       '.prettierrc.yml',
  --       '.prettierrc.yaml',
  --       '.prettierrc.js',
  --       'package.json',
  --       'prettier.config.js',
  --     },
  --   },
  -- },
})

local mason_registry = require('mason-registry')
local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() ..
    '/node_modules/@vue/language-server'
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
    -- Configure ts ls to work with vue
    ts_ls = function()
      local ts_opts = {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            { name = "@vue/typescript-plugin", location = vue_language_server_path, languages = { "vue" } },
          }
        }
      }
      require('lspconfig').ts_ls.setup(ts_opts)
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
          -- rope_rename = { enabled = true },

        }
      }
      require('lspconfig').pylsp.setup({ settings = { pylsp = pylsp_opts } })
    end,

  }
})

-- Configure mason to use prettier for formatting


local cmp = require('cmp')
local cmp_format = lsp_zero.cmp_format()

cmp.setup({
  sources = {
    -- Copilot Source
    { name = 'nvim_lsp' },
    -- { name = 'supermaven' },
    { name = "copilot" },
    { name = 'buffer' }
  },
  formatting = cmp_format,
  mapping = cmp.mapping.preset.insert({
    -- scroll up and down the documentation window
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-y>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.confirm({ select = true }),
    ['<C-d>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ['<C-f>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
  }),
})
