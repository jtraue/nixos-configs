-- require('impatient')

-- vim option scopes:
--  vim.o = global
--  vim.wo = window-local
--  vim.bo = buffer-local


-- Search and replace
vim.o.ignorecase = true -- make searches with lower case characters case insensative
vim.o.smartcase  = true -- search is case sensitive only if it contains uppercase chars
vim.o.inccommand = 'nosplit' -- show preview in buffer while doing find and replace

vim.o.ai = true -- Copy indent from current line when starting a new one
vim.o.autoread = true -- Set to auto read when a file is changed from the outside
vim.o.backspace = [[indent,eol,start]] -- allow backspace over indents, etc.
vim.o.cmdheight = 2 -- number of screen lines for command line

vim.o.colorcolumn  = 80
vim.o.cursorline   = true -- highlight line in which the cursor is
vim.o.encoding     = "utf-8" -- Set utf8 as standard encoding
vim.o.expandtab    = true -- Use spaces instead of tabs
vim.o.ffs          = [[unix,dos,mac]] -- Use Unix as the standard file type
vim.o.hidden       = true -- keep buffers open - preserves history
vim.o.laststatus   = 2 -- always show a status line
vim.o.lbr          = true -- Linebreak on 500 characters
vim.o.list         = true -- turn whitespace display on
vim.o.listchars    = [[tab:»·,trail:•,nbsp:•,extends:»,precedes:«]] -- display these whitespaces graphically
vim.o.nobackup     = true
vim.o.noerrorbells = true -- No annoying sound on errors
vim.o.foldenable   = true -- Enable folds so that I get used to them
vim.o.swapfile     = false
vim.o.visualbell   = false -- again: no sounds
vim.o.nu           = true -- Show line numbers
vim.o.ruler        = true -- Always show current position
vim.o.shiftwidth   = 4 -- 1 tab == 4 spaces
vim.o.smartindent  = true -- Smart indent
vim.o.smarttab     = true -- Be smart when using tabs ;)
vim.o.spell        = true -- enable spell checking
vim.o.spelllang    = 'en' -- default spellcheck language
vim.o.tabstop      = 4 -- ...
vim.o.tm           = 500 -- ...
vim.o.tw           = 500 -- text width
vim.o.wildmenu     = true -- enhanced command-line completion mode
vim.o.wrap         = true -- Wrap lines
vim.o.writebackup  = true -- make a backup before overwriting a file

-- Set UI related options
-- vim.o.termguicolors   = true
-- vim.wo.colorcolumn    = '100'    -- show column boarder
-- vim.wo.number         = true     -- display numberline
-- vim.wo.cursorline     = true     -- highlight current line
-- vim.wo.cursorlineopt  = 'number' -- only highlight the number of the cursorline
-- vim.wo.signcolumn     = 'yes'    -- always have signcolumn open to avoid thing shifting around all the time
-- vim.o.fillchars       = 'stl: ,stlnc: ,vert:·,eob: ' -- No '~' on lines after end of file, other stuff

vim.cmd 'colorscheme gruvbox'

-- --Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Set clipboard to use system clipboard
vim.opt.clipboard = "unnamedplus"

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("bufferline").setup {}

require("indent_blankline").setup {
    show_current_context = true,
    show_current_context_start = false,
}

require('gitsigns').setup()

require("config/telescope")
require("config/treesitter")
require("config/nvim-tree")
require("config/cmp")

vim.keymap.set("n", "ga", "<cmd>CodeActionMenu<CR>", { desc = "Code Action Menu" })

require("config/lsp")
require("config/lualine")
require("config/vimwiki")
require("config/comment")
require("config/cheatsheet")

vim.cmd [[
function! s:goyo_enter()
  lua require('lualine').hide()
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
  Gitsigns detach
endfunction

function! s:goyo_leave()
  lua require('lualine').hide({ unhide = true })
  set showmode
  set showcmd
  set scrolloff=5
  Limelight
  Gitsigns attach
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
]]
