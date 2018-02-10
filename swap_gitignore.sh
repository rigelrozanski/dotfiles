#!/bin/bash  

shDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #working directory of this bash script
repoPath="$shDir/gitignore_global"
homePath="$HOME/.gitignore_global"

if [[ $1 == push ]]; then
    cp $repoPath $homePath
    echo "Added repo gitignore to the home directory .gitignore"
else
    cp $homePath $repoPath
    echo "Added home directory .gitignore to the repo gitignore"
fi

