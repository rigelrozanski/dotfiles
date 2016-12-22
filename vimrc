" Pathogen
" set nocp
execute pathogen#infect()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
syntax on
filetype plugin indent on

" syntax enable  
" filetype plugin on  
set number  
let g:go_disable_autoinstall = 0

" Highlight
let g:go_highlight_functions = 1  
let g:go_highlight_methods = 1  
let g:go_highlight_structs = 1  
let g:go_highlight_operators = 1  
let g:go_highlight_build_constraints = 1  

" let g:neocomplete#enable_at_startup = 1

colorscheme molokai

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

nmap <F8> :TagbarToggle<CR>

map <C-n> :NERDTreeToggle<CR>

"""""""""""""""""""""""""""""""""""""
" Moving lines up/down, http://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim

function! s:swap_lines(n1, n2)
    let line1 = getline(a:n1)
    let line2 = getline(a:n2)
    call setline(a:n1, line2)
    call setline(a:n2, line1)
endfunction

function! s:swap_up()
    let n = line('.')
    if n == 1
        return
    endif

    call s:swap_lines(n, n - 1)
    exec n - 1
endfunction

function! s:swap_down()
    let n = line('.')
    if n == line('$')
        return
    endif

    call s:swap_lines(n, n + 1)
    exec n + 1
endfunction

"duplicate lines

function! s:dup_lines(n1, n2)
    let line1 = getline(a:n1)
    let line2 = getline(a:n2)
    let @a = "\n"
    call append(a:n1, @a)

    let linenew = line1    
    call setline(a:n2, linenew)
endfunction

function! s:duplicate()
    let n = line('.')
   
    call s:dup_lines(n, n + 1)
endfunction

"quick remove line function
function! s:remove()
    let n = line('.')
    :exe "normal dd"
endfunction

"fast switching tabs
function! s:tabLeft()
    :exe "normal gT"
endfunction

function! s:tabRight()
    :exe "normal gt"
endfunction

"quick remove line function
function! s:openAllGo()
    :n **/*.go
    :tab all
endfunction

"""""""""""""""""""""""""""
" mapping keys for custom vim script functions
"""""""""""""""""""""""""""
noremap <silent> <C-left> :call <SID>tabLeft()<CR>
noremap <silent> <C-right> :call <SID>tabRight()<CR>

noremap <silent> <c-s-up> :call <SID>swap_up()<CR>
noremap <silent> <c-s-down> :call <SID>swap_down()<CR>
noremap <silent> <C-S-left> :call <SID>remove()<CR>
noremap <silent> <C-S-right> :call <SID>duplicate()<CR>


"""""""""""""""""""""""""""
"" Custom Commands
""""""""""""""""""""""""""
command Ogo call <SID>openAllGo()
