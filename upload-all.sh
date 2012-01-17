#!/bin/sh

. ./common-def.sh

# ".changes" files for each deb-packet
changes_list="\
instead/build_amd64/instead_${instead_verd}_amd64.changes \
instead/build_i386/instead_${instead_verd}_i386.changes \
instead-game-cat/build_all/instead-game-cat_${cat_verd}_amd64.changes \
instead-game-lines/build_all/instead-game-lines_${lines_verd}_amd64.changes \
instead-game-toilet3in1/build_all/instead-game-toilet3in1_${toilet_verd}_amd64.changes"

for f in $changes_list; do
    d=$(dirname "$cur_dir/$f")
    b=$(basename "$cur_dir/$f")
    cd "$d"
    echo "Uploading $b..."
    dput debexpo $(basename $f)
    echo "Uploading $b [OK]"
    cd "$cur_dir"
done
