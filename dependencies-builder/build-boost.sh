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
BOOST_DIR="$SOURCE_DIR/src/boost"

# Clone boost repository
if [ ! -d "$BOOST_DIR" ]
then
  git clone --recursive --depth 1 --branch boost-1.76.0 https://github.com/boostorg/boost.git "$BOOST_DIR"
fi

for TARGET in $ARCH_TARGETS
do
  case $TARGET in
  "arm64-v8a")
    EXEC_PREFIX="aarch64"
    unset EXEC_SUFFIX
    ARCH="architecture=arm"
  ;;

  "armeabi-v7a")
    EXEC_PREFIX="arm"
    EXEC_SUFFIX="eabi"
    ARCH="architecture=arm"
  ;;

  "x86")
    EXEC_PREFIX="i686"
    unset EXEC_SUFFIX
    unset ARCH
  ;;

  "x86_64")
    EXEC_PREFIX="x86_64"
    unset EXEC_SUFFIX
    unset ARCH
  ;;
  esac

  BUILD_DIR="$BOOST_DIR/build-$TARGET"
  TOOLSET_FILE="$BOOST_DIR/tools/build/src/user-config.jam"
  TOOLCHAIN_PATH="$NDK_DIR/toolchains/llvm/prebuilt/linux-x86_64/bin"

  # Remove previous build
  rm -rf "$BUILD_DIR"

  # Create toolset
  echo "import os ;" > $TOOLSET_FILE
  echo "using clang : android" >> $TOOLSET_FILE
  echo ":" >> $TOOLSET_FILE
  echo "\"$TOOLCHAIN_PATH/clang++\"" >> $TOOLSET_FILE
  echo ":" >> $TOOLSET_FILE
  echo "<archiver>$TOOLCHAIN_PATH/$EXEC_PREFIX-linux-android$EXEC_SUFFIX-ar" >> $TOOLSET_FILE
  echo "<ranlib>$TOOLCHAIN_PATH/$EXEC_PREFIX-linux-android$EXEC_SUFFIX-ranlib" >> $TOOLSET_FILE
  echo ";" >> $TOOLSET_FILE

  cd $BOOST_DIR

  ./bootstrap.sh || die "Failed to compile b2 for $TARGET"
  ./b2 \
    -q \
    -j$(nproc) \
    --reconfigure \
    -a \
    --with-locale \
    --build-dir="$BUILD_DIR" \
    --prefix="$SOURCE_DIR/out/$TARGET" \
    toolset=clang-android \
    "$ARCH" \
    variant=release \
    --layout=versioned \
    target-os=android \
    threading=multi \
    threadapi=pthread \
    install || die "Failed to compile boost for $TARGET"
done
