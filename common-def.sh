#!/bin/sh

# Commonly used definitions

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

cur_dir=$(pwd)
archit=amd64

instead_src_dir=instead/src
cat_src_dir=instead-game-cat/src
lines_src_dir=instead-game-lines/src
toilet_src_dir=instead-game-toilet3in1/src

instead_ver=$(extract_ver $instead_src_dir)
cat_ver=$(extract_ver $cat_src_dir)
lines_ver=$(extract_ver $lines_src_dir)
toilet_ver=$(extract_ver $toilet_src_dir)

instead_verd=$(extract_verd $instead_src_dir)
cat_verd=$(extract_verd $cat_src_dir)
lines_verd=$(extract_verd $lines_src_dir)
toilet_verd=$(extract_verd $toilet_src_dir)
