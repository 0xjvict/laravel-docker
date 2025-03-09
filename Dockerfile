############################################
# Base Image
############################################
FROM serversideup/php:8.4-fpm-nginx AS base

############################################
# Development Image
############################################
FROM base AS development

# Switch to root so we can do root things
USER root

# Install the necessary packages for our development environment
RUN apt-get update \
    && apt-get install nano -y \
    && apt-get install vim -y \
    && apt-get install zip -y \
    && apt-get install unzip -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Save the build arguments as a variable
ARG USER_ID
ARG GROUP_ID

# Use the build arguments to change the UID
# and GID of www-data while also changing
# the file permissions for NGINX
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Drop back to our unprivileged user
USER www-data

############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production

# Copy our app files as www-data (33:33)
COPY --chown=www-data:www-data . /var/www/html
