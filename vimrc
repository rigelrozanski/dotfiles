" Pathoger
set nocp
execute pathogen#infect()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
set nolazyredraw
    
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" on pressing tab, insert 4 spaces
set expandtab

" disable Ex Mode
map Q <Nop>

" nerd tree show hidden by default
let g:NERDTreeShowHidden = 1

" golint on save, without govet
let g:go_metalinter_autosave = 1
let g:go_metalinter_autosave_enabled = ['golint'] 

" multiple cursors
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key='<C-d>'
let g:multi_cursor_prev_key='<C-s>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" system as the default clipboard
set clipboard=unnamed " copy to the system clipboard
set backspace=indent,eol,start " resolves backspace-not-working during insert for mac

" syntax enable  
syntax on
" filetype plugin on  
filetype plugin indent on
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

" optional fixes a glitch under some versions of terminal
if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    set t_ut=
endif

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

" ag seach functionality: https://github.com/ggreer/the_silver_searcher
" http://codeinthehole.com/writing/using-the-silver-searcher-with-vim/
if executable('ag')
    " Note we extract the column as well as the file and line number
    set grepprg=ag\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c%m
endif

" go to definition #godef #go-def 
let g:go_def_mapping_enabled = 0
au FileType go nmap gd <Plug>(go-def-tab)

" rust racer go to definition
"set hidden
"let g:racer_experimental_completer = 1
"au FileType rust nmap gd :call <SID>rustdef()<CR>

function! s:rustdef()
    "<Plug>(rust-def)
    "tabnew
    split
    call racer#GoToDefinition()
    tabedit %
    tabp
    q
    tabn
endfunction

" GoImports
let g:go_fmt_command = "goimports"

"let g:rustfmt_command = "cargo fmt -- "
"let g:rustfmt_autosave = 1


"""""""""""""""""""""""""""""""""""""
" Visual Mods

" remove paren matching
let loaded_matchparen = 1

" Moving lines up/down, http://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim


" duplicate lines
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

" quick remove line function
function! s:remove()
    :exe "normal \"_dd"
endfunction

" fast tab actions
function! s:tabLeft()
    :let tabno = tabpagenr() - 1 
	if tabno > 0
        :exe "normal " . tabno . "gt"
	endif
endfunction

function! s:tabRight()
    :let tabno = tabpagenr() + 1
    :exe "normal " . tabno . "gt"
endfunction

function! s:newtab()
    :exe "tabnew"
    :exe "NERDTreeMirror"
endfunction

" quick remove line function
function! s:openAllGo()
    :argadd **/*.go
    :argadd **/*.md
    :silent! argdelete vendor/*
    :tab all
endfunction

function! s:spellCheck()
    :exe "setlocal spell spelllang=en_us"
endfunction

function! s:spellCheckEnd()
    :exe "set nospell"
endfunction

"""""""""""""""""""""""""""
" mapping keys for custom vim script functions
"""""""""""""""""""""""""""
noremap <silent> <C-y> <Nop>
noremap <silent> <C-u> :call <SID>tabLeft()<CR>
noremap <silent> <C-i> :call <SID>tabRight()<CR>
noremap <C-o> :-tabmove<cr>
noremap <C-p> :+tabmove<cr>

inoremap <C-u> <Esc>  :call <SID>tabLeft()<CR>
inoremap <C-i> <Esc> :call <SID>tabRight()<CR>

vnoremap  <C-u> <Esc>  :call <SID>tabLeft()<CR>
vnoremap  <C-i> <Esc> `:call <SID>tabRight()<CR>

noremap <silent> <C-H> :call <SID>remove()<CR>
noremap <silent> <C-L> :call <SID>duplicate()<CR>
inoremap <silent> <C-H> <Esc>:call <SID>remove()<CR>i
inoremap <silent> <C-L> <Esc>:call <SID>duplicate()<CR>i
vnoremap <silent> <C-H> <Esc>:call <SID>remove()<CR>v
vnoremap <silent> <C-L> <Esc>:call <SID>duplicate()<CR>v

" http://vim.wikia.com/wiki/Moving_lines_up_or_down
noremap <silent> <C-K> :m-2<CR>
noremap <silent> <C-J> :m+1<CR>
inoremap <silent> <C-K> <esc>:m-2<CR>i
inoremap <silent> <C-J> <esc>:m+1<CR>i
vnoremap <silent> <C-K> :m-2<CR>gv
vnoremap <silent> <C-J> :m'>+1<CR>gv

" remap for mac copy to clipboard
vnoremap copy :w !pbcopy<CR><CR>

" remap for quick search replace
" http://vim.wikia.com/wiki/Search_and_replace_the_word_under_the_cursor 
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
vnoremap <Leader>s y:%s/<C-r>"/<C-r>"/g<Left><Left>

""" split navigation remap
nnoremap <c-s-up> <C-W><C-J>
nnoremap <c-s-down> <C-W><C-K>
nnoremap <C-S-left> <C-W><C-H>
nnoremap <C-S-right> <C-W><C-L>

nnoremap dup {v}y}p}dd{ 
nnoremap cut {v}xO<Esc>

"for faster comments
nnoremap com yiwO// <Esc>pi<Right> - 

" automatically leave insert mode after 'updatetime' milliseconds of inaction
" au CursorHoldI * stopinsert
" set 'updatetime' to 15 seconds when in insert mode
" au InsertEnter * let updaterestore=&updatetime | set updatetime=15000
" au InsertLeave * let &updatetime=updaterestore

"""""""""""""""""""""""""""""""""""
" Visual remapping
"""""""""""""""""""""""""""""""""""

" remap for left right shifting
vnoremap > xp`[v`]
vnoremap < x2hp`[v`]

" commenting lines or uncommenting lines
vnoremap // :call NERDComment(0,"comment")<CR>
vnoremap ?? :call NERDComment(0,"uncomment")<CR>

" tab on visual code
vmap <Tab> >gv
vmap <S-Tab> <gv
imap <Tab> <Tab>

"""""""""""""""""""""""""""
"" Custom Commands
""""""""""""""""""""""""""
command O call <SID>openAllGo()
command SC call <SID>spellCheck()
command SCE call <SID>spellCheckEnd()
command T call <SID>newtab()
command Q call TabCloseLeft('q!')
command HL :set hlsearch
command NHL :set nohlsearch

"override default quit command
cabbrev q <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Q' : 'q')<CR>

" open the whiteboard vim tab
command WB :tabedit $GOPATH/src/github.com/rigelrozanski/wb/boards/vim

" duplication for messed up key strokes
command W :w
command Wq :wq
command WQ :wq
command WQA :wqa
command WQa :wqa
command Wqa :wqa


" close all tabs to the right
function TabCloseRight(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
endfunction

command QQQ call TabCloseRight('<bang>')

" this next command will force close nerd tree if it's the last and only buffer
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" open current line on Github
let g:gh_line_map = 'git'

" quick insert fmt.Println("")
let dbg = "debug : %v\\n"
let bkp = "breakpoint : %v\\n"
nnoremap fms yiwofmt.Printf("<c-r>=bkp<cr>", )<esc>10<left>p9<right>p<esc>ofmt.Scanf("")<esc>
nnoremap fmt yiwofmt.Printf("<c-r>=dbg<cr>", )<esc>10<left>p9<right>p
nnoremap fmp yiwopanic(fmt.Sprintf("<c-r>=dbg<cr>", ))<esc>11<left>p9<right>p `json"yiwopanic"`
nnoremap <Leader>json yiwA `json:"<esc>pviwuA"`<esc>
nnoremap <Leader>err oif err != nil {<CR>return err<CR><left><left>}<esc>
nnoremap viwp viwpyiw
nnoremap F ggVGgq
nnoremap cd ciw<esc>

" credit: https://github.com/convissor/vim-settings/blob/master/.vimrc
" Declare function for moving left when closing a tab.
function! TabCloseLeft(cmd)
	if winnr('$') == 1 && tabpagenr('$') > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr('$')
		exec a:cmd | tabprevious
	else
		exec a:cmd
	endif
endfunction

" autoindent shell files
autocmd BufWritePre *.sh exec "normal gg=G``zz"

"__________________________________________________________________________
" goto commands

command Install call <SID>makeinstall()
function! s:makeinstall()
    if TabooTabName(tabpagenr()) == "makeinstall"
        :normal ggdG
        :silent exec "r ! make install"
    else
        :tabnew
        :TabooRename makeinstall
        :silent exec "r ! make install"
        :setlocal buftype=nofile
    endif
endfunction

command TEst call <SID>maketest() "for my fast inaccurate typing
command Test call <SID>maketest()
function! s:maketest()
    if TabooTabName(tabpagenr()) == "maketest"
        :normal ggdG
        :silent exec "r ! make test"
    else
        :tabnew
        :TabooRename maketest
        :silent exec "r ! make test"
        :setlocal buftype=nofile
    endif
endfunction

nnoremap <Leader>a :Ag <C-r><C-w><CR> 
command! -nargs=* Ag call s:agsearch(<f-args>)
function! s:agsearch(find)
    if TabooTabName(tabpagenr()) == "search"
        :normal ggdG
        :silent exec "r ! ag " . a:find
    else
        :tabnew
        :TabooRename search
        :silent exec "r ! ag " . a:find
        :setlocal buftype=nofile
    endif
    exe "normal ggi" . a:find 
endfunction

nnoremap rrr :call <SID>refreshInstall()<CR>
function! s:refreshInstall()
    if TabooTabName(tabpagenr()) == "makeinstall"
        :call <SID>makeinstall()
    elseif TabooTabName(tabpagenr()) == "maketest"
        :call <SID>maketest()
    endif
endfunction

function! GotoFileWithLineNum() 
    " filename under the cursor 
    let file_name = expand('<cfile>') 
    if !strlen(file_name) 
        echo 'NO FILE UNDER CURSOR' 
        return 
    endif 
    

    " look for a line number separated by a : 
    if search('\%#\f*:\zs[0-9]\+') 
        " change the 'iskeyword' option temporarily to pick up just numbers 
        let temp = &iskeyword 
        set iskeyword=48-57 
        let line_number = expand('<cword>') 
        exe 'set iskeyword=' . temp 
    endif 
    
    if !exists('line_number') 
        return
    endif 

    " edit the file 
    exe 'tabedit '.file_name 

    " if there is a line number, go to it 
    if exists('line_number') 
        exe line_number 
    endif 

    " go back to the previous tab, move cursor left, go back
    exe "normal gThhgt"
endfunction 

map gf :call GotoFileWithLineNum()<CR> 

"__________________________________________________________________________

nnoremap <Leader>S :Rep <C-r><C-w> 
command! -nargs=* Rep call s:ReplaceAll(<f-args>)
function! s:ReplaceAll(from, to)
    :set autoread
    :silent mksession! ~/vim_session <cr>
    :silent exec "! mt rep " . a:from . " " . a:to
    :silent source ~/vim_session <cr>     
    :set noautoread
    if TabooTabName(tabpagenr()) == ""
        :q 
    endif
endfunction

"__________________________________________________________________________

command! Reload call s:Reload()
function! s:Reload()
    :silent mksession! ~/vim_session <cr>
    :silent source ~/vim_session <cr>     
    if TabooTabName(tabpagenr()) == ""
        :q 
    endif
endfunction

"__________________________________________________________________________
    
fu! SaveSess()
    execute 'mksession! ' . getcwd() . '/.session.vim'
endfunction

autocmd VimLeave * call SaveSess()
