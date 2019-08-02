import zmq
from json import dumps as json_dumps
import time
import sys
import os
import subprocess
import time

# launch the julia listener
print("Opening the julia listener")
pong = subprocess.Popen(["julia", "julia/pong.jl"])

# Wait for 1 second
time.sleep(1)

# quit
print("Ending the julia listener")
pong.terminate()
