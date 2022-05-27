-- " vim.keymap.set("n", "<leader>a", [[]], opts)
-- " vim.keymap.set("n", "<leader>h", [[]], opts)
-- " vim.keymap.set("n", "<TAB>", [[]], opts)
-- " vim.keymap.set("n", "<S-TAB>", [[:lua require("harpoon.ui").nav_prev()<CR>]], opts)
--
-- " pcall(vim.keymap.del, "n", "<leader>ts")
-- " vim.keymap.set("n", "<leader>t", [[:lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>]], opts)

-- nnoremap <silent> <TAB>     
-- nnoremap <silent> <S-TAB>   :lua require("harpoon.ui").nav_prev()<CR>
-- nnoremap <silent> <leader>a :lua 
-- nnoremap <silent> <leader>h :lua 

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<TAB>", function()
    local function nav()
        require("harpoon.ui").nav_next()

        if string.match(vim.api.nvim_buf_get_name(0), "(empty)") then
            nav()
        end
    end

    nav()
end, opts)

vim.keymap.set("n", "<S-TAB>", function()
    local function nav()
        require("harpoon.ui").nav_prev()

        if string.match(vim.api.nvim_buf_get_name(0), "(empty)") then
            nav()
        end
    end

    nav()
end, opts)


vim.keymap.set("n", "<leader>a", [[:lua require("harpoon.mark").toggle_file()<CR><CR>]], opts)
vim.keymap.set("n", "<leader>h", [[:lua require("harpoon.ui").toggle_quick_menu()<CR><CR>]], opts)
