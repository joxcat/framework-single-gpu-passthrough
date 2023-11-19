#!/bin/bash
# Helpful to read output when debugging
set -xe
echo "=== $(date) ==="

VIDEO="c1_00_0"
VIDEO1="c1:00.0"
AUDIO="c1_00_1"
AUDIO1="c1:00.1"

# Stop display manager (Gnome specific)
systemctl stop gdm.service

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind

# Syncing Disk and clearing The Caches(RAM)
sync; echo 1 > /proc/sys/vm/drop_caches

# Un-Binding GPU From driver
sleep 2
echo "0000:$VIDEO1" > "/sys/bus/pci/devices/0000:$VIDEO1/driver/unbind"
echo "0000:$AUDIO1" > "/sys/bus/pci/devices/0000:$AUDIO1/driver/unbind"

# Waiting for AMD GPU To Finish
# Loop Variables
declare -i Loop
Loop=1
declare -i TimeOut
TimeOut=5
while ! (dmesg | grep "amdgpu 0000:$VIDEO1" | tail -5 | grep "amdgpu: finishing device."); do 
    echo "Loop-1"; 
    if [ "$Loop" -le "$TimeOut" ]; then
        echo "Waiting"; 
        TimeOut+=1; 
        echo "Try: $TimeOut"; 
        sleep 1; 
    else break;
    fi; 
done

# Unbind the GPU from display driver
virsh nodedev-detach "pci_0000_$VIDEO"
sleep 1
virsh nodedev-detach "pci_0000_$AUDIO"

# Unload AMD drivers
modprobe -r amdgpu

# Reseting The Loop Counter
Loop=1
# Making Sure that AMD GPU is Un-Loaded
while (lsmod | grep amdgpu); do 
    echo "Loop-3"; 
    if [ "$Loop" -le "$TimeOut" ]; then
        echo "AMD GPU in use"; 
        lsmod | grep amdgpu | awk '{print $1}' | while read -r AM; do 
            modprobe -r "$AM"; 
        done;
        TimeOut+=1; 
        echo "AMDGPU try: $TimeOut"; 
        sleep 1; 
    else 
        echo "Fail To Remove AMD GPU";
        rmmod amdgpu; 
        break;
    fi;
done

# Garbage collection
unset Loop
unset TimeOut

echo "=== === ==="
