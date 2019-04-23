FROM amd64/ubuntu:16.04

# Update and download swift
RUN apt-get -y update
RUN apt-get -y install vim git
RUN apt-get -y install build-essential
RUN apt-get -y install wget
RUN apt-get -y install gfortran
RUN mkdir /swift && cd /swift
RUN git clone https://github.com/SWIFTSIM/swiftsim.git

## install pre-requirement
# Openmpi-3.1.2
RUN mkdir /openmpi-source && cd /openmpi-source
RUN wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz
RUN tar xzvf openmpi-3.1.2.tar.gz
RUN cd openmpi-3.1.2 && \
    ./configure --prefix=/usr/local/openmpi-3.1.2 CXX=g++ FORTRAN=gfortran --enable-mpi-cxx -enable-mpi-fortran &&\
    make -j 10 && make -j 10 install
ENV PATH /usr/local/openmpi-3.1.2/bin:$PATH

# HDF5
RUN mkdir /HDF5 && cd /HDF5
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.4/src/hdf5-1.10.4.tar
RUN tar xvf hdf5-1.10.4.tar
RUN cd hdf5-1.10.4 &&\
    FC=mpif90 ./configure --enable-fortran --enable-parallel &&\
    make -j 10 &&\
    make install
ENV LD_LIBRARY_PATH /hdf5-1.10.4/hdf5/lib:$LD_LIBRARY_PATH 

# GSL
RUN apt-get -y install libgsl-dev

# fftw3
RUN apt-get -y install fftw3

# install autoconf
RUN apt-get -y install autoconf automake libtool

# cmake
RUN wget https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz && \
    tar -zxvf cmake-3.6.2.tar.gz && \
    cd cmake-3.6.2 && \
    ./bootstrap --prefix=/usr/local && \
    make -j 10 && \
    make install
ENV PATH /usr/local/bin:$PATH:$HOME/bin 

# metis
RUN wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz && \
    tar xzvf metis-5.1.0.tar.gz && \
    cd metis-5.1.0 && \
    make config shared=1 prefix=/metis && \
    make -j 10 && \
    make -j 10 install
ENV LIBRARY_PATH /metis/lib:$LIBRARY_PATH

# fftw3
RUN wget http://www.fftw.org/fftw-3.3.8.tar.gz && \
    tar xzvf fftw-3.3.8.tar.gz && \
    cd fftw-3.3.8 && \
    ./configure --prefix=/fftw3 --enable-shared && \
    make -j 10 CFLAGS=-fPIC && make -j 10 install
ENV LIBRARY_PATH /fftw3/lib:$LIBRARY_PATH

# Debug
RUN apt install -y mlocate
RUN updatedb && locate h5pcc

RUN locate fftw3.h
ENV LIBRARY_PATH /fftw3/include:$LIBRARY_PATH

## compile swift
RUN ldconfig && \
    cd /swiftsim && \
    ./autogen.sh && \
    ./configure --with-hdf5=/hdf5-1.10.4/hdf5/bin/h5pcc --with-metis=/metis --with-tbbmalloc --enable-parallel-hdf5=yes --with-fftw=/fftw3 &&\
    make -j 10


