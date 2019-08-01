FROM gridlabd/slac-master:latest

# set up julia
WORKDIR /opt/julia

RUN yum -y install wget

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz \
    && tar xvzf julia-1.1.1-linux-x86_64.tar.gz \
    && ln -sf /opt/julia/julia-1.1.1/bin/julia /usr/bin/julia

# initialize julia to get the required packages
COPY . /opt/build

WORKDIR /opt/build/julia

RUN julia requirements.jl

# get the right python packages installed
WORKDIR /opt/build/python

#RUN python -m pip install -r py_requirements.txt

# set the environmental variables that will be needed for communications
ENV CLIENT_CONNECT_URI 'tcp://127.0.0.1:5001'

ENV SERVER_LISTEN_URI 'tcp://127.0.0.1:5001'

# set the working directory back to where gridlabd/slac-master had it originally
WORKDIR /tmp/

ENTRYPOINT ["/bin/bash"]
