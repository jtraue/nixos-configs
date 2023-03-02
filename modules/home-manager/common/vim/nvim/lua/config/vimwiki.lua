vim.g.vimwiki_list = {
    {
        syntax = "markdown",
        ext = ".wiki",
        path = "~/cloud/home/wiki/notes",
        diary_start_week_monday = true,
        diary_frequency = "weekly",
    }
}
vim.g.vimwiki_global_ext = 0
vim.cmd("autocmd VimEnter * if argc() == 0 | execute 'VimwikiIndex' | endif")

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*/diary/[0-9]*.wiki",
    command = "0r !diary_helper %",
})

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*/meeting_notes/*.wiki",
    command = "0r !meeting_helper %",
})
