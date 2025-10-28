-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Helper function: Build and start debugging
local function build_and_debug()
  local path = vim.fn.expand("%:h")
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:t:r")
  local exe = path .. "/build/" .. output
  local ft = vim.bo.filetype
  local build_cmd
  vim.fn.system("mkdir ./build")

  if ft == "c" then
    build_cmd = string.format("gcc -g '%s' -o '%s'", file, exe)
  elseif ft == "cpp" then
    build_cmd = string.format("g++ -g '%s' -o '%s'", file, exe)
  else
    vim.notify("Not a C/C++ file", vim.log.levels.WARN)
    return
  end

  -- Build the file
  vim.notify("Building " .. file .. " ...", vim.log.levels.INFO)
  local result = vim.fn.system(build_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Build failed:\n" .. result, vim.log.levels.ERROR)
    return
  end
  vim.notify("Build successful: " .. exe, vim.log.levels.INFO)

  -- Start debugging
  local dap = require("dap")
  dap.run({
    type = "codelldb",
    request = "launch",
    name = "Launch C/C++ file",
    program = exe,
    cwd = vim.fn.getcwd(),
    stopOnEntry = false,
    runInTerminal = true,
  })
end

-- Helper function: Stop debugging
local function stop_debug()
  local dap = require("dap")
  local dapui = require("dapui")
  dap.close()
  dapui.close()
end

-- F5: Start/Restart the application
map("n", "<F5>", function()
  stop_debug()
  vim.defer_fn(build_and_debug, 100)
end, { desc = "Restart Debug (F8)" })

-- F6: Step into in debugging
map("n", "<F6>", function()
  require("dap").step_into()
end, { desc = "Step Into (F6)" })
--
-- F7: Stop debugging
map("n", "<F7>", stop_debug, { desc = "Stop Debug (F7)" })
