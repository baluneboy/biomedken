#!/usr/bin/python

import unittest
from smachine import StateException
from pims.statemachine.smplot import PlotParametersStateMachine

class TestPlotParamStateMachine(unittest.TestCase):

    def test_state_transitions(self):

        # create machine to maintain state info
        machine = PlotParametersStateMachine()

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
