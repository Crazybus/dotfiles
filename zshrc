# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

autoload -Uz promptinit
promptinit
prompt crazybus

source ~/.creds_local
export EDITOR=vim
export VISUAL=vim
export GOPATH=~/go
export PROJECT_HOME=~/pro
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
source /usr/local/bin/virtualenvwrapper.sh
source /Users/mick/Downloads/google-cloud-sdk/path.zsh.inc

export VIRTUAL_ENV_DISABLE_PROMPT=1
export DISABLE_AUTO_TITLE="true"

source ~/.zshrcfunctions

export PATH=$PATH:~/go/bin
export PATH=$PATH:/opt/local/sbin
export PATH=$PATH:/opt/local/bin
alias timeout=gtimeout
alias gpg=gpg1
alias nix='nix-shell . --command "zsh"'
alias ls='gls --color=auto'
eval $(gdircolors ~/.dircolors/dircolors.ansi-dark)

export NOTI_SOUND="Glass"
export NOTI_DEFAULT="banner speech pushbullet"

if test -f ~/.gnupg/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
  source ~/.gnupg/.gpg-agent-info
  export GPG_AGENT_INFO
  GPG_TTY=$(tty)
  export GPG_TTY
else
  eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi
