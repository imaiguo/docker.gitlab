#!/bin/bash
service ssh restart

/opt/gitlab/embedded/bin/runsvdir-start&

sleep 4

gitlab-ctl  starts

echo "program is running"

ps -aux 

bash
