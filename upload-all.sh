#!/bin/sh

# Script uploads to mentors.debian.org all the created packets.

. ./common-def.sh

# ".changes" files for each deb-packet
changes_list="\
instead/build_amd64/instead_${instead_verd}_amd64.changes \
instead/build_i386/instead_${instead_verd}_i386.changes \
instead-game-cat/build_all/instead-game-cat_${cat_verd}_amd64.changes \
instead-game-lines/build_all/instead-game-lines_${lines_verd}_amd64.changes \
instead-game-toilet3in1/build_all/instead-game-toilet3in1_${toilet_verd}_amd64.changes"

for f in $changes_list; do
    if [ ! -e $f ]; then
        echo "*** File $(basename $f) not found; SKIPPING"
        continue
    fi

    d=$(dirname "$cur_dir/$f")
    b=$(basename "$cur_dir/$f")
    cd "$d"
    echo "*** Uploading $b..."

    dput debexpo $(basename $f)
    res=$?
    status
    if [ $res ]; then
        status="[FAILED]"
    else
        status="[OK]"
    fi
    echo "Uploading $b $status"
    echo

    cd "$cur_dir"
done
