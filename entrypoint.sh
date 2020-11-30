#!/usr/bin/env bash
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

#sudo chown root:kvm /dev/kvm
#sudo usermod -a -G kvm developer

# Check for KVM issues.
#sudo virt-host-validate | grep -v -e ": PASS"

#qemu-system-x86_64 -m 2048 -enable-kvm -drive if=virtio,file=${HOME}/qemu/test.qcow2,cache=none

/bin/sleep infinity
