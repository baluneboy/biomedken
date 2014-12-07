#!/usr/bin/env python

import urwid_tasks_ui

################################################################################
## Sample program
################################################################################
def main():
  information = [('Program:',         'Test program'),
                 ('Message:',         'Hello World'),
                 ('Meaning of life:', '42'),
                 ('South:',           'Not north')
                ]

  dir_list  = 'ls -l'
  whoami    = '/usr/bin/whoami'
  date_time = '/bin/date'
  sleep     = '/bin/sleep 2'

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
                       'commands'    : [dir_list, sleep]
                      })

  my_tasks.append({'description' : u"All at once",
                       'commands'    : [dir_list, sleep, whoami, sleep, date_time, sleep]
                      })


  UI = urwid_tasks_ui.JobInterface('URWID Task Processor Demo', 'Task List', 
information, my_tasks, progress_bar = True)
  
  UI.main()


if __name__ == '__main__':
    main()