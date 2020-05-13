# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

plugins=(ssh-agent)

autoload -Uz promptinit
promptinit
source ~/pro/dotfiles/prompt_crazybus_setup

source ~/.creds_local
export EDITOR=vim
export VISUAL=vim
export GOPATH=~/go
export PROJECT_HOME=~/pro
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
export LC_CTYPE="en_US.UTF-8"
#source /usr/local/bin/virtualenvwrapper.sh
#source /Users/mick/bin/google-cloud-sdk/path.zsh.inc

export VIRTUAL_ENV_DISABLE_PROMPT=1
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DISABLE_AUTO_TITLE="true"
export AWS_DEFAULT_REGION=us-west-2

source ~/.zshrcfunctions

export PATH=$PATH:~/pro/keybase_dotfiles/bin
export PATH=$PATH:~/go/bin
export PATH=$PATH:/opt/local/sbin
export PATH=$PATH:/opt/local/bin
export PATH=$PATH:~/.local/bin
alias nix='nix-shell . --command "zsh"'

export eap=elastic-apps-163815

export NOTI_SOUND="Glass"
export NOTI_DEFAULT="banner pushbullet"

export RIPGREP_CONFIG_PATH=~/.rg

if test -f ~/.gnupg/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
  source ~/.gnupg/.gpg-agent-info
  export GPG_AGENT_INFO
  GPG_TTY=$(tty)
  export GPG_TTY
else
  (eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)) > /dev/null 2>&1
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -s "/Users/mick/.gvm/scripts/gvm" ]] && source "/Users/mick/.gvm/scripts/gvm"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/mick/pro/master/serverless/ec2/slack/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/mick/pro/master/serverless/ec2/slack/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/mick/pro/master/serverless/ec2/slack/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/mick/pro/master/serverless/ec2/slack/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /Users/mick/pro/master/serverless/ec2/slack/node_modules/tabtab/.completions/slss.zsh ]] && . /Users/mick/pro/master/serverless/ec2/slack/node_modules/tabtab/.completions/slss.zsh

if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add
export TERM=xterm

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/mick/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/mick/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/mick/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/mick/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

export BAT_THEME="Solarized (dark)"
