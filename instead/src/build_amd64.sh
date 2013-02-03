#!/bin/sh

. ./common-def.sh

# ---- VARIABLES ----

build_dir_amd64=../build_amd64

# ---- FUNCTIONS ----

build() {
    echo "Start building deb..."
    cd $instead_dir
    debuild --lintian-opts -i
    res=$?
    cd $cur_dir
    if [ $res -eq 0 ]; then
        echo "Building deb [OK]"
    else
        echo "Building deb [FAILED]"
        exit 1
    fi
}

rm_build_dir() {
    rm -rf "$build_dir_amd64"
}

move() {
    echo "Moving files to build dir..."
    rm_build_dir
    mkdir "$build_dir_amd64"
    for f in $build_files; do
        if [ "$f" = instead_${verd}_source.changes ]; then
            # i386 build file; don't process it
            continue
        fi
        if [ ! -f "$f" ]; then
            echo "Can't move file: file doesn't exist: $f [FAILED]"
            exit 1
        fi
        mv $f "$build_dir_amd64"
    done
    cp -f instead_*.orig.tar.gz "$build_dir_amd64"
    echo "Moving files to build dir [OK]"
}

test_if_run_from_build_sh() {
    if [ -z "$RUN_FROM_BUILD_SH" ]; then
        echo "Please use build.sh script instead of running this one"
        exit 1
    fi
}

# ---- ENTRY POINT ----

test_if_run_from_build_sh

case "$1" in
    "-c"|"--clean")
        clean
        ;;
    "-dc"|"--distclean")
        clean
        rm_build_dir
        ;;
    "-p"|"--prepare")
        prepare
        ;;
    "-b"|"--build")
        build
        ;;
    "-a"|"--all")
        clean
        prepare
        build
        move
        clean
        ;;
    *)
        echo "Invalid arguments"
        exit 1
esac

exit 0
