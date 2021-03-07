
nnoremap dbg :InsertDebug <CR> 
command! InsertDebug call s:InsertDebug()
function! s:InsertDebug() 
    setlocal iskeyword+=.
    let wuc = expand("<cword>") "word under cursor
    exe "normal ofmt.Printf(\"debug " . wuc  . ": %v\"," . wuc . ")"
    setlocal iskeyword-=.
endfunction

nnoremap dbp :InsertDebugPanic <CR> 
command! InsertDebugPanic call s:InsertDebugPanic()
function! s:InsertDebugPanic() 
    setlocal iskeyword+=.
    let wuc = expand("<cword>") "word under cursor
    exe "normal opanic(fmt.Sprintf(\"debug " . wuc  . ": %v\"," . wuc . "))"
    setlocal iskeyword-=.
endfunction

nnoremap dbl :InsertDebugLength <CR> 
command! InsertDebugLength call s:InsertDebugLength()
function! s:InsertDebugLength() 
    setlocal iskeyword+=.
    let wuc = expand("<cword>") "word under cursor
    exe "normal ofmt.Sprintf(\"debug len(" . wuc  . "): %v\", len(" . wuc . "))"
    setlocal iskeyword-=.
endfunction


"""""""""""""""""""""""""""""
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
