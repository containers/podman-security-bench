#!/bin/bash

# Returns the absolute path of a given string
abspath () { case "$1" in /*)printf "%s\n" "$1";; *)printf "%s\n" "$PWD/$1";; esac; }

# Audit rules default path
auditrules="/etc/audit/audit.rules"

# Check for required program(s)
req_programs() {
  for p in $1; do
    command -v "$p" >/dev/null 2>&1 || { printf "Required program not found: %s\n" "$p"; exit 1; }
  done
  if command -v ss >/dev/null 2>&1; then
    netbin=ss
    return
  fi
  if command -v netstat >/dev/null 2>&1; then
    netbin=netstat
    return
  fi
  echo "ss or netstat command not found."
  exit 1
}

# Compares versions of software of the format X.Y.Z
do_version_check() {
  [ "$1" = "$2" ] && return 10

  ver1front=$(printf "%s" "$1" | cut -d "." -f -1)
  ver1back=$(printf "%s" "$1" | cut -d "." -f 2-)
  ver2front=$(printf "%s" "$2" | cut -d "." -f -1)
  ver2back=$(printf "%s" "$2" | cut -d "." -f 2-)

  if [ "$ver1front" != "$1" ] || [ "$ver2front" != "$2" ]; then
    [ "$ver1front" -gt "$ver2front" ] && return 11
    [ "$ver1front" -lt "$ver2front" ] && return 9

    [ "$ver1front" = "$1" ] || [ -z "$ver1back" ] && ver1back=0
    [ "$ver2front" = "$2" ] || [ -z "$ver2back" ] && ver2back=0
      do_version_check "$ver1back" "$ver2back"
      return $?
  fi
  [ "$1" -gt "$2" ] && return 11 || return 9
}

# Extracts commandline args from the newest running processes named like the first parameter
get_command_line_args() {
  PROC="$1"

  for PID in $(pgrep -f -n "$PROC"); do
    tr "\0" " " < /proc/"$PID"/cmdline
  done
}

# Extract the cumulative command line arguments for the podman daemon
#
# If specified multiple times, all matches are returned.
# Accounts for long and short variants, call with short option.
# Does not account for option defaults or implicit options.
get_podman_cumulative_command_line_args() {
  OPTION="$1"

  line_arg="podmand"
  if ! get_command_line_args "podman daemon" >/dev/null 2>&1 ; then
    line_arg="podman daemon"
  fi

  get_command_line_args "$line_arg" |
  # normalize known long options to their short versions
  sed \
    -e 's/\-\-debug/-D/g' \
    -e 's/\-\-host/-H/g' \
    -e 's/\-\-log-level/-l/g' \
    -e 's/\-\-version/-v/g' \
    |
    # normalize parameters separated by space(s) to -O=VALUE
    sed \
      -e 's/\-\([DHlv]\)[= ]\([^- ][^ ]\)/-\1=\2/g' \
      |
    # get the last interesting option
    tr ' ' "\n" |
    grep "^${OPTION}" |
    # normalize quoting of values
    sed \
      -e 's/"//g' \
      -e "s/'//g"
}

# Extract the effective command line arguments for the podman daemon
#
# Accounts for multiple specifications, takes the last option.
# Accounts for long and short variants, call with short option
# Does not account for option default or implicit options.
get_podman_effective_command_line_args() {
  OPTION="$1"
  get_podman_cumulative_command_line_args "$OPTION" | tail -n1
}

get_podman_configuration_file() {
  FILE="$(get_podman_effective_command_line_args '--config-file' | \
    sed 's/.*=//g')"

  if [ -f "$FILE" ]; then
    CONFIG_FILE="$FILE"
    return
  fi
  if [ -f '/etc/podman/daemon.json' ]; then
    CONFIG_FILE='/etc/podman/daemon.json'
    return
  fi
  CONFIG_FILE='/dev/null'
}

get_podman_configuration_file_args() {
  OPTION="$1"

  get_podman_configuration_file

  grep "$OPTION" "$CONFIG_FILE" | sed 's/.*://g' | tr -d '" ',
}

get_service_file() {
  SERVICE="$1"

  if [ -f "/etc/systemd/system/$SERVICE" ]; then
    echo "/etc/systemd/system/$SERVICE"
    return
  fi
  if [ -f "/lib/systemd/system/$SERVICE" ]; then
    echo "/lib/systemd/system/$SERVICE"
    return
  fi
  if systemctl show -p FragmentPath "$SERVICE" 2> /dev/null 1>&2; then
    systemctl show -p FragmentPath "$SERVICE" | sed 's/.*=//'
    return
  fi
  echo "/usr/lib/systemd/system/$SERVICE"
}

yell_info() {
yell "# --------------------------------------------------------------------------------------------
# Podman Security Bench v$version
#
# Based off of Docker Bench for security
#   Docker, Inc. (c) 2015-2021
#
# Checks for dozens of common best-practices around deploying Podman containers in production.
# Based on the CIS Docker Benchmark 1.3.1.
# --------------------------------------------------------------------------------------------"
}

# retrieve command for package manager
get_list_cmd() {
  distro="${1}"

  case "$distro" in
    fedora|rhel|rocky)
      echo -n "rpm -qa"
      return
      ;;
    debian|ubuntu)
      echo -n "apt list --installed"
      return
      ;;
    alpine)
      echo -n "apk info"
      return
      ;;
    centos)
      echo -n "yum list --installed"
      return
      ;;
    *)
      echo -n "rpm -qa"
      return
      ;;
  esac
}


