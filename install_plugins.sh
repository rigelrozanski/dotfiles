#!/bin/bash
#
# Install all of the plugins for Gvim that are used by this repo.
# Installation differs between MacOS and Linux

# General setup

set -eu

#OS="MacOS"
OS=`uname`

# Init sudo first, if a password is needed
sudo ls > /dev/null

# Check that it is a valid OS
if [ "$OS" == "Linux" ]; then
	echo ""
elif [ "$OS" == "Darwin" ]; then
	echo ""
else 
	echo "Error: Invalid Operating System: $OS"
	exit -1
fi

# TODO: Make sure gvim is installed, put in correct version for MacOS

# Make sure all the directories exist 

# Vim config directory
if [ ! -d "~/.vim" ]; then
	mkdir ~/.vim
fi

# The Vim autoload directory
if [ ! -d "~/.vim/autoload" ]; then
	mkdir -p ~/.vim/autoload 
fi

# The Vim/Pathogen bundle directory
if [ ! -d "~/.vim/bundle" ]; then
	mkdir -p ~/.vim/bundle 
fi

# The Vim/Pathogen bundle directory
if [ ! -d "~/.vim/colors" ]; then
	mkdir -p ~/.vim/colors 
fi

# Install Pathogen
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install the bundles
pushd ~/.vim/bundle

# Install VIM-GO
git clone https://github.com/fatih/vim-go.git

# Install neocomplete
git clone https://github.com/Shougo/neocomplete.vim.git

popd

# Install Molokai color scheme 
pushd ~/.vim/colors
curl -LSso molokai.vim https://raw.githubusercontent.com/fatih/molokai/master/colors/molokai.vim

popd

# Install ctags
if [ "$OS" == "Linux" ]; then
	sudo apt-get install exuberant-ctags
else
	brew install ctags
fi

# Install gotags
go get -u github.com/jstemmer/gotags

pushd ~/.vim/bundle

# Install golint
go get -u github.com/golang/lint/golint

# Install tagbar
git clone https://github.com/majutsushi/tagbar.git

# Install nerdtree
git clone https://github.com/scrooloose/nerdtree.git

popd

