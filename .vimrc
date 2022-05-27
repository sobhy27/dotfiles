syntax on

set number
set relativenumber
set cursorline
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smarttab
set mouse=a
set guicursor=a:block
set termguicolors

call plug#begin()
Plug 'joshdick/onedark.vim'
call plug#end()

let g:mapleader = " "
let g:maplocalleader = " "

nnoremap <silent> <leader>e :Explore<CR>

colorscheme onedark
highlight CursorLine guibg=#282C34
