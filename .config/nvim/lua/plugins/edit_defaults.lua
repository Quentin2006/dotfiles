return {

  -- get rid of bs file tree and scroll animation
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      scroll = { enabled = false },
    },
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>E",  false },
      { "<leader>e",  false },
    },
  },

  -- get rid of annoying constant status updates
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
      },
    },
  },

  -- get rid of bufferline
  {
    "akinsho/bufferline.nvim",
    enabled = false,
    keys = {
      { "<leader>bp", false },
      { "<leader>bP", false },
      { "<leader>br", false },
      { "<leader>bl", false },
      { "<S-h>",      false },
      { "<S-l>",      false },
      { "[b",         false },
      { "]b",         false },
      { "[B",         false },
      { "]B",         false },
    },
  },
  {
    {
      "folke/sidekick.nvim",
      opts = {
        nes = {
          enabled = false,
        },
      },
    },
  },
}
