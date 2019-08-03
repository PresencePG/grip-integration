import unittest


from julia_client import julia_client
from julia_server import JuliaServer


class TestJuliaServer(unittest.TestCase):
    def setUp(self):
        self.client = julia_client
        self.client.connect()

    def test_server_can_receive_messages(self):
        with JuliaServer() as server:
            res = self.client.send('ping', block=False)
            self.assertEqual(res, b'pong')


if __name__ == '__main__':
    unittest.main()
