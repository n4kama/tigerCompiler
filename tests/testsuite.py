#!/usr/bin/python3

import os
import sys
from subprocess import Popen, PIPE

#Definition of colors
class txtcolors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# FUNCTION DEFINITIONS

def exec_test(filename):
    print("Testing " + filename + " : ", end='')

    bash_res = Popen(["./../src/tc", '../tests/testfiles/' + filename],
                stdin=PIPE, stdout=PIPE, stderr=PIPE)
    bash_out, bash_err = bash_res.communicate()
    bash_retval = bash_res.returncode

    if not bash_retval:
        print(txtcolors.GREEN + "OK" + txtcolors.ENDC)
    else:
        print(txtcolors.FAIL + "KO (with error code : " + str(bash_retval) + ")" + txtcolors.ENDC)
        print("tc output : ", end='')
        print(str(bash_err, "utf-8"))

# PROGRAM START

print(txtcolors.WARNING + "STARTING TEST SUITE : \n" + txtcolors.ENDC)

testfiles = os.listdir("testfiles")
for testfile in sorted(testfiles):
    exec_test(testfile)

print(txtcolors.WARNING + "\nEND OF TEST SUITE" + txtcolors.ENDC)