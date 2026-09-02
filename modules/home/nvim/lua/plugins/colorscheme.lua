return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        contrast = "hard",
        palette_overrides = {},
        overrides = {
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          FoldColumn = { bg = "NONE" },
          EndOfBuffer = { bg = "NONE" },
          MsgArea = { bg = "NONE" },
        },
        dim_inactive = false,
        transparent_mode = true,
      })
      vim.cmd("colorscheme gruvbox")
      -- Force transparent background highlights across UI
      local transparent_groups = {
        "Normal", "NormalNC", "NormalFloat", "FloatBorder",
        "SignColumn", "FoldColumn", "EndOfBuffer", "MsgArea",
        "TelescopeNormal", "TelescopeBorder", "NtreeNormal", "NeoTreeNormal",
        "SnacksNormal", "SnacksNormalNC"
      }
      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE" })
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
