#!/bin/bash

# Script that provides shortcuts for handling dockerization.

PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

function print_help {
    echo -e "\n"\
        "Script that provides shortcuts for handling dockerization.\n\n"\
        "Usage: ./dockerize.sh [COMMAND]\n\n"\
        "Available commands:"\
        "attach: open a bash terminal on the app container.\n"\
        "help: show this help.\n"\
        "start: start development containers.\n"\
        "stop: stop development containers.\n"\
        "recreate: recrate all containers"
}

function do_recreate {
    # Go to repository root
    pushd PARENT_PATH > /dev/null 2>&1

    # Configure .env file
    ./utils/docker/configure-env.sh

    do_stop

    # Delete containers
    docker container rm sptam-devcontainer

    # Rebuild with --no-cache
    docker-compose -f ./utils/docker/docker-compose.yml build

    # Restore original directory
    popd > /dev/null 2>&1
}

function do_start {
    # Go to repository root
    pushd PARENT_PATH > /dev/null 2>&1

    # Configure .env file
    ./utils/docker/configure-env.sh

    # Up
    docker-compose -f ./utils/docker/docker-compose.yml up -d

    # Restore original directory
    popd > /dev/null 2>&1
}

function do_stop {
    # Go to repository root
    pushd PARENT_PATH > /dev/null 2>&1

    # Stop
    docker-compose -f ./utils/docker/docker-compose.yml stop

    # Restore original directory
    popd > /dev/null 2>&1
}

function do_attach {
    xhost +
    do_start
    docker exec -it -w ~/catkin_ws sptam-devcontainer bash
}

# Parse arguments
while [ "$1" != "" ]; do
    case "$1" in
        attach )    do_attach; exit 0;       ;;
        help )      print_help; exit 0;      ;;
        start )     do_start; exit 0;        ;;
        stop )      do_stop; exit 0;         ;;
        recreate )  do_recreate; exit 0;     ;;
    esac
    shift
done

print_help
