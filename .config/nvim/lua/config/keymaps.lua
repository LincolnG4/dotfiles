-- Helper function to check if a value exists in a table
local function contains(tbl, val)
  for _, value in ipairs(tbl) do
    if value == val then
      return true
    end
  end
  return false
end

-- Helper function: Build and start debugging
local function build_and_debug()
  local path = vim.fn.expand("%:h")
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:t:r")
  local exe = path .. "/build/" .. output
  local ft = vim.bo.filetype
  local build_cmd
  local dap_config

  -- For C/C++, we still need to build manually
  if contains({ "c", "cpp" }, ft) then
    -- Ensure the build directory exists for C/C++
    if not vim.fn.isdirectory(path .. "/build") then
      vim.fn.mkdir(path .. "/build", "p")
    end

    if ft == "c" then
      build_cmd = string.format("gcc -g '%s' -o '%s'", file, exe)
    elseif ft == "cpp" then
      build_cmd = string.format("g++ -g '%s' -o '%s'", file, exe)
    end

    -- Build the file
    vim.notify("Building " .. file .. " ...", vim.log.levels.INFO)
    local result = vim.fn.system(build_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("Build failed:\n" .. result, vim.log.levels.ERROR)
      return
    end
    vim.notify("Build successful: " .. exe, vim.log.levels.INFO)
  elseif not contains({ "go", "python" }, ft) then
    vim.notify("Not a C, C++, Go, or Python file", vim.log.levels.WARN)
    return
  end

  -- Set up DAP configuration based on filetype
  local dap = require("dap")

  if contains({ "c", "cpp" }, ft) then
    dap_config = {
      type = "codelldb",
      request = "launch",
      name = "Launch C/C++ file",
      program = exe,
      cwd = vim.fn.getcwd(),
      stopOnEntry = false,
      runInTerminal = true,
    }
  elseif ft == "go" then
    -- For Go, we let the DAP adapter handle the build process.
    -- We just tell it which package to debug (the directory of the current file).
    dap_config = {
      type = "go",
      name = "Launch Go file",
      request = "launch",
      program = path, -- Tell Delve to debug the package in this directory
      console = "integratedTerminal",
    }
  elseif ft == "python" then
    dap_config = {
      type = "python",
      request = "launch",
      name = "Launch Python file",
      program = file,
      pythonPath = "python",
    }
  else
    vim.notify("No debugger configuration for this filetype", vim.log.levels.WARN)
    return
  end

  -- Start debugging
  vim.notify("Starting debugger...", vim.log.levels.INFO)
  dap.run(dap_config)
end

-- Helper function: Stop debugging
local function stop_debug()
  local dap = require("dap")
  if dap.status() ~= "dap is not active" then
    local dapui = require("dapui")
    dap.close()
    dapui.close()
  end
end

-- Key mappings
local map = vim.keymap.set

-- F5: Start/Restart the application
map("n", "<F5>", function()
  stop_debug()
  vim.defer_fn(build_and_debug, 100)
end, { desc = "Build and Debug (F5)" })

-- F6: Step into in debugging
map("n", "<F6>", function()
  require("dap").step_into()
end, { desc = "Step Into (F6)" })

-- Sh+F6: Continue in debugging
map("n", "<F11>", function()
  require("dap").continue()
end, { desc = "Continue (F11)" })

-- F7: Stop debugging
map("n", "<F7>", stop_debug, { desc = "Stop Debug (F7)" })
