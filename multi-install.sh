#!/bin/bash

# This script installs Homebrew formulae and cask listed in files

cask_file="./cask.txt"
formulae_file="./formulae.txt"

function usage() {
  echo "usage: $(basename ${0}) [-c] [-f] [-h]"
  echo -e "\nInstall Homebrew packages (by default program is run with -cf)\n"
  echo -e "-c\tonly install packages from ${cask_file}"
  echo -e "-f\tonly install packages from ${formulae_file}"
  echo -e "-h\tshow this help message and exit"
  exit 1
}

function check_homebrew_installation() {
  brew -v &> /dev/null
  if [[ "${?}" -ne 0 ]]; then
    echo "Homebrew is not installed on the system" >&2
    exit 1
  fi
}

function check_files_exist() {
  local files="${@}"

  for file in $files; do
    if [[ ! -f "${file}" ]]; then
      echo -e "File ${file} does not exist" >&2
      exit 1
    fi
  done
}

function install_packages() {
  local flag="${1}"
  local file="${2}"

  for package in $(cat "${file}"); do
    echo "Installing ${package}"
    brew install "${flag}" "${package}"
    echo
  done

  # Remove outdated downloads and caches for all formulae and cask
  brew cleanup --prune=all &> /dev/null
}

# Check options provided by the user
while getopts "cf" option &> /dev/null; do
  case "${option}" in
    c) install_cask="true" ;;
    f) install_formulae="true" ;;
    h) usage ;;
    ?) usage ;;
  esac
done

check_homebrew_installation

if [[ "${install_cask}" = "true" && "${install_formulae}" = "true" ]] \
|| [[ "${install_cask}" != "true" && "${install_formulae}" != "true" ]]; then
  check_files_exist "${cask_file}" "${formulae_file}"
  install_packages --cask "${cask_file}"
  install_packages --formulae "${formulae_file}"
elif [[ "${install_cask}" = "true" ]]; then
  check_files_exist "${cask_file}"
  install_packages --cask "${cask_file}"
elif [[ "${install_formulae}" = "true" ]]; then
  check_files_exist "${formulae_file}"
  install_packages --formulae "${formulae_file}"
fi
