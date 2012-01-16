#!/bin/sh

. ./common-def.sh

# ---- VARIABLES ----

build_script_i386=build_i386.sh
build_script_amd64=build_amd64.sh

# ---- ENTRY POINT ----

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
    *)
        echo "Invalid arguments"
        exit 1
esac

exit 0
