# Use a imagem oficial do PHP 8.2 com Apache
FROM php:8.2-apache

####################################
# ENV Config

# Configure o nome do seu projeto para acessá-lo. Por exemplo: http://localhost/meusite-teste
ENV PROJECT_NAME meusite-teste

####################################

# Instale as extensões PHP necessárias e outras dependências
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
    libgpgme-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql mbstring xml zip pdo_pgsql \
    && pecl install gnupg \
    && docker-php-ext-enable gnupg \
    && a2enmod rewrite

# Instale o SOAP
RUN docker-php-ext-install soap && docker-php-ext-enable soap

# Instale o OCI8 (Oracle)
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

# Instalar o Teradata ODBC Driver
COPY .docker/tdodbc2000__linux_x8664.20.00.00.10-1.tar.gz /tmp/
RUN cd /tmp && \
    tar -xvzf tdodbc2000__linux_x8664.20.00.00.10-1.tar.gz && \
    alien -i tdodbc2000/tdodbc2000-20.00.00.10-1.x86_64.rpm

# Configurar o ODBC
COPY .docker/odbc.ini /etc/odbc.ini
COPY .docker/odbcinst.ini /etc/odbcinst.ini

# Instale o Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Defina o diretório de trabalho
WORKDIR /var/www/html/${PROJECT_NAME}

# Copie os arquivos do Laravel para o container
COPY . /var/www/html/${PROJECT_NAME}

# Dê permissões apropriadas às pastas de armazenamento e cache do Laravel
RUN chown -R www-data:www-data /var/www/html/${PROJECT_NAME}/storage /var/www/html/${PROJECT_NAME}/bootstrap/cache
RUN chmod -R 775 /var/www/html/${PROJECT_NAME}/storage /var/www/html/${PROJECT_NAME}/bootstrap/cache

# Remova o diretório vendor para garantir um ambiente limpo
RUN rm -rf /var/www/html/${PROJECT_NAME}/vendor

# Verifique as dependências de plataforma do Composer
RUN composer check-platform-reqs

# Instale as dependências do Laravel
RUN composer install --no-cache --optimize-autoloader --no-dev --verbose

# Copie o arquivo de configuração do Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Exponha a porta 80 para o Apache
EXPOSE 80
