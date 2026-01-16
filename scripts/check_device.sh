#!/bin/bash
set -euo pipefail

echo "=== OS ==="
cat /etc/os-release | sed -n '1,6p'
echo

echo "=== fio ==="
fio --version
echo

echo "=== USB topology (look for 5000M/10000M and Driver=uas) ==="
lsusb -t
echo

echo "=== Block devices ==="
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT,MODEL,TRAN

echo
echo "=== Quick verdict ==="
if lsusb -t | grep -E "Mass Storage" | grep -qE "10000M|5000M"; then
  echo "OK: Storage is on USB 3.x link."
else
  echo "WARN: Storage seems on USB 2.0 (480M). Change port/cable."
fi
