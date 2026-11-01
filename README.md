# Install my custom config

```bash
sudo apt update
sudo apt install fzf
```




## Cheat Sheet

Type `rh` for the ROS 2 commands or `hlp` for every command. A reminder prints
in each new terminal and whenever you enter a git repo. Commands marked "pick"
open an fzf list: type to filter, Enter to choose.

### ROS 2: inspect and debug

| Command | What it does |
| --- | --- |
| `te [topic]` | Echo the named topic, or pick one |
| `rtop` | Pick a topic and echo it |
| `tl` | List topics |
| `ti` | Pick a topic and show its info |
| `hz` | Pick a topic and measure its rate |
| `rbag` | Pick topics (TAB for several) and record a bag |
| `rnode` | Pick a node and show its info |
| `rparam` | Pick a node and parameter, then get its value |
| `rservice` | Pick a service and show its info |
| `raction` | Pick an action and show its info |
| `rshow` | Pick a message, service or action and show its definition |

### ROS 2: build and run

| Command | What it does |
| --- | --- |
| `cb` / `cbs` | `colcon build` / with `--symlink-install` |
| `cbp <pkg>` / `cbps <pkg>` | Build one package / with `--symlink-install` |
| `si` / `so` | Source the local workspace / the ROS distro |
| `cl` | Permanently delete `install`, `build` and `log` |
| `clb` | Pick one package and permanently delete its build output (run from the workspace root) |
| `run` / `la` | `ros2 run` / `ros2 launch` |
| `rrun` | Pick a package and executable, then run it |
| `rlaunch` | Pick a package and launch file, then launch it |
| `rpkg` | Pick a package and jump to its folder (needs `python3-colcon-cd`) |
| `rosid [id]` | Show or set `ROS_DOMAIN_ID` for this shell |
| `killros` / `kr` | Force kill ROS and Gazebo processes (matches anything with "ros" in its command line, so check first) |

### Everyday

| Command | What it does |
| --- | --- |
| `path` | Print the current path and copy it to the clipboard |
| `hlp` / `rh` | Print all commands / the ROS 2 commands |
| `z <name>` / `zi` / `Ctrl+f` | Jump to a frequent folder / pick one |
| `Ctrl+r` | Search command history with fzf |
| `up <n>` | Go up `n` directories |
| `extract <file>` | Unpack almost any archive |
| `gcom "msg"` / `lazyg "msg"` | Add and commit / add, commit and push |

## Custom Commands

See **[COMMANDS.md](COMMANDS.md)** for a full reference of every custom alias
and function (navigation, eza listing, git, ROS 2, and more).

## Overview of ChrisTitusTech's `.bashrc` Configuration

The `.bashrc` file is a script that runs every time a new terminal session is started in Unix-like operating systems. It is used to configure the shell session, set up aliases, define functions, and more, making the terminal easier to use and more powerful. Below is a summary of the key sections and functionalities defined in the provided `.bashrc` file.

## How to install
```
git clone --depth=1 https://github.com/ChrisTitusTech/mybash.git
cd mybash
chmod +x setup.sh
./setup.sh
```

### Initial Setup and System Checks

- **Environment Checks**: The script checks if it is running in an interactive mode and sets up the environment accordingly.
- **System Utilities**: It checks for the presence of utilities like `fastfetch`, `bash-completion`, and system-specific configurations (`/etc/bashrc`).

### Aliases and Functions

- **Aliases**: Shortcuts for common commands are set up to enhance productivity. For example, `alias cp='cp -i'` makes the `cp` command interactive, asking for confirmation before overwriting files.
- **Functions**: Custom functions for complex operations like `extract()` for extracting various archive types, and `cpp()` for copying files with a progress bar.

### Prompt Customization and History Management

- **Prompt Command**: The `PROMPT_COMMAND` variable is set to automatically save the command history after each command.
- **History Control**: Settings to manage the size of the history file and how duplicates are handled.

### System-Specific Aliases and Settings

- **Editor Settings**: Sets `nvim` (NeoVim) as the default editor.
- **Conditional Aliases**: Depending on the system type (like Fedora), it sets specific aliases, e.g., replacing `cat` with `bat`.

### Enhancements and Utilities

- **Color and Formatting**: Enhancements for command output readability using colors and formatting for tools like `ls`, `grep`, and `man`.
- **Navigation Shortcuts**: Aliases to simplify directory navigation, e.g., `alias ..='cd ..'` to go up one directory.
- **Safety Features**: Aliases for safer file operations, like using `trash` instead of `rm` for deleting files, to prevent accidental data loss.
- **Extensive Zoxide support**: Easily navigate with `z`, `zi`, or pressing Ctrl+f to launch zi to see frequently used navigation directories.

### Advanced Functions

- **System Information**: Functions to display system information like `distribution()` to identify the Linux distribution.
- **Networking Utilities**: Tools to check internal and external IP addresses.
- **Resource Monitoring**: Commands to monitor system resources like disk usage and open ports.

### Installation and Configuration Helpers

- **Auto-Install**: A function `install_bashrc_support()` to automatically install necessary utilities based on the system type.
- **Configuration Editors**: Functions to edit important configuration files directly, e.g., `apacheconfig()` for Apache server configurations.

### Conclusion

This `.bashrc` file is a comprehensive setup that not only enhances the shell experience with useful aliases and functions but also provides system-specific configurations and safety features to cater to different user needs and system types. It is designed to make the terminal more user-friendly, efficient, and powerful for an average user.

