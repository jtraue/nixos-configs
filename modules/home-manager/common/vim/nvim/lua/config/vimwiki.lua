vim.g.vimwiki_list = {
    {
        syntax = "markdown",
        ext = ".wiki",
        path = "~/cloud/home/wiki/notes",
        diary_start_week_monday = true,
        diary_frequency = "weekly",
        vimwiki_table_mappings = 0,
    }
}
vim.g.vimwiki_global_ext = 0

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*/diary/[0-9]*.wiki",
    command = "0r !diary_helper %",
})

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*/meeting_notes/*.wiki",
    command = "0r !meeting_helper %",
})

vim.cmd("autocmd VimEnter * nested if argc() == 0 | execute 'VimwikiIndex' | endif")
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         if vim.fn.argc() == 0 then
--             vim.cmd('VimwikiIndex')
--         end
--     end
-- })
