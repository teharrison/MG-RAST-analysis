#!/bin/bash

# clean out old version of ipython if exists
pip uninstall ipython
cat files.txt | xargs rm -rfv
