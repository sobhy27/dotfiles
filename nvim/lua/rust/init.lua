local dap = require("dap")

local debug = require("rust.debug")
local inlay_hints = require("rust.inlay_hints")

local function mk_handler(fn)
    return function(...)
        local config_or_client_id = select(4, ...)
        local is_new = type(config_or_client_id) ~= "number"
        if is_new then
            fn(...)
        else
            local err = select(1, ...)
            local method = select(2, ...)
            local result = select(3, ...)
            local client_id = select(4, ...)
            local bufnr = select(5, ...)
            local config = select(6, ...)
            fn(
                err,
                result,
                { method = method, client_id = client_id, bufnr = bufnr },
                config
            )
        end
    end
end

require("lspconfig").rust_analyzer.setup({
    on_attach = function(_, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- lsp keymaps
        vim.keymap.set("n", "K", ":lua vim.lsp.buf.hover()<CR>", opts)
        vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts)
        vim.keymap.set("n", "gD", ":lua vim.lsp.buf.declaration()<CR>", opts)
        vim.keymap.set("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", opts)
        vim.keymap.set("n", "gr", ":lua vim.lsp.buf.references()<CR>", opts)
        vim.keymap.set("n", "<leader>r", ":lua vim.lsp.buf.rename()<CR>", opts)
        vim.keymap.set("n", "<leader>f", ":lua vim.lsp.buf.formatting()<CR>", opts)

        -- debugging keymaps
        vim.keymap.set("n", "<F9>", [[:lua require("dap").toggle_breakpoint()<CR>]], opts)
        vim.keymap.set("n", "<F5>", function ()
            if dap.session() then
                dap.continue()
            else
                vim.lsp.buf_request(bufnr, "experimental/runnables", debug.get_params(), mk_handler(debug.handler))
            end
        end, opts)

        -- Inlay Hints
        local group = vim.api.nvim_create_augroup("InlayHints", { clear = true })
        vim.api.nvim_create_autocmd({
            "BufEnter", "BufWinEnter", "TabEnter",
            "BufWritePost", "TextChanged", "InsertLeave"
        }, {
            group = group,
            callback = function()
                vim.lsp.buf_request(bufnr, "textDocument/inlayHint", inlay_hints.get_params(), mk_handler(inlay_hints.handler))
            end,
        })
    end,
})
