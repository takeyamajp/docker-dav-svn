FROM centos
MAINTAINER "Hiroki Takeyama"

# timezone
RUN rm -f /etc/localtime; \
   ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime;

# svn
RUN yum -y install svn; yum clean all;

# httpd
RUN yum -y install httpd mod_ssl mod_dav_svn; yum clean all;

# prevent error AH00558 on stdout
RUN echo 'ServerName ${HOSTNAME}' >> /etc/httpd/conf.d/additional.conf;

# logging
RUN echo 'CustomLog /dev/stdout "%t %h %u %U %{SVN-ACTION}e" env=SVN-ACTION' >> /etc/httpd/conf.d/additional.conf; \
    echo 'ErrorLog /dev/stderr' >> /etc/httpd/conf.d/additional.conf;

# entrypoint
RUN mkdir /svn; \
    { \
    echo '#!/bin/bash -eu'; \
    echo '{'; \
    echo '  echo "<Location />";'; \
    echo '  echo "  Dav svn";'; \
    echo '  echo "  SSLRequireSSL";'; \
    echo '  echo "  SVNParentPath /svn";'; \
    echo '  echo "  SVNListParentPath on";'; \
    echo '  echo "  AuthType Basic";'; \
    echo '  echo "  AuthName '\''Basic Authentication'\''";'; \
    echo '  echo "  AuthUserFile /svn/passwd";'; \
    echo '  echo "  Require valid-user";'; \
    echo '  echo "  AuthzSVNAccessFile /svn/access";'; \
    echo '  echo "</Location>";'; \
    echo '} > /etc/httpd/conf.d/subversion.conf'; \
    echo 'if [ ! -e /svn/${SVN_REPOSITORY} ]; then'; \
    echo '  svnadmin create /svn/${SVN_REPOSITORY}'; \
    echo 'fi'; \
    echo 'if [ ! -e /svn/passwd ]; then'; \
    echo '  htpasswd -bmc /svn/passwd ${SVN_USER} ${SVN_PASSWORD} &>/dev/null'; \
    echo 'fi'; \
    echo 'if [ ! -e /svn/access ]; then'; \
    echo '  {'; \
    echo '    echo "[/]";'; \
    echo '    echo "* = r";'; \
    echo '    echo "${SVN_USER} = rw";'; \
    echo '  } > /svn/access'; \
    echo 'fi'; \
    echo 'chown -R apache:apache /svn'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV SVN_REPOSITORY dev
ENV SVN_USER user
ENV SVN_PASSWORD user

VOLUME /svn

EXPOSE 80
EXPOSE 443

CMD ["httpd", "-DFOREGROUND"]
