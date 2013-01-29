#!/bin/bash

# clean out old version of ipython if exists
pip uninstall ipython
cat ipython_files.txt | xargs rm -rfv
