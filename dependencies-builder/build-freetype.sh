#!/bin/bash

SOURCE_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

source "$SOURCE_DIR/targets.sh"
source "$SOURCE_DIR/functions.sh"


# Check arguments
check_args "$@"

FREETYPE_DIR="$SOURCE_DIR/src/freetype"

# Clone or update SDL repository
if [ ! -d "$FREETYPE_DIR" ]
then
  git clone --depth 1 --branch VER-2-10-4 https://github.com/freetype/freetype.git "$FREETYPE_DIR"
fi

for TARGET in $ARCH_TARGETS
do
  BUILD_DIR="$FREETYPE_DIR/build-$TARGET"

  # Clean previous build
  rm -rf "$BUILD_DIR"

  # Configure the project
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_ANDROID_API=$ANDROID_API \
    -DCMAKE_ANDROID_ARCH_ABI=$TARGET \
    -DCMAKE_ANDROID_NDK="$NDK_DIR" \
    -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/out/$TARGET" \
    -S "$FREETYPE_DIR" \
    -B "$BUILD_DIR" || die "CMake configuration for $TARGET failed"

  # Build project
  cmake --build "$BUILD_DIR" --parallel $(nproc --all) || die "Build for $TARGET failed"

  # Export libraries
  cmake --install "$BUILD_DIR" || die "Install for $TARGET failed"
done
