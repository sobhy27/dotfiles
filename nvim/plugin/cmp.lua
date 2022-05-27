local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<TAB>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end),
        ["<S-TAB>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end),
    },

    sources = {
        { name = 'nvim_lua' },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 5 },
    },

    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    formatting = {
        format = lspkind.cmp_format(),
    },

    experimental = {
        native_menu = false,
    },

    enabled = function()
        -- disable completion in comments
        local context = require 'cmp.config.context'
        -- keep command mode completion enabled when cursor is in a comment
        if vim.api.nvim_get_mode().mode == 'c' then
            return true
        else
            return not context.in_treesitter_capture("comment") 
                and not context.in_syntax_group("Comment")
        end
    end
})

 -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
