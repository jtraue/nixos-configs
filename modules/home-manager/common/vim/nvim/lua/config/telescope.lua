require('telescope').load_extension 'fzf'
vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<cr>]]
    , { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>lua require('telescope.builtin').help_tags()<cr>]],
    { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]],
    { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<cr>]]
    , { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<cr>]],
    { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'z=', [[<cmd>lua require('telescope.builtin').spell_suggest()<cr>]],
    { noremap = true, silent = true })
