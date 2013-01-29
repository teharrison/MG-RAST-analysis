#!/bin/bash

# clean out old version of ipython if exists
pip uninstall ipython
cat python_files.txt | xargs rm -rfv
