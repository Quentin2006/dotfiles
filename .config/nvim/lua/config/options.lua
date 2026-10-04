-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.g.lazyvim_python_lsp = "basedpyright"

-- Arduino sketches are C++ for clangd (compile DB maps device.ino explicitly)
vim.filetype.add({ extension = { ino = "cpp" } })
-- CCIDE: Auto-upload buffer to GitHub Gist on save
_G.CCIDE = {
  augroup_id = nil,
  github_token = os.getenv("GITHUB_TOKEN") or "", -- Set GITHUB_TOKEN env var
  gist_id = "25c7ce5cf7ba79a759436dd427bf8723",
}

local function update_gist()
  if not _G.CCIDE.gist_id then
    print("Gist ID is not set. Please start the uploader with a valid gist ID.")
    return
  end

  local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local filename = vim.fn.expand("%:t")
  local data = {
    description = "Updated via Neovim",
    files = {
      [filename] = {
        content = buf_content,
      },
    },
  }

  local result = _G.CCIDE:_patch_gist(data)
  if result then
    print("Gist updated successfully.")
  end
end

--- PATCH the gist with given data. Returns true on success.
function _G.CCIDE:_patch_gist(data)
  if not self.gist_id then
    print("Gist ID is not set.")
    return false
  end
  local json_data = vim.fn.json_encode(data)
  local result = vim.fn.system({
    "curl",
    "-s",
    "-X",
    "PATCH",
    "-H",
    "Authorization: token " .. self.github_token,
    "-d",
    json_data,
    "https://api.github.com/gists/" .. self.gist_id,
  })

  if result:match('"message":') then
    local err_message = result:match('"message":%s-"(.-)"')
    print("Update failed: " .. err_message)
    return false
  end
  return true
end

vim.api.nvim_create_user_command("CCIDEUpdate", function()
  update_gist()
end, {})
