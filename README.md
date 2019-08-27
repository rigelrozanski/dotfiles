# quickstart-vim-go

_Quickstart vim to use customized functionality for golang_

---

### Usage

##### Download
```
go get -d github.com/rigelrozanski/quickstart-vim-go
```

##### Installation
```
make install
```

Use `make install` to generate a new `.vimrc` file and automatically install
packages from [this tutorial][1] and will also install [go-def][3].

##### Updating from this repo's custom vimrc
The custom `vimrc` file can be manually changed from this repo and updated in
`~/.vimrc` with the following command:
```
make update
```

##### Updating the custom vimrc from existing vimrc
As a reverse from the above command, the  `~/.vimrc` can update this repo's
local `vimrc` with
```
make pull 
```

### What's Included

- Implementation of .vimrc for a number of pluggins from [Setup VIM for Go development][1]
  - Pathogen
  - VIM-GO
  - neocomplete (commented out in .vimrc, requires [VIM with Lua][2])
  - molokai theme
  - tagbar
  - nerdtree
- Implementation of [vim-godef][3] to open definitions in new tab
- Custom functions for 
  - Swap lines up and down (Credit: [this stackflow thread][4])
  - Move selection horizontally within line
  - Insert a duplicate line to a new line below
  - Remove the current line
  - Navigate vim tabs
  - comment/uncomment visual mode selected lines
  - quick find replace of word under cursor 
  - open function definition in a new tab 
  - Spellcheck shortcuts 
  - Open all .go/.md files as tabs
- Implementation of [golint][5]

[1]: https://unknwon.io/setup-vim-for-go-development/
[2]: https://gist.github.com/jdewit/9818870
[3]: https://github.com/dgryski/vim-godef
[4]: http://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim
[5]: https://github.com/golang/lint

### Custom Functions Mapped Keys

| Command               | Mode   | Function                                                                     |
|-----------------------|--------|------------------------------------------------------------------------------|
| Ctrl-Shift-Up         | normal | Navigate pane up                                                             |
| Ctrl-Shift-Down       | normal | Navigate pane down                                                           |
| Ctrl-Shift-Left       | normal | Navigate pane left                                                           |
| Ctrl-Shift-Right      | normal | Navigate pane right                                                          |
| Ctrl-k                | any    | Swap current line and above line                                             |
| Ctrl-j                | any    | Swap current line and lower line                                             |
| Ctrl-h                | any    | Delete the current line entirely                                             |
| Ctrl-l                | any    | Duplicate the current line to a new line below                               |
| Ctrl-u                | any    | Navigate vim tab left                                                        |
| Ctrl-i                | any    | Navigate vim tab right                                                       |
| Ctrl-o                | normal | Move vim tab left                                                            |
| Ctrl-p                | normal | Move vim tab right                                                           |
| Ctrl-d                | normal | vim-multi-cursors next                                                       |
| Ctrl-s                | normal | vim-multi-cursors previous                                                   |
| Ctrl-x                | normal | vim-multi-cursors skip                                                       |
| Ctrl-g                | normal | copy the current word to the word on the position directly 1 row down        |
| Ctrl-n                | normal | open or close nerd tree navigation                                           |
| Shift-n               | normal | navigate to or from the nerd tree tab (split pane movement left/right)       |
| dup                   | normal | duplicate the current block                                                  |
| cut                   | normal | cut the current block                                                        |
| copy                  | visual | copy the current selection to the clipboard for Mac OS                       |
| git                   | normal | open current line in github.com                                              |
| <tab>-<char>          | normal | navigate to a specific character with easy-motion                            |
| :let fmt ="foo"       | normal | set default content of the fmt command (defined next)                        |
| fmt                   | normal | insert cursor variable debug line                                            |
| fmp                   | normal | insert cursor variable debug panic                                           |
| fmp                   | normal | insert cursor variable breakpoint                                            |
| \json                 | normal | adds json snippet for golang struct when hovered over field                  |
| \camel                | normal | convert word from camel to underscore case                                   |
| \test                 | normal | construct and open a go test function for the function name under the cursor |
| \debugs               | normal | add debugs print lines after each { and }                                    |
| \rmdebugs             | normal | remove debug print lines                                                     |
| \err                  | normal | insert a on next  line with if err != nil { return err }                     |
| com                   | normal | insert a on previous line the comment: // cursorsword -                      |
| \s                    | normal | setup a quick find replace for the whole document of the given cursor word   |
| \s                    | visual | setup a quick find replace for the whole document of the selected text       |
| \S                    | normal | setup a global find replace in the current directory using multitool         |
| :O                    | any    | Open all .go and .md files recursively as tabs, excluding vendor             |
| :T                    | any    | Open a new tab and toggle the NERD tree to on                                |
| :Q                    | any    | Close all the current tab                                                    |
| :HL                   | any    | enable highlighted search                                                    |
| :NHL                  | any    | disable highlighted search                                                   |
| :Wrap                 | any    | toggle vim line wrapping                                                     |
| :WB                   | any    | opens a new tab with a [wb](https://github.com/rigelrozanski/wb) named _vim_ |
| :W :Wq :WQ            | any    | :w or :wq                                                                    |
| :WQA :Wqa :WQA        | any    | :wqa                                                                         |
| :QQQ                  | any    | Close all tabs to the right of the current tab                               |
| :SC                   | any    | Starts the spell check                                                       |
| :SCE                  | any    | Ends the spell check                                                         |
| :Where                | any    | Echo the directory of the file currently being viewed                        |
| F                     | normal | Format all                                                                   |
| \d                    | normal | open get definition in new tab from [vim-godef][4]                           |
| <                     | visual | shift all selected text one character left                                   |
| >                     | visual | shift all selected text one character right                                  |
| //                    | visual | add comments to the beginnings of each line                                  |
| ??                    | visual | remove comments to the beginnings of each line                               |
| :GoTests              | visual | generate test for function in current line or functions in text selected     |
|:'<,'>SetWidth [cols]  | visual | make sure at least [cols] whitespace characters exist in each selected line  |
| :Install              | normal | Open a scratch tab with the results from `make install`                      |
| :Test                 | normal | Open a scratch tab with the results from `make test`                         |
| :Make <arg>           | normal | Open a scratch tab with the results from `make <arg>`                        |
| :Go <arg>             | normal | Open a scratch tab with the results from `go <arg>`                          |
| rrr                   | normal | quick install refresh, if in the [makeinstall] tab will run :Install         |                      
| :Ag [tofind]          | normal | Open a scratch tab with the results from `Ag [tofind]`                       |
| \a                    | normal | Same as above command for word under the cursor                              |
| \f                    | normal | open file under cursor in new tab at the line number (ex filename:lineno)    |
| \new                  | normal | create NewYourStruct function when highlighted over struct def name          |
| \fo                   | normal | create new function of the highlighted over struct def name                  |
| \time                 | normal | insert current date and timestamp at cursor                                  |
| Reload                | normal | Reload vim with all the same junk                                            |
| gf                    | normal | go to the file at the line number of the path under the cursor               |
| \gf                   | normal | copy the full path to the file for a regular fail message, then gf           |
| :Romeo                | visual | remove every other line in selection                                         |
| :Open                 | normal | open a given link under the cursor in your browser                           |
   
Deleting 

| Command          | Mode   | Function                                                                     |
|------------------|--------|------------------------------------------------------------------------------|
| dd               | normal | delete whole line                                                            |
| D                | normal | delete from cursor to end of line                                            |
| d0               | normal | delete from cursor to beginning of line                                      |
| cd               | normal | delete word                                                                  |
 
### Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

### License

quickstart-vim-go is released under the Apache 2.0 license.
