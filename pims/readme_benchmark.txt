given the following:
1. sensor
2. gmt_span
3. metric (like 10-minute interval rms)
4. summary_stat (median, 95th percentile, min, max, mean)

do this:
1. compute metric for sensor during gmt_span
2. produce summary_stat

then, after we have the benchmark, overlay this on existing near real-time plot (ftw)!
