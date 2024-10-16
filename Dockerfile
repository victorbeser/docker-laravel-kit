# Official image of PHP 8.2
FROM php:8.2-apache

####################################
# ENV Config

# The name of your project: http://localhost/mywebsite-test
ENV PROJECT_NAME mywebsite-test

####################################

# Dependencies of PHP and other
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim unzip git curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    gnupg \
    odbc-postgresql \
    libodbc1 \
    alien \
    dpkg-dev \
    unixodbc \
    unixodbc-dev \
    libgpgme-dev \
    tdsodbc \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql mbstring xml zip pdo_pgsql \
    && pecl install gnupg \
    && docker-php-ext-enable gnupg \
    && a2enmod rewrite

# Installing SOAP
RUN docker-php-ext-install soap && docker-php-ext-enable soap

# Installing the OCI8 (For Oracle Databases)
RUN apt-get update && \
    apt-get install -y libaio1 libaio-dev unzip && \
    apt-get clean

ADD https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip /tmp/
ADD https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip /tmp/
RUN unzip /tmp/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip -d /usr/local/ && \
    unzip /tmp/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip -d /usr/local/ && \
    ln -s /usr/local/instantclient_19_8 /usr/local/instantclient && \
    ln -s /usr/local/instantclient/lib* /usr/lib && \
    ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
    rm -rf /tmp/*.zip

ENV LD_LIBRARY_PATH="/usr/local/instantclient"
ENV ORACLE_HOME="/usr/local/instantclient"

RUN docker-php-source extract && \
    cd /usr/src/php/ext/oci8 && \
    phpize && \
    ./configure --with-oci8=instantclient,/usr/local/instantclient && \
    make && \
    make install && \
    docker-php-ext-enable oci8 && \
    docker-php-source delete

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ODBC Teradata Config
COPY .docker/tdodbc1720__linux_x8664.17.20.00.36-1.tar.gz /tmp/
RUN tar -xzf /tmp/tdodbc1720__linux_x8664.17.20.00.36-1.tar.gz -C /tmp/
RUN alien -k /tmp/tdodbc1720/tdodbc1720-17.20.00.36-1.x86_64.rpm
RUN dpkg -i /var/www/html/tdodbc1720_17.20.00.36-1_amd64.deb
RUN rm -rf /tmp/tdodbc1720__linux_x8664.17.20.00.36-1.tar.gz

# ODBC Config
COPY .docker/odbc.ini /etc/odbc.ini
COPY .docker/odbcinst.ini /etc/odbcinst.ini
ENV LD_LIBRARY_PATH=/opt/teradata/client/17.20/lib64:$LD_LIBRARY_PATH
RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc

COPY .docker/php.ini-development /usr/local/etc/php/php.ini

# Installing Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Workspace 
WORKDIR /var/www/html/${PROJECT_NAME}
COPY . /var/www/html/${PROJECT_NAME}

# All the necessary permissions
RUN chown -R www-data:www-data /var/www/html/${PROJECT_NAME}/storage /var/www/html/${PROJECT_NAME}/bootstrap/cache
RUN chmod -R 775 /var/www/html/${PROJECT_NAME}/storage /var/www/html/${PROJECT_NAME}/bootstrap/cache

# Remove the vendor's dir to get a clean and fast upload on your container
RUN rm -rf /var/www/html/${PROJECT_NAME}/vendor

# Composer dependencies
RUN composer check-platform-reqs

# Laravel dependencies
RUN composer install --no-cache --optimize-autoloader --no-dev --verbose

# Apache configuration
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80
