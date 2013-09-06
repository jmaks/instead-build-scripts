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

existed_files=""
installed_packets=""

populate_existed_files() {
    existed_files=""
    for f in $packet_files; do
        if [ -e $f ]; then
            existed_files="$existed_files $f"
        fi
    done
}

populate_installed_packets() {
    installed_packets=""
    for p in $packets; do
        dpkg -L $p >/dev/null 2>/dev/null
        res=$?
        if [ $res -eq 0 ]; then
            installed_packets="$installed_packets $p"
        fi
    done
}

install_all() {
    echo "==== Installing all the INSTEAD packages ===="
    populate_existed_files
    for f in $existed_files; do
        echo "*** Installing $(basename $f)"
        sudo dpkg -i $f
    done

    populate_installed_packets
    sudo aptitude -y keep $installed_packets
}

purge_all() {
    echo "==== Purging all the INSTEAD packages ===="
    populate_installed_packets
    sudo aptitude -y purge $installed_packets
}

# ---- ENTRY POINT ----

case "$1" in
    "--purge"|"-p")
        purge_all
        ;;
    *)
        install_all
        ;;
esac
