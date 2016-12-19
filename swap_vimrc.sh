#!/bin/bash  

shDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #working directory of this bash script
fromPath="$shDir/vimrc"
toPath="$HOME/.vimrc"

cp $fromPath $toPath

echo "Swapped repo vimrc with home directory .vimrc"  
