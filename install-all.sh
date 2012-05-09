#!/bin/sh

# Script installs or purges all existed packages.

. ./common-def.sh

# ---- VARIABLES ----

packet_files="\
instead/build_${archit}/instead-data_${instead_verd}_all.deb \
instead/build_${archit}/instead_${instead_verd}_${archit}.deb \
instead-game-cat/build_all/instead-game-cat_${cat_verd}_all.deb \
instead-game-lines/build_all/instead-game-lines_${lines_verd}_all.deb \
instead-game-toilet3in1/build_all/instead-game-toilet3in1_${toilet_verd}_all.deb"

packets="\
instead-game-cat \
instead-game-lines \
instead-game-toilet3in1 \
instead \
instead-data"

install_all() {
    echo "==== Installing all the INSTEAD packages ===="
    for f in $packet_files; do
        sudo dpkg -i $f
    done

    sudo aptitude -y keep $packets
}

purge_all() {
    echo "==== Purging all the INSTEAD packages ===="
    sudo aptitude -y purge $packets
}

# ---- ENTRY POINT ----

case "$1" in
    "--purge")
        purge_all
        ;;
    *)
        install_all
        ;;
esac

exit 0
