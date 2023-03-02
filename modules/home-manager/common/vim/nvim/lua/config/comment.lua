require('Comment').setup()
local api = require('Comment.api')
local esc = vim.api.nvim_replace_termcodes(
    '<ESC>', true, false, true
)

vim.keymap.set("n", "<F1>", api.toggle.linewise.current)
vim.keymap.set('v', '<F1>', function()
    vim.api.nvim_feedkeys(esc, 'nx', false)
    api.toggle.linewise(vim.fn.visualmode())
end)
