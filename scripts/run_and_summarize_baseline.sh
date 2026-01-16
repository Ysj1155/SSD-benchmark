#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1) baseline 실행
"$ROOT_DIR/scripts/run_baseline.sh"

# 2) 가장 최근 baseline 폴더 찾기
LATEST="$(ls -1dt "$ROOT_DIR"/runs/*_baseline | head -n1)"

# 3) 요약 CSV 생성
python "$ROOT_DIR/src/summarize_fio.py" "$LATEST"

# 4) 요약 CSV 출력
CSV="$ROOT_DIR/reports/$(basename "$LATEST")_summary.csv"
echo
echo "=== SUMMARY CSV ==="
cat "$CSV"
echo
echo "DONE: $LATEST"
