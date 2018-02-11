.PHONY: swap_vimrc.sh

install:
	bash install_plugins.sh
	git clone https://github.com/easymotion/vim-easymotion ~/.vim/bundle/vim-easymotion
	git clone https://github.com/terryma/vim-multiple-cursors ~/.vim/bundle/vim-multiple-cursors
	go get golang.org/x/tools/cmd/goimports

	#run swap
	bash swap_vimrc.sh push

swap: swapvimrc swapbash swapgitignore

swapvimrc:
	bash swap_vimrc.sh push

swapbash:
	bash swap_bash_profile.sh push

swapgitignore:
	bash swap_gitignore.sh push

pullvimrc:
	bash swap_vimrc.sh pull

pullbash:
	bash swap_bash_profile.sh pull
