#!/usr/bin/env bash
# File: Ansible

set -x
# Install ansibele to setup server configuration process
function ansible {
  sudo apt-get update -y
  sudo apt-get install software-properties-common -y
  sudo apt-add-repository ppa:ansible/ansible -y
  sudo apt-get update -y
  sudo apt-get install ansible -y
}

ansible