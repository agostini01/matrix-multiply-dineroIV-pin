#!/bin/bash

# DINERO -------------------------------------------------
echo "Downloading DineroIV"
wget ftp.cs.wisc.edu/markhill/DineroIV/d4-7.tar.gz
tar -xzf d4-7.tar.gz
mv d4-7 simulator
rm -f d4-7.tar.gz

echo "Entering folder"
pushd simulator
echo "Compiling"
./configure
make -j4
echo "dineroIV binary available at:"
pwd
echo
echo "Exiting folder"
popd

# PIN     -------------------------------------------------
echo "Downloading PIN"
wget https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.7-97619-g0d0c92f4f-gcc-linux.tar.gz
tar -xzf pin-3.7-97619-g0d0c92f4f-gcc-linux.tar.gz -C .
mv pin-3.7-97619-g0d0c92f4f-gcc-linux pin
rm -f pin-3.*

export PIN_ROOT=`readlink -f pin`
export DINERO_ROOT=`readlink -f simulator`


# PIN TOOLS ----------------------------------------------
echo "Entering folder"
pushd pin/source/tools/Memory/
echo "Compiling"
make -j4
echo "Exiting folder"
popd

echo "Entering folder"
pushd pin/source/tools/SimpleExamples/
echo "Compiling"
make -j4
echo
echo "Exiting folder"
popd

# Sparse and dense matrix matrix multiply project
git clone https://github.com/agostini01/sparse-matrices.git
echo "Entering folder"
pushd sparse-matrices
echo "Compiling"
make
echo "[sp|d]mm binary folder"
pwd
echo
echo "Exiting folder"
popd
