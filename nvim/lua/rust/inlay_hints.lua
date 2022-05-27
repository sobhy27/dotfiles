local M = {}

function M.get_params()
    local params = vim.lsp.util.make_given_range_params()
    params["range"]["start"]["line"] = 0
    params["range"]["end"]["line"] = vim.api.nvim_buf_line_count(0) - 1
    return params
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
        local line = val.position.line

        if parsed[line] ~= nil then
            table.insert(parsed[line], { label = val.label, kind = val.kind, range = val.position })
        else
            parsed[line] = { { label = val.label, kind = val.kind, range = val.position } }
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
                if value_inner.kind == 2 then
                    table.insert(param_hints, value_inner.label)
                end

                if value_inner.kind == 1 then
                    table.insert(other_hints, value_inner)
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
                    if value_inner_inner.kind == 2 then
                        local char_start = value_inner_inner.range.start.character
                        local char_end = value_inner_inner.range["end"].character
                        local variable_name = string.sub(
                            current_line,
                            char_start + 1,
                            char_end
                        )
                        virt_text = virt_text
                            .. variable_name
                            .. ": "
                            .. value_inner_inner.label
                    else
                        if string.sub(value_inner_inner.label, 1, 2) == ": " then
                            virt_text = virt_text .. value_inner_inner.label:sub(3)
                        else
                            virt_text = virt_text .. value_inner_inner.label
                        end
                    end
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
