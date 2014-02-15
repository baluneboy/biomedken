#!/usr/bin/python

import unittest
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

class TestPlotParamStateMachine(unittest.TestCase):

    def test_state_transitions(self):

        # create machine to maintain state info
        machine = PlotParamStateMachine()

        # test initial state
        self.assertEqual('monitor', machine.state)

        # change state from problem to found returns True
        self.assertTrue( machine.found() )

        # verify state is now found
        self.assertEqual('found', machine.state)

        # change state from found to pending returns True
        self.assertTrue( machine.pending() )

        # verify state is now pending
        self.assertEqual('pending', machine.state)

        # change state from pending to deployed returns True
        self.assertTrue( machine.deployed() )

        # verify state is now deployed
        self.assertEqual('deployed', machine.state)

        # change state from deployed to monitor returns True
        self.assertTrue( machine.monitor() )

        # verify state is now monitor
        self.assertEqual('monitor', machine.state)

        # change state from monitor to found, then pending, then problem each returns True
        self.assertTrue( machine.found() )
        self.assertTrue( machine.pending() )
        #self.assertTrue( machine.problem(msg='could not deploy parameters') )
        self.assertTrue( machine.problem() )

        # change state from problem to monitor returns True
        self.assertTrue( machine.monitor() )

        # verify state is now monitor
        self.assertEqual('monitor', machine.state)
        self.assertRaises(StateException, machine.problem)

        # push state(s) into FIFO for "next" transition(s)
        machine.push('found')
        self.assertRaises(StateException, machine.push, 'deployed')
        machine.push('pending')
        self.assertTrue(machine.next())
        self.assertTrue(machine.next())

        # change states to get back to monitor via problem
        machine.problem()
        machine.monitor()

def suite():
    return unittest.makeSuite(TestPlotParamStateMachine, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite')
