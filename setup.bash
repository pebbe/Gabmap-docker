#!/bin/bash

script='
@parts = ("/");
$p = "";
foreach $part (split m!/!, $ENV{dir}) {
    if ($part ne "") {
	$p .= "/" . $part;
	push @parts, $p;
    }
}
foreach $p (@parts) {
    $s = `stat -c %A "$p"`;
    if ($s =~ /d(...){0,2}..-/) {
        print "$p";
	exit;
    }
}
'

echo >> web04.bash
if [ $? != 0 ]
then
    echo The script web04.bash can\'t be created
    echo Run setup.bash in a directory where you have write permission
    echo Setup aborted
    exit
fi

os=`docker version -f {{.Client.Os}}`

echo
echo Directory where web04 saves your data
echo Example: $HOME/web04-data
read -p 'Directory: ' DATA
if [ "$DATA" = "" ]
then
    echo Setup aborted
    exit
fi
case "$DATA" in
    /*)
	;;
    *)
	echo You need to provide an absolute path to a directory
	echo \'$DATA\' is not an absolute path
	echo Setup aborted
	exit
	;;
esac
if [ -e "$DATA" ]
then
    if [ ! -d "$DATA" ]
    then
	echo \'$DATA\' exists and is not a directory
	echo Setup aborted
	exit
    fi
    if [ -f "$DATA/.etc/INIT-local.sh" ]
    then
	echo The file INIT-local.sh already exists in \'$DATA/.etc\'
	read -p 'Replace setup? (y/n) ' JN
	case $JN in
	    [jJyY]*)
	    	;;
	    *)
		echo Setup aborted
		exit
		;;
	esac
    else
	shopt -s dotglob
	if [ "`echo $DATA/*`" != "$DATA/"'*' ]
	then
	    echo The directory \'$DATA\' is not empty
	    echo If you truly want to use this directory, run: touch \"$DATA/.etc/INIT-local.sh\"
	    echo Setup aborted
	    exit
	fi
    fi
else

    echo Directory \'$DATA\' does not exist
    read -p 'Create directory? (y/n) ' JN
    case $JN in
	[jJyY]*)
	    ;;
	*)
	    echo Setup aborted
	    exit
	    ;;
    esac

fi
for i in .etc .queue
do
    mkdir -p "$DATA/$i"
    if [ ! -d "$DATA/$i" ]
    then
	echo Creating directory \'$DATA/$i\' failed
	echo Setup aborted
	exit
    fi
done

# ik weet niet of deze test werkt op darwin of windows
if [ "$os" = linux ]
then
    st=`stat -f -c %T "$DATA"`
    case "$st" in
	nfs*)
	    P=`dir="$DATA" perl -e "$script"`
	    if [ "$P" != "" ]
	    then
		echo The path \'$P\' needs to be executable for everybody
		echo Run this first:
		echo "  chmod a+x \"$P\""
		echo Setup aborted
		exit
	    fi
	    ;;
    esac
fi

echo
echo What port do you want to run web04 on?
echo Example: 9000
read -p 'Port number: ' PORT
if [ "$PORT" = "" ]
then
    echo Port number missing
    echo Setup aborted
    exit
fi

echo
echo 'Do you want to use web04 in single user mode or multi user mode?'
echo '  s) single user: no login, all projects visible to everyone'
echo '  m) multi user: login, each user their own limited number of projects'
read -p 'User mode (s/m) ' UM
case $UM in
    s|S)
	USERMODE=1
	;;
    m|M)
	USERMODE=2
	;;
    *)
	echo Setup aborted
	exit
	;;
esac

if [ $USERMODE = 2 ]
then

    echo
    echo What is the address to use as sender of mail by web04?
    echo Example: maintainer@web04.nl
    read -p 'Address: ' MAILFROM
    if [ "$MAILFROM" = "" ]
    then
	echo Address missing
	echo Setup aborted
	exit
    fi

    maildomain=`echo $MAILFROM | sed -e 's/.*@//'`

    echo
    echo What is the IP address of the smtp server that web04 can use to send mail?
    echo HINT: Look in your mail program in the settings of smtp.
    echo 'Examples, with/without port number (port 25 is the default):'
    echo "  smtp.$maildomain"
    echo "  smtp.$maildomain:25"
    echo "  smtp.$maildomain:465"
    echo "  smtp.$maildomain:587"
    read -p 'SMTP-server: ' SMTPSERV
    if [ "$SMTPSERV" = "" ]
    then
	echo Smtp server missing
	echo Setup aborted
	exit
    fi

    echo
    echo Do you need to log-in on the smtp server before you can send mail?
    echo If so, provide your username for the smtp server
    read -p 'Username: ' SMTPUSER
    if [ "$SMTPUSER" != "" ]
    then
	echo
	echo Provide the password for the smtp server
	read -p 'Password: ' SMTPPASS
	if [ "$SMTPPASS" = "" ]
	then
	    echo Password missing
	    echo Setup aborted
	    exit
	fi
    fi

    export PORT
    export MAILFROM
    export SMTPSERV
    export SMTPUSER
    export SMTPPASS

    perl -e '
$port     = $ENV{PORT};
$mailfrom = $ENV{MAILFROM};
$smtpserv = $ENV{SMTPSERV};
$smtpuser = $ENV{SMTPUSER};
$smtppass = $ENV{SMTPPASS};
$port     =~ s/\\/\\\\/g;
$port     =~ s/\"/\\\"/g;
$mailfrom =~ s/\\/\\\\/g;
$mailfrom =~ s/\"/\\\"/g;
$smtpserv =~ s/\\/\\\\/g;
$smtpserv =~ s/\"/\\\"/g;
$smtpuser =~ s/\\/\\\\/g;
$smtpuser =~ s/\"/\\\"/g;
$smtppass =~ s/\\/\\\\/g;
$smtppass =~ s/\"/\\\"/g;
$smtpserv =~ s/^[^:]+$/$&:25/;

while (<>) {
    s/~CONTACT~/"$contact"/e;
    s/~PORT~/"$port"/e;
    s/~MAILFROM~/"$mailfrom"/eg;
    s/~SMTPSERV~/"$smtpserv"/e;
    s/~SMTPUSER~/"$smtpuser"/e;
    s/~SMTPPASS~/"$smtppass"/e;
    print;
}
' > "$DATA/.etc/INIT-local.sh" << 'EOF'

export USERMODE=multi

# Set access mask for new files and directories
umask 077

# The 'leven' program can use a lot of memory when it has to calculate Cronbach's alpha
# Limit the amount of memory programs may use, so it won't crash the web server
ulimit -v 500000

# The base url to the webapp, including trailing slash
export APPURL=http://localhost:~PORT~/

# The base url to the webapp using https, including trailing slash
export APPURLS=http://localhost:~PORT~/

# The base url to the webapp without server, including trailing slash
export APPREL=/

# The bare e-mail address used as sender in automated e-mail messages
export MAILFROM=~MAILFROM~

# How to send e-mail, server including port number
export SMTPSERV=~SMTPSERV~
export SMTPUSER=~SMTPUSER~
export SMTPPASS=~SMTPPASS~

### The following variables are optional

# Url of contact person, either http:// or mailto:
# export CONTACT=http://yourdomain/

# Name of contact person
# export CONTACTNAME="Your Name"

# This overrides CONTACT and CONTACTNAME, and defines a complete footer in HTML
# export CONTACTLINE="For help, please contact <a href=\"mailto:yourname@yourdomain\">me</a>"

EOF

else

    mkdir -p "$DATA/User"
    if [ ! -d "$DATA/User" ]
    then
	echo Creating directory \'$DATA/User\' failed
	echo Setup aborted
	exit
    fi

    export PORT

    perl -e '
$port     = $ENV{PORT};
$port     =~ s/\\/\\\\/g;
$port     =~ s/\"/\\\"/g;

while (<>) {
    s/~PORT~/"$port"/e;
    print;
}
' > "$DATA/.etc/INIT-local.sh" << 'EOF'

export USERMODE=single

# Set access mask for new files and directories
umask 022

# The 'leven' program can use a lot of memory when it has to calculate Cronbach's alpha
# Limit the amount of memory programs may use, so it won't crash the web server
ulimit -v 500000

# The base url to the webapp, including trailing slash
export APPURL=http://localhost:~PORT~/

# The base url to the webapp using https, including trailing slash
export APPURLS=http://localhost:~PORT~/

# The base url to the webapp without server, including trailing slash
export APPREL=/

EOF

fi

echo '#!/bin/bash' > web04.bash
echo >> web04.bash
echo dir=\"$DATA\" >> web04.bash
echo port=$PORT >> web04.bash
if [ "$os" = linux ]
then
    echo localhost=127.0.0.1 >> web04.bash
else
    echo 'a=`docker-machine active 2> /dev/null`' >> web04.bash
    echo 'localhost=`docker-machine ip $a 2> /dev/null || echo 127.0.0.1`' >> web04.bash
    echo 'unset a' >> web04.bash
fi

cat >> web04.bash  <<'EOF'
case "$1" in
    start)
        docker run \
            -d \
            --name=web04.serve \
            -p $port:9000 \
            -v "$dir":/mod/data \
            pebbe/web04:latest serve || exit
            echo
            echo web04 has started on http://$localhost:$port/
            echo
        ;;
    stop)
        docker stop web04.serve
        docker rm web04.serve
        ;;
    upgrade)
        echo stopping web04
        docker stop web04.serve
        docker rm web04.serve
        docker pull pebbe/web04:latest
        echo web04 needs to be restarted
        ;;
    info)
        docker inspect web04.serve
        echo
        docker logs web04.serve
        ;;
    shell)
        docker run \
            --rm \
            -i -t \
            -v "$dir":/mod/data \
            pebbe/web04:latest shell
        ;;
    *)
	echo
	echo Usage: web04.bash CMD
	echo
	echo CMD is one of:
	echo
	echo "  start     - start web04"
	echo "  stop      - stop web04"
	echo
        echo "  upgrade   - upgrade to latest version of web04"
	echo
        echo "  info      - show debug info for running web04"
        echo
	echo "  shell     - open an interactive shell"
        echo
	echo For more information, go to:
	echo
	echo "  https://github.com/pebbe/Gabmap-docker"
	echo
	;;
esac
EOF

chmod +x web04.bash

cat <<EOF


================================================================


web04 is ready to use.

EOF
echo If you want, you can change things in: $DATA/.etc/INIT-local.sh
cat <<EOF



To start web04, run:

    ./web04.bash start



For a list of other commands, run:

    ./web04.bash


For more information, go to:

    https://github.com/pebbe/Gabmap-docker


EOF
