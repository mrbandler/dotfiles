return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },

  -- Disable tokyonight (LazyVim default)
  { "folke/tokyonight.nvim", enabled = false },
}
