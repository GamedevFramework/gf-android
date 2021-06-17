#!/bin/bash

SOURCE_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

source "$SOURCE_DIR/targets.sh"
source "$SOURCE_DIR/functions.sh"

# Check arguments
check_args "$@"

GF_DIR="$SOURCE_DIR/src/gf"

# Clone or update gf repository
if [ ! -d "$GF_DIR" ]
then
  git clone --recursive --depth 1 --branch develop https://github.com/GamedevFramework/gf.git "$GF_DIR"
fi

for TARGET in $ARCH_TARGETS
do
  BUILD_DIR="$GF_DIR/build-$TARGET"

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
    -DCMAKE_FIND_ROOT_PATH="$SOURCE_DIR/out/$TARGET" \
    -DGF_USE_EMBEDDED_LIBS=ON \
    -DGF_BUILD_GAMES=OFF \
    -DGF_BUILD_EXAMPLES=OFF \
    -DGF_BUILD_DOCUMENTATION=OFF \
    -DGF_SINGLE_COMPILTATION_UNIT=OFF \
    -S "$GF_DIR" \
    -B "$BUILD_DIR" || die "CMake configuration for $TARGET failed"

  # Build project
  cmake --build "$BUILD_DIR" --parallel $(nproc --all) || die "Build for $TARGET failed"

  # Export libraries
  cmake --install "$BUILD_DIR" || die "Install for $TARGET failed"
done
