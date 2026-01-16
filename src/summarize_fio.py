import json
import sys
from pathlib import Path
import csv

def mib_per_s(bw_kib_s: float) -> float:
    return bw_kib_s / 1024.0

def ns_to_ms(x: float) -> float:
    return x / 1e6

def load_one(json_path: Path):
    data = json.loads(json_path.read_text())
    job = data["jobs"][0]

    read = job.get("read", {}) or {}
    write = job.get("write", {}) or {}

    r_bytes = read.get("io_bytes", 0) or 0
    w_bytes = write.get("io_bytes", 0) or 0
    sect = read if r_bytes >= w_bytes else write
    mode = "read" if sect is read else "write"

    bw = sect.get("bw", 0) or 0          # KiB/s
    iops = sect.get("iops", 0.0) or 0.0

    lat_ns = sect.get("lat_ns", {}) or {}
    lat_mean = lat_ns.get("mean", None)

    p99 = None
    clat = sect.get("clat_ns", {}) or {}
    perc = clat.get("percentile", None) or lat_ns.get("percentile", None)
    if isinstance(perc, dict):
        for k in perc.keys():
            if str(k).startswith("99"):
                p99 = perc[k]
                break

    return {
        "file": json_path.name,
        "op": mode,
        "bw_mib_s": round(mib_per_s(float(bw)), 2),
        "iops": round(float(iops), 2),
        "lat_mean_ms": (round(ns_to_ms(float(lat_mean)), 3) if lat_mean is not None else ""),
        "clat_p99_ms": (round(ns_to_ms(float(p99)), 3) if p99 is not None else ""),
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: python src/summarize_fio.py <runs_dir>", file=sys.stderr)
        sys.exit(2)

    runs_dir = Path(sys.argv[1]).expanduser().resolve()
    if not runs_dir.is_dir():
        raise SystemExit(f"Not a directory: {runs_dir}")

    rows = []
    for p in sorted(runs_dir.glob("*.json")):
        try:
            rows.append(load_one(p))
        except Exception as e:
            rows.append({
                "file": p.name,
                "op": "ERR",
                "bw_mib_s": "",
                "iops": "",
                "lat_mean_ms": "",
                "clat_p99_ms": f"parse_fail: {e}",
            })

    out = Path("reports") / f"{runs_dir.name}_summary.csv"
    out.parent.mkdir(parents=True, exist_ok=True)

    with out.open("w", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["file", "op", "bw_mib_s", "iops", "lat_mean_ms", "clat_p99_ms"],
        )
        w.writeheader()
        w.writerows(rows)

    print(f"Wrote: {out} ({len(rows)} rows)")

if __name__ == "__main__":
    main()
