let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_winsize = 25
let g:netrw_altv=1
let g:netrw_liststyle=1
let g:netrw_listhide=netrw_gitignore#Hide()

function! ToggleNetrw()
let i = bufnr("$")
let wasOpen = 0
while (i >= 1)
    if (getbufvar(i, "&filetype") == "netrw")
        silent exe "bwipeout " . i
        let wasOpen = 1
    endif
    let i-=1
endwhile
if !wasOpen
    silent Lexplore
endif
endfunction
map <F3> :call ToggleNetrw() <CR>
