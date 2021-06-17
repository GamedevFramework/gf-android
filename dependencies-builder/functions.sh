# Function to print an error message and exit
function die() {
  echo "$1" >&2
  exit 1
}

# Check arguments
function check_args() {
  if [ $# -ne 1 ]
  then
    echo "Missing arguments" >&2
    echo "Usage:" >&2
    echo -e "\t$0 NDK_DIR" >&2

    exit 1
  fi

  NDK_DIR=$1
  ANDROID_API=21
}
