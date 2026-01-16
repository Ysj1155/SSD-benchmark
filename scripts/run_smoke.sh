#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/runs"
mkdir -p "$OUT_DIR"

fio --name=smoke \
  --rw=read --bs=1m --iodepth=1 --numjobs=1 --direct=1 \
  --size=1g --time_based=1 --runtime=10 \
  --output="$OUT_DIR/smoke.json" --output-format=json \
  | tee "$OUT_DIR/smoke.log"
