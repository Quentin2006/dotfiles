return {
  "stevearc/oil.nvim",
  opts = {

    columns = {
      "icon",
      "size",
      "permissions",
      "mtime",
    },
    watch_for_changes = true,

    view_options = {
      show_hidden = true,
    },
  },
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
  },
}
