import zmq
from json import dumps as json_dumps
import time
import sys
import os

connection_uri = os.environ.get('CLIENT_CONNECT_URI')

context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.connect(connection_uri)

if __name__ == '__main__':
    while True:
        message = sys.stdin.readline()
        socket.send_string(json_dumps({
            'message': message,
            'at': time.ctime(),
        }))
        response = socket.recv()
        print(response)
