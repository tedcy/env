set nocompatible
filetype off
set encoding=utf-8

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'

call vundle#end()
filetype plugin indent on
let g:go_version_warning = 0
