return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.arduino_language_server = {
        cmd = {
          "arduino-language-server",
          "-clangd",
          "clangd",
          "-cli",
          "arduino-cli",
          "-cli-config",
          vim.fn.expand("~/.arduino15/arduino-cli.yaml"),
        },
        filetypes = {
          "arduino",
        },
      }
      -- Let clangd query the ESP32-S3 cross toolchain for system
      -- includes/defines. Without this it falls back to x86_64 flags and
      -- Arduino headers don't resolve. Mirrors CompileFlags.Compiler in .clangd.
      opts.servers.clangd = vim.tbl_deep_extend("force", opts.servers.clangd or {}, {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--query-driver=/home/qscheetz/.arduino15/packages/esp32/tools/esp-x32/2601/bin/xtensa-esp32s3-elf-g++",
        },
      })
    end,
  },
}
