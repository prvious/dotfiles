export ZSH="$HOME/.oh-my-zsh"
export FZF_BASE="$(brew --prefix fzf)"
export BUN_INSTALL="$HOME/.bun"

export PATH="$BUN_INSTALL/bin:$HOME/.opencode/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/bin:$HOME/.composer/vendor/bin:$HOME/.cargo/bin:$PATH"

export UID=$(id -u)
export GID=$(id -g)
export USER=$(id -un)


alias pa='php artisan'
alias pest='./vendor/bin/pest'
alias phpstan='./vendor/bin/phpstan'
alias stan='./vendor/bin/phpstan'
alias rector='./vendor/bin/rector'
alias pint='./vendor/bin/pint'

alias amfs='php artisan migration:refresh --seed'
alias amf='php artisan migrate:fresh'

alias apps="cd ~/Apps"

alias dc="docker-compose"