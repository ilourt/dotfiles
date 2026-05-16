return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.HINT] = "H",
            [vim.diagnostic.severity.INFO] = "I",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf, remap = false }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
          vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
          vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end, opts)
          vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
          vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        end,
      })

      local servers = {
        basedpyright = {},
        biome = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {
              lint = { enable = true },
            },
          },
        },
        tailwindcss = {},
        ts_ls = {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
        vim.lsp.config(server, config)
      end

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
    },
  },
}
