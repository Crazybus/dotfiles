#!/bin/bash

function symlink() {
    source=$PWD/$1
    dest=$2
    echo Linking $source to $dest
    ln -s -f $source $dest
    ls -l $dest
}

symlink prompt_crazybus_setup ~/.zprezto/modules/prompt/functions/prompt_crazybus_setup
symlink gitconfig ~/.gitconfig
symlink slate ~/.slate
symlink zshrc ~/.zshrc
symlink zshrcfunctions ~/.zshrcfunctions
symlink bin ~/bin
symlink vimrc ~/.vimrc
symlink kube-aliases.sh ~/.kube-aliases.sh
