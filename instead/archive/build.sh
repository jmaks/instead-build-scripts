#!/bin/sh

# ---- VARIABLES ----

ver=1.5.2
verd=$ver-1 # +debian packaging ver
instead_dir=instead-$ver
instead_orig_tar=instead_$ver.orig.tar.gz
cur_dir=$(pwd)
build_files="instead_${verd}_amd64.build instead_${verd}_amd64.changes instead_${verd}_amd64.deb \
             instead_${verd}.debian.tar.gz instead_${verd}.dsc instead-data_${verd}_all.deb"
home_dir=$(echo ~)
result_dir_i386="$home_dir/pbuilder/testing/result"

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
    cd joe-fixes
    ./prepare.sh
    cd $cur_dir
    echo "Preparing for building [OK]"
}

build() {
    echo "Start building deb..."
    cd $instead_dir
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

clean_prev_result_i386() {
    echo "Cleaning previous result files for i386..."
    sudo rm -rf "$result_dir_i386/*"
    echo "Cleaning previous result files for i386 [OK]"
}

build_i386() {
    echo "Start building deb for architecture i386..."
    cd $instead_dir
    sudo DIST=testing ARCH=i386 pdebuild
    res=$?
    cd $cur_dir
    if [ $res -eq 0 ]; then
        echo "Building deb [OK]"
    else
        echo "Building deb [FAILED]"
        exit 1
    fi
}

copy_result_i386() {
    echo "Copying result files for i386..."
    sudo chown -R joe:joe $result_dir_i386
    cp -Rf $result_dir_i386/* $(pwd)
    echo "Copying result files for i386 [OK]"
}

sign_i386() {
    echo "Signing of changes file... "
    debsign instead_${verd}_i386.changes
    echo "Signing [OK]"
}

# ---- ENTRY POINT ----

if [ $# -eq 0 ]; then
    clean
    prepare
    build
    exit 0
fi

case "$1" in
    "-c"|"--clean")
        clean
        ;;
    "-p"|"--prepare")
        prepare
        ;;
    "-b"|"--build")
        build
        ;;
    "-i386")
        clean
        prepare
        clean_prev_result_i386
        build_i386
        copy_result_i386
        sign_i386
        ;;
    *)
        echo "Invalid arguments"
        exit 1
esac

exit 0
