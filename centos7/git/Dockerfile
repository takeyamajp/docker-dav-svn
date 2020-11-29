FROM centos:centos7
MAINTAINER "Hiroki Takeyama"

# certificate
RUN mkdir /cert; \
    yum -y install openssl; \
    openssl genrsa -aes256 -passout pass:dummy -out "/cert/key.pass.pem" 2048; \
    openssl rsa -passin pass:dummy -in "/cert/key.pass.pem" -out "/cert/key.pem"; \
    rm -f /cert/key.pass.pem; \
    yum clean all;

# git
RUN mkdir /git; \
    yum -y install git; \
    yum clean all;

# httpd
RUN yum -y install httpd mod_ssl; \
    sed -i 's/^#\(ServerName\) .*/\1 ${HOSTNAME}/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\s*"%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"//' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(LoadModule auth_digest_module .*\)/#\1/' /etc/httpd/conf.modules.d/00-base.conf; \
    rm -f /etc/httpd/conf.modules.d/00-proxy.conf; \
    rm -f /usr/sbin/suexec; \
    { \
    echo 'SetEnv GIT_PROJECT_ROOT /git'; \
    echo 'SetEnv GIT_HTTP_EXPORT_ALL'; \
    echo 'ScriptAlias / /usr/libexec/git-core/git-http-backend/'; \
    echo '<Location />'; \
    echo '  Options ExecCGI'; \
    echo '  AuthName "Basic Authentication"'; \
    echo '  AuthType Basic'; \
    echo '  AuthUserFile /git/passwd'; \
    echo '  Require valid-user'; \
    echo '</Location>'; \
    } >> /etc/httpd/conf/httpd.conf; \
    yum clean all;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'openssl req -new -sha384 -key "/cert/key.pem" -subj "/CN=${HOSTNAME}" -out "/cert/csr.pem"'; \
    echo 'openssl x509 -req -days 36500 -in "/cert/csr.pem" -signkey "/cert/key.pem" -out "/cert/cert.pem" &>/dev/null'; \
    echo 'sed -i "s/^\(SSLCertificateFile\) .*/\1 \/cert\/cert.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(SSLCertificateKeyFile\) .*/\1 \/cert\/key.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'if [ -e /git/cert.pem ] && [ -e /git/key.pem ]; then'; \
    echo '  sed -i "s/^\(SSLCertificateFile\) .*/\1 \/git\/cert.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo '  sed -i "s/^\(SSLCertificateKeyFile\) .*/\1 \/git\/key.pem/" /etc/httpd/conf.d/ssl.conf'; \
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
    echo 'if [ ! -e /git/${GIT_REPOSITORY} ]; then'; \
    echo '  mkdir /git/${GIT_REPOSITORY}'; \
    echo '  git init -q --bare --shared /git/${GIT_REPOSITORY}'; \
    echo 'fi'; \
    echo 'if [ -e /git/passwd ]; then'; \
    echo '  rm -f /git/passwd'; \
    echo 'fi'; \
    echo 'ARRAY_USER=(`echo ${GIT_USER} | tr "," " "`)'; \
    echo 'ARRAY_PASSWORD=(`echo ${GIT_PASSWORD} | tr "," " "`)'; \
    echo 'INDEX=0'; \
    echo 'for e in ${ARRAY_USER[@]}; do'; \
    echo '  htpasswd -bmn ${ARRAY_USER[${INDEX}]} ${ARRAY_PASSWORD[${INDEX}]} | head -c -1 >> /git/passwd'; \
    echo '  ((INDEX+=1))'; \
    echo 'done'; \
    echo 'chown -R apache:apache /git'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;

ENV TIMEZONE Asia/Tokyo

ENV REQUIRE_SSL true

ENV HTTPD_LOG true
ENV HTTPD_LOG_LEVEL warn

ENV GIT_REPOSITORY dev.git
ENV GIT_USER user1,user2
ENV GIT_PASSWORD password1,password2

VOLUME /git

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
