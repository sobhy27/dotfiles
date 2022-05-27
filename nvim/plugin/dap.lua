local dap = require("dap")

dap.listeners.after.event_initialized["dapui_config"] = function()
    local opts = { noremap = true, silent = true }

    -- terminate dap
    vim.keymap.set("n", "<F1>", [[:lua require("dap").terminate()<CR>]], opts)

    -- toggle dapui
    vim.keymap.set("n", "<F4>", [[:lua require("dapui").toggle()<CR>]], opts)

    -- dap keymaps
    vim.keymap.set("n", "<F10>", [[:lua require("dap").step_over()<CR>]], opts)
    vim.keymap.set("n", "<F11>", [[:lua require("dap").step_into()<CR>]], opts)
    vim.keymap.set("n", "<F12>", [[:lua require("dap").step_out()<CR>]], opts)

    require("nvim-dap-virtual-text").enable()
end

dap.listeners.after.event_terminated["dapui_config"] = function()
    -- delete keymaps
    pcall(vim.keymap.del, "n", "<F1>")
    pcall(vim.keymap.del, "n", "<F4>")
    pcall(vim.keymap.del, "n", "<F10>")
    pcall(vim.keymap.del, "n", "<F11>")
    pcall(vim.keymap.del, "n", "<F12>")
    
    require("dapui").close()
    require("nvim-dap-virtual-text").disable()
end

-- codelldb path
local codelldb_path = vim.fn.stdpath("config") .. "/tools/codelldb/extension/"

-- codelldb adapter
dap.adapters.codelldb = function(on_adapter)
    -- This asks the system for a free port
    local tcp = vim.loop.new_tcp()
    tcp:bind('127.0.0.1', 0)
    local port = tcp:getsockname().port
    tcp:shutdown()
    tcp:close()

    -- Start codelldb with the port
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)
    local opts = {
        stdio = { nil, stdout, stderr },
        args = { "--port", tostring(port), "--liblldb", codelldb_path .. "lldb/lib/liblldb.so" },
    }
    local handle
    local pid_or_err
    handle, pid_or_err = vim.loop.spawn(codelldb_path .. "adapter/codelldb", opts, function(code)
        stdout:close()
        stderr:close()
        handle:close()
        if code ~= 0 then
            print("codelldb exited with code", code)
        end
    end)
    if not handle then
        vim.notify("Error running codelldb: " .. tostring(pid_or_err), vim.log.levels.ERROR)
        stdout:close()
        stderr:close()
        return
    end
    vim.notify('codelldb started. pid=' .. pid_or_err)
    stderr:read_start(function(err, chunk)
        assert(not err, err)
        if chunk then
            vim.schedule(function()
                require("dap.repl").append(chunk)
            end)
        end
    end)
    local adapter = {
        type = 'server',
        host = '127.0.0.1',
        port = port
    }
    -- 💀
    -- Wait for codelldb to get ready and start listening before telling nvim-dap to connect
    -- If you get connect errors, try to increase 500 to a higher value, or check the stderr (Open the REPL)
    vim.defer_fn(function() on_adapter(adapter) end, 500)
end

require("dapui").setup()
require("nvim-dap-virtual-text").setup()
