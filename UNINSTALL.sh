#!/bin/sh -x

sudo apt-get remove --purge `dpkg -l | grep compiz | grep 0.9.4 | awk '{print $2}'`
