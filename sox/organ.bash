#!/usr/bin/env bash

# plays a synthesised ‘A minor seventh’ chord with a pipe-organ sound

PLAY=/usr/bin/play
$PLAY -n -c1 synth sin %-12 sin %-9 sin %-5 sin %-2 fade h 0.1 1 0.1

## guitar chord
#play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4 delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1 norm -1 # guitar chord

## hourly chime
#play -n synth -j 3 sin %3 sin %-2 sin %-5 sin %-9 sin %-14 sin %-21 fade h .01 2 1.5 delay 1.3 1 .76 .54 .27 remix - fade h 0 2.7 2.5 norm -1 vol 0.5 # chime
