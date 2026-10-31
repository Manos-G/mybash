#!/usr/bin/env bash
#######################################################
# ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Editor aliases
alias spico='sudo pico'
alias snano='sudo nano'
alias vim='nvim'

# Check if ripgrep is installed
if command -v rg &> /dev/null; then
    # Alias grep to rg if ripgrep is installed
    alias grep='rg'
else
    # Alias grep to /usr/bin/grep with GREP_OPTIONS if ripgrep is not installed
    alias grep="/usr/bin/grep $GREP_OPTIONS"
fi
unset GREP_OPTIONS

#######################################################
# MACHINE SPECIFIC ALIAS'S
#######################################################

# Alias's for SSH
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'

# Alias's to change the directory
alias web='cd /var/www/html'

# Alias's to mount ISO files
# mount -o loop /home/NAMEOFISO.iso /home/ISOMOUNTDIR/
# umount /home/NAMEOFISO.iso
# (Both commands done as root only.)

#######################################################
# GENERAL ALIAS'S
#######################################################

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Edit this .bashrc file
alias ebrc='edit ~/.bashrc'

# Show help for this .bashrc file
alias hlp='less ~/.bashrc_help'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'


# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Print the full path of the current directory
alias path='pwd'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands.
# Use eza (a modern ls) when available, otherwise fall back to plain ls.
# The l* aliases start with `ls`, which bash re-expands to the base
# command, so each one inherits the base options.
if command -v eza &> /dev/null; then
	alias ls='eza --color=always --group-directories-first --icons' # base: colors, icons, dirs first
	alias la='ls -a'                          # show hidden files
	alias ll='ls -la'                         # long listing, all files
	alias lla='ls -la'                        # long listing, all files
	alias las='ls -A'                         # hidden files (excluding . and ..)
	alias lls='ls -l'                         # long listing
	alias lx='ls -la --sort=extension'        # sort by extension
	alias lk='ls -la --sort=size --reverse'   # sort by size
	alias lc='ls -la --sort=changed --reverse'  # sort by change time
	alias lu='ls -la --sort=accessed --reverse' # sort by access time
	alias lt='ls -la --sort=modified --reverse' # sort by date
	alias labc='ls -la --sort=name'           # alphabetical sort
	alias lr='ls -la --recurse'               # recursive ls
	alias lw='ls --across'                    # wide (grid across) format
	alias lm='ls -la | more'                  # pipe through 'more'
	alias lf='ls -la --only-files'            # files only
	alias ldir='ls -la --only-dirs'           # directories only
else
	echo "eza is missing - falling back to ls (install it or run setup.sh)"
	alias la='ls -Alh'                # show hidden files
	alias ls='ls -aFh --color=always' # add colors and file type extensions
	alias lx='ls -lXBh'               # sort by extension
	alias lk='ls -lSrh'               # sort by size
	alias lc='ls -ltcrh'              # sort by change time
	alias lu='ls -lturh'              # sort by access time
	alias lr='ls -lRh'                # recursive ls
	alias lt='ls -ltrh'               # sort by date
	alias lm='ls -alh |more'          # pipe through 'more'
	alias lw='ls -xAh'                # wide listing format
	alias ll='ls -Fls'                # long listing format
	alias labc='ls -lap'              # alphabetical sort
	alias lf="ls -l | egrep -v '^d'"  # files only
	alias ldir="ls -l | egrep '^d'"   # directories only
	alias lla='ls -Al'                # List and Hidden Files
	alias las='ls -A'                 # Hidden Files
	alias lls='ls -l'                 # List
fi

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Use btop as the system monitor
alias top='btop'

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'

alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

# KITTY - alias to be able to use kitty features when connecting to remote servers(e.g use tmux on remote server)

alias kssh="kitty +kitten ssh"

# Zellij terminal multiplexer
alias zz='zellij'

# alias to cleanup unused docker containers, images, networks, and volumes

alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '

# Use bat as a colorized cat replacement (binary name differs by distro)
DISTRIBUTION=$(distribution)
if [ "$DISTRIBUTION" = "redhat" ] || [ "$DISTRIBUTION" = "arch" ]; then
      alias cat='bat'
else
      alias cat='batcat'
fi

# IP address lookup
alias whatismyip="whatsmyip"

alias hug="hugo server -F --bind=10.0.0.97 --baseURL=http://10.0.0.97"
