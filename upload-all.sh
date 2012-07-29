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

method=""      # uploading method: either HTTP or FTP
sel_config=""  # selected config inlay (see ~/.dput.cf file)

print_usage() {
    echo "Usage: ./$(basename $0) [method]"
    echo
    echo "Uploading methods:"
    echo "--http - Upload using HTTP method"
    echo "--ftp  - Upload using FTP method"
    echo
    echo "By default using HTTP method"
    echo "See also ~/.dput.cf file"
}

# Choosing upload method: HTTP/FTP
case "$1" in
    "--ftp")
        method=FTP
        sel_config=mentors-ftp
        ;;
    "--http"|"")
        method=HTTP
        sel_config=mentors
        ;;
    *)
        echo "Specified invalid method"
        print_usage
        exit 1
esac
echo "*** Using method $method"

# Uploading all changes
for f in $changes_list; do
    if [ ! -e $f ]; then
        echo "*** File $(basename $f) not found: [SKIP]"
        continue
    fi

    d=$(dirname "$cur_dir/$f")
    b=$(basename "$cur_dir/$f")
    cd "$d"
    echo "*** Uploading $b..."

    # Uploading
    dput $sel_config $(basename $f)
    res=$?
    if [ $res ]; then
        status="[FAILED]"
    else
        status="[OK]"
    fi
    echo "Uploading $b: $status"
    echo

    cd "$cur_dir"
done

exit 0
