#!/bin/sh

# Fixes INSTEAD window icon

# -------- variables --------

instead_dir="$1"
cur_dir=$(pwd)
icon_name="sdl_instead_wnd.png"

# -------- functions --------

print_usage() {
    echo "Usage: ./fix-icon <path/to/instead/sources/dir>"
}

check_args() {
    if [ $# -eq 0 ]; then
        print_usage
        exit 1
    fi

    if [ ! -d "$1" ]; then
        echo "First argument must be directory"
        print_usage
        exit 1
    fi
}

copy_new_icon() {
    echo -n 'Copying new icon ("sdl_instead_wnd.png")... '
    if [ -f "$instead_dir/icon/$icon_name" ]; then
        echo [ALREADY EXISTS]
    else
        cp "$cur_dir/$icon_name" "$instead_dir/icon"
        echo [OK]
    fi
}

apply_patch() {
    echo 'Applying patch for icon... '
    cd $instead_dir
    cd ..
    patch -p0 <"$cur_dir/icon-wnd.patch"
    cd $cur_dir
    echo 'Applying patch for icon     [OK]'
}

print_note() {
    echo
    echo '*** NOTE: you also need manually fix "instead.pkg" file as it has strange LF format ***'
    echo
}

# -------- main --------

check_args $@
copy_new_icon
apply_patch
print_note

exit 0
