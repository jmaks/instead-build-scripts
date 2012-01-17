#!/bin/sh

# ---- AUX FUNCTIONS ----

# $1: path to packet dir that contains debian/ dir
extract_ver() {
    ls -1 $1 | grep .orig.tar.gz | sed -rn 's/.*_(.*)\.orig\.tar\.gz/\1/p'
}

# $1: path to packet dir that contains debian/ dir
extract_verd() {
    cat $1/debian/changelog | head -1 | sed -rn 's/.*\((.*)\).*/\1/p'
}

# ---- VARIABLES ----

gn=$(ls -1 | grep orig.tar.gz | sed -rn 's/.*-(.*)_.*/\1/p')
ver=$(extract_ver .)
verd=$(extract_verd .) # +debian packaging ver
game_dir=instead-game-${gn}-$ver
game_orig_tar=instead-game-${gn}_$ver.orig.tar.gz
cur_dir=$(pwd)
home_dir=$(echo ~)
build_dir=../build_all

build_files="\
instead-game-${gn}_${verd}_all.deb \
instead-game-${gn}_${verd}_amd64.build \
instead-game-${gn}_${verd}_amd64.changes \
instead-game-${gn}_${verd}.debian.tar.gz \
instead-game-${gn}_${verd}.dsc"

# ---- FUNCTIONS ----

clean() {
    echo "Cleaning build files..."
    rm -rf $build_files
    rm -rf $game_dir
    echo "Cleaning build files [OK]"
}

rm_build() {
    rm -rf "$build_dir"
}

prepare() {
    echo "Preparing for building..."
    tar -xzf $game_orig_tar
    cp -R debian/ $game_dir
    echo "Preparing for building [OK]"
}

build() {
    echo "Start building deb..."
    cd $game_dir
    debuild --lintian-opts
    res=$?
    cd $cur_dir
    if [ $res -eq 0 ]; then
        echo "Building deb [OK]"
    else
        echo "Building deb [FAILED]"
        exit 1
    fi
}

move() {
    echo "Moving files to build dir..."
    rm_build
    mkdir "$build_dir"
    for f in $build_files; do
        mv $f "$build_dir"
    done
    cp -f instead-game-*.orig.tar.gz "$build_dir"
    echo "Moving files to build dir [OK]"
}

# ---- ENTRY POINT ----

case "$1" in
    "-c"|"--clean")
        clean
        ;;
    "-dc"|"--distclean")
        clean
        rm_build
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
