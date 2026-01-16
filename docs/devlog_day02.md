# DevLog Day02 – Cache vs Direct I/O (randread 4K QD32)

## 목적
Baseline 실험에서 randread(4K QD32)의 p99 latency가 상대적으로 크게 나타났다.
해당 지연이 page cache 영향인지, 실제 디바이스/버스 병목인지 확인하기 위해
direct I/O on/off 비교 실험을 수행했다.

## 실험 환경
- OS: Ubuntu 24.04
- Device: SanDisk Extreme Portable SSD (USB2 연결)
- Filesystem: exFAT
- Tool: fio 3.36
- Workload: randread / 4K / QD32 / runtime 45s
- 비교 조건:
  - direct=0 (page cache on)
  - direct=1 (direct I/O)

## 결과
요약 CSV:  
`reports/20260116_211350_cache_compare_summary.csv`

| mode | BW (MiB/s) | IOPS | mean latency (ms) | p99 latency (ms) |
|-----|------------|------|-------------------|------------------|
| cache on | ~11 | ~2.8k | ~11 | ~14 |
| direct on | ~31 | ~7.9k | ~4 | ~16 |

## 해석
- direct I/O 사용 시 처리량과 평균 지연이 크게 개선되었다.
- page cache가 활성화된 경우, 랜덤 + 높은 큐뎁스 + USB2 환경에서는
  캐시 이점보다 커널 경합 및 메모리 오버헤드가 더 크게 작용한 것으로 보인다.
- 다만 p99 latency는 direct I/O에서 소폭 증가하여,
  평균 성능과 꼬리 지연 사이의 트레이드오프를 확인했다.

## 다음 단계
- small-file workload에서 동일 현상이 재현되는지 확인
- USB3 환경에서 동일 실험 수행 후 비교