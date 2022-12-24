"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ale
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#ale#enabled = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 1
let g:ale_sign_error = '💣'
let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" let b:ale_linters = {
" \ 'python': ['flake8', 'mypy'],
" \ 'cmake': ['cmake-lint'],
" \ 'cpp': ['ccls'],
" \ 'rust': ['analyzer', 'cargo']
" \}
let g:ale_yaml_yamllint_options = ' -d "{extends: relaxed, rules: {line-length: {max: 120}}}"'
let g:ale_c_parse_compile_commands=1
let g:ale_cpp_parse_compile_commands=1
let g:ale_md_yaml_yamllint_options = ' -d "{extends: relaxed, rules: {line-length: {max: 120}}}"'
let g:ale_rust_cargo_use_clippy=1

" exclude line lenght check in markdownlint
let g:ale_markdown_mdl_options = '--rules "~MD013"'

let g:ale_completion_enabled = 1
