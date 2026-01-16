#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/configs/device.env"
source "$CONFIG"

RUNS_DIR="$ROOT_DIR/runs/$(date +%Y%m%d_%H%M%S)_cache_compare"
TESTDIR="$MNT/fio_test_cache_compare"
mkdir -p "$RUNS_DIR" "$TESTDIR"

COMMON=(
  --ioengine=libaio
  --time_based=1
  --runtime=45
  --size=1g
  --numjobs=1
  --group_reporting
  --filename=jobfile
  --rw=randread
  --bs=4k
  --iodepth=32
)

run_one () {
  local name="$1"; shift
  fio --name="$name" --directory="$TESTDIR" "${COMMON[@]}" "$@" \
    --output="$RUNS_DIR/${name}.json" --output-format=json \
    >"$RUNS_DIR/${name}.stdout.log" 2>"$RUNS_DIR/${name}.stderr.log"
}

echo "Runs dir: $RUNS_DIR"
run_one randread_cache_on  --direct=0
sync
run_one randread_direct_on --direct=1

python3 "$ROOT_DIR/src/summarize_fio.py" "$RUNS_DIR"
cat "$ROOT_DIR/reports/$(basename "$RUNS_DIR")_summary.csv"
