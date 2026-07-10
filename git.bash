#!/usr/bin/env bash
#######################################################
# GIT
#######################################################

# Fuzzy-checkout a branch (local or remote) via fzf
alias gitch='git checkout $(git branch --all | fzf | tr -d "[:space:]")'
