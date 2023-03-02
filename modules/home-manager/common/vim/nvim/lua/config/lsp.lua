local lsp_mappings = {
    { 'gD', vim.lsp.buf.declaration },
    { 'gd', vim.lsp.buf.definition },
    { 'gi', vim.lsp.buf.implementation },
    { 'gr', vim.lsp.buf.references },
    { '[d', vim.diagnostic.goto_prev },
    { ']d', vim.diagnostic.goto_next },
    { 'K', vim.lsp.buf.hover },
    { 'F', vim.lsp.buf.format },
    { ' s', vim.lsp.buf.signature_help },
    { ' d', vim.diagnostic.open_float },
    { ' q', vim.diagnostic.setloclist },
    { '\\r', vim.lsp.buf.rename },
    { '\\a', vim.lsp.buf.code_action },
}
for _, map in pairs(lsp_mappings) do
    vim.keymap.set('n', map[1], function() map[2]() end)
end
vim.keymap.set('x', '\\a', function() vim.lsp.buf.code_action() end)

local caps = vim.tbl_extend(
    'keep',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities()
);

local servers = {
    'bashls'
}
for _, server in ipairs(servers) do
    require('lspconfig')[server].setup({
        capabilities = caps
    })
end

require('lspconfig').sumneko_lua.setup {
    diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
    },
    -- Do no send telemetry data containing a randomized but unique identifier
    telemetry = {
        enable = false,
    },
}

require('lspconfig').nil_ls.setup {
    autostart = true,
    capabilities = caps,
    settings = {
        ['nil'] = {
            formatting = {
                command = { "nixpkgs-fmt" },
            },
        },
    },
}

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

require("trouble").setup({})

local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        -- shell
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.diagnostics.shellcheck,

        -- Nix
        null_ls.builtins.code_actions.statix,
        null_ls.builtins.diagnostics.deadnix,

        -- Markdown
        null_ls.builtins.code_actions.proselint,
        null_ls.builtins.diagnostics.mdl,

        -- Cmake
        null_ls.builtins.diagnostics.cmake_lint,

        -- yaml
        null_ls.builtins.diagnostics.yamllint,
    }
})

require('fidget').setup {}
require('nvim-lightbulb').setup({ autocmd = { enabled = true } })
require 'lspconfig'.clangd.setup {
    capabilities = caps,
}
