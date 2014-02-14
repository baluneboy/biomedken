#!/usr/bin/python

import unittest
from smachine import StateMachine, StateException
    
class PlotParamStateMachine(StateMachine):
    states = ['monitor', 'found', 'pending', 'deployed', 'problem']
    transitions = {
        'monitor':  ['found'],
        'found':    ['pending'],
        'pending':  ['deployed', 'problem'],
        'deployed': ['monitor'],
        'problem':  ['monitor'],            
    }
    
    def __init__(self):
        self.state = 'monitor'
    
    def on_enter_idle(self, from_state=None, to_state=None):
        if from_state == 'problem':
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

    def on_enter_problem(self, from_state=None, to_state=None):
        if from_state == 'pending':
            return True
        else:
            return False

    def on_enter_pending(self, from_state=None, to_state=None):
        if from_state == 'found':
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
        
        ## change state from found to pending returns True
        #self.assertTrue( machine.pending() )
        #
        ## verify state is now pending
        #self.assertEqual('pending', machine.state)
        #
        ## change state from pending to deployed returns True
        #self.assertTrue( machine.deployed() )
        #
        ## change state from deployed to found returns True
        #self.assertTrue( machine.found() )
        #
        ## verify state is now found
        #self.assertEqual('found', machine.state)
        #
        ## change state from found to pending returns True
        #self.assertTrue( machine.pending() )
        #
        ## verify state is now pending
        #self.assertEqual('pending', machine.state)
        #
        ## change state from pending to problem returns True
        #self.assertTrue( machine.problem() )        
        #
        ## verify state is now problem
        #self.assertEqual('problem', machine.state)        
        
        #self.assertTrue( machine.yellow() )
        #self.assertEqual('yellow', machine.state)
        #self.assertTrue(machine.red())
        #self.assertEqual('red', machine.state)
        #self.assertRaises(StateException, machine.green)
        #self.assertTrue(machine.yellow())
        #self.assertEqual('yellow', machine.state)
        #self.assertTrue(machine.green())
        #self.assertEqual('green', machine.state)
        #
        #machine.push('yellow')
        #machine.push('red')
        #
        #self.assertRaises(StateException, machine.push, 'green')
        #
        #self.assertTrue(machine.next())
        #self.assertTrue(machine.next())
        #
        #self.assertRaises(StateException, machine.push, 'green')
        #
        #machine.yellow()
        #machine.green()

def suite():
    return unittest.makeSuite(TestPlotParamStateMachine, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite')