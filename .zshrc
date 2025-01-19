# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.local/share/fzf/bin:$HOME/.config/composer/vendor/bin:$PATH"
FZF_HOME="${HOME}/.local/share/fzf"
export ZSH="$HOME/.oh-my-zsh"


# Download fzf, if it's not there yet
if [ ! -d "$FZF_HOME" ]; then
   mkdir -p "$(dirname $FZF_HOME)"
   git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_HOME"
   $FZF_HOME/install -y
fi

# Load completions
# Only have compinit check the completion cache for staleness once per day
#  https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
        compinit;
else
        compinit -C;
fi;


source <(fzf --zsh)

plugins=(git docker docker-compose aws gh zoxide vscode alias-finder fzf zsh-autosuggestions fzf-tab ssh ssh-agent fnm)

source $ZSH/oh-my-zsh.sh

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Keybindings
bindkey -e
bindkey ';5A' history-search-backward
bindkey ';5B' history-search-forward
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey "^[[3~" delete-char

# History
HISTSIZE=300
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

zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# https://github.com/Aloxaf/fzf-tab
# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'

eval "$(starship init zsh)"
export FPATH="~/.eza/completions/zsh:$FPATH"


# fnm
FNM_PATH="/home/clovis/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/clovis/.local/share/fnm:$PATH"
  eval "`fnm env`"
