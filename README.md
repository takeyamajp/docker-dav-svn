FROM centos  
MAINTAINER "Hiroki Takeyama"

ENV REQUIRE_SSL true

ENV SVN_REPOSITORY dev  
ENV SVN_USER user  
ENV SVN_PASSWORD user

VOLUME /svn

EXPOSE 80  
EXPOSE 443
