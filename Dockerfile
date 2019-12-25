FROM php:7.1-fpm

# install libraries required by the extensions
RUN apt-get update \
  && apt-get install -y \
    cron \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt1-dev \
    libfreetype6-dev

# install extensions
RUN docker-php-ext-configure gd --with-jpeg-dir --with-freetype-dir && \
    docker-php-ext-install \
      bcmath \
      gd \
      intl \
      mbstring \
      mcrypt \
      pdo_mysql \
      soap \
      xsl \
      zip

# creating php.ini file
RUN echo 'memory_limit = 4G\n\
max_execution_time = 1800\n\
zlib.output_compression = On\n\
pm.max_children = 20\n\
max_input_vars = 75000' >> /usr/local/etc/php/php.ini

COPY startup.sh /bin/startup.sh
RUN chmod 777 /bin/startup.sh

WORKDIR /var/www/html

# COMPOSER INSTALL AND BUILD
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer

COPY auth.json /root/.composer/auth.json

RUN composer create-project --repository=https://repo.magento.com/ magento/project-community-edition ./

ENTRYPOINT "/bin/startup.sh"

