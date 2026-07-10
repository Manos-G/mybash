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

alias cl='rm -rf install build log'

alias tl='ros2 topic list'
alias te='ros2 topic echo'

alias run='ros2 run'
alias la='ros2 launch'

# Kill lingering ROS and Gazebo processes
killros() {
	ps aux | grep -E 'ros|gazebo' | grep -v grep | awk '{print $2}' | xargs -r kill -9
}

# Source the ros2 and setup variables
source /opt/ros/"$ROS_DISTRO"/setup.bash
source ~/common_ws/install/setup.bash
source ~/microros_ws/install/setup.bash

# Load the permanent ROS_DOMAIN_ID selected during setup
[ -f ~/.ros_domain_id ] && source ~/.ros_domain_id
