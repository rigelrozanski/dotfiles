.PHONY: swap_vimrc.sh

install:
	bash install_plugins.sh
	git clone https://github.com/easymotion/vim-easymotion ~/.vim/bundle/vim-easymotion
	git clone https://github.com/terryma/vim-multiple-cursors ~/.vim/bundle/vim-multiple-cursors
	go get golang.org/x/tools/cmd/goimports

	#run update
	bash swap_vimrc.sh push

update:
	bash swap_vimrc.sh push

pull:
	bash swap_vimrc.sh pull
