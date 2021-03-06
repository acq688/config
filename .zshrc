#! /bin/zsh

source <(antibody init)
eval $(gdircolors ~/.dircolors)

# Alias to interact with bare git repository for configuration.
# Used to add, update, delete, or otherwise manager configurations.
# Example: git checkout <branch> to get a configuration represented
#          by a specific branch.
alias config='/usr/bin/git --git-dir=$HOME/.configurations/ --work-tree=$HOME'


# Better ls alias for Mac
alias ls='gls --color'

setopt COMPLETE_IN_WORD

# Enable save history of 1000 cmds, write to a certain file
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=10000

setopt    appendhistory     # Append history to the history file (no overwriting)
setopt    sharehistory      # Share history across terminals
setopt    incappendhistory  # Immediately append to the history file, not just when a term is killed

# Export some global settings
export EDITOR="vim"
export LESS="-R"

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
    compinit -i
else
    compinit -C -i
fi

autoload bashcompinit
bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

PLUGINS="$HOME/.zsh_plugins"
antibody bundle < $PLUGINS


# ---- Completion ----
# Force rehash when command not found
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}


zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# forces zsh to realize new commands
zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _match _ignored _approximate

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# menu if nb items > 2
zstyle ':completion:*' menu select=2

# Activate virtualenv bottles named .venv automatically upon cd
# function chpwd() {
    # if [ -d .venv ]; then
        # . .venv/bin/activate
    # fi
# }

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# If a home venv exists, turn it on
[[ -d ~/.venv  ]] && . ~/.venv/bin/activate

function awsclearshell {
    echo unset AWS_SESSION_TOKEN
    echo unset AWS_ACCESS_KEY_ID
    echo unset AWS_SECRET_ACCCESS_KEY
}

function awsclear {
    eval $(awsclearshell)
}

function awsrole {
    aws sts get-caller-identity --duration-in-seconds 900 --profile $1 > /dev/null
    eval $(jq -r '.Credentials | "export AWS_ACCESS_KEY_ID="+.AccessKeyId, "export AWS_SECRET_ACCESS_KEY="+.SecretAccessKey, "export AWS_SESSION_TOKEN="+.SessionToken' < ~/.aws/cli/cache/$1--*.json)
}

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"
