# Function to print an error message and exit
function die() {
  echo "$1" >&2
  exit 1
}
