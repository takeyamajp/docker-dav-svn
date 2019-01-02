# dav-svn
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/dav-svn.svg?style=flat-square)](https://hub.docker.com/r/takeyamajp/dav-svn/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/dav-svn.svg?style=flat-square)](https://hub.docker.com/r/takeyamajp/dav-svn/)

FROM centos  
MAINTAINER "Hiroki Takeyama"

ENV TIMEZONE Asia/Tokyo

ENV REQUIRE_SSL true

ENV SVN_REPOSITORY dev  
ENV SVN_USER user  
ENV SVN_PASSWORD user

VOLUME /svn

EXPOSE 80  
EXPOSE 443
