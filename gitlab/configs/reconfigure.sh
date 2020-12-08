#!/bin/bash

/opt/gitlab/embedded/bin/runsvdir-start&  

sleep 4

gitlab-ctl  reconfigure 
