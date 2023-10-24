#!/usr/bin/env bash

SUFFIX='_old'
DIRNAME=$(pwd)
echo $DIRNAME

NAME='xournalpp'
[ -d ~/.config/xournalpp ] && mv ~/.config/${NAME} ~/.config/${NAME}${SUFFIX}
ln -sf ${DIRNAME}/${NAME} ~/.config

NAME='.zshrc'
[ -f ~/${NAME} ] && mv ~/${NAME} ~/${NAME}${SUFFIX}
ln -sf ${DIRNAME}/${NAME} ~/${NAME}

NAME='.sh_aliases'
[ -f ~/${NAME} ] && mv ~/${NAME} ~/${NAME}${SUFFIX}
ln -sf ${DIRNAME}/${NAME} ~/${NAME}

NAME='.p10k.zsh'
[ -f ~/${NAME} ] && mv ~/${NAME} ~/${NAME}${SUFFIX}
ln -sf ${DIRNAME}/${NAME} ~/${NAME}