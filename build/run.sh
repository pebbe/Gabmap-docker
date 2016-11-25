#!/bin/sh
uid=1000
gid=1000
port=9911
dir=/my/docker/run-webL04/data

case "$1" in
    start)
        docker run \
            -d \
            --name=webl04.serve \
            -p $port:9000 \
            -v "$dir":/mod/data \
            rugcompling/webl04:latest serve $uid $gid
	;;
    stop)
        docker stop webl04.serve
        docker rm webl04.serve
	;;
    shell)
        docker run \
            --rm \
            -i -t \
            -v "$dir":/mod/data \
            rugcompling/webl04:latest shell
        ;;
esac
