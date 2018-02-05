export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PS1='\w$ '

eval $(thefuck --alias)

#tab to rotate through options
bind '"\t":menu-complete'

#custom alias
alias killwifi='sudo service network-manager restart'
alias killglide='rm -rf ~/.glide ; rm -rf vendor ; rm glide.lock'
alias killswp='find . -name "*.swp" -type f -delete'
alias gitcommits='git log --oneline -n 10'
alias githash='git rev-parse --short HEAD ; git rev-parse HEAD'
alias gitrevert='git reset HEAD --hard ; git clean -fd ; git checkout -- .'
alias gitsquash='git rebase -i HEAD~10'
alias gitsquash2='git add -u ; git commit -m "int" ; git reset --soft HEAD~2 && git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"'
alias gitr='cd $GOPATH/src/github.com/rigelrozanski'
alias gitt='cd $GOPATH/src/github.com/tendermint'
alias gitc='cd $GOPATH/src/github.com/cosmos'
alias vimo='vim -c "O"'
alias vimn='vim -c "NERDTreeToggle"'
alias fuck='fuck -y'

#git branch auto-completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
