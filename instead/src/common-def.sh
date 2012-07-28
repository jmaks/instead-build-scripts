#!/bin/sh

# Commonly used variables and functions

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

ver=$(extract_ver .)
verd=$(extract_verd .) # +debian packaging ver
instead_dir=instead-$ver
instead_orig_tar=instead_$ver.orig.tar.gz
cur_dir=$(pwd)
home_dir=$(echo ~)

build_files="\
instead_${verd}_amd64.deb \
instead_${verd}_amd64.build \
instead_${verd}_amd64.changes \
instead_${verd}.debian.tar.gz \
instead_${verd}.dsc \
instead-data_${verd}_all.deb"
# TODO
# instead_${verd}_source.changes -- this file was dissapear, don't know why; investigate

# ---- FUNCTIONS ----

clean() {
    echo "Cleaning build files..."
    rm -rf $build_files
    rm -rf $instead_dir
    echo "Cleaning build files [OK]"
}

prepare() {
    echo "Preparing for building..."
    tar -xzf $instead_orig_tar

    old_deb_dir="$instead_dir/debian"
    new_deb_dir="debian"
    rm -rf $old_deb_dir
    cp -R $new_deb_dir $old_deb_dir

    echo "Preparing for building [OK]"
}
