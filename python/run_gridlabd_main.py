import time

# Gridlab-D imports

from julia_server import JuliaServer
from on_commit import on_commit

from process_payload import *

# get data from test_data directory and format into correct dict structure with process_payload
dataloc = '../test_data/'
datadump = process_payload(dataloc)

# Gridlab-D set up

with JuliaServer() as server:
    print('Starting up JuliaServer. . . ')
    on_commit(datadump)
