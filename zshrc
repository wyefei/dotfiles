export PATH=$HOME/.rbenv/shims:/usr/local/bin:$PATH
export PATH=/usr/local/opt/qt@5.5/bin:$PATH
export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
    find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
      sed s/^..//) 2> /dev/null'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_CTRL_T_OPTS="--preview '(cat {} || tree -C {}) 2> /dev/null | head -200'"

# Include Z - https://github.com/rupa/z
. $HOME/z.sh

# syntax highlighting
source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# start typing + [Up/Down] - fuzzy find history forward/backward
#bindkey '^[[A' history-beginning-search-backward
#bindkey '^[[A'  history-substring-search-up
#bindkey '^[[B'  history-substring-search-down
#bindkey '^[[B' history-beginning-search-forward

# The following lines were added by compinstall
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' max-errors 4
zstyle ':completion:*' menu select=0
zstyle ':completion:*' original false
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/Users/ywang/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000000000000
SAVEHIST=1000000000000000
setopt appendhistory autocd beep
bindkey -v
# End of lines configured by zsh-newuser-install


# zsh-nvm
source ~/.zsh-nvm/zsh-nvm.plugin.zsh

# Define some colors for the prompt string.
# Confession: I have no fucking clue how to actually use tput
local GREEN=`tput setaf 2 2>/dev/null`
local CYAN=`tput setaf 6 2>/dev/null`
local RED=`tput setaf 1 2>/dev/null`
local MAGENTA=`tput setaf 5 2>/dev/null`
local WHITE=`tput sgr0 2>/dev/null`

# get the name of the branch we are on
_git_branch_name() {
	git branch 2>/dev/null | awk '/^\*/ { print $2 }'
}
_git_is_dirty() {
	git diff --quiet 2> /dev/null || echo '*'
}

autoload -U colors
colors

setopt prompt_subst

# Main prompt: [~/path]%
# Right prompt: git-branch time
setopt PROMPT_SUBST
unsetopt PROMPT_CR
PROMPT="%B%{$GREEN%}[%{$MAGENTA%}%m %{$CYAN%}%~%{$GREEN%}]%b%{$WHITE%}%# "
RPROMPT='%{$RED%}$(_git_branch_name) $(_git_is_dirty)'


# fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

###############
# GIT related #
###############
alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
local _gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
local _viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

# gsh - git commit browser
flog() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
    (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF"
}

# gshp - git commit browser with previews
flogp() {
	glNoGraph |
	fzf --no-sort --reverse --tiebreak=index --no-multi \
		--ansi --preview $_viewGitLogLine \
		--header "enter to view, alt-y to copy hash" \
		--bind "enter:execute:$_viewGitLogLine   | less -R" \
		--bind "alt-y:execute:$_gitLogLineToHash | xclip"
}

# fco - checkout git branch/tag
fco() {
  local branches target
  branches=$(
  git branch --all | grep -v HEAD             |
  sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
  sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
  (echo "$branches") |
  fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# like normal z when used with arguments but displays an fzf prompt when used without.
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
