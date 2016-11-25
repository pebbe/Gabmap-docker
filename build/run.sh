#!/bin/sh
uid=1000
gid=1000
port=9911
set -x
#docker run --rm -i -t -v /my/docker/run-webL04/data:/mod/data --user=$uid:$gid -p $port:9000 rugcompling/webl04:latest
docker run --rm -i -t -v /my/docker/run-webL04/data:/mod/data -p $port:9000 rugcompling/webl04:latest
