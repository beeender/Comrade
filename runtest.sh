#!/bin/bash
set -e

if [ -z "$1" ]; then
    TEST_CASE="test/*"
else
    TEST_CASE=$1
fi

nvim -Nu <(cat << EOF
filetype off
set rtp+=~/.config/nvim/plugged/deoplete.nvim
set rtp+=~/.config/nvim/plugged/vader.vim
set rtp+=.
filetype plugin indent on
syntax enable
EOF
) +Vader tests/*
