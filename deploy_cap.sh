#!/bin/bash

source ~/.bash_profile
bundle install
./exec_daemon.sh restart
