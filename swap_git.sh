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

shDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #working directory of this bash script
repoPath="$shDir/git-extensions/"
homePath="$HOME/.git-extensions/"

if [[ $1 == push ]]; then
    cp -a $repoPath $homePath
    echo "Added repo's git-extensions/ to the home directory .git-extensions/"
else
    cp -a $homePath $repoPath
    echo "Added home directory .git-extensions to the repo's git-extensions/"
fi

