"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vimwiki
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <Leader>wm :e @wiki@/meeting_notes/index.wiki<CR>
" use tab to switch buffers
" vimwiki overwrites the tab keyboard shortcut and plugins are loaded after the vimrc has been loaded, so we need this hack
autocmd VimEnter * noremap <tab> :bnext<cr>
autocmd VimEnter * noremap <S-tab> :bprev<cr>

" if no file given to start with, use vimwiki
" does not work with vimwiki-dev :(
" autocmd VimEnter * if argc() == 0 | execute 'VimwikiIndex' | endif

au filetype vimwiki silent! iunmap <buffer> <Tab>


" default wiki location
let g:vimwiki_list = [{
\ 'automatic_nested_syntaxes':1,
\ 'path': '@wiki@',
\ 'syntax': 'markdown',
\ 'diary_frequency': 'weekly',
\ 'diary_start_week_monday': 1,
\ 'ext': '.wiki'}]

" a useful shortcut
command! Diary VimwikiDiaryIndex
augroup vimwikigroup
autocmd!
" automatically update links on read diary
autocmd BufRead,BufNewFile diary.wiki VimwikiDiaryGenerateLinks
augroup end

autocmd BufNewFile */diary/[0-9]*.wiki :silent 0r !diary_helper '%'
autocmd BufNewFile */meeting_notes/*.wiki :silent 0r !meeting_helper '%'

" Do not use the vimwiki filetype for non-vimwiki markdown files
let g:vimwiki_global_ext = 0

