FROM centos:centos8
MAINTAINER "Hiroki Takeyama"

# certificate
RUN mkdir /cert; \
    yum -y install openssl; \
    openssl genrsa -aes128 -passout pass:dummy -out "/cert/key.pass.pem" 2048; \
    openssl rsa -passin pass:dummy -in "/cert/key.pass.pem" -out "/cert/key.pem"; \
    rm -f /cert/key.pass.pem; \
    yum clean all;

# subversion
RUN mkdir /svn; \
    yum -y install subversion; \
    yum clean all;

# httpd
RUN yum -y install httpd mod_ssl mod_dav_svn; \
    sed -i 's/^#\(ServerName\) .*/\1 ${HOSTNAME}/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf.d/ssl.conf; \
    echo 'CustomLog /dev/stdout "%{X-Forwarded-For}i %h %l %u %t %{SVN-ACTION}e %U" env=SVN-ACTION' >> /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*"%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"/CustomLog \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t %{SVN-ACTION}e %U" env=SVN-ACTION/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(LoadModule auth_digest_module .*\)/#\1/' /etc/httpd/conf.modules.d/00-base.conf; \
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

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'openssl req -new -key "/cert/key.pem" -subj "/CN=${HOSTNAME}" -out "/cert/csr.pem"'; \
    echo 'openssl x509 -req -days 36500 -in "/cert/csr.pem" -signkey "/cert/key.pem" -out "/cert/cert.pem" &>/dev/null'; \
    echo 'sed -i "s/^\(SSLCertificateFile\) .*/\1 \/cert\/cert.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(SSLCertificateKeyFile\) .*/\1 \/cert\/key.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'if [ -e /svn/cert.pem ] && [ -e /svn/key.pem ]; then'; \
    echo '  sed -i "s/^\(SSLCertificateFile\) .*/\1 \/svn\/cert.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo '  sed -i "s/^\(SSLCertificateKeyFile\) .*/\1 \/svn\/key.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'fi'; \
    echo 'sed -i "s/^\(LogLevel\) .*/\1 ${HTTPD_LOG_LEVEL}/" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^\(LogLevel\) .*/\1 ${HTTPD_LOG_LEVEL}/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(CustomLog .*\)/#\1/" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^\(ErrorLog .*\)/#\1/" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^\(CustomLog .*\)/#\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(ErrorLog .*\)/#\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'if [ ${HTTPD_LOG,,} = "true" ]; then'; \
    echo '  sed -i "s/^#\(CustomLog .*\)/\1/" /etc/httpd/conf/httpd.conf'; \
    echo '  sed -i "s/^#\(ErrorLog .*\)/\1/" /etc/httpd/conf/httpd.conf'; \
    echo '  sed -i "s/^#\(CustomLog .*\)/\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo '  sed -i "s/^#\(ErrorLog .*\)/\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'fi'; \
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
    echo 'if [ -e /svn/passwd ]; then'; \
    echo '  rm -f /svn/passwd'; \
    echo 'fi'; \
    echo 'if [ -e /svn/access ]; then'; \
    echo '  rm -f /svn/access'; \
    echo 'fi'; \
    echo '{'; \
    echo 'echo "[/]";'; \
    echo 'echo "* = r";'; \
    echo '} > /svn/access'; \
    echo 'ARRAY_USER=(`echo ${SVN_USER} | tr "," " "`)'; \
    echo 'ARRAY_PASSWORD=(`echo ${SVN_PASSWORD} | tr "," " "`)'; \
    echo 'INDEX=0'; \
    echo 'for e in ${ARRAY_USER[@]}; do'; \
    echo '  htpasswd -bmn ${ARRAY_USER[${INDEX}]} ${ARRAY_PASSWORD[${INDEX}]} | head -c -1 >> /svn/passwd'; \
    echo '  echo "${ARRAY_USER[${INDEX}]} = rw" >> /svn/access'; \
    echo '  ((INDEX+=1))'; \
    echo 'done'; \
    echo 'chown -R apache:apache /svn'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV TIMEZONE Asia/Tokyo

ENV REQUIRE_SSL true

ENV HTTPD_LOG true
ENV HTTPD_LOG_LEVEL warn

ENV SVN_REPOSITORY dev
ENV SVN_USER user1,user2
ENV SVN_PASSWORD password1,password2

VOLUME /svn

EXPOSE 80
EXPOSE 443

CMD ["httpd", "-DFOREGROUND"]
