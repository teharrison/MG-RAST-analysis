#!/bin/bash

if [[ $# != 2 ]] ; then
    echo "Usage: $0 service_dir_path service_user" 1>&2
    exit 1
fi

SERVICE_DIR=$1
SERVICE_USR=$2

# setup services
mkdir -p $SERVICE_DIR
mkdir $SERVICE_DIR/ipython
mkdir $SERVICE_DIR/notebook
mkdir $SERVICE_DIR/notebook/images
mkdir $SERVICE_DIR/notebook/js
mkdir $SERVICE_DIR/log
chown -R ${SERVICE_USR}:${SERVICE_USR} $SERVICE_DIR/ipython
chown -R ${SERVICE_USR}:${SERVICE_USR} $SERVICE_DIR/notebook
chown -R ${SERVICE_USR}:${SERVICE_USR} $SERVICE_DIR/log
cp service/start_service $SERVICE_DIR/start_service
cp service/stop_service $SERVICE_DIR/stop_service
chmod +x $SERVICE_DIR/start_service
chmod +x $SERVICE_DIR/stop_service
