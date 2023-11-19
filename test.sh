#!/bin/sh
set -x
/bin/fw-vfio-up.sh 2>&1 | tee -a /var/tmp/vfio.log
sleep 5
/bin/fw-vfio-down.sh 2>&1 | tee -a /var/tmp/vfio.log
sleep 30
shutdown +0
