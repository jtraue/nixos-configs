"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ai                                  " Copy indent from current line when starting a new one
set autoread                            " Set to auto read when a file is changed from the outside
set background=dark
set backspace=indent,eol,start          " allow backspace over indents, etc.
set cmdheight=2                         " number of screen lines for command line
set colorcolumn=80
set cursorline                          " highlight line in which the cursor is
set encoding=utf8                       " Set utf8 as standard encoding
set expandtab                           " Use spaces instead of tabs
set ffs=unix,dos,mac                    " Use Unix as the standard file type
set hidden                              " keep buffers open - preserves history
set laststatus=2                        " always show a status line
set lbr                                 " Linebreak on 500 characters
set list                                " turn whitespace display on
set listchars=tab:»·,trail:•,nbsp:•,extends:»,precedes:« " display these whitespaces graphically
set nobackup
set noerrorbells                        " No annoying sound on errors
set foldenable                          " Enable folds so that I get used to them
set noswapfile
set novisualbell                        " again: no sounds
set nu                                  " Show line numbers
set path+=**                            " for find look into subfolders
set ruler                               " Always show current position
set shiftwidth=4                        " 1 tab == 4 spaces
set smartindent                          " Smart indent
set smarttab                            " Be smart when using tabs ;)
set spell                               " enable spell checking
" set spellcapcheck                       " start sentences with a capital letter
set spelllang=en                        " default spellcheck language
set t_vb=                               " no visual bell
set tabstop=4                           " ...
set tm=500                              " ...
set tw=500                              " text width
set wildmenu                            " enhanced command-line completion mode
set wrap                                " Wrap lines
set writebackup                         " make a backup before overwriting a file

" Fold by default until I get used to folds
set foldmethod=syntax
set foldlevelstart=1

" use project local vimrc (filename .lvimrc)
set exrc
set secure
let g:localvimrc_persistent=2

" hard mode: disable arrow keys
noremap <Up>    <NOP>
noremap <Down>  <NOP>
noremap <Left>  <NOP>
noremap <Right> <NOP>

" move around panes with h,j,k,l
noremap <C-k> :wincmd k <CR>
noremap <C-l> :wincmd l <CR>
noremap <C-h> :wincmd h <CR>
noremap <C-j> :wincmd j <CR>

" close window like buffer list
nmap \x :cclose<CR>

" buffer list
let g:BufferListWidth    = 50
let g:BufferListMaxWidth = 50
map <silent> <C-b> :call BufExplorer() <CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File type settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype plugin on
filetype indent on

" remove trailing whitespace before saving
autocmd FileType bash,c,cmake,cpp,hpp,markdown,nix,python,tex,txt,vimwiki autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd BufNewFile,BufRead *.tikz set filetype=tex

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" enable syntax highlighting
syntax enable

hi SpellBad cterm=underline

" fix gitgutter's color with solarized
highlight clear SignColumn

colorscheme solarized

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" airline
let g:airline_theme='solarized'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1

""" nerd commenter
map <F1> <Plug>NERDCommenterToggle
map <F2> <Plug>NERDCommenterMinimal
" map <F3> <Plug>NERDCommenterSexy
let NERDCompactSexyComs=1
let NERDSpaceDelims=1

 let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
    \ 'ctermfgs': ['darkred', 'darkgreen', 'darkmagenta', 'darkgreen', 'darkcyan'],
\}

""" markdown preview
let g:mkdp_filetypes = ['markdown', 'vimwiki']
let g:mkdp_auto_close = 0

""" telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
