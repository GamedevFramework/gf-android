#!/bin/bash

SOURCE_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

source "$SOURCE_DIR/targets.sh"
source "$SOURCE_DIR/functions.sh"


# Check arguments
check_args "$@"

SDL_DIR="$SOURCE_DIR/src/sdl"

# Clone or update SDL repository
if [ ! -d "$SDL_DIR" ]
then
  git clone --depth 1 --branch release-2.0.9 https://github.com/libsdl-org/SDL.git "$SDL_DIR"
fi

for TARGET in $ARCH_TARGETS
do
  BUILD_DIR="$SDL_DIR/build-$TARGET"

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
    -S "$SDL_DIR" \
    -B "$BUILD_DIR" || die "CMake configuration for $TARGET failed"

  # Build project
  cmake --build "$BUILD_DIR" --parallel $(nproc --all) || die "Build for $TARGET failed"

  # Export libraries
  cmake --install "$BUILD_DIR" || die "Install for $TARGET failed"
done
