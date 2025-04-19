FROM php:8.3-alpine AS build

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /app
COPY . .

RUN apk add --no-cache jq curl && \
    composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --prefer-dist

FROM php:8.3-alpine AS production

RUN addgroup -g 10000 appuser && \
    adduser -u 10000 -G appuser -s /bin/sh -D appuser

COPY --from=build /app /var/www

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions bcmath gd intl memcached pdo_pgsql pgsql zip pcntl

ARG FRANKENPHP_VERSION=1.5.0
RUN apk add --no-cache curl && \
    curl -sSL https://github.com/dunglas/frankenphp/releases/download/v${FRANKENPHP_VERSION}/frankenphp-linux-x86_64 -o /usr/local/bin/frankenphp && \
    chmod +x /usr/local/bin/frankenphp && \
    apk del curl

RUN cat <<EOF > /usr/local/etc/php/conf.d/opcache-recommended.ini
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=0
opcache.fast_shutdown=1
opcache.enable_cli=1
opcache.jit=1255
opcache.jit_buffer_size=100M
EOF

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www

RUN mkdir -p storage/app \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    && chown -R appuser:appuser storage bootstrap/cache public \
    && chmod -R 775 storage bootstrap/cache public

USER appuser

EXPOSE 9804

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:9804/up || exit 1

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
