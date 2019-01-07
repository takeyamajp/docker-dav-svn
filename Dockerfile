FROM centos
MAINTAINER "Hiroki Takeyama"

# subversion
RUN yum -y install subversion; \
    yum clean all;

# httpd
RUN yum -y install httpd mod_ssl mod_dav_svn; \
    sed -i 's/^\s*CustomLog .*/CustomLog \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/1' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^ErrorLog .*/ErrorLog \/dev\/stderr/1' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*CustomLog .*/CustomLog \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/1' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^ErrorLog .*/ErrorLog \/dev\/stderr/1' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\s*"%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"//1' /etc/httpd/conf.d/ssl.conf; \
    echo 'CustomLog /dev/stdout "%{X-Forwarded-For}i %h %l %u %t %{SVN-ACTION}e %U" env=SVN-ACTION' >> /etc/httpd/conf/httpd.conf; \
    { \
    echo '<VirtualHost _default_:443>'; \
    echo '  CustomLog /dev/stdout "%{X-Forwarded-For}i %h %l %u %t %{SVN-ACTION}e %U" env=SVN-ACTION'; \
    echo '</VirtualHost>'; \
    } >> /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(LoadModule auth_digest_module .*\)/#\1/1' /etc/httpd/conf.d/ssl.conf; \
    rm -f /etc/httpd/conf.modules.d/00-proxy.conf; \
    rm -f /usr/sbin/suexec; \
    { \
    echo '<Location />'; \
    echo '  Dav svn'; \
    echo '  SVNParentPath /svn'; \
    echo '  SVNListParentPath on'; \
    echo '  AuthType Basic'; \
    echo '  AuthName "Basic Authentication"'; \
    echo '  AuthUserFile /svn/passwd'; \
    echo '  Require valid-user'; \
    echo '  AuthzSVNAccessFile /svn/access'; \
    echo '</Location>'; \
    } >> /etc/httpd/conf/httpd.conf; \
    yum clean all;

# prevent error AH00558 on stdout
RUN echo 'ServerName ${HOSTNAME}' >> /etc/httpd/conf.d/additional.conf;

# entrypoint
RUN mkdir /svn; \
    { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'sed -i "s/^LogLevel .*/LogLevel ${HTTPD_LOG_LEVEL}/1" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^LogLevel .*/LogLevel ${HTTPD_LOG_LEVEL}/1" /etc/httpd/conf.d/ssl.conf'; \
    echo 'if [ -e /etc/httpd/conf.d/requireSsl.conf ]; then'; \
    echo '  rm -f /etc/httpd/conf.d/requireSsl.conf'; \
    echo 'fi'; \
    echo 'if [ ${REQUIRE_SSL,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "<Location />"'; \
    echo '  echo "  SSLRequireSSL"'; \
    echo '  echo "</Location>"'; \
    echo '  } > /etc/httpd/conf.d/requireSsl.conf'; \
    echo 'fi'; \
    echo 'if [ ! -e /svn/${SVN_REPOSITORY} ]; then'; \
    echo '  svnadmin create /svn/${SVN_REPOSITORY}'; \
    echo 'fi'; \
    echo 'if [ ! -e /svn/passwd ]; then'; \
    echo '  htpasswd -bmc /svn/passwd ${SVN_USER} ${SVN_PASSWORD} &>/dev/null'; \
    echo 'fi'; \
    echo 'if [ ! -e /svn/access ]; then'; \
    echo '  {'; \
    echo '  echo "[/]";'; \
    echo '  echo "* = r";'; \
    echo '  echo "${SVN_USER} = rw";'; \
    echo '  } > /svn/access'; \
    echo 'fi'; \
    echo 'chown -R apache:apache /svn'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV TIMEZONE Asia/Tokyo

ENV REQUIRE_SSL true

ENV HTTPD_LOG_LEVEL warn

ENV SVN_REPOSITORY dev
ENV SVN_USER user
ENV SVN_PASSWORD user

VOLUME /svn

EXPOSE 80
EXPOSE 443

CMD ["httpd", "-DFOREGROUND"]
