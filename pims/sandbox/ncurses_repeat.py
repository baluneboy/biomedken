#! /usr/bin/env python

"""repeat <shell-command>

This simple program repeatedly (at 1-second intervals) executes the
shell command given on the command line and displays the output (or as
much of it as fits on the screen).  It uses curses to paint each new
output on top of the old output, so that if nothing changes, the
screen doesn't change.  This is handy to watch for changes in e.g. a
directory or process listing.

To end, hit Control-C.
"""

# Author: Guido van Rossum

# Disclaimer: there's a Linux program named 'watch' that does the same
# thing.  Honestly, I didn't know of its existence when I wrote this!

# To do: add features until it has the same functionality as watch(1);
# then compare code size and development time.

# Modified by Ken Hrovat: "Guido...re-use of run...c'mon man!"

import sys
import time
import curses
import subprocess # Guido used popen from os module

# run command # FIXME DANGER using shell=True, user could inject harmful commands!
def run(cmd):
    """run command"""
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE )
    stdout, stderr = proc.communicate()
    if stderr:
        sys.exit(stderr)
    return stdout

# loop to repeat run of command 
def main():
    """loop to repeat run of command"""
    if not sys.argv[1:]:
        print __doc__
        sys.exit(0)
    cmd = " ".join(sys.argv[1:])
    text = run(cmd)
    w = curses.initscr()
    try:
        while True:
            w.erase()
            try:
                w.addstr(0, 0, "Ctrl-C to quit")
                w.addstr(1, 0, text)
                w.addstr(1, 30, text, curses.A_REVERSE)
                w.addstr(text, curses.A_BOLD)
                w.addstr(text, curses.A_UNDERLINE)
            except curses.error:
                pass
            w.refresh()
            time.sleep(1)
            text = run(cmd)
    finally:
        curses.endwin()

if __name__ == "__main__":
    main()
