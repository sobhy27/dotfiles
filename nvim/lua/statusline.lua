local M = {}
local Marked = require("harpoon.mark")
local width = vim.api.nvim_win_get_width(0)

local function file_name(path)
    local last_idx = 0

    for idx in string.gmatch(path, "()/") do
        last_idx = idx
    end

    return string.sub(path, last_idx + 1)
end

M.gen = function()
    local list = {}

    for idx = 1, Marked.get_length() do
        local file = Marked.get_marked_file_name(idx)

        if file ~= "(empty)" and file ~= "" then
            if file ~= string.sub(vim.api.nvim_buf_get_name(0), string.len(vim.fn.getcwd()) + 2) then
                table.insert(list, file_name(file) .. " ")
            else
                table.insert(list, file_name(file) .. "*")
            end
        end
    end

    list = table.concat(list, " ")
    local current_file = file_name(vim.api.nvim_buf_get_name(0))
    local cursor = table.concat(vim.api.nvim_win_get_cursor(0), ",")

    local spc_count = width - string.len(list) - string.len(current_file) - string.len(cursor) - 12

    return string.format("%s   %s   %s   %s", list, string.rep(" ", spc_count), current_file, cursor)
end

return M
