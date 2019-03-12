#!/bin/bash

set -e

nvim -Nu <(cat << EOF
filetype off
set rtp+=~/.config/nvim/plugged/deoplete.nvim
set rtp+=~/.config/nvim/plugged/vader.vim
set rtp+=.
filetype plugin indent on
syntax enable
EOF
) +Vader tests/*
