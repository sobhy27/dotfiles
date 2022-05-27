require("lspconfig").tsserver.setup({
    on_attach = function (client, bufnr)
        client.server_capabilities.document_formatting = false
        client.server_capabilities.documentFormattingProvider = false

        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- lsp keymaps
        vim.keymap.set("n", "K", ":lua vim.lsp.buf.hover()<CR>", opts)
        vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts)
        vim.keymap.set("n", "gD", ":lua vim.lsp.buf.declaration()<CR>", opts)
        vim.keymap.set("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", opts)
        vim.keymap.set("n", "gr", ":lua vim.lsp.buf.references()<CR>", opts)
        vim.keymap.set("n", "<leader>r", ":lua vim.lsp.buf.rename()<CR>", opts)
        vim.keymap.set("n", "<leader>f", ":lua vim.lsp.buf.formatting()<CR>", opts)
    end
})
