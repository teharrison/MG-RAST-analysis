#!/bin/bash

# clean out old version of ipython if exists
pip uninstall -y ipython
rm -rfv /usr/local/lib/python2.7/dist-packages/IPython
rm -rfv /usr/local/share/doc/ipython
rm -rfv /usr/local/lib/python2.7/dist-packages/ipython*
rm -fv /usr/local/bin/ipython
rm -fv /usr/local/share/man/man1/ipython.1
