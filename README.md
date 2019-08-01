This repository holds the files needed to set up a docker container for the grip-absorption/gridlab-d simulation.

### To build the container do the following
```
$ docker build -t gridlabd-julia .
```

### To launch the container
```
$ docker run -it --rm -v $(pwd):/opt/app gridlabd-julia
```
