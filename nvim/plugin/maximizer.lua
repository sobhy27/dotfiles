local function set_keymaps()
    local opts = { noremap = true, silent = true }

    pcall(vim.keymap.del, "n", "<C-w>h")
    pcall(vim.keymap.del, "n", "<C-w>j")
    pcall(vim.keymap.del, "n", "<C-w>k")
    pcall(vim.keymap.del, "n", "<C-w>l")
    vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", opts)
    vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", opts)
    vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", opts)
    vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", opts)

    vim.g.maximizer_keymaps = true
end

local function del_keymaps()
    local opts = { noremap = true, silent = true }

    pcall(vim.keymap.del, "n", "<C-h>")
    pcall(vim.keymap.del, "n", "<C-j>")
    pcall(vim.keymap.del, "n", "<C-k>")
    pcall(vim.keymap.del, "n", "<C-l>")
    vim.keymap.set("n", "<C-w>h", "<NOP>", opts)
    vim.keymap.set("n", "<C-w>j", "<NOP>", opts)
    vim.keymap.set("n", "<C-w>k", "<NOP>", opts)
    vim.keymap.set("n", "<C-w>l", "<NOP>", opts)

    vim.g.maximizer_keymaps = nil
end

local function maximize()
    local windows = vim.api.nvim_tabpage_list_wins(0)

    for _, window in ipairs(windows) do
        vim.api.nvim_win_set_var(window, "maximizer_width", vim.api.nvim_win_get_width(window))
        vim.api.nvim_win_set_var(window, "maximizer_height", vim.api.nvim_win_get_height(window))
    end

    vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + 500)
    vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + 500)

    del_keymaps()
    vim.t.maximizer_maximized = true
end

local function restore()
    local windows = vim.api.nvim_tabpage_list_wins(0)

    for _, window in ipairs(windows) do
        local has_width, width = pcall(vim.api.nvim_win_get_var, window, "maximizer_width")
        local has_height, height = pcall(vim.api.nvim_win_get_var, window, "maximizer_height")

        if has_width and has_height then
            vim.api.nvim_win_set_width(window, width)
            vim.api.nvim_win_set_height(window, height)

            vim.api.nvim_win_set_var(window, "maximizer_width", nil)
            vim.api.nvim_win_set_var(window, "maximizer_height", nil)
        end
    end

    set_keymaps()
    vim.t.maximizer_maximized = nil
end

local group = vim.api.nvim_create_augroup("maximizer", { clear = true })

vim.api.nvim_create_autocmd({ "WinClosed", "WinNew" }, {
    group = group,
    callback = function ()
        if vim.t.maximizer_maximized then
            restore()
        end
    end,
})

vim.api.nvim_create_autocmd({ "TabEnter" }, {
    group = group,
    callback = function ()
        if vim.t.maximizer_maximized and vim.g.maximizer_keymaps then
            del_keymaps()
        else
            set_keymaps()
        end
    end
})

vim.keymap.set("n", "<leader>m", function ()
    if vim.t.maximizer_maximized then
        restore()
    else
        maximize()
    end
end, { noremap = true, silent = true })

set_keymaps()
