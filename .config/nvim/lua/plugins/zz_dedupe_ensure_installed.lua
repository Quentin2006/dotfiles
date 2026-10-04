-- LazyVim's lang.clangd and lang.rust extras BOTH push "codelldb" onto
-- mason.nvim's opts.ensure_installed:
--   extras/lang/clangd.lua  opts = { ensure_installed = { "codelldb" } }
--   extras/lang/rust.lua    vim.list_extend(opts.ensure_installed, { "codelldb" })
-- With both extras enabled the list holds codelldb twice. LazyVim's
-- lazyvim/plugins/lsp/init.lua then loops the list and calls install() twice,
-- and mason's guard fires:
--   assert(not self:is_installing(), "Package is already installing.")
-- which throws during plugin config and aborts the whole LSP setup.
--
-- Dedupe after both extras have contributed. The zz_ prefix sorts this file
-- last among lua/plugins/, so it runs after clangd.lua and rust.lua would.
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) ~= "table" then
        return
      end
      local seen, deduped = {}, {}
      for _, tool in ipairs(opts.ensure_installed) do
        if not seen[tool] then
          seen[tool] = true
          deduped[#deduped + 1] = tool
        end
      end
      opts.ensure_installed = deduped
    end,
  },
}