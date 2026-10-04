-- CS lab hosts have gcc-16 installed WITHOUT libstdc++-16-dev: the
-- /usr/lib/gcc/x86_64-linux-gnu/16 directory exists, but /usr/include/c++/16
-- does not. clangd probes for the newest toolchain directory, picks 16, and
-- injects a missing C++ include path -- so <cassert>, <cstdio> and <cmath>
-- resolve to nothing and .cu files report ceil/printf/assert as undeclared.
--
-- Fix by handing clangd GCC 15's include paths directly through
-- init_options.compileFlags, which is the same mechanism a .clangd
-- CompileFlags block uses. Conditional because omarchy has a complete GCC 16
-- and no GCC 15 at all -- adding these unconditionally there would turn a
-- clean file into six errors. A .clangd file cannot express that test, and
-- one under ~/CS/ is also read on this machine through the ada-CS sshfs mount.
--
-- Rejected alternatives, both verified:
--   --gcc-install-dir=...  clangd does not accept it; it exits 1 immediately.
--   --query-driver=g++-15   clangd accepts it but does not redirect the C++
--                          include path; diagnostics are unchanged.
--
-- zz_ prefix so this sorts after arduino_lsp.lua and appends to the clangd
-- config rather than being clobbered by its force-extend.
local MISSING_CXX = "/usr/include/c++/16"
local GCC15_CXX = "/usr/include/c++/15"
local GCC15_X86 = "/usr/include/x86_64-linux-gnu/c++/15"

if vim.fn.isdirectory(MISSING_CXX) == 0 and vim.fn.isdirectory(GCC15_CXX) == 1 then
  return {
    {
      "neovim/nvim-lspconfig",
      opts = function(_, opts)
        opts.servers.clangd = opts.servers.clangd or {}
        opts.servers.clangd.init_options = opts.servers.clangd.init_options or {}
        opts.servers.clangd.init_options.compileFlags =
          vim.list_extend(opts.servers.clangd.init_options.compileFlags or {}, {
            "-isystem", GCC15_CXX,
            "-isystem", GCC15_X86,
            "-isystem", GCC15_CXX .. "/backward",
          })
      end,
    },
  }
end