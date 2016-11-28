# -*- coding: utf-8 -*-

# NOTE: for non-ascii characters, this file should be encoded in utf-8

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
export SECRET='garbel de garbel'

# if the webapp is served through a proxy, try to find the real ip of the user
export TRY_X_FORWARDED_FOR=no

# Where the webapp stores its data, including trailing slash
export DATADIR=/mod/data/

# Location of the webapp, including trailing slash
export APPDIR=/mod/Gabmap/

# PATH should include the Python binary, and the RuG/L04 binaries
export PATH=${APPDIR}util:/mod/RuG-L04/bin:$PATH

# Additional libraries needed for binaries
#export LD_LIBRARY_PATH=${APPDIR}lib

# Site specific config
. /mod/data/.etc/INIT-local.sh
