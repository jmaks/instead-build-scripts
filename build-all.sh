#!/bin/sh

# ---- VARIABLES ----

cur_dir=$(pwd)
opt="" # option for each ./build.sh execution
msg="" # message that shows before each action

packet_list=" \
instead \
instead-game-cat \
instead-game-lines \
instead-game-toilet3in1"

# ---- FUNCTIONS ----

process_all() {
    for f in $packet_list; do
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
    *)
        opt=--all
        msg=Building
        ;;
esac

process_all
