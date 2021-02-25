#!/bin/bash  

shDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #working directory of this bash script
repoPath="$shDir/vim/ftplugin/"
homePath="$HOME/.vim/ftplugin/"

if [[ $1 == push ]]; then
    cp -R $repoPath $homePath
    echo "Swapped repo vim/ftplugin/ with home directory .vim/ftplugin/"
else
    cp -R $homePath $repoPath
    echo "Swapped home directory .vim/ftplugin/ with repo vim/ftplugin/"
fi

