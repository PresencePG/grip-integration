FROM gridlabd/slac-master:190805

RUN yum -y install curl

# copy things
COPY . /opt/build

# get system packages as needed
RUN yum -y install wget

WORKDIR /opt/build/python

RUN pip3 install -r py_requirements.txt

# install julia
WORKDIR /opt/julia

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz \
    && tar xvzf julia-1.1.1-linux-x86_64.tar.gz \
    && ln -sf /opt/julia/julia-1.1.1/bin/julia /usr/bin/julia

# initialize julia to get the required packages
WORKDIR /opt/build/julia

RUN julia requirements.jl

# set the environmental variables that will be needed for communications
ENV CLIENT_CONNECT_URI 'tcp://127.0.0.1:5001'

ENV SERVER_LISTEN_URI 'tcp://127.0.0.1:5001'

# set the working directory back to where gridlabd/slac-master had it originally
WORKDIR /tmp/
