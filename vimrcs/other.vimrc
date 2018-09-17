set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'vim-scripts/taglist.vim'
Bundle 'Valloric/YouCompleteMe'
Plugin 'iamcco/markdown-preview.vim'

call vundle#end()
filetype plugin indent on
