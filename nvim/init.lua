-- ============================================================================== --
-- Opts
-- ============================================================================== --
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- indentation
local indent_width = 4
vim.opt.tabstop = indent_width
vim.opt.softtabstop = indent_width
vim.opt.shiftwidth = indent_width
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true

-- Ignore search case until I use it
vim.opt.smartcase = true
vim.opt.smartindent = true

-- Undo file
vim.opt.undofile = true

-- disable backup
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- other editor opts
vim.opt.wrap = false
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.signcolumn = "yes"
vim.opt.mouse = "a"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.hidden = false
vim.opt.laststatus = 3
-- ============================================================================== --
-- Plugins
-- ============================================================================== --
local install_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
end

-- load lua modules faster
pcall(require, "impatient")

require("packer").startup(function()
    local use = require("packer").use

    use("wbthomason/packer.nvim")
    use("lewis6991/impatient.nvim")         -- load lua modules faster
    use("numToStr/Comment.nvim")            -- Comments
    use("ThePrimeagen/harpoon")             -- Best markdown plugin
    use("TimUntersberger/neogit")           -- magit in neovim ?
    use("nvim-lua/plenary.nvim")            -- NeoVim Framework

    -- LSP
    use("neovim/nvim-lspconfig")
    use("onsails/lspkind-nvim")

    use("L3MON4D3/LuaSnip")                 -- Snippets

    -- completion
    use("hrsh7th/nvim-cmp")
    use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
    use({ "saadparwaiz1/cmp_luasnip", after = { "nvim-cmp", "LuaSnip" } })

    -- Debugging
    use("mfussenegger/nvim-dap")
    use("rcarriga/nvim-dap-ui")
    use("theHamsta/nvim-dap-virtual-text")

    use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

    use("b0o/SchemaStore.nvim")             -- JSON schemas
    use("saecki/crates.nvim")               -- Rust crates

    -- prettier
    use({ "prettier/vim-prettier",
        run = "yarn install --frozen-lockfile --production",
        ft = { "javascript", "typescript", "css", "less", "scss", "json", "graphql", "markdown", "vue", "svelte", "yaml", "html" },
    })

    -- Appearance
    use("navarasu/onedark.nvim")            -- Colorscheme
    use("kyazdani42/nvim-web-devicons")     -- icons

    -- AutoSync plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
-- ============================================================================== --
-- Conf
-- ============================================================================== --
pcall(vim.keymap.del, "n", "<Space>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "!", ":!", { noremap = true })
vim.keymap.set("n", "?", ":nohlsearch<CR>", opts)

vim.keymap.set("n", "<leader>e", ":Explore<CR>", opts)

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("n", "<", "V<<ESC>", opts)
vim.keymap.set("n", ">", "V><ESC>", opts)

-- better escape
vim.keymap.set("i", "<C-c>", "<ESC>", opts)
vim.keymap.set("v", "<C-c>", "<ESC>", opts)
vim.keymap.set("n", "<C-c>", "<ESC>", opts)

vim.keymap.set("n", "gq", ":tabclose<CR>", opts)

require("Comment").setup()

-- This is my custom status line
-- it lists harpoon marks on the statusline
-- works like tabs but better
vim.opt.statusline = " %{%v:lua.require'statusline'.gen()%} "

-- language config
require("c")
require("rust")
require("go")
require("JS")
require("sumneko_lua")

local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    group = group,
    callback = function ()
        if vim.fn.filewritable(vim.api.nvim_buf_get_name(0)) == 1 then
            vim.cmd("write")
        end
    end
})

vim.cmd("colorscheme onedark")
vim.cmd("highlight CursorLine guibg=NONE")
pcall(vim.keymap.del, "n", "<leader>ts")
