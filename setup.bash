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
    echo Het script web04.bash kan niet aangemaakt worden
    echo Draai setup.bash in een directory waar je schrijfrechten hebt
    echo Setup afgebroken
    exit
fi

os=`docker version -f {{.Client.Os}}`

echo
echo Plaats waar web04 bestanden opslaat
echo Voorbeeld: $HOME/web04-data
read -p 'Directory: ' DATA
if [ "$DATA" = "" ]
then
    echo Setup afgebroken
    exit
fi
case "$DATA" in
    /*)
	;;
    *)
	echo Je moet een absoluut path naar een directory opgeven
	echo \'$DATA\' is geen absoluut path
	echo Setup afgebroken
	exit
	;;
esac
if [ -e "$DATA" ]
then
    if [ ! -d "$DATA" ]
    then
	echo \'$DATA\' bestaat en is geen directory
	echo Setup afgebroken
	exit
    fi
    if [ -f "$DATA/.etc/INIT-local.sh" ]
    then
	echo Er staat al een INIT-local.sh in \'$DATA/.etc\'
	read -p 'Setup vervangen? (j/n) ' JN
	case $JN in
	    [jJyY]*)
	    	;;
	    *)
		echo Setup afgebroken
		exit
		;;
	esac
    else
	shopt -s dotglob
	if [ "`echo $DATA/*`" != "$DATA/"'*' ]
	then
	    echo De directory \'$DATA\' is niet leeg
	    echo Als je echt deze directory wilt gebruiken, doe dan: touch \"$DATA/.etc/INIT-local.sh\"
	    echo Setup afgebroken
	    exit
	fi
    fi
else

    echo Directory \'$DATA\' bestaat niet
    read -p 'Directory aanmaken? (j/n) ' JN
    case $JN in
	[jJyY]*)
	    ;;
	*)
	    echo Setup afgebroken
	    exit
	    ;;
    esac

fi
for i in .etc .queue
do
    mkdir -p "$DATA/$i"
    if [ ! -d "$DATA/$i" ]
    then
	echo Maken van directory \'$DATA/$i\' is mislukt
	echo Setup afgebroken
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
		echo Het path \'$P\' moet voor iedereen executable zijn
		echo Doe eerst:
		echo "  chmod a+x \"$P\""
		echo Setup afgebroken
		exit
	    fi
	    ;;
    esac
fi

echo
echo Op welke poort wil je web04 laten draaien?
echo Voorbeeld: 9000
read -p 'Poort: ' PORT
if [ "$PORT" = "" ]
then
    echo Poortnummer ontbreekt
    echo Setup afgebroken
    exit
fi

echo
echo Wat is het adres dat gebruikt moet worden als afzender in mail verstuurd door web04?
echo Voorbeeld: maintainer@web04.nl
read -p 'Adres: ' MAILFROM
if [ "$MAILFROM" = "" ]
then
    echo Adres ontbreekt
    echo Setup afgebroken
    exit
fi

maildomain=`echo $MAILFROM | sed -e 's/.*@//'`

echo
echo Wat is het adres van de smtp-server waarmee web04 mail kan versturen?
echo TIP: Kijk in je mailprogramma naar de instellingen van smtp.
echo 'Voorbeelden, met/zonder poortnummer (poort 25 is de default):'
echo "  smtp.$maildomain"
echo "  smtp.$maildomain:25"
echo "  smtp.$maildomain:465"
echo "  smtp.$maildomain:587"
read -p 'SMTP-server: ' SMTPSERV
if [ "$SMTPSERV" = "" ]
then
    echo Smtp-server ontbreekt
    echo Setup afgebroken
    exit
fi

echo
echo Is het nodig in te loggen op de smtp-server voordat je er mail heen kunt zenden?
echo Zo ja, geef dan je loginnaam voor de smtp-server
read -p 'Username: ' SMTPUSER
if [ "$SMTPUSER" != "" ]
then
    echo
    echo Geef je password voor de smtp-server
    read -p 'Password: ' SMTPPASS
    if [ "$SMTPPASS" = "" ]
    then
	echo Password ontbreekt
	echo Setup afgebroken
	exit
    fi
fi

export PORT
export MAILFROM
export SMTPSERV
export SMTPUSER
export SMTPPASS

perl -n -e '
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

# The bare e-mail address used as sender in automated e-mail messages
export MAILFROM=~MAILFROM~

# How to send e-mail
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
if [ "$os" = linux ]
then
    echo uid=`stat -c %u "$DATA/.etc/INIT-local.sh"` >> web04.bash
    echo gid=`stat -c %g "$DATA/.etc/INIT-local.sh"` >> web04.bash
else
    echo uid=1000 >> web04.bash
    echo gid=1000 >> web04.bash
fi

cat >> web04.bash  <<'EOF'
case "$1" in
    start)
        docker run \
            -d \
            --name=web04.serve \
            -p $port:9000 \
            -v "$dir":/mod/data \
            pebbe/web04:latest serve $uid $gid
            echo
            echo web04 is gestart op http://$localhost:$port/
            echo
        ;;
    stop)
        docker stop web04.serve
        docker rm web04.serve
        ;;
    upgrade)
        echo web04 wordt gestopt
        docker stop web04.serve
        docker rm web04.serve
        docker pull pebbe/web04:latest
        echo web04 moet opnieuw gestart worden
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
	echo Gebruik: web04.bash CMD
	echo
	echo CMD is een van:
	echo
	echo "  start          - start web04"
	echo "  stop           - stop web04"
	echo
        echo "  upgrade        - upgrade naar laatste versie van web04"
	echo
	echo "  shell          - open een interactieve shell"
        echo
	echo Voor meer informatie, kijk op:
	echo
	echo "  https://github.com/pebbe/Gabmap-docker"
	echo
	;;
esac
EOF

chmod +x web04.bash

cat <<EOF


================================================================


web04 is klaar voor gebruik.

EOF
echo Eventueel kun je nog dingen aanpassen in: $DATA/.etc/INIT-local.sh
cat <<EOF



Om web04 te starten, run:

    ./web04.bash start



Voor een overzicht van andere commando's, run:

    ./web04.bash


Voor meer informatie, kijk op:

    https://github.com/pebbe/Gabmap-docker


EOF
