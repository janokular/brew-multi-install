#!/bin/bash

# This script installs Homebrew formulae and casks from a list

usage() {
  echo "Usage: ${0} [-c] FILE"
  echo 'Install all listed Homebrew formulae and casks'
  echo -e "-c\tTreat all named arguments as casks"
  exit 1
}

# Check options provided by the user
while getopts c option &> /dev/null; do
  case ${option} in
    c) cask='--cask' ;;
    ?) usage ;;
  esac
done

# Remove options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# Check if user provided only one file
if [[ "${#}" -lt 1 ]]; then
  echo 'Error: No file provided' >&2
  usage
elif [[ "${#}" -gt 1 ]]; then
  echo 'Error: Too many files provided' >&2
  usage
fi

# First argument is treated as packages
packages="${1}"

# Check if packages exists and is a file
if [[ ! -f "${packages}" ]]; then
  echo "Error: Cannot open file ${packages}" >&2
  usage
fi

# Check if packages is not empty
if [[ ! -s "${packages}" ]]; then
  echo "Error: Provided file ${packages} is empty" >&2
  exit 1
fi

# Check if Homebrew is installed
brew -v &> /dev/null
if [[ "${?}" -ne 0 ]]; then
  echo 'Error: Homebrew is not installed on the system'
  exit 1
fi

# Install all listed formulae and casks from the packages
while read -r package; do
  echo "Installing ${package}"
  brew install ${cask} ${package}
  echo
done < "${packages}"

# Remove outdated downloads and caches for all formulae and casks
brew cleanup --prune=all &> /dev/null

exit 0
