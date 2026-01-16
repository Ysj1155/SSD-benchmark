# Day 01 – Project Setup (Ubuntu 24.04.3)

## Goal
Turn ad-hoc terminal benchmarking into a reproducible mini-lab.

## Environment
- Ubuntu 24.04.3 LTS
- fio 3.36
- Python venv (.venv)

## What I did
- Created repo structure: scripts/, runs/, reports/, docs/, src/
- Added smoke benchmark script with JSON + log output
- Added Python parser and PyCharm Run config for summary

## Next
- Plug SanDisk SSD and verify USB link speed (5000M vs 10000M) and UASP (uas)
- Add baseline 4 workloads and parser for BW/avg/p99 latency
