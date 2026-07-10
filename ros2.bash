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
alias te='ros2 topic echo'

alias run='ros2 run'
alias la='ros2 launch'

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
