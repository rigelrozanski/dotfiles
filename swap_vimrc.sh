#!/bin/bash  

shDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #working directory of this bash script
repoPath="$shDir/vimrc"
homePath="$HOME/.vimrc"
customPath="$HOME/.vimrc_custom"

# Initialize the custom file if it doesn't already exist
if [ ! -f .vimrc_custom ]; then
    touch $customPath
fi

# swap the vimrc files
if [[ $1 == push ]]; then
  cp $repoPath $homePath
  echo "Swapped repo vimrc with home directory .vimrc"
else
  cp $homePath $repoPath
  echo "Swapped home directory .vimrc repo vimrc with"
fi

