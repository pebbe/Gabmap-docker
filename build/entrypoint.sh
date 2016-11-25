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
	trap cleanexit 1 2 3 9 15
	set -e
	addgroup --gid "$3" web
	yes | adduser --no-create-home --uid "$2" --gid "$3" --disabled-password web > /dev/null
	lighttpd -D -f /mod/etc/httpd.config > /dev/null &
	cpid=$!
	wait $cpid
	;;
    shell)                                                                                                      
        echo                                                                                                    
        echo Beschikbare editor: nano                                                                           
        echo                                                                                                    
        /bin/bash --rcfile /mod/etc/profile.sh                                                                     
        ;;                                                                                                      
esac
