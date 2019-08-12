# dav-svn
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/dav-svn.svg)](https://hub.docker.com/r/takeyamajp/dav-svn/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/dav-svn.svg)](https://hub.docker.com/r/takeyamajp/dav-svn/)
[![](https://img.shields.io/badge/GitHub-Dockerfile-orange.svg)](https://github.com/takeyamajp/docker-dav-svn/blob/master/Dockerfile)
[![license](https://img.shields.io/github/license/takeyamajp/docker-dav-svn.svg)](https://github.com/takeyamajp/docker-dav-svn/blob/master/LICENSE)

    FROM centos:centos7  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV REQUIRE_SSL true
    
    ENV HTTPD_SERVER_ADMIN root@localhost  
    ENV HTTPD_LOG true  
    ENV HTTPD_LOG_LEVEL warn
    
    ENV SVN_REPOSITORY dev  
    ENV SVN_USER user1,user2  
    ENV SVN_PASSWORD password1,password2
    
    VOLUME /svn
    
    EXPOSE 80  
    EXPOSE 443
    
