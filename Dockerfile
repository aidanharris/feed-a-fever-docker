# USAGE:
#   sudo docker build --build-arg FEVER_SHA256SUM=6a2ed36cf1566ab42d837d0d34fec1c724015450b986e889f5474984f38912b1 -t aidanharris-feed-a-fever .
FROM php:5-fpm
ARG FEVER_SHA256SUM

RUN cd /tmp \
    && curl -s -O -L http://www.feedafever.com/gateway/public/fever.zip \
    && FEVER_SHA256SUM=$FEVER_SHA256SUM bash -c 'if [[ "$(echo $FEVER_SHA256SUM\ \ /tmp/fever.zip | sha256sum --quiet -c -)" != "" ]];  then printf "\033[0;31mSHA256SUM Does Not Match!\033[0m\n"; exit 1; fi' \
    && apt-get update && apt-get install -y unzip \
    && unzip fever.zip \
    && mv fever html \
    && mv html /var/www \
    && apt-get remove -y --purge unzip \
    && apt-get install -y \
       lighttpd \
    && systemctl enable lighttpd \
    && lighty-enable-mod fastcgi \
    && php -r 'file_put_contents("/etc/lighttpd/conf-enabled/10-fastcgi.conf", base64_decode("IyAvdXNyL3NoYXJlL2RvYy9saWdodHRwZC9mYXN0Y2dpLnR4dC5negojIGh0dHA6Ly9yZWRtaW5lLmxpZ2h0dHBkLm5ldC9wcm9qZWN0cy9saWdodHRwZC93aWtpL0RvY3M6Q29uZmlndXJhdGlvbk9wdGlvbnMjbW9kX2Zhc3RjZ2ktZmFzdGNnaQoKZmFzdGNnaS5zZXJ2ZXIgKz0gKCAiLnBocCIgPT4KICAgICAgICAoKAogICAgICAgICAgICAgICAgImhvc3QiID0+ICIxMjcuMC4wLjEiLAogICAgICAgICAgICAgICAgInBvcnQiID0+ICI5MDAwIiwKICAgICAgICAgICAgICAgICJicm9rZW4tc2NyaXB0ZmlsZW5hbWUiID0+ICJlbmFibGUiCiAgICAgICAgKSkKKQoKc2VydmVyLm1vZHVsZXMgKz0gKCAibW9kX2Zhc3RjZ2kiICkK"));' \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring mysql mysqli pdo pdo_mysql \
    && cd /var/www/html \
    && php boot.php \
    && chmod 755 -R /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && php -r 'file_put_contents("/usr/bin/bootstrap-fever", base64_decode("IyEvYmluL2Jhc2gKCk5PVF9TVE9QUElORz0xCgpwaHAtZnBtICYKL2V0Yy9pbml0LmQvbGlnaHR0cGQgc3RhcnQKCmNvbnRyb2xfYygpCiMgcnVuIGlmIHVzZXIgaGl0cyBjb250cm9sLWMKewogIE5PVF9TVE9QUElORz0wCiAgcGtpbGwgcGhwLWZwbQogIC9ldGMvaW5pdC5kL2xpZ2h0dHBkIHN0b3AKICBwa2lsbCBsaWdodHRwZAogIGV4aXQgMAp9CgojIHRyYXAga2V5Ym9hcmQgaW50ZXJydXB0IChjb250cm9sLWMpCnRyYXAgY29udHJvbF9jIFNJR0lOVAoKd2hpbGUgWyAkTk9UX1NUT1BQSU5HIF0KZG8KICBwZ3JlcCBwaHAtZnBtID4gL2Rldi9udWxsIHx8IHBocC1mcG0KICBwZ3JlcCBsaWdodHRwZCA+IC9kZXYvbnVsbCB8fCAvZXRjL2luaXQuZC9saWdodHRwZCBzdGFydAogIHNsZWVwIDEwCmRvbmUK"));' \
    && chmod +x /usr/bin/bootstrap-fever \
    && apt-get autoremove -y --purge \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

ENTRYPOINT ["bootstrap-fever"]
