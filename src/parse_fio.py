import json
from pathlib import Path

RUNS_DIR = Path(__file__).resolve().parents[1] / "runs"

def mbps(bw_kib: float) -> float:
    return bw_kib / 1024.0

def main():
    p = RUNS_DIR / "smoke.json"
    if not p.exists():
        raise FileNotFoundError(f"Missing {p}. Run ./scripts/run_smoke.sh first.")

    data = json.loads(p.read_text())
    job = data["jobs"][0]
    read = job["read"]

    iops = read.get("iops")
    bw_kib = read.get("bw")  # KiB/s
    lat_ns = read.get("lat_ns", {})
    lat_mean_ns = lat_ns.get("mean")

    print("=== fio smoke summary ===")
    print(f"IOPS: {iops:.2f}")
    print(f"BW:   {mbps(bw_kib):.2f} MiB/s")
    if lat_mean_ns is not None:
        print(f"Lat(mean): {lat_mean_ns/1e6:.3f} ms")
    else:
        print("Lat(mean): n/a")

if __name__ == "__main__":
    main()
