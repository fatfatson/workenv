OS=$(uname)

function find_top_dir
{
    if [ -n "$top_dir" ]; then
        return 0
    fi

    this_dir=$(cd $(dirname $0) && pwd)
    target=$1
    while [ ! -d $target ]
    do
        cd ..
        if [ "`pwd`" == "/" ]; then 
            break 
        fi
    done

    if [ `pwd` == / ]; then
        echo "*** Can't find top_dir which contains $target ***"
        exit 1
    else
        top_dir=`pwd`
        export top_dir
        echo "*** top_dir found: $top_dir ***"
    fi
}
export -f find_top_dir


function check_and_run
{
	if [ -f $1 ]
   	then 
        source $1 
    fi
}

function iconvFile
{
    cf=gbk
    ct=utf8
    for i in $1; do iconv -f $cf -t $ct ${i} > ${i}.bak; mv ${i}.bak ${i}; done
}

#去掉文件每一行最后的0x0d
function trimd
{
    sed  -i "s/\r\$//g" $@
}

function adbs
{
    if [ x$1 == x ]; then
        adb devices | sed '1d'
        return
    fi
    dno=`expr $1 + 1`
    device="-s $(adb devices | sed -n $dno'p' | awk '{print $1}')"
    echo $dno $device
    shift
    adb $device $@
}
export -f adbs

function adbi
{
    if [ x$2 == x ]; then
        adb install -r $1
    else
        adbs $1 install -r $2
    fi
}

function geny
{
    if [ x$1 == x ]; then
        VBoxManage list vms
        return
    fi
    device=$(VBoxManage list vms | sed -n $1'p' | sed 's/\"\(.*\)\".*/\1/g')
    echo $device
    nohup ~/genymotion/player --vm-name "$device"&
}

function run_sshagent
{
    [ -z "$SSH_AUTH_SOCK" ] && eval $(ssh-agent -s)
    ssh-add
}

function run_goagent_tunnel
{
    autossh -M 0 -gN -L 9527:0.0.0.0:3128 -o ServerAliveInterval=60 goagent@xw.mmdai.org 2>/dev/null &
}

function tmsp
{
    tmux split $1 -c $PWD
}

function hkp_do
{
    http_proxy=http://127.0.0.1:9527 https_proxy=http://127.0.0.1:9527 $@
}

#############################################
if [ "$OS" == "Darwin" ] ;then


if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
alias ctags="`brew --prefix`/bin/ctags"
alias ls='ls -alG'
alias sed=gsed
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

#############################################
elif [ "$OS" == "Linux" ] ;then

alias api="sudo apt-get install"
alias aps="apt-cache search"
alias sudo='sudo '
alias ls='ls -al --color=auto'

#############################################
elif [[ $OS == CYGWIN* ]]; then
alias ls='ls -al --color=auto'
alias sudo=''
export CYGWIN="winsymlinks"
export JAVA_HOME="/cygdrive/c/Program Files (x86)/Java/jdk1.8.0_31"
export PATH=$PATH:"/cygdrive/c/Program Files (x86)/Java/jdk1.8.0_31/bin"
unset GIT_SSH

fi

#############################################

alias tmuxk='tmux kill-server'
alias tmuxa='tmux attach'
export PATH=/usr/local/sbin:/usr/local/bin/:$PATH
