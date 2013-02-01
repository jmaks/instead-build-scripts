#!/bin/sh

# Script for uploading/removing to mentors.debian.org all the created packets.

. ./common-def.sh

# ".changes" files for each deb-packet
# i386 version commented due to dput uploading bug
changes_list="instead/build_amd64/instead_${instead_verd}_amd64.changes"
#instead/build_i386/instead_${instead_verd}_i386.changes \
#instead-game-cat/build_all/instead-game-cat_${cat_verd}_amd64.changes \
#instead-game-lines/build_all/instead-game-lines_${lines_verd}_amd64.changes \
#instead-game-toilet3in1/build_all/instead-game-toilet3in1_${toilet_verd}_amd64.changes"

action=""      # uploading method: either HTTP or FTP; or "purge" for removing files
sel_config=""  # selected config inlay (see ~/.dput.cf file)

print_usage() {
    echo "Usage: ./$(basename $0) [action]"
    echo
    echo "Actions:"
    echo "--http   - Upload using HTTP method"
    echo "--ftp    - Upload using FTP method; this is preferred method"
    echo "--purge  - Remove all files on mentors"
    echo
    echo "See also ~/.dput.cf file"
}

# Choosing upload method: HTTP/FTP
case "$1" in
    "--ftp" | "")
        # Prefer FTP method by default
        action=FTP
        sel_config=mentors-ftp
        echo "*** Selected: upload via $action"
        ;;
    "--http")
        action=HTTP
        sel_config=mentors
        echo "*** Selected: upload via $action"
        ;;
    "--purge")
        action=purge
        echo "*** Selected: removing my files on mentors.debian.org"
        ;;
    *)
        echo "Specified invalid method"
        print_usage
        exit 1
esac
echo

# Uploading all changes
for f in $changes_list; do
    if [ ! -e $f ]; then
        echo "*** File $(basename $f) not found: [SKIP]"
        continue
    fi

    d=$(dirname "$cur_dir/$f")
    b=$(basename "$cur_dir/$f")
    cd "$d"

    # Getting rid of previous upload (maybe not finished)
    rm -f *.upload

    # Action
    if [ $action = "purge" ]; then
        # Removing
        echo "*** Removing $b..."
        dcut --input $(basename $f)
    else
        # Uploading
        echo "*** Uploading $b..."
        dput -f $sel_config $(basename $f)
        res=$?
        if [ $res ]; then
            status="[FAILED]"
        else
            status="[OK]"
        fi
        echo "Uploading $b: $status"
    fi
    echo

    cd "$cur_dir"
done

exit 0
