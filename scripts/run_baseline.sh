#!/bin/bash
set -euo pipefail

# 0) paths
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS_DIR="$ROOT_DIR/runs/$(date +%Y%m%d_%H%M%S)_baseline"

# 1) SSD mountpoint (prefer configs/device.env)
CONFIG="$ROOT_DIR/configs/device.env"
TESTDIR_NAME="fio_test"

if [ -f "$CONFIG" ]; then
  # shellcheck disable=SC1090
  source "$CONFIG"
fi

if [ -z "${MNT:-}" ]; then
  echo "INFO: MNT not set in configs/device.env, trying auto-detect..."
  # Try to find an external USB disk mountpoint that looks like SanDisk/Extreme
  MNT="$(lsblk -o TRAN,MODEL,MOUNTPOINT -nr \
    | awk '$1=="usb" && $3!="" {print $0}' \
    | grep -iE 'SanDisk|Extreme' \
    | head -n1 \
    | awk '{print $NF}')"
fi

if [ -z "${MNT:-}" ]; then
  echo "ERROR: Could not determine SSD mountpoint."
  echo "Run: lsblk -o TRAN,MODEL,MOUNTPOINT and set MNT in configs/device.env"
  exit 1
fi

TESTDIR="$MNT/$TESTDIR_NAME"

mkdir -p "$RUNS_DIR" "$TESTDIR"

echo "Mountpoint : $MNT"
echo "Test dir   : $TESTDIR"
echo "Runs dir   : $RUNS_DIR"
echo

COMMON=(
  --ioengine=libaio
  --direct=1
  --time_based=1
  --runtime=60
  --size=1g
  --numjobs=1
  --group_reporting
  --filename=jobfile
)

run_fio () {
  local name="$1"; shift
  echo "=== RUN $name ==="
  fio --name="$name" --directory="$TESTDIR" "${COMMON[@]}" "$@" \
  --output="$RUNS_DIR/${name}.json" --output-format=json \
  >"$RUNS_DIR/${name}.stdout.log" 2>"$RUNS_DIR/${name}.stderr.log"
  echo
}

run_fio seq_read_1m_qd1       --rw=read      --bs=1m --iodepth=1
run_fio seq_write_1m_qd1      --rw=write     --bs=1m --iodepth=1
run_fio rand_read_4k_qd32     --rw=randread  --bs=4k --iodepth=32
run_fio rand_write_4k_qd32    --rw=randwrite --bs=4k --iodepth=32

echo "Done. Results in: $RUNS_DIR"
