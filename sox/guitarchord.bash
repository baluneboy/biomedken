#!/usr/bin/env bash

# guitar chord
PLAY=/usr/bin/play
$PLAY -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4 delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1 norm -1 vol 0.3
