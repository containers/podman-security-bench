#!/bin/bash

check_3() {
  logit ""
  local id="3"
  local desc="Podman daemon configuration files"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_3_1() {
  local id="3.1"
  local desc="Ensure that the podman.service file ownership is set to root:root (Automated)"
  local remediation="Find out the file location: systemctl show -p FragmentPath podman.service. If the file does not exist, this recommendation is not applicable. If the file does exist, you should run the command chown root:root <path>, in order to set the ownership and group ownership for the file to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file=$(get_service_file podman.service)
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g "$file")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong ownership for $file"
    logcheckresult "WARN" "Wrong ownership for $file"
    return
  fi
  info -c "$check"
  info "     * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_2() {
  local id="3.2"
  local desc="Ensure that podman.service file permissions are appropriately set (Automated)"
  local remediation="Find out the file location: systemctl show -p FragmentPath podman.service. If the file does not exist, this recommendation is not applicable. If the file exists, run the command chmod 644 <path> to set the file permissions to 644."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file=$(get_service_file podman.service)
  if [ -f "$file" ]; then
    if [ "$(stat -c %a "$file")" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong permissions for $file"
    logcheckresult "WARN" "Wrong permissions for $file"
    return
  fi
  info -c "$check"
  info "     * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_3() {
  local id="3.3"
  local desc="Ensure that podman.socket file ownership is set to root:root (Automated)"
  local remediation="Find out the file location: systemctl show -p FragmentPath podman.socket. If the file does not exist, this recommendation is not applicable. If the file exists, run the command chown root:root <path> to set the ownership and group ownership for the file to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file=$(get_service_file podman.socket)
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g "$file")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong ownership for $file"
    logcheckresult "WARN" "Wrong ownership for $file"
    return
  fi
  info -c "$check"
  info "     * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_4() {
  local id="3.4"
  local desc="Ensure that podman.socket file permissions are set to 644 or more restrictive (Automated)"
  local remediation="Find out the file location: systemctl show -p FragmentPath podman.socket. If the file does not exist, this recommendation is not applicable. If the file does exist, you should run the command chmod 644 <path> to set the file permissions to 644."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file=$(get_service_file podman.socket)
  if [ -f "$file" ]; then
    if [ "$(stat -c %a "$file")" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong permissions for $file"
    logcheckresult "WARN" "Wrong permissions for $file"
    return
  fi
  info -c "$check"
  info "     * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_5() {
  local id="3.5"
  local desc="Ensure that the /etc/podman directory ownership is set to root:root (Automated)"
  local remediation="You should run the following command: chown root:root /etc/podman. This sets the ownership and group ownership for the directory to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/podman"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong ownership for $directory"
    logcheckresult "WARN" "Wrong ownership for $directory"
    return
  fi
  info -c "$check"
  info "     * Directory not found"
  logcheckresult "INFO" "Directory not found"
}

check_3_6() {
  local id="3.6"
  local desc="Ensure that /etc/podman directory permissions are set to 755 or more restrictively (Automated)"
  local remediation="You should run the following command: chmod 755 /etc/podman. This sets the permissions for the directory to 755."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/podman"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %a $directory)" -le 755 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong permissions for $directory"
    logcheckresult "WARN" "Wrong permissions for $directory"
    return
  fi
  info -c "$check"
  info "     * Directory not found"
  logcheckresult "INFO" "Directory not found"
}

check_3_7() {
  local id="3.7"
  local desc="Ensure that registry certificate file ownership is set to root:root (Automated)"
  local remediation="You should run the following command: chown root:root /etc/podman/certs.d/<registry-name>/*. This would set the individual ownership and group ownership for the registry certificate files to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/podman/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    owners=$(find "$directory" -type f -name '*.crt')
    for p in $owners; do
      if [ "$(stat -c %u "$p")" -ne 0 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      warn -s "$check"
      warn "     * Wrong ownership for $directory"
      logcheckresult "WARN" "Wrong ownership for $directory"
      return
    fi
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  info -c "$check"
  info "     * Directory not found"
  logcheckresult "INFO" "Directory not found"
}

check_3_8() {
  local id="3.8"
  local desc="Ensure that registry certificate file permissions are set to 444 or more restrictively (Automated)"
  local remediation="You should run the following command: chmod 444 /etc/podman/certs.d/<registry-name>/*. This would set the permissions for the registry certificate files to 444."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/podman/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    perms=$(find "$directory" -type f -name '*.crt')
    for p in $perms; do
      if [ "$(stat -c %a "$p")" -gt 444 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      warn -s "$check"
      warn "     * Wrong permissions for $directory"
      logcheckresult "WARN" "Wrong permissions for $directory"
      return
    fi
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  info -c "$check"
  info "     * Directory not found"
  logcheckresult "INFO" "Directory not found"
}

check_3_9() {
  local id="3.9"
  local desc="Ensure that TLS CA certificate file ownership is set to root:root (Automated)"
  local remediation="You should run the following command: chown root:root <path to TLS CA certificate file>. This sets the individual ownership and group ownership for the TLS CA certificate file to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  tlscacert=$(get_podman_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -n "$(get_podman_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_podman_configuration_file_args 'tlscacert')
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "     * Wrong ownership for $tlscacert"
    logcheckresult "WARN" "Wrong ownership for $tlscacert"
    return
  fi
  info -c "$check"
  info "     * No TLS CA certificate found"
  logcheckresult "INFO" "No TLS CA certificate found"
}

check_3_10() {
  local id="3.10"
  local desc="Ensure that TLS CA certificate file permissions are set to 444 or more restrictively (Automated)"
  local remediation="You should run the following command: chmod 444 <path to TLS CA certificate file>. This sets the file permissions on the TLS CA file to 444."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  tlscacert=$(get_podman_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -n "$(get_podman_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_podman_configuration_file_args 'tlscacert')
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %a "$tlscacert")" -le 444 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong permissions for $tlscacert"
    logcheckresult "WARN" "Wrong permissions for $tlscacert"
    return
  fi
  info -c "$check"
  info "      * No TLS CA certificate found"
  logcheckresult "INFO" "No TLS CA certificate found"
}

check_3_11() {
  local id="3.11"
  local desc="Ensure that Podman server certificate file ownership is set to root:root (Automated)"
  local remediation="You should run the following command: chown root:root <path to Podman server certificate file>. This sets the individual ownership and the group ownership for the Podman server certificate file to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  tlscert=$(get_podman_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -n "$(get_podman_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_podman_configuration_file_args 'tlscert')
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong ownership for $tlscert"
    logcheckresult "WARN" "Wrong ownership for $tlscert"
    return
  fi
  info -c "$check"
  info "      * No TLS Server certificate found"
  logcheckresult "INFO" "No TLS Server certificate found"
}

check_3_12() {
  local id="3.12"
  local desc="Ensure that the Podman server certificate file permissions are set to 444 or more restrictively (Automated)"
  local remediation="You should run the following command: chmod 444 <path to Podman server certificate file>. This sets the file permissions of the Podman server certificate file to 444."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  tlscert=$(get_podman_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -n "$(get_podman_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_podman_configuration_file_args 'tlscert')
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %a "$tlscert")" -le 444 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong permissions for $tlscert"
    logcheckresult "WARN" "Wrong permissions for $tlscert"
    return
  fi
  info -c "$check"
  info "      * No TLS Server certificate found"
  logcheckresult "INFO" "No TLS Server certificate found"
}

check_3_13() {
  local id="3.13"
  local desc="Ensure that the Podman server certificate key file ownership is set to root:root (Automated)"
  local remediation="You should run the following command: chown root:root <path to Podman server certificate key file>. This sets the individual ownership and group ownership for the Podman server certificate key file to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  tlskey=$(get_podman_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -n "$(get_podman_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_podman_configuration_file_args 'tlskey')
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong ownership for $tlskey"
    logcheckresult "WARN" "Wrong ownership for $tlskey"
    return
  fi
  info -c "$check"
  info "      * No TLS Key found"
  logcheckresult "INFO" "No TLS Key found"
}

check_3_14() {
  local id="3.14"
  local desc="Ensure that the Podman server certificate key file permissions are set to 400 (Automated)"
  local remediation="You should run the following command: chmod 400 <path to Podman server certificate key file>. This sets the Podman server certificate key file permissions to 400."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  tlskey=$(get_podman_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -n "$(get_podman_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_podman_configuration_file_args 'tlskey')
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %a "$tlskey")" -eq 400 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong permissions for $tlskey"
    logcheckresult "WARN" "Wrong permissions for $tlskey"
    return
  fi
  info -c "$check"
  info "      * No TLS Key found"
  logcheckresult "INFO" "No TLS Key found"
}

check_3_15() {
  local id="3.15"
  local desc="Ensure that the Podman socket file ownership is set to root:podman (Automated)"
  local remediation="You should run the following command: chown root:podman /var/run/podman.sock. This sets the ownership to root and group ownership to podman for the default Podman socket file."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/var/run/podman.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:podman' ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong ownership for $file"
    logcheckresult "WARN" "Wrong ownership for $file"
    return
  fi
  info -c "$check"
  info "      * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_16() {
  local id="3.16"
  local desc="Ensure that the Podman socket file permissions are set to 660 or more restrictively (Automated)"
  local remediation="You should run the following command: chmod 660 /var/run/podman.sock. This sets the file permissions of the Podman socket file to 660."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/var/run/podman.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %a $file)" -le 660 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong permissions for $file"
    logcheckresult "WARN" "Wrong permissions for $file"
    return
  fi
  info -c "$check"
  info "      * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_17() {
  local id="3.17"
  local desc="Ensure that the daemon.json file ownership is set to root:root (Automated)"
  local remediation="You should run the following command: chown root:root /etc/podman/daemon.json. This sets the ownership and group ownership for the file to root."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/etc/podman/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong ownership for $file"
    logcheckresult "WARN" "Wrong ownership for $file"
    return
  fi
  info -c "$check"
  info "      * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_18() {
  local id="3.18"
  local desc="Ensure that daemon.json file permissions are set to 644 or more restrictive (Automated)"
  local remediation="You should run the following command: chmod 644 /etc/podman/daemon.json. This sets the file permissions for this file to 644."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/etc/podman/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    warn "      * Wrong permissions for $file"
    logcheckresult "WARN" "Wrong permissions for $file"
    return
  fi
  info -c "$check"
  info "      * File not found"
  logcheckresult "INFO" "File not found"
}

check_3_end() {
  endsectionjson
}
