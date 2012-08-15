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

# setup services
mkdir -p $SERVICE_DIR
mkdir -m 777 $SERVICE_DIR/ipython
mkdir -m 777 $SERVICE_DIR/notebook
mkdir -m 777 $SERVICE_DIR/log
chown ${SERVICE_USR}:${SERVICE_USR} $SERVICE_DIR/ipython
chown ${SERVICE_USR}:${SERVICE_USR} $SERVICE_DIR/notebook
chown ${SERVICE_USR}:${SERVICE_USR} $SERVICE_DIR/log
cp service/start_service $SERVICE_DIR/start_service
cp service/stop_service $SERVICE_DIR/stop_service
chmod +x $SERVICE_DIR/start_service
chmod +x $SERVICE_DIR/stop_service
