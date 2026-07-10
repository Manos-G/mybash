#!/usr/bin/env bash
#######################################################
# ROS2
#######################################################

# alias ros2 commands

alias si='source install/setup.bash'
alias so='source /opt/ros/humble/setup.bash'

alias cb='colcon build'
alias cbs='colcon build --symlink-install'
alias cbp='colcon build --packages-select'

alias cl='rm -rf install build log'

alias tl='ros2 topic list'
alias te='ros2 topic echo'

alias run='ros2 run'
alias la='ros2 launch'

# Source the ros2 and setup variables
source /opt/ros/humble/setup.bash
source ~/common_ws/install/setup.bash
source ~/microros_ws/install/setup.bash

ROS_DISTRO=humble
