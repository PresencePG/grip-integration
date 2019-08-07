FROM gridlabd/slac-master:190805

# copy things
COPY . /opt/build

# get system packages as needed
RUN yum -y install wget

# get the right python packages installed
RUN ln -sf /usr/bin/python3.6 /usr/bin/python

WORKDIR /opt/build/python

RUN python -m pip install --upgrade pip

RUN python -m pip install -r py_requirements.txt

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

ENTRYPOINT ["/bin/bash"]
