#!/bin/bash

CONFIG_FILE='./config'

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
  echo "Usage: ${0} [-f FILE]"
  echo "Install all listed Homebrew formulae and casks: default ${CONFIG_FILE}"
  echo -e "-f FILE\tUse FILE for the list of Homebrew formulae and casks"
  exit 1
}

# Check options provided by the user
while getopts f:v OPTION &> /dev/null
do
  case ${OPTION} in
    f) CONFIG_FILE=${OPTARG} ;;
    ?) usage ;;
  esac
done

# Check if CONFIG_FILE exists and is a file
if [[ ! -f "${CONFIG_FILE}" ]]
then
  echo -e "${RED}Cannot open ${CONFIG_FILE}${NC}" >&2
  exit 1
fi

# Check if CONFIG_FILE is not empty
if [[ ! -s "${CONFIG_FILE}" ]]
then
  echo -e "${RED}Provided file ${CONFIG_FILE} is empty${NC}" >&2
  exit 1
fi

# Check if Homebrew is installed
brew -v &> /dev/null
if [[ ! "${?}" -eq 0 ]]
then
  echo -e "${YELLOW}Homebrew is not installed on the system${NC}"
  echo 'Installing Homebrew'
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
fi

# Install all listed formulae and casks from the CONFIG_FILE
for FORMULA in $(cat "${CONFIG_FILE}")
do
  echo "Installing ${FORMULA}"
  brew install "${FORMULA}"
  
  # Check the status of the brew install command
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "${RED}Failed at installing ${FORMULA}${NC}\n"
  else
    echo -e "${GREEN}Successfully installed ${FORMULA}${NC}\n"
  fi
done

# Remove outdated downloads for all formulae and casks
brew cleanup &> /dev/null

exit 0