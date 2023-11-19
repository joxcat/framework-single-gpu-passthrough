#!/bin/bash
set -xe
echo "=== $(date) ==="

#Load amd driver
modprobe amdgpu

# Re-Bind GPU to AMD Driver
virsh nodedev-reattach pci_0000_c1_00_1
sleep 1
virsh nodedev-reattach pci_0000_c1_00_0

# Restart Display Manager
systemctl start gdm.service

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind

echo "=== === ==="
