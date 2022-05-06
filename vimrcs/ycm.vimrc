set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
Bundle 'tedcy/YouCompleteMe'

call vundle#end()
filetype plugin indent on
let g:go_version_warning = 0
