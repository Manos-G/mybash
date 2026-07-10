# Custom Commands Reference

A complete list of the aliases and functions defined by this configuration,
grouped by the module they live in.

> **Note:** `la` is defined twice. `ros2.bash` is sourced last, so `la` ends up
> meaning **`ros2 launch`**, overriding the directory-listing `la`.

---

## Navigation (`aliases.bash`)

| Command | Does |
| --- | --- |
| `home` | `cd ~` |
| `..` | Go up one directory |
| `...` | Go up two directories |
| `....` | Go up three directories |
| `.....` | Go up four directories |
| `cd..` | Fix the common `cd..` typo (`cd ..`) |
| `bd` | Go back to the previous directory (`cd "$OLDPWD"`) |
| `web` | `cd /var/www/html` |
| `cd [dir]` | Change directory **and auto-list** it with eza (function) |
| `up <n>` | Go up `<n>` directories (e.g. `up 4`) |
| `cpg <file> <dir>` | Copy a file, then `cd` into the destination |
| `mvg <file> <dir>` | Move a file, then `cd` into the destination |
| `mkdirg <dir>` | Make a directory, then `cd` into it |
| `pwdtail` | Print the last two components of the working directory |

## Listing — eza-backed (`aliases.bash`)

Falls back to plain `ls` (with equivalent flags) if `eza` is not installed.

| Command | Does |
| --- | --- |
| `ls` | eza with colors, icons, directories first |
| `la` | Show hidden files *(but see the note above — `la` is `ros2 launch`)* |
| `ll` / `lla` | Long listing, all files |
| `las` | Hidden files (excluding `.` and `..`) |
| `lls` | Long listing |
| `lx` | Sort by extension |
| `lk` | Sort by size |
| `lc` | Sort by change time |
| `lu` | Sort by access time |
| `lt` | Sort by modification date |
| `labc` | Alphabetical sort |
| `lr` | Recursive listing |
| `lw` | Wide (grid across) format |
| `lm` | Piped through `more` |
| `lf` | Files only |
| `ldir` | Directories only |

## File Operations & Safety (`aliases.bash`)

| Command | Does |
| --- | --- |
| `cp` | `cp -i` (confirm before overwrite) |
| `mv` | `mv -i` (confirm before overwrite) |
| `rm` | `trash -v` (move to trash instead of deleting) |
| `rmd` | Force-remove a directory recursively |
| `mkdir` | `mkdir -p` (create parent dirs) |
| `cat` | `bat` / `batcat` (syntax-highlighted cat) |
| `extract <archive...>` | Extract almost any archive type (function) |
| `cpp <src> <dst>` | Copy a file with a progress bar (function) |
| `trim` | Trim leading/trailing whitespace (function, for scripts) |

## Archives (`aliases.bash`)

| Command | Does |
| --- | --- |
| `mktar` / `mkbz2` / `mkgz` | Create `.tar` / `.tar.bz2` / `.tar.gz` |
| `untar` / `unbz2` / `ungz` | Extract `.tar` / `.tar.bz2` / `.tar.gz` |

## Search (`aliases.bash`, `history.bash`, `functions.bash`)

| Command | Does |
| --- | --- |
| `grep` | `rg` (ripgrep) when installed |
| `h <text>` | Search command history |
| `p <text>` | Search running processes |
| `f <text>` | Find files in the current folder |
| `ftext <text>` | Search *inside* files recursively (function) |
| `countfiles` | Count files, links, and directories in the current folder |
| `checkcommand <name>` | Show whether a name is an alias, file, or builtin |

## Permissions (`aliases.bash`)

| Command | Does |
| --- | --- |
| `mx` | `chmod a+x` (make executable) |
| `000` `644` `666` `755` `777` | `chmod -R` to that mode |

## System Info & Monitoring (`aliases.bash`, `functions.bash`)

| Command | Does |
| --- | --- |
| `top` | `btop` (modern resource monitor) |
| `topcpu` | Top 10 processes by CPU |
| `diskspace` | Disk usage, sorted |
| `folders` | Size of folders one level deep |
| `folderssort` | Folders sorted by size |
| `mountedinfo` | Mounted filesystem info (`df -hT`) |
| `openports` | Show open ports |
| `tree` | Pretty directory tree |
| `treed` | Directory tree, directories only |
| `logs` | Tail all text logs in `/var/log` |
| `distribution` | Detect the Linux distribution (function) |
| `ver` | Show the OS version (function) |
| `ver`/`distribution` | Used internally by `install_bashrc_support` |

## Networking (`aliases.bash`, `functions.bash`)

| Command | Does |
| --- | --- |
| `whatismyip` / `whatsmyip` | Show internal and external IP addresses |

## Editors (`aliases.bash`)

| Command | Does |
| --- | --- |
| `vi` / `vim` | `nvim` |
| `vis` | `nvim "+set si"` |
| `svi` | `sudo vi` |
| `spico` / `snano` | `sudo pico` / `sudo nano` |
| `ebrc` | Edit `~/.bashrc` |
| `hlp` | Show `~/.bashrc_help` |

## Terminal Tools (`aliases.bash`, `functions.bash`)

| Command | Does |
| --- | --- |
| `zz` | Launch `zellij` (terminal multiplexer) |
| `yz` | Launch `yazi` file manager; `cd`s to its last dir on quit (function) |
| `kssh` | `kitty +kitten ssh` (kitty features over SSH) |
| `clickpaste` | Type the clipboard contents after a 3s delay |
| `alert` | Desktop notification when a long command finishes |
| `da` | Print a formatted date/time |
| `docker-clean` | Prune docker containers, images, networks, and volumes |
| `sha1 <file>` | SHA1 checksum |
| `hb <file>` | Upload a file to a hastebin paste (function) |

## Git (`git.bash`, `git-setup.sh`)

| Command | Does |
| --- | --- |
| `gitch` | Fuzzy-checkout a branch with `fzf` (shell alias) |
| `gcom "msg"` | `git add .` + commit (function) |
| `lazyg "msg"` | `git add .` + commit + push (function) |

After running `./git-setup.sh` once, these **git subcommands** are also available globally:

| Command | Does |
| --- | --- |
| `git ch` | Fuzzy-checkout a branch with `fzf` |
| `git lg` | Pretty, colored commit graph log |
| `git amend` | Amend the last commit without editing its message |
| *(config)* | `push.autoSetupRemote true` — auto-track the remote on first push |

## ROS 2 (`ros2.bash`)

| Command | Does |
| --- | --- |
| `si` | `source install/setup.bash` (source the local workspace) |
| `so` | Source the ROS distro (`/opt/ros/$ROS_DISTRO/setup.bash`) |
| `cb` | `colcon build` |
| `cbs` | `colcon build --symlink-install` |
| `cbp <pkg>` | `colcon build --packages-select` |
| `cbps <pkg>` | `colcon build --symlink-install --packages-select` |
| `cl` | Clean the workspace (`rm -rf install build log`) |
| `tl` | `ros2 topic list` |
| `te <topic>` | `ros2 topic echo` |
| `run` | `ros2 run` |
| `la` | `ros2 launch` |
| `killros` | Kill lingering ROS and Gazebo processes (function) |
| `rosid [id]` | Show or set `ROS_DOMAIN_ID` for the current shell (function) |

## Keybindings (`ui.bash`, `history.bash`)

| Key | Does |
| --- | --- |
| `Ctrl+f` | Launch `zi` (zoxide interactive directory jump) |
| `Ctrl+r` | fzf-powered history search |
| `Up` / `Down` | History search based on what you've already typed |
