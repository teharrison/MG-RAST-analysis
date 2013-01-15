#!/bin/bash

# download and install daemonize
git clone git://github.com/bmc/daemonize.git
pushd daemonize
./configure
make
make install
popd