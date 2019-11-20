ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-alpine

ARG TZ
ARG PHP_EXTENSIONS
ARG MORE_EXTENSION_INSTALLER
ARG ALPINE_REPOSITORIES

# 修改镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN docker-php-ext-install -j$(nproc) bcmath sockets pcntl
RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

COPY ./extensions /tmp/extensions

WORKDIR /tmp/extensions

ENV EXTENSIONS=",${PHP_EXTENSIONS},"
ENV MC="-j$(nproc)"
ADD ./composer.phar /usr/local/bin/composer
RUN export MC="-j$(nproc)" \
    && chmod +x install.sh \
    && chmod +x /usr/local/bin/composer \
    && chmod +x "${MORE_EXTENSION_INSTALLER}" \
    && sh install.sh \
    && sh "${MORE_EXTENSION_INSTALLER}" \
    && rm -rf /tmp/extensions \
    && composer config -g repos.packagist composer https://php.cnpkg.org

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

WORKDIR /var/www/html
