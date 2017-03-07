.PHONY: swap_vimrc.sh

install:
	#first install godef
	go get -v github.com/rogpeppe/godef
	go install -v github.com/rogpeppe/godef
	git clone https://github.com/dgryski/vim-godef ~/.vim/bundle/vim-godef
	
	#now run update
	bash swap_vimrc.sh push

update:
	bash swap_vimrc.sh push

pull:
	bash swap_vimrc.sh pull
