#!/bin/bash

# This script installs Homebrew formulae and casks from a list

PACKAGES='./packages'

# Colors for messages
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
  echo "Usage: ${0} [-f FILE]"
  echo "Install all listed Homebrew formulae and casks: default ${PACKAGES}"
  echo -e "-f FILE\tUse FILE for the list of Homebrew formulae and casks"
  exit 1
}

# Check options provided by the user
while getopts f:v OPTION &> /dev/null
do
  case ${OPTION} in
    f) PACKAGES=${OPTARG} ;;
    ?) usage ;;
  esac
done

# Check if PACKAGES exists and is a file
if [[ ! -f "${PACKAGES}" ]]
then
  echo -e "${RED}Cannot open file ${PACKAGES}${NC}" >&2
  exit 1
fi

# Check if PACKAGES is not empty
if [[ ! -s "${PACKAGES}" ]]
then
  echo -e "${RED}Provided file ${PACKAGES} is empty${NC}" >&2
  exit 1
fi

# Check if Homebrew is installed
brew -v &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo -e "${YELLOW}Warning:${NC} Homebrew is not installed on the system"
  echo 'Installing Homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install all listed formulae and casks from the PACKAGES
for PACKAGE in $(cat "${PACKAGES}")
do
  echo "Installing ${PACKAGE}"
  brew install "${PACKAGE}"
  echo
done

# Remove outdated downloads for all formulae and casks
brew cleanup &> /dev/null

exit 0
