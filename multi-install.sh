#!/bin/bash

# This script installs Homebrew formulae and casks from files

casks_file="./casks"
formulae_file="./formulae"

usage() {
  echo "${0} [-c] [-f]"
  echo 'Install Homebrew packages'
  echo 'By deafult packages from both files are installed'
  echo -e "-c\tInstall packages from casks file"
  echo -e "-f\tInstall packages from formulae file"
  exit 1
}

validate_files() {
  local files=$@

  # Check if files exist and are not empty
  for file in $files; do
    if [[ ! -sf "${file}" ]]; then
      echo "${0}: Following file ${file} is empty or doesn't exist" >&2
      exit 1
    fi
  done
}

install_packages() {
  local file=$1
  local flag=$2

  # Install all listed formulae and casks from the packages
  while read -r package; do
    echo "Installing ${package}"
    brew install ${flag} ${package}
    echo
  done < "${file}"

  # Remove outdated downloads and caches for all formulae and casks
  brew cleanup --prune=all &> /dev/null
}

# Check options provided by the user
while getopts cf option &> /dev/null; do
  case ${option} in
    c) install_casks='True' ;;
    f) install_formulae='True' ;;
    ?) usage ;;
  esac
done

# Remove options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# Check if Homebrew is installed
brew -v &> /dev/null
if [[ "${?}" -ne 0 ]]; then
  echo "${0}: Homebrew is not installed on the system" >&2
  exit 1
fi

if [[ $install_casks = 'True' && $install_formulae = 'True' ]] \
|| [[ $install_casks != 'True' && $install_formulae != 'True' ]]; then
  validate_files $casks_file $formulae_file
  install_packages $casks_file --cask
  install_packages $formulae_file --formulae
  exit 0
elif [[ $install_casks = 'True' ]]; then
  validate_files $casks_file
  install_packages $casks_file --cask
  exit 0
elif [[ $install_formulae = 'True' ]]; then
  validate_files $formulae_file
  install_packages $formulae_file --formulae
  exit 0
fi
