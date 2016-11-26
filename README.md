# Gabmap in Docker #

With this, you can run Gabmap in Docker.

Download and run the script `setup.bash`

This creates a script `web04.bash` which you can use to start Gabmap.

* * * * *

More on Gabmap:
https://github.com/pebbe/Gabmap

## Problems? ##

First read the instruction below for your platform.

Still problems? Make sure you have the latest version of
*Gabmap for Docker*:

 1. Download and run the latest version of `setup.bash`
 2. Run `web04.bash upgrade`
 3. Run `web04.bash start`

Still problems? Go to https://github.com/pebbe/Gabmap-docker/issues

## Linux ##

It should just work.

## Windows ##

**Docker for Windows**

You need a script `setup.cmd`, but that isn't available yet.

**Docker Toolbox**

Not tested.

When you run `setup.bash`, the first question you get is what directory
to use to save your data. You need to enter a directory name that starts
with: `/c/Users`

When you run `web04.bash start` in the Docker shell, and all goes well,
then the last thing you see is a notice like this:

```
web04 has started on http://192.168.99.100:9000/
```

(IP address and port number may differ.)

The shown URL is where Gabmap is available in the Docker shell. This URL
is not available in your web browser, because that doesn't run from the
Docker shell. You can set up a link by running the following command
once in a regular Windows shell:

```
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=9000 connectaddress=192.168.99.100 connectport=9000
```

(Tested with Windows 10, chance the IP address and port number if needed)

Then you can access Gabmap in your web browser at this URL:
http://localhost:9000/


## Mac OS X ##

Not tested.

**Docker for Mac**

When you run `setup.bash`, the first question you get is what directory
to use to save your data. I don't know if you can use any directory. You
may need to use a directory that starts with: `/Users`

The scripts `setup.bash` and `web04.bash` should work in an ordinary
shell on Mac. But in *Docker for Windows*, the linking of a directory
to a container is currently not working. I have no idea what the
situation is on Mac.

**Docker Toolkit**

When you run `setup.bash`, the first question you get is what directory
to use to save your data. You need to enter a directory name that starts
with: `/Users`

Does Mac have the same problem as Windows, that the URL where Gabmap is
running is not available from outside of the Docker shell? And if yes,
how do you solve this?
