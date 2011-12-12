#!/bin/sh

# Prepares orig tarball for packeting


# -------- variables --------

ver=1.5.2
instead_dir=../instead-$ver
fixes_dir="."
cur_dir=$(pwd)
icon_name="sdl_instead_wnd.png"

# -------- functions --------

# Replace old maemo patch by fixed file
replace_maemo_patch() {
    echo -n "Replacing maemo patch... "
    old_patch_path="$instead_dir/maemo-build.patch"
    new_patch_path="$fixes_dir/maemo-build.patch"
    rm -f "$old_patch_path"
    cp "$new_patch_path" "$old_patch_path"
    echo [OK]
}

# Moves debian/changelog to ChangeLog
move_changelog() {
    echo -n "Moving changelog... "
    old_changelog_path="$instead_dir/debian/changelog"
    new_changelog_path="$instead_dir/ChangeLog"
    if [ -f "$new_changelog_path" ]; then
        echo [ALREADY EXISTS]
        return
    fi
    if [ -f "$old_changelog_path" ]; then
        mv "$instead_dir/debian/changelog" "$instead_dir/ChangeLog"
        echo [OK]
    else
        echo [NOT FOUND]
    fi
}

# Replaces debian directory by new
replace_debian_dir() {
    echo -n "Replacing debian/ dir... "
    old_deb_dir="$instead_dir/debian"
    new_deb_dir="$fixes_dir/debian"
    rm -rf $old_deb_dir
    cp -R $new_deb_dir $old_deb_dir
    echo [OK]
}

# Makes necessary links for man-pages generating
# (as lintian requires of man for each binary)
create_man_links() {
    echo -n "Creating links for man-pages... "
    cd $instead_dir
    # Creating link for sdl-instead
    if [ ! -e doc/sdl-instead.6 ]; then
        ln -s instead.6 doc/sdl-instead.6
    fi
    if [ ! -e doc/sdl-instead.txt ]; then
        ln -s instead.txt doc/sdl-instead.txt
    fi
    cd $cur_dir
    echo [OK]
}

# Makes link for proper makefile
select_proper_makefile() {
    echo -n "Selecting proper makefile... "
    cd $instead_dir
    if [ -e Rules.make ]; then
        rm -f Rules.make
    fi
    ln -s Rules.make.system Rules.make
    cd $cur_dir
    echo [OK]
}

# Copies window icon
copy_icon() {
    echo -n "Copying window icon... "
    if [ -f "$instead_dir/icon/$icon_name" ]; then
        echo [ALREADY EXISTS]
    else
        cp "$cur_dir/$icon_name" "$instead_dir/icon"
        echo [OK]
    fi
}

# Removes inner zlib sources since using system zlib
# This directory must be removed by hand but if it didn't so - this function
# can be useful
remove_zlib() {
    echo -n "Removing inner zlib... "
    inner_zlib_dir="$instead_dir/src/zlib"
    if [ -d "$inner_zlib_dir" ]; then
        rm -rf $inner_zlib_dir
    fi
    echo [OK]
}

# -------- main --------

replace_maemo_patch
move_changelog
replace_debian_dir
create_man_links
select_proper_makefile
copy_icon
remove_zlib

exit 0
