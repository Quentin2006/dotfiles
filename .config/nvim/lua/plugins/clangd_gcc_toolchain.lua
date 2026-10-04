-- CS lab hosts (ada, linuxlab) carry a HALF-INSTALLED GCC 16: the gcc-16
-- package is present so /usr/lib/gcc/x86_64-linux-gnu/16 exists, but
-- libstdc++-16-dev is not, so /usr/include/c++/16 does NOT.
--
-- clangd probes for the newest toolchain directory, picks 16, and injects
-- -I/usr/include/c++/16. That path is missing, so <cassert>, <cstdio> and
-- <cmath> resolve to nothing and .cu files report:
--     no matching function for call to 'ceil'
--     no matching function for call to 'printf'
--     use of undeclared identifier 'assert'
--
-- Pin the toolchain to GCC 15, which IS complete there. This must stay
-- conditional: omarchy has a complete GCC 16 and no GCC 15 at all, so pinning
-- it unconditionally turns a clean file into six errors. A .clangd file cannot
-- do this test, and one placed under ~/CS/ would also be read through the
-- ada-CS sshfs mount on this machine -- hence the check here.
--
-- Loads after arduino_lsp.lua (alphabetical), so this appends to the clangd
-- cmd it configured rather than being clobbered by its force-extend.
local MISSING_CXX = "/usr/include/c++/16"
local GCC15 = "/usr/lib/gcc/x86_64-linux-gnu/15"

if vim.fn.isdirectory(MISSING_CXX) == 0 and vim.fn.isdirectory(GCC15) == 1 then
  return {
    {
      "neovim/nvim-lspconfig",
      opts = function(_, opts)
        opts.servers.clangd = opts.servers.clangd or {}
        opts.servers.clangd.cmd = opts.servers.clangd.cmd or { "clangd" }
        opts.servers.clangd.cmd = vim.list_extend(opts.servers.clangd.cmd, {
          "--gcc-install-dir=" .. GCC15,
        })
      end,
    },
  }
end