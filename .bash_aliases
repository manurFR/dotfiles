### Emmanuel Bizieau 06/02/2023 ###

DISTRO="`uname` `lsb_release -d 2>/dev/null | cut -f2`"
echo "[EB] sourcing .bash_aliases [${DISTRO%% }]"

alias ba="vim ~/.bash_aliases && source ~/.bash_aliases"

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
alias topo='git topo-log'
alias gll='git limit-log'
alias gpr='git pull --rebase'
alias stash='git stash save'
alias pop='git stash pop'

alias gcam="git commit -am"
alias gcm="git commit -m"
alias prune="git remote prune origin"

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

# Windows Terminal
alias c="cd /mnt/c"
alias d="cd /mnt/d"
alias actions="echo '╔════ Windows Terminal ═════════════════════════════════════════════════════════════════════════════════════════════════════╗';\
			         echo '║ Onglets > Nouveau: Ctrl+Maj+t | Changer vers N: Ctrl+Alt+N (chiffres du haut) | Prochain/Précédent: Ctrl+Flèche           ║';\
			         echo '║ Volets  > Vert.: Alt+Maj+[+] | Horiz.: Alt+Maj+[-] | Dépl. vers: Alt+Flèche | Redim.: Alt+Maj+Flèche | Fermer: Ctrl+Maj+w ║';\
			         echo '╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝'"
actions

# specifique Ubuntu WSL2
if [[ "${DISTRO}" == *"Ubuntu"* ]]; then
	export UBUNTU="true"
  export HOME_UBUNTU="/home/$(whoami)"
  # openssh requiert des fichiers en "chmod 600" ce qui est impossible sur le drive Windows - j'ai fait une copie de .ssh dans le drive Ubuntu pour ça, 
	#  mais du coup cette copie n'est pas dans $HOME, et il faut forcer son utilisation explicitement
	alias ssh="ssh -F $HOME_UBUNTU/.ssh/config -i $HOME_UBUNTU/.ssh/id_rsa"
  
  # LS_COLORS : on change les "other writable" (clé "ow") pour + de visibilité des "ls" car WSL classe les répertoires sous cette catégorie au lieu de "di"
  LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=01;34:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
	export LS_COLORS
  
  alias explorer="explorer.exe ." # ouvrir un explorer directement dans le HOME Ubuntu
  
  # Orange only
  alias vpnkit="sudo service wsl2-vpnkit stop; sudo service wsl2-vpnkit start"
  sudo service wsl-vpnkit status 2>&1 | grep "not running" > /dev/null && sudo service wsl-vpnkit start
  
fi
