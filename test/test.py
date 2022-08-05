#!/usr/bin/python

import unittest
import os

class TestStub(unittest.TestCase):

    def test_stub(self):
        fail_tests = os.environ.get("FAIL_TESTS", "false")
        self.assertNotIn(fail_tests.lower(), ['true', '1', 't', 'y', 'yes'])

if __name__ == '__main__':
    unittest.main()