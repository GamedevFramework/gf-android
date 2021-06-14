#!/bin/bash

SOURCE_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

source "$SOURCE_DIR/targets.sh"
source "$SOURCE_DIR/functions.sh"

# Check arguments
if [ $# -ne 1 ]
then
  echo "Missing arguments" >&2
  echo "Usage:" >&2
  echo -e "\t$0 NDK_DIR" >&2

  exit 1
fi
NDK_DIR=$1
FREETYPE_DIR="$SOURCE_DIR/src/freetype"

# Clone or update SDL repository
if [ ! -d "$FREETYPE_DIR" ]
then
  git clone --depth 1 --branch VER-2-10-4 https://github.com/freetype/freetype.git "$FREETYPE_DIR"
fi

for TARGET in $ARCH_TARGETS
do
  BUILD_DIR="$FREETYPE_DIR/build-$TARGET"

  false
  # Clean previous build
  rm -rf "$BUILD_DIR"

  # Configure the project
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=24 \
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
