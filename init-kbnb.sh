#!/bin/bash                                                                                                                                             

SHOCK_USER='public'
SHOCK_URL='http://140.221.84.125:8000'
BUILD_MODE='none'
DEV_DIR=/kb/dev_container

if [ -n "$1" ]; then
    if [[ "$1" == *"-h"* ]]; then
        echo "Usage: init_kbnb SHOCK_USER($SHOCK_USER) SHOCK_URL($SHOCK_URL) BUILD_MODE(none|ipython|all)"
        exit
    else
        SHOCK_USER=$1
    fi
fi
if [ -n "$2" ]; then
    SHOCK_URL=$2
fi
if [ -n "$3" ]; then
    BUILD_MODS=$3
fi

# get the kbase env                                                                                                                                     
source $DEV_DIR/user-env.sh

# re-build kbase modules                                                                                                                                
if [ $BUILD_MODE == 'all' ]; then
    cd $DEV_DIR/modules
    # update repos                                                                                                                                      
    for M in *; do
        pushd $M
        git pull origin master
        popd
    done
    # make deploy                                                                                                                                       
    cd $DEV_DIR
    make
    make deploy
fi

# re-build just analysis_book                                                                                                                           
if [ $BUILD_MODE == 'ipython' ]; then
    cd $DEV_DIR/modules/analysis_book
    git pull origin master
    make deploy-server
fi

# we don't want nginx running                                                                                                                           
/etc/init.d/nginx stop

# place notebook dir in /mnt                                                                                                                            
mv /kb/deployment/services/analysis_book/notebook /mnt/notebook
ln -s /mnt/notebook /kb/deployment/services/analysis_book/notebook
chown -R ipython:ipython /mnt/notebook

# start notebook                                                                                                                                        
/kb/deployment/services/analysis_book/stop_service
/kb/deployment/services/analysis_book/start_service $SHOCK_USER $SHOCK_URL

