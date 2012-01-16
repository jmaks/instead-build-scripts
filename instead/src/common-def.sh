#!/bin/sh

# Commonly used variables and functions

# ---- VARIABLES ----

ver=$(ls -l | grep orig.tar.gz | grep -Po '\d\.\d\.\d')
verd=$ver-1 # +debian packaging ver
instead_dir=instead-$ver
instead_orig_tar=instead_$ver.orig.tar.gz
cur_dir=$(pwd)
home_dir=$(echo ~)

build_files=" \
instead_${verd}_amd64.deb \
instead_${verd}_amd64.build \
instead_${verd}_amd64.changes \
instead_${verd}_source.changes \
instead_${verd}.debian.tar.gz \
instead_${verd}.dsc \
instead-data_${verd}_all.deb"

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
