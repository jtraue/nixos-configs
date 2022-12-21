""" autoformat
nnoremap <buffer><F8> :<C-u>Autoformat<CR>
vnoremap <F8> :Autoformat<CR>

" fall back to vim's indent file/retabbing/whitespace removal
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

let g:formatters_python = ['yapf']
let g:formatters_cmake = ['cmake_format']
let g:formatdef_cmake_format = '"cmake-format - "'
let g:formatdef_nix = '"nixpkgs-fmt"'
let g:formatters_nix = [ 'nix' ]

augroup Autoformatting
    " Remove all vimrc autocommands in this group (useful if vimrc is sourced twice)
    autocmd!
    autocmd BufWritePre * :Autoformat
augroup END

augroup NoAutoformattingProjects
    " Remove all vimrc autocommands in this group (useful if vimrc is sourced twice)
    autocmd!
    autocmd BufNewFile,BufRead ~/src/dev/supernova-core/**/* autocmd! Autoformatting
    autocmd BufNewFile,BufRead ~/src/dev/particle/**/*.py autocmd! Autoformatting
    autocmd BufNewFile,BufRead ~/src/external/**/* autocmd! Autoformatting
    autocmd BufNewFile,BufRead ~/src/doc/makedocument/**/* autocmd! Autoformatting
augroup END
