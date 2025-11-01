. ~/.env.sh
. ~/.functions.sh

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export FPATH="~/.eza/completions/zsh:$HOME/.docker/completions:$FPATH"

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit;
else
    compinit -C;
fi;


source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fnm env --shell zsh)"

plugins=(git starship aws gh z zoxide zsh-autosuggestions fzf fzf-tab ssh ssh-agent fnm eza bun)

source $ZSH/oh-my-zsh.sh

# Keybindings
bindkey -e
bindkey ';5A' history-search-backward
bindkey ';5B' history-search-forward
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey "^[[3~" delete-char

# History
HISTSIZE=500
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'show-group' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'color-scale' all,age,size
zstyle ':omz:plugins:eza' 'color-scale-mode' gradient
# zstyle ':omz:plugins:eza' 'time-style' $TIME_STYLE
zstyle ':omz:plugins:eza' 'hyperlink' yes

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'