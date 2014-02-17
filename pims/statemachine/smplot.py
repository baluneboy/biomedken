#!/usr/bin/python

from smachine import StateMachine

# a state machine for plot parameters
class PlotParametersStateMachine(StateMachine):
    state = None
    states = ['monitor', 'found', 'pending', 'deployed', 'problem']
    transitions = {
        None:       ['monitor'],
        'monitor':  ['found'],
        'found':    ['pending'],
        'pending':  ['deployed', 'problem'],
        'deployed': ['monitor'],
        'problem':  ['monitor'],
    }

    def __init__(self):
        self.monitor() # start with monitor

    def on_enter_monitor(self, from_state=None, to_state=None):
        if from_state == None:
            # initial entry point
            print 'initial entry point, start monitoring'
            return True
        elif from_state == 'problem':
            print 'reset after problem, restart monitoring'
            return True
        elif from_state == 'deployed':
            print 'done with previous deployment, start monitoring'
            return True
        else:
            return False

    def on_enter_found(self, from_state=None, to_state=None):
        if from_state == 'monitor':
            # found a file to be processed
            print 'a file to be processed was found'
            return True
        else:
            return False

    def on_enter_pending(self, from_state=None, to_state=None):
        if from_state == 'found':
            # now do processing
            print 'file being processed, deployment still pending'
            return True
        else:
            return False

    def on_enter_problem(self, from_state=None, to_state=None, msg=None):
        if from_state == 'pending':
            if msg:
                print '%s problem: %s' % (self.__class__.__name__, msg)
            return True
        else:
            return False

    def on_enter_deployed(self, from_state=None, to_state=None):
        if from_state == 'pending':
            # we done did it
            print 'new file was deployed'
            return True
        else:
            return False

if __name__ == "__main__":
    
    # create machine to maintain state info
    machine = PlotParametersStateMachine()
    
    # a bad sequence
    sequence = ['found', 'pending']
    for s in sequence:
        machine.push(s)
        machine.next()
    machine.problem('a big issue')

    # a good sequence
    sequence = ['monitor', 'found', 'pending', 'deployed', 'monitor']
    for s in sequence:
        machine.push(s)
        machine.next()
