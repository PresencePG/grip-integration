import time

# Gridlab-D imports

from julia_server import JuliaServer
from on_commit import on_commit

# Gridlab-D set up

with JuliaServer() as server:
    print('Running gridlabd.start(\'wait\')')
    for iteration in range(0, 10):
        on_commit(f'Gridlab-D iteration {iteration}')
        time.sleep(1)
