#!/usr/bin/env python

import sys
import time
import urwid_tasks_ui

################################################################################
## Sample program
################################################################################
def main(i, remaining_minutes):
    information = [('Program:',           'Test program'),
                   ('Minutes Remaining:', '%.1f' % remaining_minutes),
                   ('Iteration:',         '%d' % i ),
                   ('South:',             'Not north')
                  ]

    dir_list  = 'ls -l /tmp'
    dir_list2 = 'ls -l /tmp/*.pdf'
    whoami    = '/usr/bin/whoami'
    date_time = '/bin/date'
    sleep     = '/bin/sleep 1'

    my_tasks = []

    ## Create a set of arbitrary tasks, delay two seconds after each command so
    ## the program doesn't execute too quickly

    my_tasks.append({'description' : u"File Listing",
                         'commands'    : [dir_list, sleep]
                        })

    my_tasks.append({'description' : u"Basic Information",
                         'commands'    : [whoami, sleep, date_time, sleep]
                        })

    my_tasks.append({'description' : u"File Listing 2",
                         'commands'    : [dir_list2, sleep]
                        })

    UI = urwid_tasks_ui.JobInterface('URWID Task Processor Demo', 'Task List',
                                     information, my_tasks, progress_bar=True)

    UI.main()

if __name__ == '__main__':

    timeout_minutes = float(sys.argv[1])
    iteration = 0
    timeout = time.time() + 60*timeout_minutes
    while True:
        remaining_minutes = ( timeout - time.time() ) / 60.0
        if remaining_minutes <= 0:
            break
        iteration += 1
        main(iteration, remaining_minutes)
