#
# PaQu in Docker
#
# To build and push to repository:
#
#     docker build -t registry.webhosting.rug.nl/compling/web04:latest .
#     docker push registry.webhosting.rug.nl/compling/web04:latest
#

FROM debian:8

MAINTAINER Peter Kleiweg <p.c.j.kleiweg@rug.nl>

RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl \
  flex \
  git \
  less \
  lighttpd \
  locales \
  make \
  nano \
  netpbm \
  python-numpy \
  python-pyproj \
  python3-numpy \
  python3-pyproj \
  R-base-core \
  time \
  vim

RUN sed -e 's/^# en_US.UTF-8'/en_US.UTF-8'/' /etc/locale.gen > /etc/locale.gen.tmp && \
    mv /etc/locale.gen.tmp /etc/locale.gen && \
    locale-gen

RUN mkdir -p /mod/etc && \
    cd /mod && \
    curl -s http://www.let.rug.nl/~kleiweg/L04/L04-src.tar.gz | tar vxzf - && \
    cd RuG-L04 && \
    make -C src && \
    R CMD INSTALL R/iL04*.tar.gz && \
    rm -fr Changes.txt Manuals R README.txt etc pyL04 src

ADD https://github.com/pebbe/Gabmap/commits/master.atom /master
RUN cd /mod && git clone https://github.com/pebbe/Gabmap && rm /master && \
    cd /mod/Gabmap && \
    make -C util && \
    rm -fr .htaccess .git L04.ps bin/.htaccess examples/*.u16 examples/HEADER.html examples/.htaccess doc/IntroVideo doc/flowcharts src test

RUN perl -p -e 's!\{0\[binurls\]\}!/bin/!' /mod/Gabmap/tools/ll2kml.html.IN > /mod/Gabmap/tools/ll2kml.html && \
    perl -p -e 's!\{0\[binurls\]\}!/bin/!' /mod/Gabmap/tools/xs2utf.html.IN > /mod/Gabmap/tools/xs2utf.html

ADD INIT.sh /mod/Gabmap/bin/
ADD profile.sh /mod/etc/
ADD httpd.config /mod/etc/

ADD epstopdf /mod/Gabmap/util
RUN chmod 755 /mod/Gabmap/util/epstopdf

EXPOSE 9000

ADD entrypoint.sh /mod/etc/
RUN chmod 755 /mod/etc/entrypoint.sh

ENTRYPOINT ["/mod/etc/entrypoint.sh"]
CMD ["shell"]
