#!/bin/bash

if [[ $# != 2 ]] ; then
    echo "Usage: $0 service_dir_path service_user" 1>&2
    exit 1
fi

SERVICE_DIR=$1
SERVICE_USR=$2

# download and install daemonize
git clone git://github.com/bmc/daemonize.git
pushd daemonize
./configure
make
make install
popd