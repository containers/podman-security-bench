#!/bin/bash

check_1() {
  logit ""
  local id="1"
  local desc="Host Configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_1_1() {
  local id="1.1"
  local desc="Linux Hosts Specific Configuration"
  local check="$id - $desc"
  info "$check"
}

check_1_1_1() {
  local id="1.1.1"
  local desc="Ensure a separate partition for containers has been created (Automated)"
  local remediation="For new installations, you should create a separate partition for the /var/lib/containers mount point. For systems that have already been installed, you should use the Logical Volume Manager (LVM) within Linux to create a new partition."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  podman_root_dir=$(podman info -f '{{ .Store.GraphRoot }}')
  if podman info | grep -q userns ; then
    podman_root_dir=$(readlink -f "$podman_root_dir/..")
  fi

  if mountpoint -q -- "$podman_root_dir" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_1_1_3() {
  local id="1.1.3"
  local desc="Ensure auditing is configured for the Podman executable(Automated)"
  local remediation="Install auditd. Add -w /usr/bin/podman -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/usr/bin/podman"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_4() {
  local id="1.1.4"
  local desc="Ensure auditing is configured for Podman files and directories -/run/podman (Automated)"
  local remediation="Install auditd. Add -a exit,always -F path=/run/podman -F perm=war -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/run/podman"
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_1_1_5() {
  local id="1.1.5"
  local desc="Ensure auditing is configured for Podman files and directories - /var/lib/containers (Automated)"
  local remediation="Install auditd. Add -w /var/lib/containers -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  directory="/var/lib/containers"
  audit_dir_check $directory "$check" "$auditrules"
}

check_1_1_6() {
  local id="1.1.6"
  local desc="Ensure auditing is configured for Podman files and directories - /etc/containers (Automated)"
  local remediation="Install auditd. Add -w /etc/containers -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/containers"
  audit_dir_check $directory "$check" "$auditrules"
}

check_1_1_7() {
  local id="1.1.7"
  local desc="Ensure auditing is configured for Podman files and directories - podman.service (Automated)"
  local remediation
  remediation="Install auditd. Add -w $(get_service_file podman.service) -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file podman.service)"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
        return
      fi
      warn -s "$check"
      logcheckresult "WARN"
      return
    fi
    if grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  info -c "$check"
  info "       * File not found"
  logcheckresult "INFO" "File not found"
}

audit_dir_check() {
  directory=$1
  check=$2
  auditrules=$3
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
        return
      fi
      warn -s "$check"
      logcheckresult "WARN"
      return
    fi
    if grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  info -c "$check"
  info "       * Directory not found"
  logcheckresult "INFO" "Directory not found"
}
 
audit_file_check() {
    file=$1
    check=$2
    auditrules=$3
    
    if [ -e "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
        return
      fi
      warn -s "$check"
      logcheckresult "WARN"
      return
    fi
    if grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  info -c "$check"
  info "       * File not found"
  logcheckresult "INFO" "File not found"
}

check_1_1_9() {
  local id="1.1.9"
  local desc="Ensure auditing is configured for Podman files and directories - podman.socket (Automated)"
  local remediation
  remediation="Install auditd. Add -w $(get_service_file podman.socket) -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file podman.socket)"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_10() {
  local id="1.1.10"
  local desc="Ensure auditing is configured for Podman files and directories - /usr/share/containers/containers.conf (Automated)"
  local remediation="Install auditd. Add -w /usr/share/containers/containers.conf -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/usr/share/containers/containers.conf"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_11() {
  local id="1.1.11"
  local desc="Ensure auditing is configured for Podman files and directories - /etc/containers/containers.conf (Automated)"
  local remediation="Install auditd. Add -w /etc/containers/containers.conf -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/etc/containers/containers.conf"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_12() {
  local id="1.1.12"
  local desc="1.1.12 Ensure auditing is configured for Podmanfiles and directories - /etc/containers/storage.conf (Automated)"
  local remediation="Install auditd. Add -w /etc/containers/storage.conf -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/etc/containers/storage.conf"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_14() {
  local id="1.1.14"
  local desc="Ensure auditing is configured for Podman files and directories - /usr/bin/podman (Automated)"
  local remediation="Install auditd. Add -w /usr/bin/podman -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/usr/bin/podman"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_17() {
  local id="1.1.18"
  local desc="Ensure auditing is configured for Podman files and directories - /usr/bin/crun (Automated)"
  local remediation="Install auditd. Add -w /usr/bin/crun -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/usr/bin/crun"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_1_18() {
  local id="1.1.18"
  local desc="Ensure auditing is configured for Podman files and directories - /usr/bin/runc (Automated)"
  local remediation="Install auditd. Add -w /usr/bin/runc -k podman to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  file="/usr/bin/runc"
  audit_file_check "$file" "$check" "$auditrules"
}

check_1_2() {
  local id="1.2"
  local desc="General Configuration"
  local check="$id - $desc"
  info "$check"
}

check_1_2_1() {
  local id="1.2.1"
  local desc="Ensure the container host has been Hardened (Manual)"
  local remediation="You may consider various Security Benchmarks for your container host."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_1_2_2() {
  local id="1.2.2"
  local desc="Ensure that the version of Podman is up to date (Manual)"
  local remediation="You should monitor versions of Podman releases and make sure your software is updated as required."
  local remediationImpact="You should perform a risk assessment regarding Podman version updates and review how they may impact your operations."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  podman_version=$(podman version | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  podman_current_version="$(date +%y.%m.0 -d @$(( $(date +%s) - 2592000)))"
  do_version_check "$podman_current_version" "$podman_version"
  if [ $? -eq 11 ]; then
    pass -c "$check"
    info "       * Using $podman_version, verify is it up to date as deemed necessary"
    logcheckresult "INFO" "Using $podman_version"
    return
  fi
  pass -c "$check"
  info "       * Using $podman_version which is current"
  info "       * Check with your operating system vendor for support and security maintenance for Podman"
  logcheckresult "PASS" "Using $podman_version"
}

check_1_end() {
  endsectionjson
}
