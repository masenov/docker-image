FROM nvidia/cuda:8.0-cudnn5-devel

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    apt-get update && \
    apt-get install -y wget git libhdf5-dev g++ graphviz sudo nano cmake && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash /Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.12-Linux-x86_64.sh

# Python
ARG python_version=3.6.0

ENV NB_USER keras
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    echo "keras:keras" | chpasswd && \
    adduser keras sudo && \
    mkdir -p $CONDA_DIR && \
    chown keras $CONDA_DIR -R && \
    mkdir -p /src && \
    chown keras /src

USER keras



RUN conda install -y python=${python_version} && \
    pip install --upgrade pip && \
    pip install tensorflow-gpu && \
    conda install Pillow scikit-learn notebook pandas matplotlib mkl nose pyyaml six h5py && \
    conda install theano pygpu && \
    git clone git://github.com/fchollet/keras.git /src && pip install -e /src[tests] && \
    pip install git+git://github.com/fchollet/keras.git && \
    pip install chainer==1.23.0 && \
    conda clean -yt 

# Not use of theano
#ADD theanorc /home/keras/.theanorc
ENV PYTHONPATH='/src/:$PYTHONPATH'

###
# OpenCV
RUN pip install opencv-python 

# Autograd 
RUN pip install autograd

WORKDIR /src

EXPOSE 8888

CMD /bin/bash
CMD jupyter notebook --port=8888 --ip=0.0.0.0

