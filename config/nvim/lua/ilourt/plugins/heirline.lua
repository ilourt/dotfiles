return {
  "rebelot/heirline.nvim",
  dependencies = {
    {
      "lewis6991/gitsigns.nvim",
      opts = {},
    },
  },
  config = function()
    require("ilourt.plugins-setup.heirline")
  end,
}
