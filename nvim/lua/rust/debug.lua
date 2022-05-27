local dap = require("dap")
local Job = require("plenary.job")

local M = {}

function M.get_params()
    return {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = nil, -- get em all
    }
end

function M.handler(err, result)
    if err then
        return
    end

    result = vim.tbl_filter(function(value)
        return value.args.cargoArgs[1] ~= "check"
    end, result)

    for i, _ in ipairs(result) do
        if result[i].args.cargoArgs[1] == "run" then
            result[i].args.cargoArgs[1] = "build"
        elseif result[i].args.cargoArgs[1] == "test" then
            table.insert(result[i].args.cargoArgs, 2, "--no-run")
        end
    end

    local options = {}
    for _, debuggable in ipairs(result) do
        local ret = ""
        local args = debuggable.args

        for _, value in ipairs(args.cargoArgs) do
            ret = ret .. value .. " "
        end

        for _, value in ipairs(args.cargoExtraArgs) do
            ret = ret .. value .. " "
        end

        if not vim.tbl_isempty(args.executableArgs) then
            ret = ret .. "-- "
            for _, value in ipairs(args.executableArgs) do
                ret = ret .. value .. " "
            end
        end

        table.insert(options, ret)
    end

    vim.ui.select(options,
        { prompt = "Debuggables", kind = "rust-tools/debuggables" },
        function(_, choice)
            local args = result[choice].args
            local cargo_args = args.cargoArgs

            table.insert(cargo_args, "--message-format=json")

            for _, value in ipairs(args.cargoExtraArgs) do
                table.insert(cargo_args, value)
            end

            vim.notify("\nCompiling...")
            Job:new({
                command = "cargo",
                args = cargo_args,
                cwd = args.workspaceRoot,
                on_exit = function(j, code)
                    if code and code > 0 then
                          vim.schedule(function()
                              vim.notify(err, vim.log.levels.ERROR)
                          end)
                    end
                    vim.schedule(function()
                        for _, value in pairs(j:result()) do
                            local json = vim.fn.json_decode(value)
                            if type(json) == "table" and json.executable ~= vim.NIL and json.executable ~= nil then
                                dap.run({
                                    name = "Rust debug",
                                    type = "codelldb",
                                    request = "launch",
                                    program = json.executable,
                                    args = args.executableArgs or {},
                                    cwd = args.workspaceRoot,
                                    stopOnEntry = false,
                                    runInTerminal = false,
                                })
                                
                                break
                            end
                        end
                    end)
                end,
            }):start()
        end
    )
end

return M
