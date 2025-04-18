FROM php:8.3-alpine AS build

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN apk add --no-cache jq curl

RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --prefer-dist

FROM php:8.3-alpine AS production

RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser

COPY --from=build /app /var/www

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions bcmath gd intl memcached pdo_pgsql pgsql zip pcntl

ARG FRANKENPHP_VERSION=1.5.0
RUN curl -sSL https://github.com/dunglas/frankenphp/releases/download/v${FRANKENPHP_VERSION}/frankenphp-linux-x86_64 -o /usr/local/bin/frankenphp \
    && chmod +x /usr/local/bin/frankenphp

RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=0'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.jit=1255'; \
    echo 'opcache.jit_buffer_size=100M'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www

COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /var/www/storage/app \
    /var/www/storage/framework/cache \
    /var/www/storage/framework/sessions \
    /var/www/storage/framework/views \
    /var/www/storage/logs \
    && chown -R appuser:appuser /var/www/storage /var/www/bootstrap/cache /var/www/public \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache /var/www/public

USER appuser

EXPOSE 9804

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:9804/health || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]
