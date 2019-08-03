import zmq
from json import dumps as json_dumps
import time
import sys
import os
import subprocess
import time
import asyncio

# launch the python talker
CLIENT_CONNECT_URI = os.environ.get('CLIENT_CONNECT_URI')

class JuliaClient:
    def __init__(self, connection_uri=CLIENT_CONNECT_URI):
        self._connection_uri = connection_uri
        self._context = zmq.Context()
        self._socket = self._context.socket(zmq.PAIR)
        self.connected = False

    def connect(self):
        if self.connected: return
        self._socket.connect(self._connection_uri)
        self.connected = True

    def send_async(self, message, block=True):
        timestamp = time.ctime()
        flags = 0 if block else zmq.NOBLOCK
        self._socket.send_string(json_dumps({
            'message': message,
            'at': timestamp,
        }), flags=flags)
        return timestamp

    def send(self, message, block=True):
        self.send_async(message, block=block)
        flags = 0 if block else zmq.NOBLOCK
        response = self._socket.recv(flags=flags)
        return response

    def send_poll(self, message, timeout_sec=10):
        start_ts = time.time()
        res = None
        while not res and (time.time() - start_ts) < timeout_sec:
            try:
                res = self.send(message, block=False)
                success = True
            except zmq.ZMQError:
                time.sleep(1)
                pass
        if not res:
            raise TimeoutError('Failed to poll server with message')
        return res

julia_client = JuliaClient()
