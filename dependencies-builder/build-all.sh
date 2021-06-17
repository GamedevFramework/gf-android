#!/bin/bash

SOURCE_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

source "$SOURCE_DIR/targets.sh"
source "$SOURCE_DIR/functions.sh"

# check arguments
check_args "$@"

# Clean previous build
rm -rf "$SOURCE_DIR/out"

# run all scripts
"$SOURCE_DIR/build-sdl.sh" "$NDK_DIR" || die "Cross compilation of SDL failed"
"$SOURCE_DIR/build-boost.sh" "$NDK_DIR" || die "Cross compilation of boost failed"
"$SOURCE_DIR/build-freetype.sh" "$NDK_DIR" || die "Cross compilation of freetype failed"
"$SOURCE_DIR/build-pugixml.sh" "$NDK_DIR" || die "Cross compilation of pugixml failed"
"$SOURCE_DIR/build-gf.sh" "$NDK_DIR" || die "Cross compilation of gf failed"

# Remove useless output dir
for TARGET in $ARCH_TARGETS
do
  rm -rf "$SOURCE_DIR/out/$TARGET/bin" "$SOURCE_DIR/out/$TARGET/share"
done
