set nocompatible

set number
set relativenumber

filetype plugin indent on
syntax on

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

set backspace=indent,eol,start

set hlsearch

set t_Co=256

set wildmenu

" Change cursor shape in different modes
let &t_EI = "\e[2 q" " NORMAL █ (Block, steady)
let &t_SI = "\e[5 q" " INSERT | (Beam/Bar, blinking)
let &t_SR = "\e[3 q" " REPLACE _ (Underline, blinking)
