
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

command! -range -nargs=1 SetWidth <line1>,<line2>call SetWidth(<f-args>)
function! SetWidth(cols)
    let path = expand('%:p')
    let linenostart = a:firstline  - 1
    let linenoend = a:lastline - 1
    let cmd = "vimrcgo column-width " . path . " " . linenostart . " " . linenoend . " " . a:cols
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

nnoremap <Leader>new <S-v>}k:CreateNewXxx <CR>
command! -range CreateNewXxx call CreateNewXxx(<line1>,<line2>)
function! CreateNewXxx(linestart, lineend)
    let path = expand('%:p')
    let linenostart = a:linestart  - 1
    let linenoend = a:lineend - 1
    let cmd = "vimrcgo create-new-xxx " . path . " " . linenostart . " " . linenoend 
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

nnoremap <Leader>fo :LCreateFunctionOf <CR>
command! -nargs=1 Fo call s:CreateFunctionOf(<f-args>)
command! LCreateFunctionOf call s:CreateFunctionOf("Dummiii")
function! s:CreateFunctionOf(funcname)
    let path = expand('%:p')
    let lineno = line('.')
    let cmd = "vimrcgo create-function-of " . path . " " . lineno . " " . a:funcname
    let results = system(cmd) 
    exe "normal " . results
    startinsert! " equivalent to hitting 'a' in normal mode 
endfunction

command! -nargs=1 Fulfill call s:CreateStructFulfilling(<f-args>)
function! s:CreateStructFulfilling(structname)
    let path = expand('%:p')
    let lineno = line('.')
    let cmd = "vimrcgo create-struct-fulfilling-interface  " . path . " " . lineno . " " . a:structname
    let results = system(cmd) 
    exe "normal " . results
endfunction

nnoremap <Leader>fnget :CreateGetFunctionOf <CR>
nnoremap <Leader>fnset :CreateSetFunctionOf <CR>
nnoremap <Leader>fngset :CreateGetSetFunctionOf <CR>
command! CreateGetFunctionOf call s:CreateGetSetFunctionOf("get")
command! CreateSetFunctionOf call s:CreateGetSetFunctionOf("set")
command! CreateGetSetFunctionOf call s:CreateGetSetFunctionOf("getandset")
function! s:CreateGetSetFunctionOf(getandorset)
    let path = expand('%:p')
    let lineno = line('.')
    let cmd = "vimrcgo create-get-set-function-of " . path . " " . lineno . " " . a:getandorset
    let results = system(cmd) 
    exe "normal " . results
endfunction

nnoremap <Leader>test :CreateTest <C-r><C-w><CR>
command! -nargs=1 CreateTest call s:CreateTest(<f-args>)
function! s:CreateTest(fnname)
    let path = expand('%:p')
    let cmd = "vimrcgo create-test " . a:fnname . " " . path
    let testpath = system(cmd) 
    exe "tabnew" testpath
endfunction

nnoremap <Leader>debugs :DebugPrints <C-r><C-w><CR>
command! -nargs=1 DebugPrints call s:DebugPrints(<f-args>)
function! s:DebugPrints(fnname)
    let lineno = line('.') - 1
    let path = expand('%:p')
    let cmd = "vimrcgo debug-prints " . a:fnname . " " . path . " " . lineno
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

nnoremap <Leader>rmdebugs :RmDebugPrints <CR>
command! RmDebugPrints call s:RmDebugPrints()
function! s:RmDebugPrints()
    let lineno = line('.') - 1
    let path = expand('%:p')
    let cmd = "vimrcgo remove-debug-prints " . path . " " . lineno
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

command! AddCal call s:CalAdd()
command! CalAdd call s:CalAdd()
function! s:CalAdd()
    :w
    let lineno = line('.') - 1
    let path = expand('%:p')
    let cmd = "vimrcgo add " . path . " " . lineno
    let results = system(cmd) 
    edit! "reload the current buffer
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
