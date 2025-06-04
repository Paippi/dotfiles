#!/bin/sh
PATH_TO_COC=$HOME/.vim/bundle/coc.nvim
npm --prefix $PATH_TO_COC ci $PATH_TO_COC
vim -c ':CocUpdate' -c 'qa!'
