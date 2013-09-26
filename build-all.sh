#!/bin/sh

# Script builds all packets

# ---- VARIABLES ----

cur_dir=$(pwd)
opt="" # option for each ./build.sh execution
msg="" # message that shows before each action

# Packets available for building
packets="\
instead \
instead-game-cat \
instead-game-lines \
instead-game-toilet3in1"

# ---- FUNCTIONS ----

print_usage() {
    echo "Usage: $0 <option>"
    echo
    echo "OPTIONS:"
    echo "-c  | --clean      -  clean built files"
    echo "-dc | --distclean  -  clean built files and result packets"
    echo "-b  | --build      -  Build all available packets"
    echo "-a  | --all        -  The same as \"--build\""
    echo "-l  | --list       -  Print list of packets to be built with \"-b\" option"
    echo "-h  | --help       -  This help"
}

process_all() {
    for f in $packets; do
        echo "<<<<<<<< $msg $f >>>>>>>>"
        cd $f/src
        ./build.sh $opt
        cd $cur_dir
    done
}

# ---- ENTRY POINT ----

case "$1" in
    "-c"|"--clean")
        opt=--clean
        msg=Cleaning
        ;;
    "-dc"|"--distclean")
        opt=--distclean
        msg=Purging
        ;;
    "-b"|"--build"|"-a"|"--all")
        opt=--all
        msg=Building
        ;;
    "-l"|"--list")
        echo "Available packets:"
        for p in $packets; do
            echo " - $p"
        done
        exit 0
        ;;
    "-h"|"--help")
        print_usage
        exit 0
        ;;
    *)
        echo "Invalid argument specified" >&2
        print_usage
        exit 1
        ;;
esac

process_all
