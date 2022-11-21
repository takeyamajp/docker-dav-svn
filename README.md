# dav-svn
Star this repository if it is useful for you.  
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/dav-svn.svg)](https://hub.docker.com/r/takeyamajp/dav-svn/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/dav-svn.svg)](https://hub.docker.com/r/takeyamajp/dav-svn/)
[![license](https://img.shields.io/github/license/takeyamajp/docker-dav-svn.svg)](https://github.com/takeyamajp/docker-dav-svn/blob/master/LICENSE)

### Supported tags and respective Dockerfile links  
- [`latest`, `rocky9`](https://github.com/takeyamajp/docker-dav-svn/blob/master/rocky9/Dockerfile) (Rocky Linux 9)
- [`rocky8`](https://github.com/takeyamajp/docker-dav-svn/blob/master/rocky8/Dockerfile) (Rocky Linux 8)
- [`centos8`](https://github.com/takeyamajp/docker-dav-svn/blob/master/centos8/Dockerfile)
- [`centos7`](https://github.com/takeyamajp/docker-dav-svn/blob/master/centos7/Dockerfile)

### Image summary
    FROM centos:centos8  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV REQUIRE_SSL true
    
    ENV HTTPD_LOG true  
    ENV HTTPD_LOG_LEVEL warn
    
    ENV SVN_REPOSITORY dev  
    ENV CREATE_BASIC_DIRECTORY_STRUCTURE true  
    ENV SVN_USER user1,user2  
    ENV SVN_PASSWORD password1,password2
    
    VOLUME /svn
    
    EXPOSE 80  
    EXPOSE 443
    
