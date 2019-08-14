#! /bin/sh

docker run -it --rm -v $(pwd):/opt/tests --workdir /opt/tests slacgrip/master
