#!/usr/bin/env bash
# Global git configuration: handy aliases and sensible defaults.
# Run once: ./git-setup.sh
set -e

# Fuzzy-checkout a branch (local or remote) via fzf
git config --global alias.ch '!git checkout $(git branch --all | fzf | tr -d "[:space:]")'

# Pretty, colored commit graph
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Automatically set up the remote tracking branch on first push
git config --global push.autoSetupRemote true

# Amend the last commit without editing its message
git config --global alias.amend "commit --amend --no-edit"
