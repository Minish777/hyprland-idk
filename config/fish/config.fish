if status is-interactive
    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls (eza)
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'
    command -v eza &> /dev/null && alias lt='eza --tree --icons --group-directories-first'
    command -v eza &> /dev/null && alias llt='eza -l --tree --icons'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # System management (Arch)
    alias update='sudo pacman -Syu'                 # update system
    alias aup='paru -Sua'                           # update AUR packages
    alias install='sudo pacman -S'                  # install package
    alias remove='sudo pacman -Rns'                 # remove package (+deps, config)
    alias search='pacman -Ss'                       # search packages
    alias info='pacman -Si'                         # package info
    alias clean='sudo pacman -Sc --noconfirm'       # clean package cache
    alias orphans='sudo pacman -Qtdq'               # list orphan packages
    alias clear-orphans='sudo pacman -Rns (sudo pacman -Qtdq)'
    alias reload='source ~/.config/fish/config.fish' # reload fish config

    # spicetify
    alias sipd='spicetify backup apply && spicetify apply'

    # Quick tools
    alias c='clear'
    alias m='micro'
    alias y='yazi'
    alias ff='fastfetch'
    command -v bat &> /dev/null && alias cat='bat --paging=never'
    abbr -a bat 'bat --paging=never'
    command -v eza &> /dev/null && abbr -a eza 'eza --icons --group-directories-first'

    # Custom colours (Noctalia terminal sequences)
    cat ~/.cache/terminal-sequences 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end

set -gx PATH "$HOME/.local/bin" "$HOME/.spicetify" $PATH

# opencode
fish_add_path "$HOME/.opencode/bin"

# быстрые команды для управления zapret
alias zapret-config='$HOME/zapret-configs/install.sh'
alias zapret-utils='$HOME/zapret-configs/utils-zapret.sh'

function zapret-ls
    for url in media.discordapp.net cdn.discordapp.com discord.com www.youtube.com vk.com
        set code (curl -sS --max-time 6 -o /dev/null -w "%{http_code}" "https://$url" 2>&1)
        printf "%-25s %s\n" $url $code
    end
end
