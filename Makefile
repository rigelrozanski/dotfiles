.PHONY: swap_vimrc.sh

getdeps:
	bash install_plugins.sh
	git clone https://github.com/easymotion/vim-easymotion ~/.vim/bundle/vim-easymotion
	git clone https://github.com/terryma/vim-multiple-cursors ~/.vim/bundle/vim-multiple-cursors
	go get golang.org/x/tools/cmd/goimports

install:
	go install ./vimrcgo

swap: swapvimrc swapvim swapbash swapgit swapkitty

swapvimrc:
	bash swap_vimrc.sh push

swapvim:
	bash swap_vim.sh push

swapbash:
	bash swap_bash_profile.sh push

swapkitty:
	bash swap_kitty.sh push

swapgit:
	bash swap_git.sh push

pullvimrc:
	bash swap_vimrc.sh pull

pullvim:
	bash swap_vim.sh pull

pullbash:
	bash swap_bash_profile.sh pull
