# -*- coding: utf-8 -*- 

# This is an example init file.
# Modify it for your own site, and save as: INIT.sh
#
# NOTE: for non-ascii characters, this file should be encoded in utf-8

# Set access mask for new files and directories
umask 077

# The 'leven' program can use a lot of memory when it has to calculate Cronbach's alpha
# Limit the amount of memory programs may use, so it won't crash the web server
ulimit -v 500000

# Maximum number of projects per user
export MAXPROJECTS=20

# Maximum number of days of inactivity before removal of account
export MAXDAYS=60

# Python settings

# Which Python binary to use, requires Python 3.1 or above
export PYTHON2=python
export PYTHON3=python3

export PYTHON2PATH=`pwd`
export PYTHON3PATH=`pwd`
export PYTHONPATH=$PYTHON3PATH

# Make sure sys.stdout is set to UTF-8
export PYTHONIOENCODING=utf-8
export LANG=en_US.UTF-8  
export LC_COLLATE=C

# Where libraries for R are stored
export R_LIBS_USER=

# Some string used for encryption, change it for your site
export SECRET='gasheyri iorhyer fjdfjlui dfpe8'

# if the webapp is served through a proxy, try to find the real ip of the user
export TRY_X_FORWARDED_FOR=no

# Where the webapp stores its data, including trailing slash
export DATADIR=/mod/data/

# Location of the webapp, including trailing slash
export APPDIR=/mod/Gabmap/

# The base url to the webapp, including trailing slash
## export APPURL=http://yourdomain/~yourname/gabmap/

# The base url to the webapp using https, including trailing slash
## export APPURLS=https://yourdomain/~yourname/gabmap/

# The base url to the webapp without server, including trailing slash
export APPREL=/

# Links to some standard web pages
export ABOUTURL="http://www.gabmap.nl/?page_id=18"
export HELPURL="http://www.gabmap.nl/?page_id=12"

# PATH should include the Python binary, and the RuG/L04 binaries
export PATH=${APPDIR}util:/mod/RuG-L04/bin:$PATH

# Additional libraries needed for binaries
#export LD_LIBRARY_PATH=${APPDIR}lib

# The bare e-mail address used as sender in automated e-mail messages
## export MAILFROM=yourname@yourdomain

# How to send e-mail
## export SMTPSERV=your.mailserver.com
## export SMTPUSER=
## export SMTPPASS=


### The following variables are optional

# Url of contact person, either http:// or mailto:
## export CONTACT=mailto:yourname@yourdomain

# Name of contact person
## export CONTACTNAME="Your Name"

# This overrides CONTACT and CONTACTNAME, and defines a complete footer in HTML
#export CONTACTLINE="For help, please contact <a href=\"mailto:yourname@yourdomain\">me</a>"

# Site specific config
. /mod/data/.etc/INIT-local.sh
