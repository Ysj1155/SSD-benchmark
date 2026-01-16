# SSD-benchmark

## Experiments
- Baseline fio benchmarks (seq/rand read/write)
- Cache vs Direct I/O comparison (randread 4K QD32)

Key finding:
- In USB2 environment, direct I/O improved randread throughput by ~3×
  while slightly increasing p99 latency.

Detailed analysis:
- docs/devlog_day02.md
