FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CERTBOT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV DHLEVEL=2048 ONLY_SUBDOMAINS=false AWS_CONFIG_FILE=/config/dns-conf/route53.ini
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	cargo \
	g++ \
	gcc \
	libffi-dev \
	openssl-dev \
	python3-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	curl \
	fail2ban \
	gnupg \
	memcached \
	nginx \
	nginx-mod-http-brotli \
	nginx-mod-http-dav-ext \
	nginx-mod-http-echo \
	nginx-mod-http-fancyindex \
	nginx-mod-http-geoip2 \
	nginx-mod-http-headers-more \
	nginx-mod-http-image-filter \
	nginx-mod-http-nchan \
	nginx-mod-http-perl \
	nginx-mod-http-redis2 \
	nginx-mod-http-set-misc \
	nginx-mod-http-upload-progress \
	nginx-mod-http-xslt-filter \
	nginx-mod-mail \
	nginx-mod-rtmp \
	nginx-mod-stream \
	nginx-mod-stream-geoip2 \
	nginx-vim \
	php8-bcmath \
	php8-bz2 \
	php8-ctype \
	php8-curl \
	php8-dom \
	php8-exif \
	php8-ftp \
	php8-gd \
	php8-iconv \
	php8-imap \
	php8-intl \
	php8-ldap \
	php8-mcrypt \
	php8-pecl-memcached \
	php8-mysqli \
	php8-mysqlnd \
	php8-opcache \
	php8-pdo_mysql \
	php8-pdo_odbc \
	php8-pdo_pgsql \
	php8-pdo_sqlite \
	php8-pear \
	php8-pecl-apcu \
	php8-pecl-redis \
	php8-pgsql \
	php8-phar \
	php8-posix \
	php8-soap \
	php8-sockets \
	php8-sodium \
	php8-sqlite3 \
	php8-tokenizer \
	php8-xml \
	php8-xmlreader \
	php8-xmlrpc \
	php8-xsl \
	php8-zip \
	py3-cryptography \
	py3-future \
	py3-pip \
	whois && \
 echo "**** install certbot plugins ****" && \
 if [ -z ${CERTBOT_VERSION+x} ]; then \
        CERTBOT="certbot"; \
 else \
        CERTBOT="certbot==${CERTBOT_VERSION}"; \
 fi && \
 pip3 install -U \
	pip && \
 pip3 install -U \
	${CERTBOT} \
	certbot-dns-aliyun \
	certbot-dns-cloudflare \
	certbot-dns-cloudxns \
	certbot-dns-cpanel \
	certbot-dns-digitalocean \
	certbot-dns-dnsimple \
	certbot-dns-dnsmadeeasy \
	certbot-dns-domeneshop \
	certbot-dns-google \
	certbot-dns-hetzner \
	certbot-dns-inwx \
	certbot-dns-linode \
	certbot-dns-luadns \
	certbot-dns-netcup \
	certbot-dns-njalla \
	certbot-dns-nsone \
	certbot-dns-ovh \
	certbot-dns-rfc2136 \
	certbot-dns-route53 \
	certbot-dns-transip \
	certbot-plugin-gandi \
	cryptography \
	requests && \
 echo "**** remove unnecessary fail2ban filters ****" && \
 rm \
	/etc/fail2ban/jail.d/alpine-ssh.conf && \
 echo "**** copy fail2ban default action and filter to /default ****" && \
 mkdir -p /defaults/fail2ban && \
 mv /etc/fail2ban/action.d /defaults/fail2ban/ && \
 mv /etc/fail2ban/filter.d /defaults/fail2ban/ && \
 echo "**** copy proxy confs to /default ****" && \
 mkdir -p /defaults/proxy-confs && \
 curl -o \
	/tmp/proxy.tar.gz -L \
	"https://github.com/linuxserver/reverse-proxy-confs/tarball/master" && \
 tar xf \
	/tmp/proxy.tar.gz -C \
	/defaults/proxy-confs --strip-components=1 --exclude=linux*/.gitattributes --exclude=linux*/.github --exclude=linux*/.gitignore --exclude=linux*/LICENSE && \
 echo "**** configure nginx ****" && \
 rm -f /etc/nginx/conf.d/default.conf && \
 curl -o \
	/defaults/dhparams.pem -L \
	"https://lsio.ams3.digitaloceanspaces.com/dhparams.pem" && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 for cleanfiles in *.pyc *.pyo; \
	do \
	find /usr/lib/python3.*  -iname "${cleanfiles}" -exec rm -f '{}' + \
	; done && \
 rm -rf \
	/tmp/* \
	/root/.cache

# add local files
COPY root/ /
