
" rust racer go to definition
"set hidden
"let g:racer_experimental_completer = 1
"au FileType rust nmap gd :call <SID>rustdef()<CR>

"function! s:rustdef()
    ""<Plug>(rust-def)
    ""tabnew
    "split
    "call racer#GoToDefinition()
    "tabedit %
    "tabp
    "q
    "tabn
"endfunction


"let g:rustfmt_command = "cargo fmt -- "
"let g:rustfmt_autosave = 1

"au BufWrite * :RustFmt

