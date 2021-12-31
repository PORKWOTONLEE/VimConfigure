#!/bin/bash
HOME="/home/ben"
SCRIPT_ROOT=`pwd`
SRC_DIR=${SCRIPT_ROOT}/src
CACHE_DIR=${SRC_DIR}/cache

# 创建Vim的文件夹
function CreatVimDir()
{
    # 创建.vim文件夹
    if [ ! -d "${HOME}/.vim/" ]
    then 
        mkdir ${HOME}/.vim > /dev/null 2>&1
    fi

    # 创建autoload文件夹
    if [ ! -d "${HOME}/.vim/autoload/" ]
    then 
        mkdir ${HOME}/.vim/autoload > /dev/null 2>&1
    fi

    if [ -d "${HOME}/.vim/autoload/" -a -d "${HOME}/.vim/" ]
    then
        echo -e "：成功"
    else
        echo -e "：失败"
    fi
}

# SSHKEY确认
function SSHKEYConfirm()
{
    read IsSSHKEYReady
    if [ ${IsSSHKEYReady} != "Y" ]
    then
        exit 1
    fi
}

# 命令/模块是否存在
function AutoInstallMod()
{
    if type $1 > /dev/null 2>&1
    then
        echo "：已存在，无需安装"
    else
        Command="apt"
        CommandFlag="-y"
        Mod=$1
        ModFlag=""
        # 若是npm模块，添加-g参数
        if [ $1 == "n" -o $1 == "yarn" ]
        then
            Command="npm"
            ModFlag="-g"
            CommandFlag=""
        fi

        # 如存在备用参数，使用备用参数
        if [ $# -eq 2 ]
        then
            Mod=$2
        fi
        sudo ${Command} ${CommandFlag} install ${ModFlag} ${Mod} > /dev/null 2>&1

        # 若是n模块，更新到最新
        if [ $1 == "n" ]
        then
            sudo n latest > /dev/null 2>&1
        fi

        # 判断是否安装成功
        if type $1 > /dev/null 2>&1
        then
            echo -e "：成功"
        else
            echo -e "：失败"
        fi
    fi
}

# 安装最新Ctags
function AutoInstallCtags()
{
    if type ctags > /dev/null 2>&1
    then
        echo -e "：已存在，是否要更新[Y/N]\c"
        read IsCtagsUpdate
        if [ ${IsCtagsUpdate} == "Y" ]
        then
            cd ${CACHE_DIR} > /dev/null 2>&1
            git clone https://github.com/universal-ctags/ctags.git > /dev/null 2>&1
            cd ctags > /dev/null 2>&1
            ./autogen.sh > /dev/null 2>&1
            ./configure > /dev/null 2>&1
            sudo make > /dev/null 2>&1
            sudo make install > /dev/null 2>&1
            if type ctags > /dev/null 2>&1
            then
                echo -e "：更新成功"
            else
                echo -e "：更新失败"
            fi
        fi
    else
        cd ${CACHE_DIR} > /dev/null 2>&1
        git clone git@github.com:universal-ctags/ctags.git > /dev/null 2>&1
        cd ctags > /dev/null 2>&1
        ./autogen.sh > /dev/null 2>&1
        ./configure > /dev/null 2>&1
        sudo make > /dev/null 2>&1
        sudo make install > /dev/null 2>&1
        if type ctags > /dev/null 2>&1
        then
            echo -e "：成功"
        else
            AutoInstallMod universal-ctags
        fi
    fi
}

# 预处理
echo -e "  │"
echo -e "  ├──(0/4)[预处理]"
echo -e "  │    ├──(1/4)[生成必要文件夹]\c"
CreatVimDir
echo -e "  │    ├──(2/4)[更新仓库]\c"
sudo apt update > /dev/null 2>&1
echo -e "：成功"
echo -e "  │    ├──(3/4)[添加GitHub到SSH已知服务器]\c"
ssh-keyscan www.github.com >> ${HOME}/.ssh/known_hosts > /dev/null 2>&1
echo -e "：成功"
echo -e "  │    └──(4/4)[配置GitHub-SSHKEY]\c"
if [ -f "${HOME}/.ssh/id_rsa.pub" ]
then
    echo -e "已配置，如出现问题，请重新配置"
else
    echo -e "\n  │         ├──(1/8)[请按下列步骤进行配置]"
    echo -e "  │         ├──(2/8)[打开另一个终端]"
    echo -e "  │         ├──(3/8)[输入sshkey-gen]"
    echo -e "  │         ├──(4/8)[连续输入回车]"
    echo -e "  │         ├──(5/8)[直到出现以下图样]"
    echo -e "  │         │   The key fingerprint is:"
    echo -e "  │         │   SHA256:*********************************"
    echo -e "  │         │   The key's randomart image is:"
    echo -e "  │         │   +---[RSA 3072]----+"
    echo -e "  │         │   |         .     + |"
    echo -e "  │         │   |         .*o=.Bo.|"
    echo -e "  │         │   |         =o. =o..|"
    echo -e "  │         │   |        o..  .o..|"
    echo -e "  │         │   |        S+ + =oo |"
    echo -e "  │         │   |        = = * =.o|"
    echo -e "  │         │   |       o o + o o.|"
    echo -e "  │         │   |      .oo        |"
    echo -e "  │         │   |    .o+=o        |"
    echo -e "  │         │   +----[SHA256]-----+"
    echo -e "  │         ├──(6/8)[输入cat ~/.ssh/id_rsa.pub]"
    echo -e "  │         ├──(7/8)[将出现的代码复制到GitHub，并确认]"
    echo -e "  │         └──(8/8)[是否完成以上操作Y/N]\c"
    SSHKEYConfirm
fi
echo -e "  │ "

# 配置vimrc
echo -e "  ├──(1/4)[配置vim插件环境]"
echo -e "  │    ├──(1/3)[安装git]\c"
AutoInstallMod git
echo -e "  │    ├──(2/3)[配置coc.nvim依赖]"
echo -e "  │    │    ├──(1/5)[安装clangd]\c"
AutoInstallMod clangd 
echo -e "  │    │    ├──(2/5)[安装ripgrep]\c"
AutoInstallMod rg ripgrep
echo -e "  │    │    ├──(3/5)[安装npm]\c"
AutoInstallMod npm
echo -e "  │    │    ├──(4/5)[安装&升级n]\c"
AutoInstallMod n
echo -e "  │    │    └──(5/5)[安装yarn]\c"
AutoInstallMod yarn
echo -e "  │    └──(3/3)[配置Taglist依赖]"
echo -e "  │         ├──(1/4)[安装pkg-config]\c"
AutoInstallMod pkg-config
echo -e "  │         ├──(2/4)[安装autoconf]\c"
AutoInstallMod autoconf
echo -e "  │         ├──(3/4)[安装automake]\c"
AutoInstallMod automake
echo -e "  │         └──(4/4)[安装universal-ctags]\c"
AutoInstallCtags

# 配置vim插件
echo -e "  │" 
echo -e "  ├──(2/4)[配置vim插件]\c"
cp ${SRC_DIR}/plug.vim ${HOME}/.vim/autoload/ > /dev/null 2>&1
vim -c ":PlugInstall" ${SRC_DIR}/tips.md
vim -c ":CocInstall coc-clangd" ${SRC_DIR}/tips.md
echo -e "：成功"

# 配置vimrc
echo -e "  ├──(3/4)[配置vimrc]\c"
cp ${SRC_DIR}/vimrc ~/.vimrc > /dev/null 2>&1
if [ -f ${HOME}/.vimrc ]
then
    echo -e "：成功"
else
    echo -e "：失败"
fi 
echo -e "  │" 


# 清理缓存文件
echo -e "  │" 
echo -e "  ├──(4/4)[清理缓存文件]\c"
echo -e "：成功"
echo -e "  │"
sudo rm -rf ${SCRIPT_ROOT}/yarn.lock 
sudo rm -rf ${SCRIPT_ROOT}/node_modules
sudo rm -rf ${CACHE_DIR}/ctags

