#!/bin/bash

function cleanexit {
    if [ "$cpid" != "" ]
    then
        kill $cpid
        sleep 2
    fi
    exit
}

case "$1" in
    serve)
	set -e
	uid=`stat -c %u /mod/data`
	gid=`stat -c %g /mod/data`
	addgroup --gid $gid web
	yes | adduser --no-create-home --uid $uid --gid $gid --disabled-password web
	trap cleanexit 1 2 3 9 15
	lighttpd -D -f /mod/etc/httpd.config &
	cpid=$!
	wait $cpid
	;;
    shell)
        echo
        echo Beschikbare editors: nano, vim
        echo
        /bin/bash --rcfile /mod/etc/profile.sh
        ;;
esac
