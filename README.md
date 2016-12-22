# RigeVIM

_Customized VIM functionality for the .vimrc file_

---

### Installation

run `bash swap_vimrc.sh`  
OR  
replace your .vimrc file in the home directory with the repository file 'vimrc'

### What's Included

- Implementation of .vimrc for a number of pluggins from [Setup VIM for Go development][1]
  - Pathogen
  - VIM-GO
  - neocomplete (commented out in .vimrc, requires [VIM with Lua][2])
  - molokai theme
  - tagbar
  - nerdtree
- Custom functions for 
  - Swap lines up and down (Credit: [this stackflow thread][3])
  - Insert a duplicate line to a new line below
  - Remove the current line
  - Navigate vim tabs

[1]: https://unknwon.io/setup-vim-for-go-development/
[2]: https://gist.github.com/jdewit/9818870
[3]: http://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim

### Custom Functions Mapped Keys

While vim is in _normal mode_ the following commands perform the customized functions

| Ctrl-Shift-Up    | Swap current line and above line               |
|------------------|------------------------------------------------|
| Ctrl-Shift-Down  | Swap current line and lower line               |
| Ctrl-Shift-Left  | Delete the current line entirely               |
| Ctrl-Shift-Right | Duplicate the current line to a new line below |
| Ctrl-Left        | Navigate vim tab left                          |
| Ctrl-Right       | Navigate vim tab right                         |

 
### Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

### License

RigeVIM is released under the Apache 2.0 license.
