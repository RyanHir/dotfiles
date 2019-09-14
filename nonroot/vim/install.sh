#! /bin/sh

cp config ~/.vimrc

if [ ! -d ~/.vim/pack/plugins/start/lightline ]
then
git clone https://github.com/itchyny/lightline.vim ~/.vim/pack/plugins/start/lightline
fi
