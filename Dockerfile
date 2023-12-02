######### Linux setup #########
FROM ubuntu:16.04
# set shell to bash by default
SHELL [ "/bin/bash", "--login", "-c" ]
# install some linux stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends make build-essential coreutils wget ca-certificates curl git vim zip unzip bzip2 libbz2-dev zlib1g-dev sudo

######### User setup #########
# for security, create a non-root user
ARG username=jastro
ARG uid=1000
ARG gid=100
ENV USER $username
ENV UID $uid
ENV GID $gid
ENV HOME /home/$USER
RUN adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
    $USER

######### Copy data into container #########
# set a top level directory
WORKDIR /ecosystem
# copy PlatoSim and L1 pipeline into container
COPY . .

######### Permissions #########
# set permissions on copied files
RUN chown -R $UID:$GID /ecosystem/jastro

######### Miniconda #########
# switch to non-root user
USER $USER
# install miniconda
# select the correct version from https://repo.anaconda.com/miniconda/
ENV MINICONDA_VERSION py39_23.1.0-1
ENV MINICONDA_ARCH Linux-x86_64
ENV CONDA_DIR $HOME/miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-$MINICONDA_ARCH.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
# add to PATH
ENV PATH=$CONDA_DIR/bin:$PATH
# install deps
RUN pip install cython
RUN pip install numpy
RUN pip install astropy
RUN pip install fitsio
RUN pip install ccdproc
RUN pip install pyregion
RUN pip install sep
RUN pip install donuts
RUN pip install matplotlib
RUN pip install pandas

######### JASTRO #########
WORKDIR /ecosystem/jastro
# install jastro
RUN python setup.py install
