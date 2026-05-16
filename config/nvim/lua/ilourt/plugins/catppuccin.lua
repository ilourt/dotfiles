return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = function()
    local C = require('catppuccin.palettes').get_palette('mocha')

    return {
      flavour = 'mocha',
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { 'italic' },
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
        },
        aerial = true,
        cmp = true,
        gitsigns = true,
        lsp_trouble = true,
        markdown = true,
        mason = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      custom_highlights = {
        NormalFloat = { fg = C.text, bg = C.mantle },
        FloatBorder = { fg = C.blue, bg = C.mantle },
        OnYank = { fg = C.base, bg = C.teal },

        Pmenu = { fg = C.text, bg = C.surface0 },
        PmenuSel = { fg = C.surface0, bg = C.blue },
        CmpItemAbbr = { fg = C.text },
        CmpItemAbbrMatch = { fg = C.blue, style = { 'bold' } },
        CmpItemAbbrMatchFuzzy = { fg = C.blue, style = { 'bold' } },

        DiagnosticHint = { fg = C.blue, style = { 'italic' } },
        DiagnosticSignHint = { fg = C.blue },
        DiagnosticFloatingHint = { fg = C.blue },

        ['@parameter'] = { fg = C.maroon, style = {} },
        ['@namespace'] = { fg = C.lavender, style = {} },
        ['@text.emphasis'] = { fg = C.maroon, style = {} },
        ['@text.uri'] = { fg = C.rosewater, style = { 'underline' } },
        ['@tag.attribute'] = { fg = C.teal, style = {} },

        LspInfoBorder = { link = 'FloatBorder' },
        LspInfoTitle = { fg = C.blue },
        LspInfoList = { fg = C.green },
        LspInfoFiletype = { fg = C.yellow },
        LspInfoTip = { link = 'Comment' },

        TelescopePromptBorder = { fg = C.blue, bg = C.base },
        TelescopePromptTitle = { fg = C.blue, bg = C.base },
        TelescopeResultsBorder = { fg = C.blue, bg = C.base },
        TelescopeResultsTitle = { fg = C.blue, bg = C.base },
        TelescopePreviewBorder = { fg = C.blue, bg = C.base },
        TelescopePreviewTitle = { fg = C.blue, bg = C.base },

        MiniIndentscopeSymbol = { fg = C.text },
      },
    }
  end,
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme('catppuccin')
  end,
}
