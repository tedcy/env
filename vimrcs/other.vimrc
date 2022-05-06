set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
"Plugin 'vim-scripts/taglist.vim'
Bundle 'tedcy/YouCompleteMe'
Plugin 'iamcco/markdown-preview.vim'
Bundle 'majutsushi/tagbar'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'ianding1/leetcode.vim'

call vundle#end()
filetype plugin indent on
let g:go_version_warning = 0
