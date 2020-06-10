#!/bin/bash  

shDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #working directory of this bash script
repoPath="$shDir/kitty.conf"
homePath="$HOME/.config/kitty/kitty.conf"

if [[ $1 == push ]]; then
    cp $repoPath $homePath
    echo "Swapped repo kitty.conf with working kitty.conf"
else
    cp $homePath $repoPath
    echo "Swapped working kitty.conf repo kitty.conf with"
fi

