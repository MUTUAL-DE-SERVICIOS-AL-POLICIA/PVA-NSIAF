FROM scardon/ruby-node-alpine:2.3.6
LABEL maintainer="djimenez@agetic.gob.bo"
LABEL Description="Backend para el sistema NSIAF"

ENV DOMINIO nsiaf
ENV RAILS_SERVE_STATIC_FILES enabled
ENV RAILS_ENV production

RUN mkdir -p /opt/nsiaf
WORKDIR /opt/nsiaf
RUN apk add --no-cache --update --allow-untrusted --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ xvfb ttf-freefont fontconfig dbus qt5-qtbase-dev wkhtmltopdf tzdata dcron wget build-base libxml2-dev libxslt-dev postgresql-dev build-base mariadb-dev; rm /etc/localtime; ln -s /usr/share/zoneinfo/America/La_Paz /etc/localtime; npm install -g yarn@1.5.1; wget --no-check-certificate -O /tmp/nsiaf.tar.gz -c https://gitlab.geo.gob.bo/adsib/nsiaf/repository/archive.tar.gz?ref=agetic-mysql; tar -xf /tmp/nsiaf.tar.gz -C /opt/nsiaf --strip-components 1; bundle install --deployment --without development test; yarn install --allow-root; mkdir log; mkdir tmp; touch log/production.log; mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin; echo $'#!/usr/bin/env sh\nXvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \nDISPLAY=:0.0 wkhtmltopdf-origin $@ \nkillall Xvfb' | tee /usr/bin/wkhtmltopdf; chmod +x /usr/bin/wkhtmltopdf; mkdir -p /opt/wkhtmltox/bin; ln -s /usr/bin/wkhtmltopdf /opt/wkhtmltox/bin/wkhtmltopdf; rm -rf /var/cache/apk/*; rm -rf /tmp/*;

COPY database.yml config/database.yml
COPY secrets.yml config/secrets.yml
COPY run.sh /opt/run.sh

VOLUME ["/opt/nsiaf"]
EXPOSE 3000
ENTRYPOINT /opt/run.sh