cat <<'EOF' > scripts/run_smallfile_test.sh
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../configs/device.env"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS_DIR="$ROOT_DIR/runs/$(date +%Y%m%d_%H%M%S)_smallfile"
TESTDIR="$MNT/$TESTDIR_NAME/smallfile"

mkdir -p "$RUNS_DIR" "$TESTDIR"

echo "Creating many small files..."
time bash -c "for i in \$(seq 1 20000); do echo \$i > \"$TESTDIR/f_\$i.txt\"; done" \
  |& tee "$RUNS_DIR/create.log"

sync

echo "Stat scan..."
time find "$TESTDIR" -type f -printf '.' | wc -c |& tee "$RUNS_DIR/find_count.log"

echo "Deleting..."
time rm -f "$TESTDIR"/f_*.txt |& tee "$RUNS_DIR/delete.log"
sync

echo "DONE: $RUNS_DIR"
EOF

chmod +x scripts/run_smallfile_test.sh
