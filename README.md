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
