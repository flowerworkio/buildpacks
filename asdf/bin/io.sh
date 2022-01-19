#!/usr/bin/env bash

function io::title() {
  local blue reset message
  blue="\033[0;34m"
  reset="\033[0;39m"
  message="${1}"

  echo -e "\n${blue}${message}${reset}" >&2
}

function io::info() {
  local message
  message="${1}"

  echo -e "${message}" >&2
}

function io::error() {
  local message red reset
  message="${1}"
  red="\033[0;31m"
  reset="\033[0;39m"

  echo -e "${red}${message}${reset}" >&2
  exit 1
}

function io::success() {
  local message green reset
  message="${1}"
  green="\033[0;32m"
  reset="\033[0;39m"

  echo -e "${green}${message}${reset}" >&2
  exitcode="${2:-0}"
  exit "${exitcode}"
}

function io::warn() {
  local message yellow reset
  message="${1}"
  yellow="\033[0;33m"
  reset="\033[0;39m"

  echo -e "${yellow}${message}${reset}" >&2
  exit 0
}

function io::debug() {
  local message purple reset
  message="${1}"
  purple="\033[0;35m"
  reset="\033[1;35m"

  echo -e "${purple}${message}${reset}" >&2
  exit 0
}
