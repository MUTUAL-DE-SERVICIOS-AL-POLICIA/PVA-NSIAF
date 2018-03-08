FROM ruby:2.3.6
MAINTAINER Daniel Jimenez Jerez <djimenez@agetic.gob.bo>

ENV DOMINIO=nsiaf
ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_SERVE_STATIC_FILES enabled
RUN echo "America/La_Paz" | tee /etc/timezone; dpkg-reconfigure -f noniteractive tzdata; apt-get update; apt-get install -y nodejs npm imagemagick libmagickwand-dev cron; wget -O /tmp/wkhtmltopdf.tar.xz -c https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz; tar -xf /tmp/wkhtmltopdf.tar.xz -C /opt/; ln -s /usr/bin/nodejs /usr/bin/node; npm install -g bower@1.8.2; wget --no-check-certificate -O /tmp/nsiaf.tar.gz -c https://gitlab.geo.gob.bo/adsib/nsiaf/repository/archive.tar.gz?ref=agetic-mysql; mkdir -p /opt/nsiaf; tar -xf /tmp/nsiaf.tar.gz -C /opt/nsiaf --strip-components 1; rm -rf /tmp/*
WORKDIR /opt/nsiaf
RUN bundle install --deployment --without development test; bundle exec bower install --allow-root; mkdir log; mkdir tmp; touch log/production.log; apt-get remove -y --purge nodejs npm curl wget g++ gcc make automake git openssh-client mercurial; apt-get autoremove --purge -y; apt-get autoclean
COPY database.yml config/database.yml
COPY secrets.yml config/secrets.yml
COPY run.sh /opt/run.sh

VOLUME ["/var/www/html/nsiaf", "/var/log/apache2"]
EXPOSE 3000
ENTRYPOINT /opt/run.sh
