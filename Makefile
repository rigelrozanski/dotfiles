.PHONY: swap_vimrc.sh

install:
	go get -v github.com/rogpeppe/godef
	go install -v github.com/rogpeppe/godef
	git clone https://github.com/dgryski/vim-godef ~/.vim/bundle/vim-godef
	git clone https://github.com/easymotion/vim-easymotion ~/.vim/bundle/vim-easymotion
	go get golang.org/x/tools/cmd/goimports

	#run update
	bash swap_vimrc.sh push

update:
	bash swap_vimrc.sh push

pull:
	bash swap_vimrc.sh pull
