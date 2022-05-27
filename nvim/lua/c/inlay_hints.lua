local M = {}

function M.get_params()
    return { textDocument = vim.lsp.util.make_text_document_params() }
end

local namespace = vim.api.nvim_create_namespace("experimental/inlayHints")

function M.handler(err, result, ctx)
    if err then
        return
    end

    local bufnr = ctx.bufnr

    if vim.api.nvim_get_current_buf() ~= bufnr then
        return
    end

    -- clean it up at first
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local parsed = {}
    for _, val in pairs(result) do
        local line = tostring(val.range["end"].line)

        if parsed[line] ~= nil then
            table.insert(parsed[line], { label = val.label, kind = val.kind })
        else
            parsed[line] = { { label = val.label, kind = val.kind } }
        end
    end


    for key, value in pairs(parsed) do
        local virt_text = ""
        local line = tonumber(key)

        local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]

        if current_line then
            local param_hints = {}
            local other_hints = {}

            -- segregate paramter hints and other hints
            for _, value_inner in ipairs(value) do
                if value_inner.kind == "parameter" then
                    table.insert(param_hints, value_inner.label:sub(1, -2))
                else
                    local hint_text = value_inner.label
                    if hint_text:sub(1, 2) == ": " then
                        hint_text = hint_text:sub(3)
                    end
                    table.insert(other_hints, hint_text)
                end
            end

            -- show parameter hints inside brackets with commas and a thin arrow
            if not vim.tbl_isempty(param_hints) then
                virt_text = virt_text .. "<- ("
                for i, value_inner_inner in ipairs(param_hints) do
                    virt_text = virt_text .. value_inner_inner:sub(1, -2)
                    if i ~= #param_hints then
                        virt_text = virt_text .. ", "
                    end
                end
                virt_text = virt_text .. ") "
            end

            -- show other hints with commas and a thicc arrow
            if not vim.tbl_isempty(other_hints) then
                virt_text = virt_text .. "=> "
                for i, value_inner_inner in ipairs(other_hints) do
                    virt_text = virt_text .. value_inner_inner
                    if i ~= #other_hints then
                        virt_text = virt_text .. ", "
                    end
                end
            end

            -- set the virtual text if it is not empty
            if virt_text ~= "" then
                vim.api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
                    virt_text_pos = "eol",
                    virt_text = {
                        { virt_text, "Comment" },
                    },
                    hl_mode = "combine",
                })
            end
        end
    end
end

return M
