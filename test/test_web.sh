#!/bin/bash

PASS=0
URL=$1
NAME=$2

curl -D test/header.txt "$URL" > /dev/null

if [ -s test/header.txt ]; then
    PASS=`grep '^HTTP' test/header.txt | grep -c 200`
    rm test/header.txt
fi

if [ $PASS ]; then
    echo "$NAME passed all tests."
else
    echo "$name is not running. Make sure analysis_book is deployed and service is running."
fi
