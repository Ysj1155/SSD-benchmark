# Devlog Day 02 - Cache vs Direct (randread 4k qd32)

## Goal
- Compare page cache ON vs direct I/O to see impact on throughput/latency tail.

## Environment
- OS: Ubuntu 24.04.3 LTS
- Device: SanDisk Extreme Portable SSD (USB, UAS)
- Note: USB2 bandwidth bottleneck suspected on this laptop.

## Command / Script
- scripts/run_cache_compare.sh
- Output: runs/YYYYMMDD_HHMMSS_cache_compare/*.json
- Summary: reports/*cache_compare*_summary.csv

## Results (summary CSV)
Attach / link:
- reports/YYYYMMDD_HHMMSS_cache_compare_summary.csv

Key numbers:
- cache_on:  ~11 MiB/s, p99 ~14 ms
- direct_on: ~31 MiB/s, p99 ~16-17 ms

## Interpretation
- Throughput: direct I/O much higher (cache_on slower likely due to cache behavior + writeback/IO path)
- Tail latency: p99 did not improve with cache; direct shows higher throughput but similar p99 range

## Next
- Repeat run 3 times and average
- Add seq read/write 1M QD1 baseline alongside
- Generate 2 plots: bw (MiB/s), p99 (ms)
