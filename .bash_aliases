### Emmanuel Bizieau 19/02/2021 ###

echo "[EB] sourcing .bash_aliases"

alias ba="vim ~/.bash_aliases && source ~/.bash_aliases"

# pour Windows Terminal
alias c="cd /mnt/c"
alias d="cd /mnt/d"
alias explorer="explorer.exe ." # ouvrir un explorer directement dans le HOME Ubuntu

# cd, ls, find, grep
alias l="ls -lhFGh --color"
alias ls="ls -FG --color"
alias ll="ls -laFGvh --color --group-directories-first"
alias f="find . -iname"
alias pgrep="ps aux | grep"
alias ..="cd .."
alias ...="cd .. ; cd .."
alias path='echo -e ${PATH//:/\\n}'
alias aliasg='alias | grep'
alias detect_crlf='find . -not -type d -exec file "{}" ";" | grep CRLF'

# taille des fichiers
alias size="du -hs * | sort -hr; printf '%0.s-' {1..35}; echo; du -hs | sed 's/\./[Total]/'"
alias df="df -kTh"
alias du="du -kh"

# git
alias gd='git diff -w HEAD'
alias st='git st'
alias t='svn info &> /dev/null ; if [ $? -eq 0 ]; then svn log -l 8 ; else git --no-pager topo-log -12 ; fi'
alias gpr='git pull --rebase'
alias stash='git stash save'
alias pop='git stash pop'

alias gcam="git commit -am"
alias gcm="git commit -m"

# maven
alias mci='mvn clean install'
alias mcid='mvn clean install -DskipTests'

# python
alias pip="python -m pip"
source ~/.venvwrapper

# rainbow !!!!!!
alias rainbow='yes "$(seq 231 -1 16)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'

# find then open in vim
fvi () { vim $(find . -iname "$1") ; }

# grep in word files (.doc uniquement et nécessite catdoc) - usage: docgrep <pattern> ["grep-options"]
docgrep() { find . -name "*.doc" | while read i; do catdoc "$i" | grep --label="$i" -H $2 "$1"; done }

# usage: $ sudobg <command to run in background>
sudobg() {
  sudo echo "Password entered"
  sudo $@ &
}

# Shows most used commands, cool script I got this from:
#    http://lifehacker.com/software/how-to/turbocharge-your-terminal-274317.php
alias profileme="history | awk '{print \$2}' | awk 'BEGIN{FS=\"|\"}{print \$1}' | sort | uniq -c | sort -n | tail -n 20 | sort -nr"

# Prompt (intégration de Git)
get_dir() {
    printf "%s" $(pwd | sed "s:$HOME:~:")
}

get_sha() {
    git rev-parse --short HEAD 2>/dev/null
}

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_DESCRIBE_STYLE="branch"
#export GIT_PS1_SHOWCOLORHINTS=1

GIT_PROMPT=`locate -l1 dotfiles/git-prompt.sh 2>/dev/null 2>/dev/null || find ~ -maxdepth 2 -iname git-prompt.sh`
source ${GIT_PROMPT}

function prompt {
    EXITSTATUS="$?"
    BULLET="●"

    if [ "${EXITSTATUS}" -eq 0 ]
    then
        STATUS="${GREEN}${BULLET}${OFF}"
    else
        STATUS="${RED}${BULLET}${OFF}"
    fi

    # Mise à jour de la title bar du Terminal
    case $TERM in
        xterm*)
            TITLEBAR='\[\033]0;\u@\h: \w\007\]'
            ;;
        *)
            TITLEBAR=''
            ;;
    esac

    RED="\[\033[0;31m\]"
    BLUE="\[\e[34m\]"
    GREEN="\[\e[0;32m\]"
    PURPLE="\[\e[0;35m\]"
    OFF="\[\033[m\]"

    BOLD="\[\033[1m\]"

    PRE_NAME="\u"
    # est-on dans docker ?
    if [[ -f /proc/self/cgroup ]]
    then
        if [[ `awk -F/ '$2 == "docker"' /proc/self/cgroup` ]]
        then
            PRE_NAME="${PRE_NAME}@docker"
        fi
    fi

    PRE_GIT="${TITLEBAR}${PRE_NAME}> [${RED}${BOLD}\t${OFF}] ${BLUE}\w${OFF} "
    GIT="$(__git_ps1 '[%s] ')"
    if [[ $VIRTUAL_ENV != "" ]]
    then
        VENV="${PURPLE}#${VIRTUAL_ENV##*/} "
    else
        VENV=""
    fi

    PS1="${PRE_GIT}${GREEN}${GIT}${OFF}${VENV}${STATUS} \$ "
}
PROMPT_COMMAND=prompt

# archive extraction
extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       rar x $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
alias xt=extract

# 'up' = cd .. | 'up 4' = cd ../../../..
up(){
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

function ask()          # See 'killps' for example of use.
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

function killps()   # kill by process name
{
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var' var=$pid | cut -d' ' -f 11- )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}

function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}

function ii()   # Get current host related info.
{
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
    echo -e "\n${BRed}Users logged on:$NC " ; w -hs |
             cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC " ; date
    echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; free
    echo -e "\n${BRed}Diskspace :$NC " ; mydf / $HOME
    echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
    echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}


function bytesToHuman() { # convert 2048 to "2.00 K" etc.
    if (( ${#} == 0 )); then # piped input
        read b
    else
        b=$1
    fi
    b=${b:-0}; d=''; s=0; S=(Bytes {K,M,G,T,P,E,Z,Y})
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        let s++
    done
    echo "$b$d ${S[$s]}"
}

ts2date() {
    ts=$1
    millis=""
    if [ ${#ts} -gt 10 ]; then  # timestamp avec millisecondes, que l'on retire
        length=${#ts}
        newlength=$(expr ${length} - 3)
        millis=".${ts:$newlength:$length}"
        ts=${ts:0:$newlength}
    fi
    date +"%Y-%m-%d %H:%M:%S${millis}" -d@${ts}
}
