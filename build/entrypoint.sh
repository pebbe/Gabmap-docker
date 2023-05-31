#!/bin/bash

function cleanexit {
    if [ "$cpid" != "" ]
    then
        kill $cpid
        sleep 2
    fi
    exit
}

uid=`stat -c %u /mod/data`
gid=`stat -c %g /mod/data`

case "$1" in
    serve)
	set -e
	if [ "$uid" = "0" ]
	then
	    groupadd --system --gid 999 web
	    useradd --system --uid 999 --gid 999 --no-create-home web
	    cd /mod/data
	    for i in . .queue User
	    do
		if [ -d $i ]
		then
		    chown root:web $i
		    chmod g+sw $i
		fi
	    done
	else
	    groupadd --gid $gid web
	    useradd --no-create-home --uid $uid --gid $gid web
	fi
	trap cleanexit 1 2 3 9 15
	lighttpd -D -f /mod/etc/httpd.config &
	cpid=$!
	wait $cpid
	;;
    shell)
	if [ "$uid" = "0" ]
	then
	    groupadd --system --gid 999 web
	    useradd --system --uid 999 --gid 999 --no-create-home web
	else
	    groupadd --gid $gid web
	    useradd --no-create-home --uid $uid --gid $gid web
	fi
        echo
        echo Beschikbare editors: nano, vim
        echo
        /bin/bash --rcfile /mod/etc/profile.sh
        ;;
esac
