#!/usr/bin/python

from smachine import StateMachine, StateException

class PlotParamStateMachine(StateMachine):
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
        self.monitor()

    def on_enter_monitor(self, from_state=None, to_state=None):
        if from_state == None:
            return True
        elif from_state == 'problem':
            return True
        elif from_state == 'deployed':
            return True
        else:
            return False

    def on_enter_found(self, from_state=None, to_state=None):
        if from_state == 'monitor':
            return True
        else:
            return False

    def on_enter_pending(self, from_state=None, to_state=None):
        if from_state == 'found':
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
            return True
        else:
            return False
