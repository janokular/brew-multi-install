#!/bin/bash

# This script installs Homebrew formulae and casks from a list

usage() {
  echo "Usage: ${0} [-c] FILE"
  echo 'Install all listed Homebrew formulae and casks'
  echo -e "-c\tTreat all named arguments as casks"
  exit 1
}

# Check options provided by the user
while getopts c OPTION &> /dev/null
do
  case ${OPTION} in
    c) CASK='--cask' ;;
    ?) usage ;;
  esac
done

# Remove options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# Check if user provided only one file
if [[ "${#}" -lt 1 ]]
then
  echo 'Error: No file provided' >&2
  usage
elif [[ "${#}" -gt 1 ]]
then
  echo 'Error: Too many files provided' >&2
  usage
fi

# First argument is treated as PACKAGES
PACKAGES="${1}"

# Check if PACKAGES exists and is a file
if [[ ! -f "${PACKAGES}" ]]
then
  echo "Error: Cannot open file ${PACKAGES}" >&2
  usage
fi

# Check if PACKAGES is not empty
if [[ ! -s "${PACKAGES}" ]]
then
  echo "Error: Provided file ${PACKAGES} is empty" >&2
  exit 1
fi

# Check if Homebrew is installed
brew -v &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo 'Warning: Homebrew is not installed on the system'
  echo 'Installing Homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install all listed formulae and casks from the PACKAGES
while read -r PACKAGE
do
  echo "Installing ${PACKAGE}"
  brew install ${CASK} ${PACKAGE}
  echo
done < "${PACKAGES}"

# Remove outdated downloads and caches for all formulae and casks
brew cleanup --prune=all &> /dev/null

exit 0
