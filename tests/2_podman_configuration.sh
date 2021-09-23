#!/bin/bash

check_2() {
  logit ""
  local id="2"
  local desc="Podman service configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_2_1() {
  local id="2.1"
  local desc="Run the Podman service as a non-root user, if possible (Manual)"
  local remediation="Follow the current Podman documentation on how to install the Podman service as a non-root user."
  local remediationImpact="There are multiple prerequisites depending on which distribution that is in use, and also known limitations regarding networking and resource limitation. Running in rootless mode also changes the location of any configuration files in use, including all containers using the service."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_2_3() {
  local id="2.3"
  local desc="Ensure the logging level is set to 'info' (Scored)"
  local remediation="Ensure that the Podman service configuration file has the following configuration included log-level: info. Alternatively, run the Podman service as following: podmand --log-level=info"
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_configuration_file_args 'log-level' >/dev/null 2>&1; then
    if get_podman_configuration_file_args 'log-level' | grep info >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    if [ -z "$(get_podman_configuration_file_args 'log-level')" ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if get_podman_effective_command_line_args '-l'; then
    if get_podman_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_4() {
  local id="2.4"
  local desc="Ensure Podman is allowed to make changes to iptables (Scored)"
  local remediation="Do not run the Podman service with --iptables=false option."
  local remediationImpact="The Podman service service requires iptables rules to be enabled before it starts."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if get_podman_configuration_file_args 'iptables' | grep "false" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_5() {
  local id="2.5"
  local desc="Ensure insecure registries are not used (Scored)"
  local remediation="You should ensure that no insecure registries are in use."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if ! [ -z "$(get_podman_configuration_file_args 'insecure-registries')" ]; then
    if get_podman_configuration_file_args 'insecure-registries' | grep '\[]' >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_6() {
  local id="2.6"
  local desc="Ensure aufs storage driver is not used (Scored)"
  local remediation="Do not start Podman service as using podmand --storage-driver aufs option."
  local remediationImpact="aufs is the only storage driver that allows containers to share executable and shared  library memory. Its use should be reviewed in line with your organization's security policy."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if podman info 2>/dev/null | grep -e "^\sStorage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_7() {
  local id="2.7"
  local desc="Ensure TLS authentication for Podman service is configured (Scored)"
  local remediation="Follow the steps mentioned in the Podman documentation or other references. By default, TLS authentication is not configured."
  local remediationImpact="You would need to manage and guard certificates and keys for the Podman service and Podman clients."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if [ $(get_podman_configuration_file_args 'tcp://') ] || \
    [ $(get_podman_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://') >/dev/null 2>&1 ]; then
    if [ $(get_podman_configuration_file_args '"tlsverify":' | grep 'true') ] || \
        [ $(get_podman_cumulative_command_line_args '--tlsverify' | grep 'tlsverify') >/dev/null 2>&1 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    if [ $(get_podman_configuration_file_args '"tls":' | grep 'true') ] || \
        [ $(get_podman_cumulative_command_line_args '--tls' | grep 'tls$') >/dev/null 2>&1 ]; then
      warn -s "$check"
      warn "     * Podman service currently listening on TCP with TLS, but no verification"
      logcheckresult "WARN" "Podman service currently listening on TCP with TLS, but no verification"
      return
    fi
    warn -s "$check"
    warn "     * Podman service currently listening on TCP without TLS"
    logcheckresult "WARN" "Podman service currently listening on TCP without TLS"
    return
  fi
  info -c "$check"
  info "     * Podman service not listening on TCP"
  logcheckresult "INFO" "Podman service not listening on TCP"
}

check_2_8() {
  local id="2.8"
  local desc="Ensure the default ulimit is configured appropriately (Manual)"
  local remediation="Run Podman in service mode and pass --default-ulimit as option with respective ulimits as appropriate in your environment and in line with your security policy. Example: podmand --default-ulimit nproc=1024:2048 --default-ulimit nofile=100:200"
  local remediationImpact="If ulimits are set incorrectly this could cause issues with system resources, possibly causing a denial of service condition."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_configuration_file_args 'default-ulimit' | grep -v '{}' >/dev/null 2>&1; then
    pass -c "$check"
    logcheckresult "PASS"
    return
  fi
  if get_podman_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
    pass -c "$check"
    logcheckresult "PASS"
    return
  fi
  info -c "$check"
  info "     * Default ulimit doesn't appear to be set"
  logcheckresult "INFO" "Default ulimit doesn't appear to be set"
}

check_2_10() {
  local id="2.10"
  local desc="Ensure the default cgroup usage has been confirmed (Scored)"
  local remediation="The default setting is in line with good security practice and can be left in situ."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_configuration_file_args 'cgroup-parent' | grep -v ''; then
    warn -s "$check"
    info "     * Confirm cgroup usage"
    logcheckresult "WARN" "Confirm cgroup usage"
    return
  fi
  if get_podman_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
    warn -s "$check"
    info "     * Confirm cgroup usage"
    logcheckresult "WARN" "Confirm cgroup usage"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_11() {
  local id="2.11"
  local desc="Ensure base device size is not changed until needed (Scored)"
  local remediation="Do not set --storage-opt dm.basesize until needed."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_configuration_file_args 'storage-opts' | grep "dm.basesize" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if get_podman_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_13() {
  local id="2.13"
  local desc="Ensure centralized and remote logging is configured (Scored)"
  local remediation="Set up the desired log driver following its documentation. Start the podman service using that logging driver. Example: podmand --log-driver=syslog --log-opt syslog-address=tcp://192.xxx.xxx.xxx"
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if podman info --format '{{ .Host.LogDriver }}' | grep 'json-file' >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_14() {
  local id="2.14"
  local desc="Ensure containers are restricted from acquiring new privileges (Scored)"
  local remediation="You should run the Podman containers with podman run --no-new-privileges"
  local remediationImpact="no_new_priv prevents LSMs such as SELinux from escalating the privileges of individual containers."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_podman_effective_command_line_args '--no-new-privileges' | grep "no-new-privileges" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if get_podman_configuration_file_args 'no-new-privileges' | grep true >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_16() {
  local id="2.16"
  local desc="Ensure that a service-wide SELinux is enabled (Scored)"
  local remediation="You should run the Podman by default with SELinux enabled on SELinux enabled machines"
  local remediationImpact="With SELinux disabled, container escape is much less secured. SELinux has shown itself to prevent many unkonwn container priviledge escalations."
  local check="$id - $desc"
  starttestjson "$id" "$desc"
  if [ selinuxenabled ]; then
     if podman info --format '{{ .Host.Security.SELinuxEnabled }}' | grep true >/dev/null 2>&1; then
      pass -c "$check"
      logcheckresult "PASS"
      return
     fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  info -c "$check"
  logcheckresult "INFO"
}

check_2_17() {
  local id="2.17"
  local desc="Ensure that a service-wide custom seccomp profile is applied if appropriate (Manual)"
  local remediation="By default, Podman's default seccomp profile is applied. If this is adequate for your environment, no action is necessary."
  local remediationImpact="A misconfigured seccomp profile could possibly interrupt your container environment. You should therefore exercise extreme care if you choose to override the default settings."
  local check="$id - $desc"
  starttestjson "$id" "$desc"
  if podman info --format '{{ .Host.Security.SECCOMPEnabled }}' | grep true >/dev/null 2>&1; then
      if podman info --format '{{ .Host.Security.SECCOMPProfilePath }}'| grep '/usr/share/containers/seccomp.json' 2>/dev/null 1>&2; then
	  pass -c "$check"
	  logcheckresult "PASS"
	  return
      fi
      warn -s "$check"
      logcheckresult "WARN"
      return
  fi
  info -c "$check"
  logcheckresult "INFO"
}

check_2_end() {
  endsectionjson
}
