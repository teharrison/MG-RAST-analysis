#!/bin/bash                                                                                                                                             

HELP=0
NGINX=0
USER_TOKEN=''
SHOCK_SERVER='http://140.221.84.144:8000'
BUILD_MODE='none'
DEV_DIR=/kb/dev_container

# get args
while getopts hnt:s:b: option; do
    case "${option}"
	    in
	    h) HELP=1;;
	    n) NGINX=1;;
	    t) USER_TOKEN=${OPTARG};;
	    s) SHOCK_SERVER=${OPTARG};;
	    b) BUILD_MODE=${OPTARG};;
    esac
done

# help
if [ $HELP -eq 1 ]; then
    echo "Usage: init-kbnb.sh [-h -n] -t USER_TOKEN -s SHOCK_SERVER -b BUILD_MODE(none|ipython|all)"
    exit
fi

# get the kbase env
source $DEV_DIR/user-env.sh

# re-build kbase modules
if [ $BUILD_MODE == 'all' ]; then
    cd $DEV_DIR/modules
    # update repos
    for M in *; do
        echo "updating $M module"
        pushd $M
        git pull origin master
        popd
    done
    # make deploy
    echo "deploying all modules"
    cd $DEV_DIR
    make
    make deploy
fi

# re-build just analysis_book
if [ $BUILD_MODE == 'ipython' ]; then
    echo "updating and deploying analysis_book module"
    cd $DEV_DIR/modules/analysis_book
    git pull origin master
    make deploy-server
fi

# default - we don't want nginx running
if [ $NGINX -eq 0 ]; then
    echo "server mode - disable nginx"
    /etc/init.d/nginx stop
fi

# place notebook dir in /mnt
if [ ! -d /mnt/notebook ]; then
    echo "set up notebook dir"
    mv /kb/deployment/services/analysis_book/notebook /mnt/notebook
    ln -s /mnt/notebook /kb/deployment/services/analysis_book/notebook
    chown -R ipython:ipython /mnt/notebook
fi

# start notebook
echo "start analysis_book service"
/kb/deployment/services/analysis_book/stop_service
sleep 1
/kb/deployment/services/analysis_book/start_service -a 'globus' -t "$USER_TOKEN" -s "$SHOCK_SERVER"

