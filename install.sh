#! /bin/sh

cp com.amethyst.Amethyst.plist ~/Library/Preferences/com.amethyst.Amethyst.plist
cp spacehammer.fnl ~/.spacehammer/config.fnl
cp ~/.gitconfig ~/.gitconfig


#######################################################################
echo "Installing Vim Config"
#######################################################################

cd vim

TIME=`date +%s`
echo "backing up"
mv ~/.vim ~/.vim-$TIME
mv ~/.vimrc ~/.vimrc-$TIME
mv ~/.gvimrc ~/.gvimrc-$TIME

echo "linking .vimrc and .gvimrc"
ln -s `pwd` ~/.vim
ln -s `pwd`/vimrc ~/.vimrc
ln -s `pwd`/gvimrc ~/.gvimrc

echo "installing vim-plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "installing packages"
vim -T dumb +PlugInstall! +PlugClean! +qall -

cd ..

