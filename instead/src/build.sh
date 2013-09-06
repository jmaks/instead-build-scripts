#!/bin/sh

. ./common-def.sh


# ---- FUNCTIONS ----

print_usage() {
    echo "Usage: $0 <option>"
    echo
    echo "OPTIONS:"
    echo "-i386               -  Build for 32-bit architecture (i386)"
    echo "-amd64              -  Build for 64-bit architecture (amd64)"
    echo "-a  | --all         -  Build for both 32- and 64-bit architectures"
    echo "-c  | --clean       -  Clean all build files"
    echo "-dc | --distclean   -  Clean all built files and resulting packets"
    echo "-h  | --help        -  Show this help"
}

# ---- VARIABLES ----

build_script_i386=build_i386.sh
build_script_amd64=build_amd64.sh

# ---- ENTRY POINT ----

# Let underlaying scripts know that they runned from build.sh
export RUN_FROM_BUILD_SH=y

# Multithreaded make
proc_num=$(cat /proc/cpuinfo | grep ^proc | wc -l)
export DEB_BUILD_OPTIONS="parallel=$proc_num"

case "$1" in
    "-i386")
        ./$build_script_i386 --all
        ;;
    "-amd64")
        ./$build_script_amd64 --all
        ;;
    "-a"|"--all")
        ./$build_script_amd64 --all
        ./$build_script_i386 --all
        ;;
    "-c"|"--clean")
        clean
        ;;
    "-dc"|"--distclean")
        ./$build_script_amd64 --distclean
        ./$build_script_i386 --distclean
        ;;
    "-h"|"--help")
        print_usage
        exit 0
        ;;
    *)
        echo "Invalid arguments"
        print_usage
        exit 1
esac
