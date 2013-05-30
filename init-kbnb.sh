#!/bin/bash                                                                                                                                             

source conf/ipython-cfg.sh

HELP=0
NGINX=0
USER_TOKEN=''
BUILD_MODE='none'
DEV_DIR=/kb/dev_container
DEP_DIR=/kb/deployment/services/analysis_book

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
if [ ! -d $KBNB_DIR ]; then
    echo "set up notebook dir"
    mv $DEP_DIR/notebook $KBNB_DIR
    ln -s $KBNB_DIR $DEP_DIR/notebook
    chown -R ipython:ipython $KBNB_DIR
fi

# start notebook
echo "start analysis_book service"
$DEP_DIR/stop_service
sleep 1
$DEP_DIR/start_service -a $SHOCK_AUTH -t "$USER_TOKEN" -s "$SHOCK_SERVER"
