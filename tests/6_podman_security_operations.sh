#!/bin/bash

check_6() {
  logit ""
  local id="6"
  local desc="Podman Security Operations"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_6_1() {
  local id="6.1"
  local desc="Ensure that image sprawl is avoided (Manual)"
  local remediation="You should keep only the images that you actually need and establish a workflow to remove old or stale images from the host. Additionally, you should use features such as pull-by-digest to get specific images from the registry."
  local remediationImpact="podman system prune -a removes all exited containers as well as all images and volumes that are not referenced by running containers, including for UCP and DTR."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  images=$(podman images -q | sort -u | wc -l | awk '{print $1}')
  active_images=0

  for c in $(podman inspect --format "{{.Image}}" "$(podman ps -qa)" 2>/dev/null); do
    if podman images --no-trunc -a | grep "$c" > /dev/null ; then
      active_images=$(( active_images += 1 ))
    fi
  done

  info -c "$check"
  info "     * There are currently: $images images"

  if [ "$active_images" -lt "$((images / 2))" ]; then
    info "     * Only $active_images out of $images are in use"
  fi
  logcheckresult "INFO" "$active_images active/$images in use"
}

check_6_2() {
  local id="6.2"
  local desc="Ensure that container sprawl is avoided (Manual)"
  local remediation="You should periodically check your container inventory on each host and clean up containers which are not in active use with the command: podman container prune"
  local remediationImpact="You should retain containers that are actively in use, and delete ones which are no longer needed."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  total_containers=$(podman info 2>/dev/null | grep "Containers" | awk '{print $2}')
  running_containers=$(podman ps -q | wc -l | awk '{print $1}')
  diff="$((total_containers - running_containers))"
  info -c "$check"
  if [ "$diff" -gt 25 ]; then
    info "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
  else
    info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
  fi
  logcheckresult "INFO" "$total_containers total/$running_containers running"
}

check_6_end() {
  endsectionjson
}
