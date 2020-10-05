FROM slacgismo/gridlabd:beauharnois-11

RUN yum -y install curl

RUN yum -y install libffi-devel
RUN cd /usr/local/src && \
    curl https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tgz > Python-3.7.7.tgz && \
    tar xzf Python-3.7.7.tgz && \
    cd Python-3.7.7 && \
    ./configure --enable-optimizations --enable-shared && \
    make altinstall && \
    /sbin/ldconfig /usr/local/lib && \
    /usr/local/bin/python3 -m pip install matplotlib Pillow pandas numpy && \
    cd /usr/local/src && \
    rm -f Python-3.7.7.tgz

# copy things to a build directory
COPY . /opt/build

# set the working directory for python
WORKDIR /opt/build/python

# install python requirements
RUN /usr/local/bin/python3 -m pip install --upgrade pip
RUN /usr/local/bin/python3 -m pip install -r py_requirements.txt

# install wget so that we can grab things
RUN yum -y install wget

# change dir and install julia
WORKDIR /opt/julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3.1-linux-x86_64.tar.gz \
    && tar xvzf julia-1.3.1-linux-x86_64.tar.gz \
    && ln -sf /opt/julia/julia-1.3.1/bin/julia /usr/bin/julia

# initialize julia to get the required packages
WORKDIR /opt/build/julia

RUN julia requirements.jl

# set the environmental variables that will be needed for communications
ENV CLIENT_CONNECT_URI 'tcp://127.0.0.1:5001'
ENV SERVER_LISTEN_URI 'tcp://127.0.0.1:5001'

# set the working directory back to where gridlabd/slac-master had it originally
WORKDIR /tmp/
