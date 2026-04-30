#!/bin/bash

# This script installs Homebrew formulae and casks listed in files

casks_file="./casks.txt"
formulae_file="./formulae.txt"

function usage() {
  echo "usage: $(basename ${0}) [-c] [-f] [-h]"
  echo -e "\nInstall Homebrew packages (by default program is run with -sf)\n"
  echo -e "-c\tonly install packages from ${casks_file}"
  echo -e "-f\tonly install packages from ${formulae_file}"
  echo -e "-h\tshow this help message and exit"
  exit 1
}

function check_hombrew_installation() {
  brew -v &> /dev/null
  if [[ "${?}" -ne 0 ]]; then
    echo "${0}: Homebrew is not installed on the system" >&2
    exit 1
  fi
}

function check_files_exist_and_not_empty() {
  local files=$@

  for file in $files; do
    if [[ ! -f "${file}" ]]; then
      echo -e "File ${file} does not exist" >&2
      exit 1
    elif [[ ! -s "${repos_file}" ]]; then 
      echo -e "File ${file} is empty$" >&2
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

  # Remove outdated downloads and caches for all formulae and casks
  brew cleanup --prune=all &> /dev/null
}

# Check options provided by the user
while getopts cf option &> /dev/null; do
  case ${option} in
    c) install_casks="true" ;;
    f) install_formulae="true" ;;
    h) usage ;;
    ?) usage ;;
  esac
done

check_hombrew_installation

if [[ "${install_casks}" = "true" && "${install_formulae}" = "true" ]] \
|| [[ "${install_casks}" != "true" && "${install_formulae}" != "true" ]]; then
  check_files_exist_and_not_empty "${casks_file}" "${formulae_file}"
  install_packages --cask "${casks_file}"
  install_packages --formulae "{$formulae_file}"
  exit 0
elif [[ "${install_casks}" = "true" ]]; then
  check_files_exist_and_not_empty "${casks_file}"
  install_packages --cask "${casks_file}"
  exit 0
elif [[ "{$formulae_file}" = "true" ]]; then
  check_files_exist_and_not_empty "{$formulae_file}"
  install_packages --formulae "{$formulae_file}"
  exit 0
fi
