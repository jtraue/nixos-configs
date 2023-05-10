require('nvim-tree').setup({
    actions = {
        change_dir = {
            enable = false,
        },
    },
})
vim.keymap.set('n', '<leader>tt', require('nvim-tree.api').tree.toggle)
