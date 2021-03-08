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

"better word wrapping during `gq` command
"allows for hanging indentation
set ai fo+=q

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

colorscheme molokai

" vugu is a mod of html
au BufRead,BufNewFile *.vugu setfiletype gohtmltmpl

" optional fixes a glitch under some versions of terminal
if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    set t_ut=
endif

nmap <F8> :TagbarToggle<CR>

map <C-n> :NERDTreeToggle<CR>

" ag seach functionality: https://github.com/ggreer/the_silver_searcher
" http://codeinthehole.com/writing/using-the-silver-searcher-with-vim/
if executable('ag')
    " Note we extract the column as well as the file and line number
    set grepprg=ag\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c%m
endif

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
    if &scb ==# "noscrollbind"
       :exe "normal \"_dd"
    else  " if scrollbind is set remove from all open lines 
       let n = line('.')
       exe "normal \"_dd"
       exe "normal \<C-w>\<C-t>"
       exe n 
       exe "normal \"_dd"
       exe "normal \<C-w>\<C-w>"
    endif
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

command Notes call <SID>openNotes()
function! s:openNotes()
    "get the qu notes filepath
    let cmd = "qu lsfl app=vim-notes"
    let notesfile = system(cmd) 

    " open filename in right split
    :exe "botright vnew " . notesfile
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

" TODO replace with something much better in go 
" math evaluation
inoremap <C-E> <C-O>yiW<End>=<C-R>=<C-R>0<CR>

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

nnoremap dup {v}y}p}dd{ 
nnoremap cut {v}xO<Esc>

"for faster comments
nnoremap com yiwO// <Esc>pi<Right> - 

" insert timesstamp
nnoremap time :pu=strftime('%Y %b %d - %H:%M, [%a .%Z]')<CR>i<BS><ESC>

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

" credit: https://github.com/convissor/vim-settings/blob/master/.vimrc
" Declare function for moving left when closing a tab.
command Q call TabCloseLeft('q!')
function! TabCloseLeft(cmd)
	if winnr('$') == 1 && tabpagenr('$') > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr('$')
		exec a:cmd | tabprevious
	else
		exec a:cmd
	endif
endfunction

command HL :set hlsearch
command NHL :set nohlsearch
command Wrap :set wrap!


command T call <SID>newtab()
function! s:newtab()
    :exe "tabnew"
endfunction

command SC call <SID>spellCheck()
function! s:spellCheck()
    :exe "setlocal spell spelllang=en_us"
endfunction

command SCE call <SID>spellCheckEnd()
function! s:spellCheckEnd()
    :exe "set nospell"
endfunction

"override default quit command
cabbrev q <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Q' : 'q')<CR>

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

nnoremap <Leader>json yiwA `json:"<esc>pbve:s#\%V\(\<\u\l\+\\|\l\+\)\(\u\)#\l\1_\l\2#g<CR>A"`<esc>
nnoremap <Leader>camel bve:s#\%V\(\<\u\l\+\\|\l\+\)\(\u\)#\l\1_\l\2#g<CR><esc>
nnoremap <Leader>err oif err != nil {<CR>return err<CR><left><left>}<esc>
nnoremap viwp viwpyiwgvy
nnoremap F ggVGgq
nnoremap cd ciw<esc>
nnoremap <C-g> yiwjviwp

"__________________________________________________________________________
" goto commands

function! s:tabIsEmpty()
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
    elseif TabooTabName(tabpagenr()) == "XXX"
        :call <SID>xxxsearch()
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

command! XXX call s:xxxsearch()
function! s:xxxsearch()
    if TabooTabName(tabpagenr()) == "XXX"
        :normal ggdG
        :silent exec "r ! ag --ignore *.pb.go XXX"
    else
        :tabnew
        :TabooRename XXX
        :silent exec "r ! ag --ignore *.pb.go XXX"
        :setlocal buftype=nofile
    endif
    exe "normal ggiXXX"
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

fu! Fresh()
    exe 'e!'
    :let tabno = tabpagenr()
    "create than close a tab as a hack to refresh
    exe "tabnew"
    exe "q"
    exe "normal " . tabno . "gt"
endfunction

autocmd VimLeave * call SaveSess()
autocmd BufWritePost * call Fresh() "properly refresh vim issue resolved

" autoindent shell files
autocmd BufWritePre *.sh exec "normal gg=G``zz"

" this next command will force close nerd tree if it's the last and only buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

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
