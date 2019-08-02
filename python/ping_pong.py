import zmq
from json import dumps as json_dumps
import time
import sys
import os
import subprocess
import time

# launch the python talker
connection_uri = os.environ.get('CLIENT_CONNECT_URI')

context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.connect(connection_uri)

# launch the julia listener
print("Opening the julia listener")
pong = subprocess.Popen(["julia", "julia/pong.jl"])

# send a message
message = "Hello"
socket.send_string(json_dumps({
    'message': message,
    'at': time.ctime(),
}))
response = socket.recv()
print(response)

pong.wait()

# quit
print("Ending the julia listener")
pong.terminate()
