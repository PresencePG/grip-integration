This repository holds the files needed to set up a docker container for the grip-absorption/gridlab-d simulation.

### To build the container do the following
```
$ docker build -t gridlabd-julia .
```
or just `build.sh`

### To launch the container starting at the test directory
```
$ docker run -it --rm -v $(pwd):/opt/tests --workdir /opt/tests gridlabd-julia
```
or just `launch.sh`

### To run some tests from within the container after launching
```
$ cd /opt/tests
$ sh test.sh
```
Note that the tests are not yet 100% working...

### To run the julia server tests

```
$ docker run -it --rm -v $(pwd):/opt/build --workdir /opt/build/python gridlabd-julia

[root@<docker-id> python]# python julia_server.test.py
```

### To run the example Gridlab-D start script and on_commit hooks

```
$ docker run -it --rm -v $(pwd):/opt/build --workdir /opt/build/python gridlabd-julia

[root@<docker-id> python]# python run_gridlabd_main.py
```
