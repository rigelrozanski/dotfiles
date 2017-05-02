# quickstart-vim-go

_Quickstart vim to use customized functionality for golang_

---

### Usage

##### Download
```
go get -d github.com/rigelrozanski/quickstart-vim-go
```

##### Installation
This tool will generate a new `.vimrc` file, but first you have to do [this][1] setup
Pathogen, vim-go, neocomplete, molokai theme, tagbar, and nerdtree, should be installed with the 
given link before running this installation. Additionally, I recommend that you install [go-def][4].
Once you've run through the tutorial you use:  
```
make install
```

##### Updating from this repo's custom vimrc
The custom `vimrc` file can be manually changed from this repo and updated in `~/.vimrc` with the
following command:
```
make update
```

##### Updating the custom vimrc from existing vimrc
As a reverse from the above command, the  `~/.vimrc` can update this repo's local `vimrc` with
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
- Implementation of [vim-godef][4] to open definitions in new tab
- Custom functions for 
  - Swap lines up and down (Credit: [this stackflow thread][3])
  - Move selection horizontally within line
  - Insert a duplicate line to a new line below
  - Remove the current line
  - Navigate vim tabs
  - comment/uncomment visual mode selected lines
  - quick find replace of word under cursor 
  - open function definition in a new tab 
  - Spellcheck shortcuts 
  - Open all .go/.md files as tabs


[1]: https://unknwon.io/setup-vim-for-go-development/
[2]: https://gist.github.com/jdewit/9818870
[3]: http://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim
[4]: https://github.com/dgryski/vim-godef

### Custom Functions Mapped Keys

| Command          | Mode   | Function                                                                   |
|------------------|--------|----------------------------------------------------------------------------|
| Ctrl-Shift-Up    | any    | Swap current line and above line                                           |
| Ctrl-Shift-Down  | any    | Swap current line and lower line                                           |
| Ctrl-Shift-Left  | any    | Delete the current line entirely                                           |
| Ctrl-Shift-Right | any    | Duplicate the current line to a new line below                             |
| Ctrl-Left        | any    | Navigate vim tab left                                                      |
| Ctrl-Right       | any    | Navigate vim tab right                                                     |
| Alt-Left         | normal | Move vim tab left                                                          |
| Alt-Right        | normal | Move vim tab right                                                         |
| dup              | normal | duplicate the current block                                                |
| cut              | normal | cut the current block                                                      |
| \s               | any    | setup a quick find replace for the whole document on the given cursor word |
| :O               | any    | Open all .go and .md files recursively as tabs, excluding vendor           |
| :T               | any    | Open a new tab and toggle the NERD tree to on                              |
| :Q               | any    | Close all the current tab                                                  |
| :SC              | any    | Starts the spell check                                                     |
| :SCE             | any    | Ends the spell check                                                       |
| gd               | normal | open get definition in new tab from [vim-godef][4]                         |
| gf               | normal | open file under cursor in new tab, great for use with `:GoCallers`         |
| <                | visual | shift all selected text one character left                                 |
| >                | visual | shift all selected text one character right                                |
| //               | visual | add comments to the beginnings of each line                                |
| ??               | visual | remove comments to the beginnings of each line                             |

 
### Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

### License

quickstart-vim-go is released under the Apache 2.0 license.
