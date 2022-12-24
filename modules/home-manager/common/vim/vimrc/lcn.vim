"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LanguageClient-neovim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Required for operations modifying multiple buffers like rename.
set hidden
let g:LanguageClient_serverCommands = {
  \ 'c': ['clangd'],
  \ 'cpp': ['clangd'],
  \ 'rust': ['rls'],
  \ 'nix': ['rnix-lsp']
\ }

let g:LanguageClient_autoStart = 1

nnoremap <F5> <Plug>(lcn-menu)

lua << EOF

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
local on_attach = function(client, bufnr)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
end

require('lspconfig')['clangd'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}

local lsp_status = require('lsp-status')
lsp_status.register_progress() 
lsp_status.config({
  diagnostics = false,
  current_function = false,
  status_symbol = ''
})

EOF
