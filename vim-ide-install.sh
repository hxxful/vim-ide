#!/bin/bash

echo -e "
#######################VIM-IDE自动化脚本########################
说明: 
  一键定制化vim-ide, 在Ubuntu18.04上安装成功,其它平台暂未测试
  如果安装出现问题,用户可自行修改相关脚本命令
提示:
  \033[32m(1)vim要求8.0及以上哈，注意哦!!!\033[0m
  (2)从github获取YouCompleteMe源码及子模块较慢时，建议单独下载
  并放入到~/.vim/bundle/YouCompleteMe目录下
  (3)安装依赖工具较慢时,修改/etc/apt/sources.list里的镜像源地址
  为离你最近的镜像源，可极大提高软件包下载速的度，参考如下:
  清华大学: 记得选对版本哦！！！
  https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
作者:
  侯鲜薪 2019-9-29 13:00
################################################################
"

MSG_INFO="  \033[32m通知:\033[0m"
MSG_WARN="  \033[31m警告:\033[0m"
MSG_ERROR="  \033[31m错误:\033[0m"
	
USR_DIR="${HOME}"
CUR_DIR="$(pwd)"
echo "用户目录:${USR_DIR}"
echo "当前目录:${CUR_DIR}"

echo "1.安装Vundle"
if [ ! -d "${USR_DIR}/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else
    echo -e "${MSG_WARN}目录${USR_DIR}/.vim/bundle/Vundle.vim已存在，跳过安装Vundle"
fi

echo "2.安装YouCompleteMe"
echo "(1)---获取源码"
if [ ! -d "${USR_DIR}/.vim/bundle/YouCompleteMe" ]; then
    git clone https://github.com/Valloric/YouCompleteMe.git ${USR_DIR}/.vim/bundle/YouCompleteMe
    cd ${USR_DIR}/.vim/bundle/YouCompleteMe
    git submodule update --init --recursive
else
    echo -e "${MSG_WARN}目录${USR_DIR}/.vim/bundle/YouCompleteMe已存在,跳过YouCompleteMe源码获取"
fi

echo "(2)---安装依赖"
apt-get install ctags
apt-get install cmake
apt-get install libclang-8-dev
apt-get install libboost-all-dev
echo "(3)---创建编译临时生成目录"
cd ~
if [ ! -d ${USR_DIR}/ycm_build ]; then
    mkdir ycm_build
    cd ycm_build
    echo "(4)---编译源码(注:其中libclang-3.9.so的具体位置根据自己的实际情况修改设定)"
    cmake -G "Unix Makefiles" -DUSE_SYSTEM_BOOST=ON -DEXTERNAL_LIBCLANG_PATH=/usr/lib/x86_64-linux-gnu/libclang-8.so . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
    echo "(5)---开始构建"
    cmake --build . --target ycm_core --config Release
    echo "(6)---开始配置"
    cp ~/.vim/bundle/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py ~/.vim/
else
    echo -e "${MSG_WARN} 目录${USR_DIR}/ycm_build已存在，跳过YouCompleteMe源码编译安装"
	echo "(4)---编译源码 跳过"
	echo "(5)---开始构建 跳过"
	echo "(6)---开始配置 跳过"
fi

echo "(7)---安装Bear"
if [ ! -d ${USR_DIR}/ycm_build/Bear ]; then
    git clone https://github.com/hxxful/Bear
    cd Bear
    ./install.sh
else
    echo -e "${MSG_WARN} 目录${USR_DIR}/ycm_build/Bear，跳过Bear安装"
fi

echo "3.安装air-line字体"
if [ ! -f /usr/share/fonts/PowerlineSymbols.otf ]; then
    wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
	mv PowerlineSymbols.otf /usr/share/fonts/
else
    echo -e "${MSG_WARN} 字体文件/usr/share/fonts/PowerlineSymbols.otf已存在，跳过PowerlineSymbols.otf安装"
fi

if [ ! -f /etc/fonts/conf.d/10-powerline-symbols.conf ]; then
    wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
    mv 10-powerline-symbols.conf /etc/fonts/conf.d/
    fc-cache -vf /usr/share/fonts/
else
    echo -e "${MSG_WARN} 配置文件/etc/fonts/conf.d/10-powerline-symbols.conf已存在，跳过10-powerline-symbols.conf安装"
fi

echo "4.替换~/.vimrc文件"
cd ${CUR_DIR}
mv ~/.vimrc .vimrc_backup -f
cp vimrc ~/.vimrc

echo "5.请打开vim,在命令模式下输入命令:PluginInstall"

