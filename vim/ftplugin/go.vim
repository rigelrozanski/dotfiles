setlocal iskeyword+=.


let g:tagbar_type_go = {  
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }


" go to definition #godef #go-def 
let g:go_def_mapping_enabled = 0
au FileType go nmap gd <Plug>(go-def-tab)

" GoImports
let g:go_fmt_command = "goimports"


map gf :call GotoFileWithLineNum()<CR> 
nnoremap <Leader>gf ma/FAIL\t<CR>eebvEy`abhpli/<ESC>Bi$GOPATH/src/<esc>5l:call GotoFileWithLineNum()<CR>

"""""""""""""""""""""""""""
"" Custom Commands
""""""""""""""""""""""""""
" quick remove line function
command O call <SID>openAllGo()
function! s:openAllGo()
    :argadd **/*.go
    :argadd **/*.md
    :silent! argdelete vendor/*
    :tab all
endfunction

command -nargs=1 Go call <SID>gogeneric(<f-args>)
function! s:gogeneric(cmd)
    :tabnew
    :TabooRename gogeneric
    :silent exec "r ! go " . a:cmd
    :setlocal buftype=nofile
endfunction
