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
" let g:NERDTreeShowHidden = 1

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
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
vnoremap <Leader>s y:%s/<C-r>"/<C-r>"/g<Left><Left>

""" split navigation remap
nnoremap <c-s-up> <C-W><C-J>
nnoremap <c-s-down> <C-W><C-K>
nnoremap <C-S-left> <C-W><C-H>
nnoremap <C-S-right> <C-W><C-L>
nnoremap <S-n>  :call <SID>navigateNerdTree()<CR>

function! s:navigateNerdTree()
        if (exists("b:NERDTree") && b:NERDTree.isTabTree()) 
            execute "normal \<C-W>\<C-L>"
        else 
            execute "normal \<C-W>\<C-H>"
        endif
endfunction

nnoremap dup {v}y}p}dd{ 
nnoremap cut {v}xO<Esc>

"for faster comments
nnoremap com yiwO// <Esc>pi<Right> - 

" insert timesstamp
nnoremap time :pu=strftime('%Y %b %d - %H:%M, [%a .%Z]')<CR>i<BS><ESC>

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
"vmap <Tab> >gv
"vmap <S-Tab> <gv
"imap <Tab> <Tab>

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
command Wrap :set wrap!

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

" get the current file directory
command Where :echo @%


" close all tabs to the right
function TabCloseRight(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
endfunction

command QQQ call TabCloseRight('<bang>')


" open current line on Github
let g:gh_line_map = 'git'

" quick insert fmt.Println("")
let dbg = "debug : %v\\n"
let bkp = "breakpoint : %v\\n"
nnoremap fms yiwofmt.Printf("<c-r>=bkp<cr>", )<esc>10<left>p9<right>p<esc>ofmt.Scanf("")<esc>
nnoremap fmt yiwofmt.Printf("<c-r>=dbg<cr>", )<esc>10<left>p9<right>p
nnoremap fmp yiwopanic(fmt.Sprintf("<c-r>=dbg<cr>", ))<esc>11<left>p9<right>p `json"yiwopanic"`
nnoremap <Leader>json yiwA `json:"<esc>pbve:s#\%V\(\<\u\l\+\\|\l\+\)\(\u\)#\l\1_\l\2#g<CR>A"`<esc>
nnoremap <Leader>camel bve:s#\%V\(\<\u\l\+\\|\l\+\)\(\u\)#\l\1_\l\2#g<CR><esc>
nnoremap <Leader>err oif err != nil {<CR>return err<CR><left><left>}<esc>
nnoremap viwp viwpyiwgvy
nnoremap F ggVGgq
nnoremap cd ciw<esc>
nnoremap <C-g> yiwjviwp

" credit: https://github.com/convissor/vim-settings/blob/master/.vimrc
" Declare function for moving left when closing a tab.
function! TabCloseLeft(cmd)
	if winnr('$') == 1 && tabpagenr('$') > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr('$')
		exec a:cmd | tabprevious
	else
		exec a:cmd
	endif
endfunction


"__________________________________________________________________________
" goto commands

function! s:tabIsEmpty()
    "return winnr('$') == 1 && len(expand('%')) == 0 && line2byte(line('$') + 1) <= 2 
    return len(expand('%')) == 0 && line2byte(line('$') + 1) <= 2 
endfunction

function! s:tabIsEmptyRename(newtabname)
    if TabooTabName(tabpagenr()) == a:newtabname 
        return
    elseif s:tabIsEmpty()
        exec "TabooRename " . a:newtabname
        :setlocal buftype=nofile
    endif
endfunction

nnoremap rrr :call <SID>refreshInstall()<CR>
function! s:refreshInstall()
    if TabooTabName(tabpagenr()) == "makeinstall"
        :call <SID>makeinstall()
    elseif TabooTabName(tabpagenr()) == "maketest"
        :call <SID>maketest()
    endif
endfunction

command Install call <SID>makeinstall()
function! s:makeinstall()
    call s:tabIsEmptyRename("makeinstall")
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
    call s:tabIsEmptyRename("maketest")
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

command -nargs=1 Make call <SID>makegeneric(<f-args>)
function! s:makegeneric(cmd)
    :tabnew
    :TabooRename makegeneric
    :silent exec "r ! make " . a:cmd
    :setlocal buftype=nofile
endfunction

command -nargs=1 Go call <SID>gogeneric(<f-args>)
function! s:gogeneric(cmd)
    :tabnew
    :TabooRename gogeneric
    :silent exec "r ! go " . a:cmd
    :setlocal buftype=nofile
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

"open all files in seperate tabs
command -nargs=1 OpenAll call <SID>openAll(<f-args>)
function! s:openAll(dir)
    execute 'args **/' . a:dir
    silent argdo tabe %
    syntax on
endfunction

"delete all lines with certain text
command -nargs=1 Rmlines call <SID>rmlines(<f-args>)
function! s:rmlines(keyword)
    execute '%s/.*' . a:keyword . '.*\n//g'
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
nnoremap <Leader>gf ma/FAIL\t<CR>eebvEy`abhpli/<ESC>Bi$GOPATH/src/<esc>5l:call GotoFileWithLineNum()<CR>

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

command! -range -nargs=1 SetWidth <line1>,<line2>call SetWidth(<f-args>)
function! SetWidth(cols)
    let path = expand('%:p')
    let linenostart = a:firstline  - 1
    let linenoend = a:lastline - 1
    let cmd = "mt vim column-width " . path . " " . linenostart . " " . linenoend . " " . a:cols
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

nnoremap <Leader>new <S-v>}k:CreateNewXxx <CR>
command! -range CreateNewXxx call CreateNewXxx(<line1>,<line2>)
function! CreateNewXxx(linestart, lineend)
    let path = expand('%:p')
    let linenostart = a:linestart  - 1
    let linenoend = a:lineend - 1
    let cmd = "mt vim create-new-xxx " . path . " " . linenostart . " " . linenoend 
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

"command! -range UpdateAlias call UpdateAlias()
command! UpdateAlias call UpdateAlias()
function! UpdateAlias()
    let path = expand('%:p')
    let cmd = "mt update-alias " . path 
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

command! -range Romeo call Romeo(<line1>,<line2>)
function! Romeo(linestart, lineend)
    let diffr = a:lineend - a:linestart
    let c = 0
    while c <= diffr/2
        exe "normal vXj"
        let c += 1
    endwhile
endfunction

nnoremap <Leader>fo <S-v>}k:CreateFunctionOf <CR>
command! -range CreateFunctionOf call CreateFunctionOf(<line1>,<line2>)
function! CreateFunctionOf(linestart, lineend)
    let path = expand('%:p')
    let linenostart = a:linestart  - 1
    let linenoend = a:lineend - 1
    let cmd = "mt vim create-function-of " . path . " " . linenostart . " " . linenoend 
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

nnoremap <Leader>test :CreateTest <C-r><C-w><CR>
command! -nargs=1 CreateTest call s:CreateTest(<f-args>)
function! s:CreateTest(fnname)
    let path = expand('%:p')
    let cmd = "mt vim create-test " . a:fnname . " " . path
    let testpath = system(cmd) 
    exe "tabnew" testpath
endfunction

nnoremap <Leader>debugs :DebugPrints <C-r><C-w><CR>
command! -nargs=1 DebugPrints call s:DebugPrints(<f-args>)
function! s:DebugPrints(fnname)
    let lineno = line('.') - 1
    let path = expand('%:p')
    let cmd = "mt vim debug-prints " . a:fnname . " " . path . " " . lineno
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

nnoremap <Leader>rmdebugs :RmDebugPrints <CR>
command! RmDebugPrints call s:RmDebugPrints()
function! s:RmDebugPrints()
    let lineno = line('.') - 1
    let path = expand('%:p')
    let cmd = "mt vim remove-debug-prints " . path . " " . lineno
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

command! AddCal call s:CalAdd()
command! CalAdd call s:CalAdd()
function! s:CalAdd()
    :w
    let lineno = line('.') - 1
    let path = expand('%:p')
    let cmd = "mt cal add " . path . " " . lineno
    let results = system(cmd) 
    edit! "reload the current buffer
endfunction

"__________________________________________________________________________
" END OF FILE/SESSION/SAVE stuff

command! Reload call s:Reload()
function! s:Reload()
    exe "normal y}j".(4+ii*2+ex)."ei,\epbbvu".(ii+1)."jo\epbvu".(lex+1)."beli:\eA,\e``"
    :silent mksession! ~/vim_session <cr>
    :silent source ~/vim_session <cr>     
    if TabooTabName(tabpagenr()) == ""
        :q 
    endif
endfunction

command! Open call s:Open()
function! s:Open()
    exe "normal gx"
endfunction

"__________________________________________________________________________
    
fu! SaveSess()
    execute 'mksession! ' . getcwd() . '/.session.vim'
endfunction

autocmd VimLeave * call SaveSess()

" autoindent shell files
autocmd BufWritePre *.sh exec "normal gg=G``zz"

" this next command will force close nerd tree if it's the last and only buffer
" autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd BufEnter * call EnterBuffer()

let g:canClose = 0 
fu! EnterBuffer()
    if winnr("$") > 2 
        let g:canClose = 1
    endif
    if g:canClose 
        if (winnr("$") == 1 && s:tabIsEmpty()) | q | endif
        if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    endif
endfunction

"__________________________________________________________________________

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff
augroup encrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg set viminfo=
  " We don't want a swap file, as it writes unencrypted data to disk
  autocmd BufReadPre,FileReadPre *.gpg set noswapfile

  " Switch to binary mode to read the encrypted file
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null

  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.gpg u
augroup END

" set default encryption
:setlocal cm=blowfish2
