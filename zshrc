####################
#### .zshrc.d/cmd_time.zsh
####################
zmodload zsh/datetime

_command_time_preexec() {
  timer=${timer:-${$(($EPOCHREALTIME*1000))%.*}}
  ZSH_COMMAND_TIME_MSG=${ZSH_COMMAND_TIME_MSG-"Time: %s"}
  ZSH_COMMAND_TIME_COLOR=${ZSH_COMMAND_TIME_COLOR-"white"}
  export ZSH_COMMAND_TIME=""
}

_command_time_precmd() {
  if [ $timer ]; then
    timer_show=$((${$(($EPOCHREALTIME*1000))%.*} - $timer))
    if [ -n "$TTY" ] && [ $timer_show -ge ${ZSH_COMMAND_TIME_MIN_SECONDS:-3000} ] || [ -n "$timing" ]; then
      export ZSH_COMMAND_TIME="$timer_show"
      if [ ! -z ${ZSH_COMMAND_TIME_MSG} ]; then
        zsh_command_time
      fi
    fi
    unset timer
  fi
}

_dot_color="66;66;66"
get_dot () {
  local STR=$@
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=" %{\x1b[38;2;${_dot_color}m%}"
  (( LENGTH = ${COLUMNS} - $LENGTH))

  for i in {0..$(($LENGTH - 11))}
    do
      SPACES="$SPACES."
    done
  SPACES="$SPACES%{$reset_color%} "

  echo $SPACES
}

zsh_command_time() {
    if [ -n "$ZSH_COMMAND_TIME" ]; then
        hours=$(($ZSH_COMMAND_TIME/3600000))
        min=$(($ZSH_COMMAND_TIME/60000%60))
        sec=$(($ZSH_COMMAND_TIME/1000%60))
        ms=$(($ZSH_COMMAND_TIME%1000))
        if [ "$ZSH_COMMAND_TIME" -le 1000 ]; then
            timer_show="$fg[green]$ms ms."
        elif [ "$ZSH_COMMAND_TIME" -gt 1000 ] && [ "$ZSH_COMMAND_TIME" -le 60000 ]; then
            timer_show="$fg[green]$sec s. $ms ms."
        elif [ "$ZSH_COMMAND_TIME" -gt 60000 ] && [ "$ZSH_COMMAND_TIME" -le 180000 ]; then
            timer_show="$fg[yellow]$min min. $sec s. $ms ms."
        else
            if [ "$hours" -gt 0 ]; then
                min=$(($min%60000))
                timer_show="$fg[red]$hours h. $min min. $sec s."
            else
                timer_show="$fg[red]$min min. $sec s."
            fi
        fi
        x="%{\x1b[38;2;${_dot_color}m%}..........%{$reset_color%}"
        print -rP "$(echo $x) ${ZSH_COMMAND_TIME_MSG} $timer_show $(get_dot ${ZSH_COMMAND_TIME_MSG} "$timer_show")"
    fi
}

precmd_functions+=(_command_time_precmd)
preexec_functions+=(_command_time_preexec)

####################
#### .zshrc.d/common.zsh
####################
#允许在交互模式中使用注释
setopt INTERACTIVE_COMMENTS

#启用自动 cd，输入目录名回车进入目录
setopt AUTO_CD

#扩展路径
#/v/c/p/p => /var/cache/pacman/pkg
setopt complete_in_word

#禁用 core dumps
# limit coredumpsize 0

#键绑定风格 (e)macs|(v)i
bindkey -e
#设置 [DEL]键 为向后删除
bindkey "\e[3~" delete-char

#以下字符视为单词的一部分
WORDCHARS='-*[]~#%^<>{}'

###### title
case $TERM in (*xterm*|*rxvt*|(dt|k|E)term)
   preexec () { print -Pn "\e]0;${PWD/$HOME/\~}: $1\a" }
   ;;
esac

alias rm='rm -i'
alias mv='mv -i'
alias ll='ls -alh'
alias du='du -h'
alias df='df -h'
alias mkdir='mkdir -p'
alias r='grep --color=auto'
alias diff='diff -u'
alias e='code'
alias t='tmux'
alias tl='tmux list-sessions'
alias ta='tmux attach -t'
alias x='export'
alias o='echo'

function take() {
    mkdir -p $@ && cd ${@:$#}
}
function px { ps aux | grep -i "$*" }
function p { pgrep -a "$*" }
__default_indirect_object="local z=\${@: -1} y=\$1 && [[ \$z == \$1 ]] && y=\"\$default\""


if [ -x "$(command -v nvim)" ]; then
    alias v='nvim'
elif [ -x "$(command -v vim)" ]; then
    alias v='vim'
else
    alias v='vi'
fi

export TIME_STYLE=long-iso
alias n='date +%y%m%d%H%M%S'
alias now='date -Iseconds'

####################
#### .zshrc.d/completion.zsh
####################
autoload -U compinit
compinit
# zmodload zsh/complist
zmodload -i zsh/complist

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end
setopt auto_list  # TODO: unknow
#setopt complete_aliases

#自动补全缓存
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh_cache

#自动补全选项
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*:*:default' force-list always
zstyle ':completion:*' select-prompt '%SSelect:  lines: %L  matches: %M  [%p]'

zstyle ':completion:*:match:*' original only
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate

#路径补全
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion::complete:*' '\\'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

#补全类型提示分组
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;32m -- %d (errors: %e) --\e[0m'

#彩色补全菜单
if whence dircolors >/dev/null; then
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  alias ls='ls --color'
else
  export CLICOLOR=1
  zstyle ':completion:*:default' list-colors ''
fi
export ZLSCOLORS="${LS_COLORS}"

#修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
#错误校正
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# cd
# zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# cd ~ 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

#kill 命令补全
compdef pkill=killall
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
fi

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*' 'nixbld*'

# ignore uninteresting hosts
zstyle ':completion:*:*:*:hosts' ignored-patterns \
        loopback ip6-localhost ip6-loopback localhost6 localhost6.localdomain6 localhost.localdomain

## ignores filenames already in the line
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes

## Ignore completion functions for commands you don't have:
zstyle ':completion:*:functions' ignored-patterns '_*'

####################
#### .zshrc.d/crypt.zsh
####################
function rnd {
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c ${1:-13}
}

function gen-self-signed-cert {
    openssl req \
        -newkey rsa:4096 -nodes -sha256 -keyout $1.key \
        -x509 -days 365 -out $1.crt \
        -subj /CN=$1
}

function gen-wg-key {
    umask 077 # default: 022
    wg genkey | tee ${1:-wg} | wg pubkey > ${1:-wg}.pub
}

export PASSWORD_RULE_PATH=$HOME/.config/passwd
if [ -d $PASSWORD_RULE_PATH ]; then
    chmod -R go-rwx $PASSWORD_RULE_PATH
fi

function gpw {
    local length=12
    local config='default'
    local http=''
    local options=$(getopt -o c:l:h  -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
        -c)
            shift
            config="$1"
            ;;
        -l)
            shift
            length="$1"
            ;;
        -h)
            http="true"
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done
    # local pwd=$(eval "echo \"\$$config\"")
    token=$(cat $PASSWORD_RULE_PATH/token/$config)
    pwd=$(pwgen -B1cn ${length} -H <(echo -n "$1" | openssl dgst -sha1 -hmac "$token"))
    echo $pwd
    if [ ! -z $http ]; then
        if (( $+commands[htpasswd] )); then
            echo $(htpasswd -nBb $1 $pwd)
        else
            echo $1:$(openssl passwd -apr1 $pwd)
        fi
    fi
}

function _comp_gpw {
    local name
    _arguments '-c[config]:config:->config' '-l[length]:length:' '-h[htpasswd]' "1:item:->item"
    case "$state" in
        config)
            _alternative ":config:($(ls -A $PASSWORD_RULE_PATH/rule))"
        ;;
        item)
            if [ -z ${opt_args[-c]} ]; then
                name="default"
            else
                name=${opt_args[-c]}
            fi
            local matcher
            _alternative "::($(cat $PASSWORD_RULE_PATH/rule/$name))"
        ;;
    esac
}

compdef _comp_gpw gpw
####################
#### .zshrc.d/dirs.zsh
####################
if [[ -d $HOME/world ]]; then
    hash -d w="$HOME/world"
else
    hash -d w="/world"
fi

hash -d c="$CFG"
hash -d h="$WHEEL"
hash -d s="$HOME/.ssh"
hash -d d="$HOME/Downloads"
hash -d o="$HOME/Documents"

####################
#### .zshrc.d/docker.zsh
####################
# $CRICTL | k3s crictl | podman
export CRICTL=${CRICTL:-docker}

alias d="$CRICTL"
alias di="$CRICTL images"
alias drmi="$CRICTL rmi"
alias dt="$CRICTL tag"
alias dp="$CRICTL ps"
alias dpa="$CRICTL ps -a"
alias dl="$CRICTL logs -ft"
alias dpl="$CRICTL pull"
alias dps="$CRICTL push"
alias dr="$CRICTL run -i -t --rm -v \$(pwd):/world"
alias drr="$CRICTL run --rm -v \$(pwd):/world"
alias dcs="$CRICTL container stop"
alias dcr="$CRICTL container rm"
alias dcp="$CRICTL cp"
alias dsp="$CRICTL system prune -f"
alias dspa="$CRICTL system prune --all --force --volumes"
alias dvi="$CRICTL volume inspect"
alias dvr="$CRICTL volume rm"
#alias dvp="$CRICTL volume prune"
alias dvp="$CRICTL volume rm \$($CRICTL volume ls -q | awk -F, 'length(\$0) == 64 { print }')"
alias dvl="$CRICTL volume ls"
alias dvc="$CRICTL volume create"
alias dsv="$CRICTL save"
alias dld="$CRICTL load"
alias dh="$CRICTL history"
alias dhl="$CRICTL history --no-trunc"
alias dis="$CRICTL inspect"

alias dc="docker-compose"
alias dcu="docker-compose up"
alias dcud="docker-compose up -d"
alias dcd="docker-compose down"

function da {
    if [ $# -gt 1 ]; then
        $CRICTL exec -it $@
    else
        $CRICTL exec -it $1 /bin/sh -c "[ -e /bin/zsh ] && /bin/zsh || [ -e /bin/bash ] && /bin/bash || /bin/sh"
    fi
}

function dcsr {
    local i
    for i in $*
        $CRICTL container stop $i && $CRICTL container rm $i
}

_dgcn () {
    local dsc=()
    while read -r line; do
        local rest=$(echo $line | awk '{$1="";$2=""; print $0;}')
        local id=$(echo $line | awk '{print $1;}')
        local name=$(echo $line | awk '{print $2;}')
        dsc+="$name:$rest"
        dsc+="$id:$rest"
    done <<< $($CRICTL container ls --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t')
    _describe containers dsc
}
compdef _dgcn da dcsr

function dvbk {
    for i in $*
        $CRICTL run --rm        \
            -v $(pwd):/backup  \
            -v ${i}:/data      \
            ubuntu:focal \
            tar --transform='s/^\.//' -zcvf /backup/vol_${i}_`date +%Y%m%d%H%M%S`.tar.gz -C /data .
}

_dvlq () {
    _alternative "$CRICTL volumes:volume:($($CRICTL volume ls -q | awk -F, 'length($0) != 64 { print }'))"
}
compdef _dvlq dvbk

function dvrs {
    $CRICTL volume create $2
    $CRICTL run --rm            \
            -v $(pwd):/backup  \
            -v $2:/data        \
            alpine             \
            tar zxvf /backup/$1 -C /data
}

_dvrs () {
    _arguments '1:backup file:_files' '2:volume:_dvlq'
}
compdef _dvrs dvrs

function ipl {
    if (( $+commands[skopeo] )); then
        echo 'use local skopeo'
        for i in $*; do
            echo "<-- $i"
            sleep 1
            skopeo copy docker://$i docker-daemon:$i
        done
    else
        echo 'use container skopeo'
        for i in $*; do
            echo "<-- $i"
            sleep 1
            docker run -it --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -e http_proxy=$http_proxy \
                -e https_proxy=$https_proxy \
                nnurphy/k8su skopeo copy \
                docker://$i \
                docker-daemon:$i
        done
    fi
}

####################
#### .zshrc.d/git.zsh
####################
alias g='git'
alias gs='git status'
alias gc='git checkout'
alias gci='git commit'
alias gca='git commit -a'
alias gcaa='git commit -a --amend'
alias gn='git checkout -b'
alias gb='git branch'
alias gbd='git branch -D'
alias gpl='git pull'
alias gps='git push'
function gpsu {
    local default='origin'
    eval $__default_indirect_object
    git push -u $y $z
}
alias gl='git log --oneline --decorate --graph'
alias glp='git log -p'
alias gly='git log --since=yesterday'
alias glt='git log --since=today'
alias glm='git log --since=midnight'
alias gm='git merge'
alias gr='git rebase -i --autosquash'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add .'
alias gut='git reset HEAD --'
alias grh='git reset --hard'
alias grhh='git reset --hard HEAD'
alias glst='git log -1 HEAD'
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'
function gtdr {
    local default='origin'
    eval $__default_indirect_object
    git push $y :refs/tags/$z
}
alias ggc='git reflog expire --all --expire=now && git gc --prune=now --aggressive'
function grad {
    local default='origin'
    eval $__default_indirect_object
    git remote add $y $z
}
function gcf  { vim .git/config }

####################
#### .zshrc.d/history.zsh
####################
#历史纪录条目数量
export HISTSIZE=100000
#注销后保存的历史纪录条目数量
export SAVEHIST=10000
#历史纪录文件
export HISTFILE=~/.zsh_history
#以附加的方式写入历史纪录
setopt INC_APPEND_HISTORY
#如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
#为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY

#启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
#相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS

#在命令前添加空格，不将此命令添加到纪录文件中
#setopt HIST_IGNORE_SPACE


####################
#### .zshrc.d/keybinding.zsh
####################
user-tab(){
    case $BUFFER in
        "" )                       # "" -> "cd "
            BUFFER="cd "
            zle end-of-line
            zle expand-or-complete
            ;;
        " " )
            if [ -f Taskfile.yml ]; then
                BUFFER="task "
            elif [ -f justfile ]; then
                BUFFER="just "
            elif [ -f Makefile ]; then
                BUFFER="make "
            else
                return
            fi
            zle end-of-line
            zle expand-or-complete
            ;;
        "cd --" )                  # "cd --" -> "cd +"
            BUFFER="cd +"
            zle end-of-line
            zle expand-or-complete
            ;;
        "cd +-" )                  # "cd +-" -> "cd -"
            BUFFER="cd -"
            zle end-of-line
            zle expand-or-complete
            ;;
        * )
            zle expand-or-complete
            ;;
    esac
}
zle -N user-tab
bindkey "\t" user-tab

user-ret(){
    if [[ $BUFFER = "" ]]; then
        BUFFER="ls"
        zle end-of-line
        zle accept-line
    elif [[ $BUFFER = " " ]]; then
        BUFFER="ls -lh"
        zle end-of-line
        zle accept-line
    elif [[ $BUFFER = "  " ]]; then
        BUFFER="ls -lah"
        zle end-of-line
        zle accept-line
    elif [[ $BUFFER =~ "\.\.\.+" ]]; then
        # <1> . -> ../ <2> " ../" -> " " <3> // -> /
        BUFFER=${${${BUFFER//\./\.\.\/}// \.\.\// }//\/\//\/}
        zle end-of-line
        zle accept-line
    else
        zle accept-line
    fi
}
zle -N user-ret
bindkey "\r" user-ret

user-spc(){
    # cursor (behind && over) space && not behind ~
    if [[ $LBUFFER =~ ".*[^ ~] +$" ]] && [[ ( $RBUFFER == "" ) || ( $RBUFFER =~ "^ .*" ) ]]; then
        LBUFFER=${LBUFFER}"~"
        zle backward-char
        zle forward-char
        zle expand-or-complete
    else
        zle magic-space
    fi
}
zle -N user-spc
bindkey " " user-spc

user-bspc-word(){
    if [[ $BUFFER = "" ]]; then
        BUFFER="popd"
        zle accept-line
    else
        zle backward-kill-word
    fi
}
zle -N user-bspc-word
bindkey "\C-w" user-bspc-word

user-bspc(){
    if [[ $BUFFER = "" ]]; then
        BUFFER="cd .."
        zle accept-line
    else
        zle backward-delete-char
    fi
}
zle -N user-bspc
bindkey "\C-h" user-bspc

user-esc() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    elif [[ $BUFFER == $EDITOR\ * ]]; then
        LBUFFER="${LBUFFER#$EDITOR }"
        LBUFFER="sudoedit $LBUFFER"
    elif [[ $BUFFER == sudoedit\ * ]]; then
        LBUFFER="${LBUFFER#sudoedit }"
        LBUFFER="$EDITOR $LBUFFER"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N user-esc
bindkey "\e\e" user-esc

bindkey "\C-q" push-line-or-edit
bindkey "^[q" quote-line
#bindkey "\C-r" history-incremental-pattern-search-backward
#bindkey "\C-s" history-incremental-pattern-search-forward

####################
#### .zshrc.d/link.zsh
####################
function entf {
    local title
    local content=""
    eval set -- $(getopt -o t:c: -- "$@")
    while true; do
        case "$1" in
        -t)
            shift
            title=$1
            ;;
        -c)
            shift
            content=$1
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    curl -# --ssl \
        --url "smtp://${EMAIL_SERVER:-smtp.qq.com}" \
        --user "${EMAIL_ACCOUNT}:${EMAIL_TOKEN}" \
        --mail-from $EMAIL_ACCOUNT \
        --mail-rcpt $1 \
        --upload-file <(echo -e "From: \"$EMAIL_ACCOUNT\" <$EMAIL_ACCOUNT>\nTo: \"$1\" <$1>\nSubject: ${title}\nDate: $(date)\n\n${content}")
}

function _comp_entf_recipients {
    local -a recipients
    for i in ${(ps:\n:)EMAIL_RECIPIENTS}; do
        recipients+=($i)
    done
    _describe 'recipients' recipients
}

function _comp_entf {
    _arguments '-t[title]' '-c[content]' '1:recipient:_comp_entf_recipients'
}

compdef _comp_entf entf

####################
#### .zshrc.d/os.zsh
####################
# $OSTYPE =~ [mac]^darwin, linux-gnu, [win]msys, FreeBSD, [termux]linux-android
# Darwin\ *64;Linux\ armv7*;Linux\ aarch64*;Linux\ *64;CYGWIN*\ *64;MINGW*\ *64;MSYS*\ *64

case $(uname -sm) in
  Darwin\ *64 )
    alias lns='ln -fs'
    function af { lsof -p $1 +r 1 &>/dev/null }
    alias osxattrd='xattr -r -d com.apple.quarantine'
    alias rmdss='find . -name ".DS_Store" -depth -exec rm {} \;'
    [[ -x $HOME/.iterm2_shell_integration.zsh ]]  && source $HOME/.iterm2_shell_integration.zsh
  ;;
  Linux\ *64 )
    alias lns='ln -fsr'
    function af { tail --pid=$1 -f /dev/null }
  ;;
  * )
    alias lns='ln -fsr'
  ;;
esac

compdef _kill af

if (( $+commands[ip] )); then
  export route=$(ip route | awk 'NR==1 {print $3}')
else
  export route=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')
fi

if [ -n "$WSL_DISTRO_NAME" ]; then
  export DISPLAY=${route}:0.0
fi

function china_mirrors {
  case $(grep ^ID= /etc/os-release | sed 's/ID=\(.*\)/\1/') in
    ubuntu )
      cp /etc/apt/sources.list /etc/apt/sources.list.$(date +%y%m%d%H%M%S)
      sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    ;;
    debian )
      cp /etc/apt/sources.list /etc/apt/sources.list.$(date +%y%m%d%H%M%S)
      sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1ftp2.cn.debian.org\3main contrib non-free/g' /etc/apt/sources.list
    ;;
    alpine )
      cp /etc/apk/repositories /etc/apk/repositories.$(date +%y%m%d%H%M%S)
      sed -i 's/dl-cdn.alpinelinux.org/mirror.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
    ;;
    * )
  esac
}

function make-swapfile {
    local file="/root/swapfile"
    local size="16"
    local options=$(getopt -o f:s: -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
        -f)
            shift
            file=$1
            ;;
        -s)
            shift
            size=$1
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    dd if=/dev/zero of=$file bs=1M count=$((1024*${size})) # GB
    chmod 0600 $file
    mkswap $file
    swapon $file
    echo "$file swap swap defaults 0 2" >> /etc/fstab
}


function iptables---- {
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --dport 22,80,443 -j ACCEPT
    iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
    iptables -A INPUT -p tcp --dport 55555 -j ACCEPT
    iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -i wg0 -j ACCEPT
    iptables -P INPUT DROP
}

function iptables-allow-address {
    iptables -A INPUT -s $1 -j ACCEPT
}

function iptables-clean-input {
    iptables -P INPUT ACCEPT
    iptables -F
}

alias iptables-list-input="iptables -L INPUT --line-num -n"
####################
#### .zshrc.d/prompt.zsh
####################
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BLACK; do
    eval _$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval $color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
FINISH="%{$terminfo[sgr0]%}"

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[default]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

_git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}

_git_prompt () {
  local _branch=$(_git_branch)
  local _status=$(_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result$_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}


_PATH="%{$fg_bold[default]%}%~%{$reset_color%}"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[default]%}%n"
  _LIBERTY="%{$fg[green]%}$"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"

_space_color="88;88;88"
get_space () {
  local STR=$@
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=" %{\x1b[38;2;${_space_color}m%}"
  (( LENGTH = ${COLUMNS} - $LENGTH))

  for i in {0..$(($LENGTH - 2))}
    do
      SPACES="$SPACES-"
    done
  SPACES="$SPACES%{$reset_color%} "

  echo $SPACES
}

_1LEFT="$_USERNAME $_PATH"
_1RIGHT="[%D %T] "

prompt_precmd () {
  _1SPACES=`get_space $_1LEFT $_PS1_KUBE $_1RIGHT`
  print
  print -rP "$_1LEFT$_1SPACES$_PS1_KUBE$_1RIGHT"
}

setopt prompt_subst
PROMPT='$(_git_prompt)$_LIBERTY '
RPROMPT=''

autoload -U add-zsh-hook
add-zsh-hook precmd prompt_precmd

####################
#### .zshrc.d/ssh.zsh
####################
function gen-ssh-key {
    local file='id_ed25519'
    local comment=$(date -Iseconds)
    local options=$(getopt -o c:f: -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
        -c )
            shift
            comment="$1"
            ;;
        -f )
            shift
            file="$1"
            ;;
        -- )
            shift
            break
            ;;
        esac
        shift
    done
    ssh-keygen -t ed25519 -f ${file} -C ${comment}
    if (( $+commands[puttygen] )); then
        puttygen ${file} -o ${file}.ppk
    fi
}

alias ssh-copy-id-with-pwd='ssh-copy-id -o PreferredAuthentications=password -o PubkeyAuthentication=no -f -i'
alias sa='ssh-agent $SHELL'
alias sad='ssh-add'
alias rs="rsync -avP"

function s {
    local password="-o IdentitiesOnly=yes "
    local cmd="ssh "
    local show=""
    local shell=""
    eval set -- $(getopt -o VXPIi:p:u:R:L:D:J:ZB -- "$@")
    while true; do
        case "$1" in
        -V)
            show="1"
            ;;
        -X)
            cmd+="-X "
            ;;
        -P)
            password=""
            ;;
        -I)
            cmd+="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
            ;;
        -i)
            shift
            cmd+="-i $1 "
            ;;
        -p)
            shift
            cmd+="-p $1 "
            ;;
        -u)
            shift
            cmd+="-o ProxyCommand='websocat -bE - $1' "
            ;;
        -R)
            shift
            cmd+="-NTvR $1 "
            ;;
        -L)
            shift
            cmd+="-NTvL $1 "
            ;;
        -D)
            shift
            cmd+="-NTvD $1 "
            ;;
        -J)
            shift
            cmd+="-J $1 "
            ;;
        -B)
            shell="/bin/bash -ic "
            ;;
        -Z)
            shell="-t /bin/zsh -ic "
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    cmd+="${password}$1"
    if [ ! -z $2 ]; then
        shift
        cmd+=" ${shell}'$@'"
    fi

    if [ ! -z $show ]; then
        ssh -V
        echo
        echo $cmd
        return
    fi

    eval $cmd
}

compdef s=ssh
####################
#### .zshrc.d/task.zsh
####################
alias j='just'

autoload -U is-at-least

_just() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    local common=(
'--color=[Print colorful output]: :(auto always never)' \
'-f+[Use <JUSTFILE> as justfile.]' \
'--justfile=[Use <JUSTFILE> as justfile.]' \
'*--set[Override <VARIABLE> with <VALUE>]: :_just_variables' \
'--shell=[Invoke <SHELL> to run recipes]' \
'*--shell-arg=[Invoke shell with <SHELL-ARG> as an argument]' \
'-d+[Use <WORKING-DIRECTORY> as working directory. --justfile must also be set]' \
'--working-directory=[Use <WORKING-DIRECTORY> as working directory. --justfile must also be set]' \
'--completions=[Print shell completion script for <SHELL>]: :(zsh bash fish powershell elvish)' \
'-s+[Show information about <RECIPE>]: :_just_commands' \
'--show=[Show information about <RECIPE>]: :_just_commands' \
'(-q --quiet)--dry-run[Print what just would do without doing it]' \
'--highlight[Highlight echoed recipe lines in bold]' \
'--no-highlight[Don'\''t highlight echoed recipe lines in bold]' \
'(--dry-run)-q[Suppress all output]' \
'(--dry-run)--quiet[Suppress all output]' \
'--clear-shell-args[Clear shell arguments]' \
'*-v[Use verbose output]' \
'*--verbose[Use verbose output]' \
'--dump[Print entire justfile]' \
'-e[Edit justfile with editor given by $VISUAL or $EDITOR, falling back to `vim`]' \
'--edit[Edit justfile with editor given by $VISUAL or $EDITOR, falling back to `vim`]' \
'--evaluate[Print evaluated variables]' \
'--init[Initialize new justfile in project root]' \
'-l[List available recipes and their arguments]' \
'--list[List available recipes and their arguments]' \
'--summary[List names of available recipes]' \
'--variables[List names of variables]' \
'-h[Print help information]' \
'--help[Print help information]' \
'-V[Print version information]' \
'--version[Print version information]' \
)

    _arguments "${_arguments_options[@]}" $common \
        '1: :_just_commands' \
        '*: :->args' \
        && ret=0

    case $state in
        args)
            curcontext="${curcontext%:*}-${words[2]}:"

            local lastarg=${words[${#words}]}

            if [[ ${lastarg} = */* ]]; then
                # Arguments contain slash would be recognised as a file
                _arguments -s -S $common '*:: :_files'
            else
                # Show usage message
                _message "`just --show ${words[2]}`"
                # Or complete with other commands
                #_arguments -s -S $common '*:: :_just_commands'
            fi
        ;;
    esac

    return ret
}

(( $+functions[_just_commands] )) ||
_just_commands() {
    local commands; commands=(
        ${${${(M)"${(f)$(_call_program commands just --list)}":#    *}/ ##/}/ ##/:Args: }
    )

    _describe -t commands 'just commands' commands "$@"
}

(( $+functions[_just_variables] )) ||
_just_variables() {
    local variables; variables=(
        ${(s: :)$(_call_program commands just --variables)}
    )

    _describe -t variables 'variables' variables
}

#_just "$@"

compdef _just just

####################
#### .zshrc.d/utils.zsh
####################
function re-zsh {
    source ~/.zshrc
}

#[Esc][h] man 当前命令时，显示简短说明
alias run-help >&/dev/null && unalias run-help
autoload run-help

# -L 只追踪相对链接 -E 添加 html 后缀
alias sget='wget -m -k -E -p -np -e robots=off'
alias aria2rpc='aria2c --max-connection-per-server=8 --min-split-size=10M --enable-rpc --rpc-listen-all=true --rpc-allow-origin-all'
alias lo="lsof -nP -i"

function toggle-proxy {
    if [ -z $http_proxy ] || [ ! -z $1 ]; then
        local url=${1:-http://localhost:1081}
        echo "set proxy to $url"
        export http_proxy=$url
        export https_proxy=$url
        export no_proxy=localhost,127.0.0.0/8,*.local
    else
        echo "unset proxy"
        unset http_proxy
        unset https_proxy
        unset no_proxy
    fi
}

function toggle-git-proxy {
    if [ -z "$(git config --global --get http.proxy)" ] || [ ! -z $1 ]; then
        local url=${1:-http://localhost:1081}
        echo "set git proxy to $url"
        git config --global http.proxy $url
        git config --global https.proxy $url
    else
        echo "unset git proxy"
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    fi
}

#历史命令 top10
alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

function timeconv { date -d @$1 +"%Y-%m-%d %T" }

function sch {
    grep -rnw '.' -e $1
}

function runmd {
    local i
    for i in $*
        awk '/```/{f=0} f; /```bash/{f=1}' ${i} | /bin/bash -ex
}

# 查找大文件
function findBigFiles {
    find . -type f -size +$1 -print0 | xargs -0 du -h | sort -nr
}

function slam {
    local n=0
    until eval $*
    do
        n=$[$n+1]
        echo "$fg_bold[red]...$n...$reset_color $*"
        sleep 1
    done
}


####################
#### .zshrc.d/k8s
####################
if (( $+commands[kubectl] )); then
    export KUBECTL=${KUBECTL:-kubectl}
elif (( $+commands[k3s] )); then
    export KUBECTL=${KUBECTL:-k3s kubectl}
elif (( $+commands[microk8s.kubectl] )); then
    export KUBECTL=${KUBECTL:-microk8s.kubectl}
fi


if [ ! -z $KUBECTL ]; then
    if (( $+commands[$KUBECTL] )); then
        __KUBECTL_COMPLETION_FILE="${HOME}/.zsh_cache/kubectl_completion"

        if [[ ! -f $__KUBECTL_COMPLETION_FILE ]]; then
            mkdir -p ${HOME}/.zsh_cache
            eval $KUBECTL completion zsh >! $__KUBECTL_COMPLETION_FILE
        fi

        [[ -f $__KUBECTL_COMPLETION_FILE ]] && source $__KUBECTL_COMPLETION_FILE

        unset __KUBECTL_COMPLETION_FILE
    fi

    # This command is used a LOT both below and in daily life
    alias k=$KUBECTL
    alias kg="$KUBECTL get"
    alias kd="$KUBECTL describe"
    alias ke="$KUBECTL edit"
    alias kc="$KUBECTL create"

    # Apply a YML file
    alias kaf="$KUBECTL apply -f"
    # Apply resources from a directory containing kustomization.yaml
    alias kak="$KUBECTL apply -k"

    # Drop into an interactive terminal on a container
    alias keti="$KUBECTL exec -ti"
    alias kat="$KUBECTL exec -ti"

    # Manage configuration quickly to switch contexts between local, dev ad staging.
    alias kcuc="$KUBECTL config use-context"
    alias kcsc="$KUBECTL config set-context"
    alias kcdc="$KUBECTL config delete-context"
    alias kccc="$KUBECTL config current-context"

    # List all contexts
    alias kcgc="$KUBECTL config get-contexts"

    # General aliases
    alias kdel="$KUBECTL delete"
    alias kdelf="$KUBECTL delete -f"
    alias kdelk="$KUBECTL delete -k"

    # Pod management.
    alias kgp="$KUBECTL get pods"
    alias kgpw="kgp --watch"
    alias kgpwide="kgp -o wide"
    alias kep="$KUBECTL edit pods"
    alias kdp="$KUBECTL describe pods"
    alias kdelp="$KUBECTL delete pods"

    # get pod by label: kgpl "app=myapp" -n myns
    alias kgpl="kgp -l"

    # Service management.
    alias kgs="$KUBECTL get svc"
    alias kgsw="kgs --watch"
    alias kgswide="kgs -o wide"
    alias kes="$KUBECTL edit svc"
    alias kds="$KUBECTL describe svc"
    alias kdels="$KUBECTL delete svc"

    # Ingress management
    alias kgi="$KUBECTL get ingress"
    alias kei="$KUBECTL edit ingress"
    alias kdi="$KUBECTL describe ingress"
    alias kdeli="$KUBECTL delete ingress"

    # Namespace management
    alias kgns="$KUBECTL get namespaces"
    alias kens="$KUBECTL edit namespace"
    alias kdns="$KUBECTL describe namespace"
    alias kcns="$KUBECTL create namespace"
    alias kdelns="$KUBECTL delete namespace"
    alias kcn="$KUBECTL config set-context \$($KUBECTL config current-context) --namespace"

    # ConfigMap management
    alias kgcm="$KUBECTL get configmaps"
    alias kecm="$KUBECTL edit configmap"
    alias kdcm="$KUBECTL describe configmap"
    alias kdelcm="$KUBECTL delete configmap"

    # Secret management
    alias kgsec="$KUBECTL get secret"
    alias kdsec="$KUBECTL describe secret"
    alias kdelsec="$KUBECTL delete secret"

    # Deployment management.
    alias kgd="$KUBECTL get deployment"
    alias kgdw="kgd --watch"
    alias kgdwide="kgd -o wide"
    alias ked="$KUBECTL edit deployment"
    alias kdd="$KUBECTL describe deployment"
    alias kdeld="$KUBECTL delete deployment"
    alias ksd="$KUBECTL scale deployment"
    alias krsd="$KUBECTL rollout status deployment"
    kres(){
        $KUBECTL set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
    }

    # Rollout management.
    alias kgrs="$KUBECTL get rs"
    alias krh="$KUBECTL rollout history"
    alias kru="$KUBECTL rollout undo"

    # Statefulset management.
    alias kgss="$KUBECTL get statefulset"
    alias kgssw="kgss --watch"
    alias kgsswide="kgss -o wide"
    alias kess="$KUBECTL edit statefulset"
    alias kdss="$KUBECTL describe statefulset"
    alias kdelss="$KUBECTL delete statefulset"
    alias ksss="$KUBECTL scale statefulset"
    alias krsss="$KUBECTL rollout status statefulset"

    # Port forwarding
    alias kpf="$KUBECTL port-forward"

    # Tools for accessing all information
    alias kga="$KUBECTL get all"
    alias kgaa="$KUBECTL get all --all-namespaces"

    # Logs
    alias kl="$KUBECTL logs"
    alias klf="$KUBECTL logs -f"

    # File copy
    alias kcp="$KUBECTL cp"

    # Node Management
    alias kgno="$KUBECTL get nodes"
    alias keno="$KUBECTL edit node"
    alias kdno="$KUBECTL describe node"
    alias kdelno="$KUBECTL delete node"

    # PVC management.
    alias kgpvc="$KUBECTL get pvc"
    alias kgpvcw="kgpvc --watch"
    alias kepvc="$KUBECTL edit pvc"
    alias kdpvc="$KUBECTL describe pvc"
    alias kdelpvc="$KUBECTL delete pvc"

    # top
    alias ktn="$KUBECTL top node"
    alias ktp="$KUBECTL top pod"

    if (( $+commands[helm] )); then
        __HELM_COMPLETION_FILE="${HOME}/.zsh_cache/helm_completion"

        if [[ ! -f $__HELM_COMPLETION_FILE ]]; then
            helm completion zsh >! $__HELM_COMPLETION_FILE
        fi

        [[ -f $__HELM_COMPLETION_FILE ]] && source $__HELM_COMPLETION_FILE

        unset __HELM_COMPLETION_FILE
    fi


#!/bin/zsh

# Kubernetes prompt helper for bash/zsh
# ported to oh-my-zsh
# Displays current context and namespace

# Copyright 2018 Jon Mosco
#
#  Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Debug
[[ -n $DEBUG ]] && set -x

setopt PROMPT_SUBST
zmodload zsh/stat
zmodload zsh/datetime

# Default values for the prompt
# Override these values in ~/.zshrc
KUBE_PS1_BINARY="${KUBECTL:-kubectl}"
KUBE_PS1_SYMBOL_ENABLE="${KUBE_PS1_SYMBOL_ENABLE:-true}"
KUBE_PS1_SYMBOL_DEFAULT="${KUBE_PS1_SYMBOL_DEFAULT:-\u2388 }"
KUBE_PS1_SYMBOL_USE_IMG="${KUBE_PS1_SYMBOL_USE_IMG:-false}"
KUBE_PS1_NS_ENABLE="${KUBE_PS1_NS_ENABLE:-true}"
KUBE_PS1_SEPARATOR="${KUBE_PS1_SEPARATOR-|}"
KUBE_PS1_DIVIDER="${KUBE_PS1_DIVIDER-:}"
KUBE_PS1_PREFIX="${KUBE_PS1_PREFIX-(}"
KUBE_PS1_SUFFIX="${KUBE_PS1_SUFFIX-)}"
KUBE_PS1_LAST_TIME=0
KUBE_PS1_ENABLED=true

KUBE_PS1_COLOR_SYMBOL="%{$fg[blue]%}"
KUBE_PS1_COLOR_CONTEXT="%{$fg[gray]%}"
KUBE_PS1_COLOR_NS="%{$fg_bold[default]%}"

_kube_ps1_binary_check() {
  command -v "$1" >/dev/null
}

_kube_ps1_symbol() {
  [[ "${KUBE_PS1_SYMBOL_ENABLE}" == false ]] && return

  KUBE_PS1_SYMBOL="${KUBE_PS1_SYMBOL_DEFAULT}"
  KUBE_PS1_SYMBOL_IMG="\u2638 "

  if [[ "${KUBE_PS1_SYMBOL_USE_IMG}" == true ]]; then
    KUBE_PS1_SYMBOL="${KUBE_PS1_SYMBOL_IMG}"
  fi

  echo "${KUBE_PS1_SYMBOL}"
}

_kube_ps1_split() {
  type setopt >/dev/null 2>&1 && setopt SH_WORD_SPLIT
  local IFS=$1
  echo $2
}

_kube_ps1_file_newer_than() {
  local mtime
  local file=$1
  local check_time=$2

  zmodload -e "zsh/stat"
  if [[ "$?" -eq 0 ]]; then
    mtime=$(stat +mtime "${file}")
  elif stat -c "%s" /dev/null &> /dev/null; then
    # GNU stat
    mtime=$(stat -c %Y "${file}")
  else
    # BSD stat
    mtime=$(stat -f %m "$file")
  fi

  [[ "${mtime}" -gt "${check_time}" ]]
}

_kube_ps1_update_cache() {
  KUBECONFIG="${KUBECONFIG:=$HOME/.kube/config}"
  if ! _kube_ps1_binary_check "${KUBE_PS1_BINARY}"; then
    # No ability to fetch context/namespace; display N/A.
    KUBE_PS1_CONTEXT="BINARY-N/A"
    KUBE_PS1_NAMESPACE="N/A"
    return
  fi

  if [[ "${KUBECONFIG}" != "${KUBE_PS1_KUBECONFIG_CACHE}" ]]; then
    # User changed KUBECONFIG; unconditionally refetch.
    KUBE_PS1_KUBECONFIG_CACHE=${KUBECONFIG}
    _kube_ps1_get_context_ns
    return
  fi

  # kubectl will read the environment variable $KUBECONFIG
  # otherwise set it to ~/.kube/config
  local conf
  for conf in $(_kube_ps1_split : "${KUBECONFIG:-${HOME}/.kube/config}"); do
    [[ -r "${conf}" ]] || continue
    if _kube_ps1_file_newer_than "${conf}" "${KUBE_PS1_LAST_TIME}"; then
      _kube_ps1_get_context_ns
      update_ps1
      return
    fi
  done
}

_kube_ps1_get_context_ns() {

  # Set the command time
  KUBE_PS1_LAST_TIME=$EPOCHSECONDS

  KUBE_PS1_CONTEXT="$(${KUBE_PS1_BINARY} config current-context 2>/dev/null)"
  if [[ -z "${KUBE_PS1_CONTEXT}" ]]; then
    KUBE_PS1_CONTEXT="N/A"
    KUBE_PS1_NAMESPACE="N/A"
    return
  elif [[ "${KUBE_PS1_NS_ENABLE}" == true ]]; then
    KUBE_PS1_NAMESPACE="$(${KUBE_PS1_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    # Set namespace to 'default' if it is not defined
    KUBE_PS1_NAMESPACE="${KUBE_PS1_NAMESPACE:-default}"
  fi
}

# function to disable the prompt on the current shell
kubeon(){
  KUBE_PS1_ENABLED=true
}

# function to disable the prompt on the current shell
kubeoff(){
  KUBE_PS1_ENABLED=false
}

# Build our prompt
kube_ps1 () {
  local reset_color="%{$reset_color%}"
  [[ ${KUBE_PS1_ENABLED} != 'true' ]] && return

  KUBE_PS1="${reset_color}"
  KUBE_PS1+="${KUBE_PS1_COLOR_SYMBOL}$(_kube_ps1_symbol)"
  KUBE_PS1+="${reset_color}$KUBE_PS1_SEPERATOR"
  KUBE_PS1+="${KUBE_PS1_COLOR_CONTEXT}$KUBE_PS1_CONTEXT${reset_color}"
  KUBE_PS1+="$KUBE_PS1_DIVIDER"
  KUBE_PS1+="${KUBE_PS1_COLOR_NS}$KUBE_PS1_NAMESPACE${reset_color}"
  KUBE_PS1+=""

  echo "${KUBE_PS1}"
}

_PS1_KUBE=""
function update_ps1 {
    _PS1_KUBE="$(kube_ps1) "
}

_kube_ps1_update_cache
update_ps1

autoload -U add-zsh-hook
add-zsh-hook precmd _kube_ps1_update_cache

    export KUBE_EDITOR=vim

    if (( $+commands[k3d] )); then
        export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
    elif (( $+commands[k3s] )); then
        export KUBECONFIG=~/.local/etc/rancher/k3s/k3s.yaml
        # sudo k3s server --docker --no-deploy traefik
    fi

    if [[ ! "$PATH" == */opt/cni/bin* && -d /opt/cni/bin ]]; then
        export PATH=/opt/cni/bin:$PATH
    fi

    function clean-evicted-pod {
        $KUBECTL get pods --all-namespaces -ojson \
          | jq -r '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | .metadata.name + " " + .metadata.namespace' \
          | xargs -n2 -l bash -c "$KUBECTL delete pods \$0 --namespace=\$1"
    }

fi