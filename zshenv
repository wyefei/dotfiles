# Handy aliases
alias grmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias gpb='git remote prune origin'
alias gpbd='git remote prune origin --dry-run'
alias gbr='git branch -vv'
alias gco='git checkout'
alias gaam="git commit -a --amend"
alias gst='git status'
alias gd='git diff'
alias gup='git pull --rebase'
alias gpf='git push -f'
alias gclean='git reflog expire --expire=now --all; git gc --prune=now'
alias bs='bundle exec sidekiq -c 5 -i 1 -C config/sidekiq_dev.yml'
alias es='elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml'
alias prodc='heroku run rails c -a hired-production'

gpoc() {
  local mybranch=$(git rev-parse --abbrev-ref HEAD) || return
	echo git push -u origin ${mybranch}
	git push -u origin $(echo "$mybranch")
}

# fbr - checkout git branch
fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
