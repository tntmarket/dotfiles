#! /bin/sh

VIM_FOLDER=`dirname $0`

echo "restoring $VIM_FOLDER"

cp -rf $VIM_FOLDER ~/.vim
ln -sf ~/.vim/vimrc ~/.vimrc
ln -sf ~/.vim/gvimrc ~/.gvimrc
