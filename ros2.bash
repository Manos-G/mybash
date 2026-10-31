#!/usr/bin/env bash
#######################################################
# ROS2
#######################################################

# ROS 2 distribution
export ROS_DISTRO=jazzy

# alias ros2 commands

alias si='source install/setup.bash'
alias so="source /opt/ros/$ROS_DISTRO/setup.bash"

alias cb='colcon build'
alias cbs='colcon build --symlink-install'
alias cbp='colcon build --packages-select'
alias cbps='colcon build --symlink-install --packages-select'

alias cl='rm -rf install build log'

alias tl='ros2 topic list'
alias te='rtop' #'ros2 topic echo'

alias run='ros2 run'
alias la='ros2 launch'

alias kr='killros'
alias rh='ros_help'

# Kill lingering ROS and Gazebo processes
killros() {
	ps aux | grep -E 'ros|gazebo' | grep -v grep | awk '{print $2}' | xargs -r kill -9
}

# Show or set ROS_DOMAIN_ID for the current shell
rosid() {
	if [ -z "$1" ]; then
		echo "Current ROS_DOMAIN_ID is: ${ROS_DOMAIN_ID:-0 (Default)}"
	else
		export ROS_DOMAIN_ID=$1
		echo "ROS_DOMAIN_ID set to $ROS_DOMAIN_ID"
	fi
}

# Source the ros2 distro and workspace overlays (only if they exist)
[ -f /opt/ros/"$ROS_DISTRO"/setup.bash ] && source /opt/ros/"$ROS_DISTRO"/setup.bash
[ -f ~/common_ws/install/setup.bash ] && source ~/common_ws/install/setup.bash
[ -f ~/microros_ws/install/setup.bash ] && source ~/microros_ws/install/setup.bash

# Load the permanent ROS_DOMAIN_ID selected during setup
[ -f ~/.ros_domain_id ] && source ~/.ros_domain_id

# Enable colcon_cd (required for the rpkg fzf function)
if [ -f /usr/share/colcon_cd/function/colcon_cd.sh ]; then
    source /usr/share/colcon_cd/function/colcon_cd.sh
    source /usr/share/colcon_cd/function/colcon_cd-argcomplete.bash
fi

# --- ROS 2 fzf Helpers ---

# Interactively measure topic publish rate (hz)
hz() {
  local topic=$(ros2 topic list | fzf --prompt="Topic Hz> " --height=40% --layout=reverse)
  if [ -n "$topic" ]; then
    echo "Measuring rate for $topic..."
    ros2 topic hz "$topic"
  fi
}

ti() {
  local topic=$(ros2 topic list | fzf --prompt="Topic Info> " --height=40% --layout=reverse)
  if [ -n "$topic" ]; then
    ros2 topic info "$topic"
  fi
}

# Interactively view service info
rservice() {
  local srv=$(ros2 service list | fzf --prompt="Service Info> " --height=40% --layout=reverse)
  if [ -n "$srv" ]; then
    ros2 service info "$srv"
  fi
}

# Interactively view action info
raction() {
  local act=$(ros2 action list | fzf --prompt="Action Info> " --height=40% --layout=reverse)
  if [ -n "$act" ]; then
    ros2 action info "$act"
  fi
}

# Interactively echo a topic
rtop() {
  local topic=$(ros2 topic list | fzf --prompt="Echo Topic> " --height=40% --layout=reverse)
  if [ -n "$topic" ]; then
    echo "Echoing $topic..."
    ros2 topic echo "$topic"
  fi
}

# Interactively view node info
rnode() {
  local node=$(ros2 node list | fzf --prompt="Node Info> " --height=40% --layout=reverse)
  if [ -n "$node" ]; then
    ros2 node info "$node"
  fi
}

# Interactively jump to a package directory (Requires colcon_cd)
rpkg() {
  local pkg=$(ros2 pkg list | fzf --prompt="Go to Package> " --height=40% --layout=reverse)
  if [ -n "$pkg" ]; then
    colcon_cd "$pkg"
  fi
}

rshow() {
  # We grep out the header lines and clean up the spaces so fzf gets a clean list
  local interface=$(ros2 interface list | grep -v -E "(Messages:|Services:|Actions:)" | sed '/^[[:space:]]*$/d' | awk '{$1=$1;print}' | fzf --prompt="Interface Show> " --height=40% --layout=reverse)
  if [ -n "$interface" ]; then
    ros2 interface show "$interface"
  fi
}

# Clean a specific locally built package using fzf
clb() {
  # First, check if we are actually in the root of a workspace
  if [ ! -d "build" ]; then
    echo "Error: No 'build/' directory found. Make sure you are in your workspace root."
    return 1
  fi

  # Force ls to output plain text to avoid ANSI color code corruption in fzf
  local pkg=$(ls -1 --color=never build | fzf --prompt="Clean Package> " --height=40% --layout=reverse)
  
  if [ -n "$pkg" ]; then
    echo "Cleaning build and install folders for: $pkg"
    rm -rf "build/$pkg" "install/$pkg"
    
    # Also clean the log folder for this package if it exists
    if [ -d "log/$pkg" ]; then
      rm -rf "log/$pkg"
    fi
    
    echo "Done."
  fi
}

# Interactively get a parameter value from a node
rparam() {
  local node=$(ros2 node list | fzf --prompt="Select Node> " --height=40% --layout=reverse)
  if [ -n "$node" ]; then
    local param=$(ros2 param list "$node" | fzf --prompt="Select Param ($node)> " --height=40% --layout=reverse)
    if [ -n "$param" ]; then
      ros2 param get "$node" "$param"
    fi
  fi
}

# Interactively select multiple topics to record (Use TAB to select multiple)
rbag() {
  local topics=$(ros2 topic list | fzf -m --prompt="Select Topics (TAB to multi-select)> " --height=40% --layout=reverse)
  if [ -n "$topics" ]; then
    # Convert multiline selection into a space-separated string
    local topic_list=$(echo "$topics" | tr '\n' ' ')
    echo "Starting rosbag record for: $topic_list"
    ros2 bag record $topic_list
  fi
}

# Interactively select a package and then an executable to run
rrun() {
  local pkg=$(ros2 pkg list | fzf --prompt="Run Package> " --height=40% --layout=reverse)
  if [ -n "$pkg" ]; then
    # Get all executables for the selected package
    local exec=$(ros2 pkg executables "$pkg" | awk '{print $2}' | fzf --prompt="Executable ($pkg)> " --height=40% --layout=reverse)
    if [ -n "$exec" ]; then
      echo "Running: ros2 run $pkg $exec"
      ros2 run "$pkg" "$exec"
    fi
  fi
}

# Interactively select a package and then a launch file
rlaunch() {
  local pkg=$(ros2 pkg list | fzf --prompt="Launch Package> " --height=40% --layout=reverse)
  if [ -n "$pkg" ]; then
    local pkg_share=$(ros2 pkg prefix "$pkg")/share/"$pkg"
    # Added -L to follow symlinks (crucial for --symlink-install workspaces)
    local launch_file=$(find -L "$pkg_share" -type f -iname "*launch*" -exec basename {} ';' 2>/dev/null | fzf --prompt="Launch File ($pkg)> " --height=40% --layout=reverse)
    if [ -n "$launch_file" ]; then
      echo "Launching: ros2 launch $pkg $launch_file"
      ros2 launch "$pkg" "$launch_file"
    fi
  fi
}

# Display a cheat sheet for all custom ROS 2 aliases and functions
ros_help() {
    _ros_help_row() { printf '  \e[1;36m%-8s\e[0m : %s\n' "$1" "$2"; }

    echo -e "\e[1;32mROS 2 Custom Toolkit Help\e[0m"

    echo -e "\n\e[1;34mWorkspace & Environment\e[0m"
    _ros_help_row "si" "Source local workspace (install/setup.bash)"
    _ros_help_row "so" "Source system ROS 2 install (/opt/ros/\$ROS_DISTRO/setup.bash)"
    _ros_help_row "rosid" "Show current ROS_DOMAIN_ID, or set it (e.g., 'rosid 5')"

    echo -e "\n\e[1;34mBuilding & Cleaning\e[0m"
    _ros_help_row "cb" "colcon build"
    _ros_help_row "cbs" "colcon build --symlink-install"
    _ros_help_row "cbp" "colcon build --packages-select <pkg>"
    _ros_help_row "cbps" "colcon build --symlink-install --packages-select <pkg>"
    _ros_help_row "cl" "Delete install, build, and log directories completely"
    _ros_help_row "clb" "Pick one package to clean from build/, install/ and log/"

    echo -e "\n\e[1;34mTopics (fzf)\e[0m"
    _ros_help_row "rtop" "Pick a topic and echo it"
    _ros_help_row "te" "Alias for rtop"
    _ros_help_row "ti" "Pick a topic and view its info"
    _ros_help_row "hz" "Pick a topic and measure its publish rate"
    _ros_help_row "rbag" "Pick topics (TAB for multiple) and record a bag"

    echo -e "\n\e[1;34mNodes, Services & Actions (fzf)\e[0m"
    _ros_help_row "rnode" "Pick a node and view its info"
    _ros_help_row "rparam" "Pick a node and parameter, then get its value"
    _ros_help_row "rservice" "Pick a service and view its info"
    _ros_help_row "raction" "Pick an action and view its info"
    _ros_help_row "rshow" "Pick a message/service/action and show its definition"

    echo -e "\n\e[1;34mPackages & Running (fzf)\e[0m"
    _ros_help_row "rpkg" "Pick a package and jump to its directory (colcon_cd)"
    _ros_help_row "rrun" "Pick a package and executable, then run it"
    _ros_help_row "rlaunch" "Pick a package and launch file, then launch it"

    echo -e "\n\e[1;34mUtilities\e[0m"
    _ros_help_row "tl" "ros2 topic list"
    _ros_help_row "run" "ros2 run"
    _ros_help_row "la" "ros2 launch"
    _ros_help_row "killros" "Force kill all ROS 2 and Gazebo processes"
    _ros_help_row "kr" "Alias for killros"
    _ros_help_row "ros_help" "Show this help"
    _ros_help_row "rh" "Alias for ros_help"
    echo ""

    unset -f _ros_help_row
}
