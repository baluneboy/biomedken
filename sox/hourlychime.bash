#!/usr/bin/env bash

## hourly chime
PLAY=/usr/bin/play
$PLAY -n synth -j 3 sin %3 sin %-2 sin %-5 sin %-9 sin %-14 sin %-21 fade h .01 2 1.5 delay 1.3 1 .76 .54 .27 remix - fade h 0 2.7 2.5 norm -1 vol 0.5
