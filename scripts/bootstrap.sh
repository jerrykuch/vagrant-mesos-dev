#!/bin/bash

set -e

BASE_DIR=$HOME
LOG_DIR=$BASE_DIR/logs

SCRIPTS_DIR=$BASE_DIR/scripts
SCRIPTS_OS_DIR=$SCRIPTS_DIR/os
SCRIPTS_APP_BUILD_SPECS_DIR=$SCRIPTS_DIR/app
SCRIPTS_UTIL_DIR=$SCRIPTS_DIR/util

APP_BUILD_SPECS=(docker zookeeper mesos)

PROCESSOR_ARCH=`uname -p`
OS_NAME=`uname -s`

pre_install() {
  check_platform
  create_log_dir
  source_deps
}

check_platform() {
  if [ "$OS_NAME" = Linux ] && [ "$PROCESSOR_ARCH" = x86_64 ]
  then
    if [ ! -f /etc/debian_version ]
    then
      echo "Unsupported linux distro"
      exit 1
    else
      source $SCRIPTS_OS_DIR/ubuntu-64.sh
    fi
  else
    echo "Unsupported OS"
    exit 1
  fi

  echo "Starting build for $OS_NAME on $PROCESSOR_ARCH"
}

create_log_dir() {
  if [ ! -d $LOG_DIR ]
  then
    echo "Creating app log dir"
    mkdir $LOG_DIR
  else
    echo "App log dir already exists, skipping"
  fi
}

source_deps() {
  if [ ! -f $SCRIPTS_UTIL_DIR/util.sh ]
  then
    echo "Could not source util script at: $SCRIPTS_UTIL_DIR/util.sh"
    exit 1
  fi

  source $SCRIPTS_UTIL_DIR/util.sh
}

install() {
  install_os_deps

  for i in ${APP_BUILD_SPECS[@]}; do
    if [ ! -f $SCRIPTS_APP_BUILD_SPECS_DIR/${i}.sh ]
    then
      echo "Could not source application file at: $SCRIPTS_APP_BUILD_SPECS_DIR/${i}.sh"
      exit 1
    else
      source $SCRIPTS_APP_BUILD_SPECS_DIR/${i}.sh
      install_${i}
    fi
  done
}

pre_install
install
