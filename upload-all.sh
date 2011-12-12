#!/bin/sh

changes_list="instead/build_amd64/instead_1.5.2-1_amd64.changes \
instead/build_i386/instead_1.5.2-1_i386.changes \
instead-game-cat/build_all/instead-game-cat_1.5-1_amd64.changes \
instead-game-lines/build_all/instead-game-lines_1.0-1_amd64.changes \
instead-game-toilet3in1/build_all/instead-game-toilet3in1_1.0-1_amd64.changes"

cur_dir=$(pwd)

for f in $changes_list; do
    d=$(dirname "$cur_dir/$f")
    b=$(basename "$cur_dir/$f")
    cd "$d"
    echo "Uploading $b..."
    dput debexpo $(basename $f)
    echo "Uploading $b [OK]"
    cd "$cur_dir"
done
