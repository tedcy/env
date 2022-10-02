" 不要使用vi的键盘模式，而是vim自己的
set nocompatible
filetype off
set encoding=utf-8

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'flazz/vim-colorschemes'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'fatih/vim-go'
"Plugin 'vim-scripts/taglist.vim'
Plugin 'tedcy/YouCompleteMe'
Plugin 'iamcco/markdown-preview.vim'
Plugin 'majutsushi/tagbar'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'tedcy/leetcode.vim'
Plugin 'yyzybb/cppenv'

call vundle#end()
filetype plugin indent on
let g:go_version_warning = 0

"grep搜索
map gr viw"ny:grep <C-r>n `find . -type f` --binary-files=without-match<CR><CR><C-o>:cw<CR>
vmap gr "ny:grep <C-r>n find . -type f` --binary-files=without-match<CR><CR><C-o>:cw<CR>
map gnr viw"ny:grep <C-r>n `find .. -type f` --binary-files=without-match<CR><CR><C-o>:cw<CR>
vmap gnr "ny:grep <C-r>n `find .. -type f` --binary-files=without-match<CR><CR><C-o>:cw<CR>

"最大化
nnoremap <leader>r :resize 80<CR>

"高亮
syntax on
au BufRead,BufNewFile *.go set filetype=go
"纠正mac下语法监测显示错误的问题
"link哪些输入:highlight看实际效果来调整
"如果不想link 想单独设置效果输入
"hi SpellBad ctermfg=www ctermbg=xxx guifg=#yyyyyy guibg=#zzzzzz 
"hi SpellCap ctermfg=www ctermbg=xxx guifg=#yyyyyy guibg=#zzzzzz 
highlight link SyntasticError Search
highlight link SyntasticWarning Search 
colorscheme torte

"设置c++补全
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
"nnoremap gt :YcmCompleter GetTypeImprecise<CR>
nnoremap gy :YcmCompleter GoToImprecise<CR>
nnoremap gu :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap gt <plug>(YCMHover)
map <F9> :YcmCompleter FixIt<CR>
nnoremap gf <Plug>(YCMFindSymbolInDocument)
nnoremap gfw <Plug>(YCMFindSymbolInWorkspace)

"设置ycm debug
let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'debug'
let g:ycm_clangd_args = ['-pretty']

let g:ycm_auto_hover = ''

"Tab转换成空格
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" 显示行号  
set number
"搜索逐字符高亮  
set hlsearch 
"还在输入时就进行匹配，并且显示匹配的位置
set incsearch
" 使回格键（backspace）正常处理indent, eol, start等
set backspace=indent,eol,start
" 高亮显示匹配的括号  
set showmatch  
" 匹配括号高亮的时间（单位是十分之一秒）  
set matchtime=5 
" 设定默认解码
set fenc=utf-8
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936
"缺省不产生备份文件 
set nobackup
set noswapfile
"后退file
set undofile
set undodir=$VIM/vimfiles/undodir
set undolevels=100
"需要自动改变vim的当前目录为打开的文件所在目录
"set autochdir有bug，必须这样写才生效
autocmd VimEnter * set autochdir
"启动具有菜单项提示的命令行自动完成。
set wildmenu
" 设置不自动折行
set nowrap
"折叠
"set nofoldenable
"set foldmethod=syntax
"set foldlevel=1
"去除vim自带的preview补全窗口
set completeopt=menuone

" taglist
"let Tlist_Show_One_File=1
"let Tlist_Exit_OnlyWindow=1
"map TL :Tlist<CR>
"map TU :TlistUpdate<CR>

" vim-go
let g:go_fmt_autosave = 0
let g:go_def_mapping_enabled = 0
let g:go_bin_path = '/tmp/bin'
let g:go_highlight_trailing_whitespace_error = 0
au BufNewFile,BufRead *.go nnoremap gy :GoDef<CR>

" C++
autocmd BufNewFile,BufRead *.cpp map <F2> :! g++ -std=c++17 %:p -o out.exe -g -pthread && ./out.exe<CR>

"https://github.com/iamcco/markdown-preview.vim/blob/master/README_cn.md
""let g:mkdp_path_to_chrome="chrome"
let g:mkdp_auto_close=0
"autocmd BufNewFile,BufRead *.md map <F7> :MarkdownPreview<CR>
""autocmd BufNewFile,BufRead *.md map <F8> :StopMarkdownPreview<CR>
nmap <F6> <Plug>MarkdownPreview
nmap <F7> <Plug>StopMarkdownPreview

" tagbar
map <F8> :TagbarToggle<CR>
let g:tagbar_sort = 0

autocmd BufEnter * let &titlestring = hostname() . '-' . expand("%:t") 
set title

" snippets
let g:UltiSnipsExpandTrigger="<C-e>"

"leetcode"
let g:leetcode_china=1  "中国区leetcode"
let g:leetcode_browser='chrome'   "登录leetcode-cn.com的浏览器"
let g:leetcode_cookie='cookie'
let g:leetcode_debug=1
nnoremap <leader>ll :LeetCodeList<cr>
nnoremap <leader>lt :LeetCodeTest<cr>
nnoremap <leader>ls :LeetCodeSubmit<cr>
nnoremap <leader>li :LeetCodeSignIn<cr>

" cppenv
au BufNewFile,BufRead * execute cppenv#dummy()
au BufNewFile,BufRead *.h,*.hpp,*.inl,*.ipp,*.cpp,*.c,*.cc,*.go,*.proto execute cppenv#infect()
au BufNewFile,BufRead *.h,*.hpp,*.inl,*.ipp,*.cpp,*.c,*.cc,*.go,*.proto set fo-=ro

" 配色方案
set background=dark
set termguicolors
colorscheme solarized8_dark_high
"colorscheme gruvbox
"colorscheme molokai
