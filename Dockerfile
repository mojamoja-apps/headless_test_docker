FROM php:8.1-apache
RUN apt-get update \
    && apt-get install -y \
    chromium \
    vim \
    zip \
    unzip \
    iputils-ping \
    git \
    gnupg \
    curl \
    nodejs \
    wget \
    npm \
    libonig-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    zlib1g-dev \
    && docker-php-ext-install \
                pdo_mysql \
                zip \
                bcmath \
                gd \
                sockets \
    && docker-php-ext-configure gd \
                --with-freetype=/usr/include/ \
                --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ドキュメントルートを変更する
ENV APACHE_DOCUMENT_ROOT='/home/develop/public/'
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# mod_rewriteを 有効に
RUN cd /etc/apache2/mods-enabled \
    && ln -s ../mods-available/rewrite.load

# コンテナログイン時のパスを最後に指定
WORKDIR  /home/develop

# php.iniをコピー
COPY php.ini /usr/local/etc/php/
