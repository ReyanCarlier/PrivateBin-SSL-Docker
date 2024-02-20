FROM php:7.4-fpm-alpine

ENV RELEASE 1.0.0

ARG DOMAIN_NAME="domain.com"
ARG USER_EMAIL="john@doe.com"
ENV DOMAIN_NAME=${DOMAIN_NAME}
ENV USER_EMAIL=${USER_EMAIL}

# Install dependencies, including Nginx, Supervisor, Certbot for SSL certificates, and libraries for PHP extensions
RUN apk add --no-cache nginx supervisor curl certbot py3-pip \
    freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev gnupg tzdata \
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# Cleanup unnecessary files and setup logs redirection
RUN rm -rf /var/www/* \
    && mkdir -p /var/www /var/log/supervisor /var/log/nginx /run/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Install PrivateBin
RUN \
    docker-php-ext-install -j$(nproc) opcache \
    && rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
# Install PHP extension: gd
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev \
# Remove (some of the) default nginx config
    && rm -f /etc/nginx.conf \
    && rm -f /etc/nginx/conf.d/default.conf \
    && rm -rf /etc/nginx/sites-* \
    && rm -rf /var/log/nginx \
# Ensure nginx logs, even if the config has errors, are written to stderr
    && rm /var/lib/nginx/logs \
    && mkdir -p /var/lib/nginx/logs \
    && ln -s /dev/stderr /var/lib/nginx/logs/error.log \
# Create folder where the user hook into our default configs
    && mkdir -p /etc/nginx/server.d/ \
    && mkdir -p /etc/nginx/location.d/ \
# Bring php-fpm configs into a more controallable state
    && rm /usr/local/etc/php-fpm.d/www.conf.default \
    && mv /usr/local/etc/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/00-docker.conf \
    && mv /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/10-www.conf \
    && mv /usr/local/etc/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/20-docker.conf \
    export GNUPGHOME="$(mktemp -d)" \
    && gpg2 --list-public-keys || /bin/true \
    && curl -s https://privatebin.info/key/release.asc | gpg2 --import - \
    && rm -rf /var/www/* \
    && cd /tmp \
    && curl -Ls https://github.com/PrivateBin/PrivateBin/releases/download/${RELEASE}/PrivateBin-${RELEASE}.tar.gz.asc > PrivateBin-${RELEASE}.tar.gz.asc \
    && curl -Ls https://github.com/PrivateBin/PrivateBin/archive/${RELEASE}.tar.gz > PrivateBin-${RELEASE}.tar.gz \
    && gpg2 --verify PrivateBin-${RELEASE}.tar.gz.asc \
    && cd /var/www \
    && tar -xzf /tmp/PrivateBin-${RELEASE}.tar.gz --strip 1 \
    && rm *.md cfg/conf.sample.php \
    && mv cfg /srv \
    && mv lib /srv \
    && mv tpl /srv \
    && mv vendor /srv \
    && mkdir -p /srv/data \
    && sed -i "s#define('PATH', '');#define('PATH', '/srv/');#" index.php \
    && chown -R www-data.www-data /var/www /srv/* \
    && rm -rf "${GNUPGHOME}" /tmp/* \
    && apk del --no-cache gnupg

# Copy configuration files
RUN mkdir /etc/nginx/conf.d
COPY /etc/nginx/error.log /var/log/nginx/error.log

# Copy Nginx configuration files
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx.conf.new /etc/nginx/nginx.conf.bak

# Copy Supervisor configuration file
COPY etc/supervisord.conf /etc/supervisord.conf

# Copy scripts
COPY /scripts/entrypoint.sh /entrypoint.sh
COPY /scripts/ssl_keygen.sh /tmp/ssl_keygen.sh

# Copy SSL keys /!\ Make sure you have those fils, it can be an old key or an invalid one, but each time
# you launch the Docker, it'll generate a new SSL Key. Watch out to rate limits.
COPY /etc/ssl/fullchain.pem /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem
COPY /etc/ssl/privkey.pem /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem
RUN chmod +x /entrypoint.sh
RUN chmod +x /tmp/ssl_keygen.sh
RUN chown -R www-data.www-data /var/www /srv/*

# Set work directory
WORKDIR /var/www

# Declare volumes for persistence and log management
VOLUME ["/srv/data", "/tmp", "/var/tmp", "/run", "/var/log"]

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Use the entrypoint script to initialize the container
ENTRYPOINT ["/entrypoint.sh"]
