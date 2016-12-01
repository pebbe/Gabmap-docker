@ECHO OFF

SETLOCAL EnableExtensions EnableDelayedExpansion

ECHO.
ECHO Directory where web04 saves your data
ECHO Example: %HOMEDRIVE%%HOMEPATH%\web04-data
SET DATA=
SET /p "DATA=Directory: "
CALL :Trim DATA %DATA%
IF NOT DEFINED DATA (
    ECHO Setup aborted
    GOTO:EOF
)

PUSHD "%DATA%" 2> NUL && POPD && GOTO EndDataNotExists

IF EXIST "%DATA%" (
    ECHO "%DATA%" exists and is not a directory
    ECHO Setup aborted
    GOTO:EOF
)

ECHO Directory "%DATA%" does not exist
SET JN=
SET /p "JN=Create directory? (y/n) "
CALL :JaNee
IF NOT "%JN%"=="j" (
    ECHO Setup aborted
    GOTO:EOF
)

MKDIR "%DATA%"
GOTO EndData
:EndDataNotExists

IF NOT EXIST %DATA%\.etc\INIT-local.sh GOTO EndSetupExists
ECHO The file INIT-local.sh already exists in '%DATA%\.etc'
SET JN=
SET /p "JN=Replace setup? (y/n) "
CALL :JaNee
IF NOT "%JN%"=="j" (
        ECHO Setup aborted
        GOTO:EOF
)
GOTO EndData
:EndSetupExists

FOR /f %%a IN ('DIR /b "%DATA%"') DO (
    ECHO The directory '%DATA%' is not empty
    ECHO If you truly want to use this directory, run: ECHO ^> "%DATA%\.etc\INIT-local.sh"
    ECHO Setup aborted
    GOTO:EOF
)

:EndData
CALL :DataFull "%DATA%"

CALL :MkSub .etc
IF "%ERROR%"=="1" GOTO:EOF
CALL :MkSub .queue
IF "%ERROR%"=="1" GOTO:EOF

ECHO.
ECHO What port do you want to run web04 on?
ECHO Example: 9000
SET PORT=
SET /p "PORT=Port number: "
CALL :Trim PORT %PORT%
IF NOT DEFINED PORT (
    ECHO Port number missing
    ECHO Setup aborted
    GOTO:EOF
)

ECHO.
ECHO Do you want to use web04 in single user mode or multi user mode?
ECHO   s) single user: no login, all projects visible to everyone
ECHO   m) multi user: login, each user their own limited number of projects
SET UM=
SET /p "UM=User mode (s/m): "
CALL :Trim UM %UM%
SET USERMODE=0
IF "%UM%"=="s" SET USERMODE=1
IF "%UM%"=="S" SET USERMODE=1
IF "%UM%"=="m" SET USERMODE=2
IF "%UM%"=="M" SET USERMODE=2
IF "%USERMODE%"=="0" (
    ECHO User mode missing
    ECHO Setup aborted
    GOTO:EOF
)
IF "%USERMODE%"=="1" GOTO SingleUser

ECHO.
ECHO What is the address to use as sender of mail by web04?
ECHO Voorbeeld: maintainer@web04.nl
SET MAILFROM=
SET /p "MAILFROM=Adres: "
CALL :Trim MAILFROM %MAILFROM%
IF NOT DEFINED MAILFROM (
    ECHO Address missing
    ECHO Setup aborted
    GOTO:EOF
)

FOR /F "tokens=2 delims=@" %%a IN ("%MAILFROM%") DO SET maildomain=%%a
CALL :Trim maildomain %maildomain%
IF NOT DEFINED maildomain SET maildomain=web04.nl

ECHO.
ECHO What is the IP address of the smtp server that web04 can use to send mail?
ECHO HINT: Look in your mail program in the settings of smtp.
ECHO Examples, with/without port number (port 25 is the default):
ECHO   smtp.%maildomain%
ECHO   smtp.%maildomain%:25
ECHO   smtp.%maildomain%:465
ECHO   smtp.%maildomain%:587
SET SMTPSERV=
SET /p "SMTPSERV=SMTP server: "
CALL :Trim SMTPSERV %SMTPSERV%
IF NOT DEFINED SMTPSERV (
    ECHO Smtp server missing
    ECHO Setup aborted
    GOTO:EOF
)
FOR /F "tokens=1* delims=:" %%a IN ("%SMTPSERV%") DO SET p=%%b
IF NOT DEFINED p SET SMTPSERV=%SMTPSERV%:25

ECHO.
ECHO Do you need to log-in on the smtp server before you can send mail?
ECHO If so, provide your username for the smtp server
SET SMTPUSER=
SET /p "SMTPUSER=Username: "
CALL :Trim SMTPUSER %SMTPUSER%

SET SMTPPASS=
IF NOT DEFINED SMTPUSER GOTO EndMailPass
ECHO.
ECHO Provide the password for the smtp server
SET /p "SMTPPASS=Password: "
CALL :Trim SMTPPASS %SMTPPASS%
IF NOT DEFINED SMTPPASS (
    ECHO Password missing
    ECHO Setup aborted
    GOTO:EOF
)
:EndMailPass

SET out="%DATA%\.etc\INIT-local.sh

ECHO. > %out%
ECHO export USERMODE=multi>> %out%
ECHO. >> %out%
ECHO # Set access mask for new files and directories>> %out%
ECHO umask 077>> %out%
ECHO. >> %out%
ECHO # The 'leven' program can use a lot of memory when it has to calculate Cronbach's alpha>> %out%
ECHO # Limit the amount of memory programs may use, so it won't crash the web server>> %out%
ECHO ulimit -v 500000>> %out%
ECHO. >> %out%
ECHO # The base url to the webapp, including trailing slash>> %out%
ECHO export APPURL=http://localhost:%PORT%/>> %out%
ECHO. >> %out%
ECHO # The base url to the webapp using https, including trailing slash>> %out%
ECHO export APPURLS=http://localhost:%PORT%/>> %out%
ECHO. >> %out%
ECHO # The base url to the webapp without server, including trailing slash>> %out%
ECHO export APPREL=/>> %out%
ECHO. >> %out%
ECHO # The bare e-mail address used as sender in automated e-mail messages>> %out%
ECHO export MAILFROM=%MAILFROM%>> %out%
ECHO. >> %out%
ECHO # How to send e-mail, server including port number>> %out%
ECHO export SMTPSERV=%SMTPSERV%>> %out%
ECHO export SMTPUSER=%SMTPUSER%>> %out%
ECHO export SMTPPASS=%SMTPPASS%>> %out%
ECHO. >> %out%
ECHO ### The following variables are optional>> %out%
ECHO. >> %out%
ECHO # Url of contact person, either http:// or mailto:>> %out%
ECHO # export CONTACT=http://yourdomain/>> %out%
ECHO. >> %out%
ECHO # Name of contact person>> %out%
ECHO # export CONTACTNAME="Your Name">> %out%
ECHO. >> %out%
ECHO # This overrides CONTACT and CONTACTNAME, and defines a complete footer in HTML>> %out%
ECHO # export CONTACTLINE="For help, please contact <a href=\"mailto:yourname@yourdomain\">me</a>">> %out%
ECHO. >> %out%

GOTO EndInitLocal

:SingleUser

CALL :MkSub User
IF "%ERROR%"=="1" GOTO:EOF

SET out="%DATA%\.etc\INIT-local.sh

ECHO. > %out%
ECHO export USERMODE=single>> %out%
ECHO. >> %out%
ECHO # Set access mask for new files and directories>> %out%
ECHO umask 022>> %out%
ECHO. >> %out%
ECHO # The 'leven' program can use a lot of memory when it has to calculate Cronbach's alpha>> %out%
ECHO # Limit the amount of memory programs may use, so it won't crash the web server>> %out%
ECHO ulimit -v 500000>> %out%
ECHO. >> %out%
ECHO # The base url to the webapp, including trailing slash>> %out%
ECHO export APPURL=http://localhost:%PORT%/>> %out%
ECHO. >> %out%
ECHO # The base url to the webapp using https, including trailing slash>> %out%
ECHO export APPURLS=http://localhost:%PORT%/>> %out%
ECHO. >> %out%
ECHO # The base url to the webapp without server, including trailing slash>> %out%
ECHO export APPREL=/>> %out%
ECHO. >> %out%

:EndInitLocal

CALL :dirfix "%DATA%"


ECHO @ECHO OFF> web04.cmd
ECHO SET dir=%DATA%>> web04.cmd
ECHO SET udir=%udir%>> web04.cmd
ECHO SET port=%PORT%>> web04.cmd
ECHO SET localhost=127.0.0.1>> web04.cmd
ECHO SET machine=default>> web04.cmd
ECHO FOR /f %%%%a in ('docker-machine active') DO SET machine=%%%%a>> web04.cmd
ECHO FOR /f %%%%a in ('docker-machine ip %%machine%%') DO SET localhost=%%%%a>> web04.cmd
ECHO IF NOT EXIST "%%dir%%\.etc\INIT-local.sh" (>> web04.cmd
ECHO     ECHO File does not exist: %%dir%%\.etc\INIT-local.sh>> web04.cmd
ECHO     GOTO:EOF>> web04.cmd
ECHO )>> web04.cmd
ECHO. >> web04.cmd
ECHO SET CMD=%%1>> web04.cmd
ECHO. >> web04.cmd
ECHO IF NOT "%%CMD%%"=="start" GOTO EndStart>> web04.cmd
ECHO docker run -d --name=web04.serve -p %%port%%:9000 -v "%%udir%%:/mod/data" pebbe/web04:latest serve>> web04.cmd
ECHO IF NOT "%%ERRORLEVEL%%"=="0" GOTO:EOF>> web04.cmd
ECHO ECHO web04 has started on http://%%localhost%%:%%port%%/>> web04.cmd
ECHO GOTO:EOF>> web04.cmd
ECHO :EndStart>> web04.cmd
ECHO.>> web04.cmd
ECHO IF NOT "%%CMD%%"=="stop" GOTO EndStop>> web04.cmd
ECHO docker stop web04.serve>> web04.cmd
ECHO docker rm web04.serve>> web04.cmd
ECHO GOTO:EOF>> web04.cmd
ECHO :EndStop>> web04.cmd
ECHO.>> web04.cmd
ECHO IF NOT "%%CMD%%"=="upgrade" GOTO EndUpgrade>> web04.cmd
ECHO ECHO stopping web04>> web04.cmd
ECHO docker stop web04.serve>> web04.cmd
ECHO docker rm web04.serve>> web04.cmd
ECHO docker pull pebbe/web04:latest>> web04.cmd
ECHO ECHO web04 needs to be restarted>> web04.cmd
ECHO GOTO:EOF>> web04.cmd
ECHO :EndUpgrade>> web04.cmd
ECHO.>> web04.cmd
ECHO IF NOT "%%CMD%%"=="info" GOTO EndInfo>> web04.cmd
ECHO docker inspect web04.serve>> web04.cmd
ECHO ECHO. >> web04.cmd
ECHO docker logs web04.serve>> web04.cmd
ECHO GOTO:EOF>> web04.cmd
ECHO :EndInfo>> web04.cmd
ECHO.>> web04.cmd
ECHO IF NOT "%%CMD%%"=="shell" GOTO EndShell>> web04.cmd
ECHO docker run --rm -i -t -v "%%udir%%:/mod/data" pebbe/web04:latest shell>> web04.cmd
ECHO GOTO:EOF>> web04.cmd
ECHO :EndShell>> web04.cmd
ECHO.>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO Usage: web04 CMD>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO echo CMD is one of:>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO   start     - start web04>> web04.cmd
ECHO ECHO   stop      - stop web04>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO   upgrade   - upgrade to latest version of web04>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO   info      - show debug info for running web04>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO   shell     - open an interactive shell>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO For more information, go to:>> web04.cmd
ECHO ECHO.>> web04.cmd
ECHO ECHO   https://github.com/pebbe/Gabmap-docker>> web04.cmd
ECHO ECHO.>> web04.cmd

ECHO.
ECHO ================================================================
ECHO.
ECHO web04 is ready to use.
ECHO.
ECHO If you want, you can change things in: %DATA%\.etc\INIT-local.sh
ECHO.
ECHO.
ECHO To start web04, run:
ECHO.
ECHO     web04.cmd start
ECHO.
ECHO.
ECHO For a list of other commands, run:
ECHO.
ECHO     web04.cmd
ECHO.
ECHO.
ECHO For more information, go to:
ECHO.
ECHO     https://github.com/pebbe/Gabmap-docker
ECHO.

GOTO:EOF


:Trim
SET p=%*
FOR /f "tokens=1*" %%a IN ("!p!") DO SET %1=%%b
GOTO:EOF


:JaNee
CALL :Trim JN %JN%
IF "%JN%"=="J" SET JN=j
IF "%JN%"=="y" SET JN=j
IF "%JN%"=="Y" SET JN=j
IF "%JN%"=="N" SET JN=n
GOTO:EOF


:DataFull
SET DATA=%~f1
GOTO:EOF


:MkSub
SET ERROR=0
PUSHD "%DATA%\%1" 2> NUL && POPD && GOTO:EOF
MKDIR "%DATA%\%1"
IF "%ERRORLEVEL%"=="0" GOTO:EOF
SET ERROR=1
ECHO Maken van directory '%DATA%\%1' is mislukt
ECHO Setup afgebroken
GOTO:EOF


:dirfix
REM verander "C:\My path\My file" -> "/c/My path/My file"
REM resultaat in %udir%
SET t=%*
SET t=%t:"=%
FOR /F "tokens=1* delims=:" %%a IN ("%t%") DO (
        SET udir=/%%a
        SET t=%%b
)
CALL :LoCase udir
SET udir=%udir%%t:\=/%
GOTO:EOF


:LoCase
REM Subroutine to convert a variable VALUE to all lower case.
REM The argument for this subroutine is the variable NAME.
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF

