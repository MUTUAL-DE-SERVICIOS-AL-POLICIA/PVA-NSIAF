FROM ruby:2.3.6

LABEL maintainer="uiid-investigacion@agetic.gob.bo" \
      version="1.0.0" \
      description="Backend para el sistema de activos y almacenes NSIAF"

ENV DOMINIO=nsiaf \
    RAILS_SERVE_STATIC_FILES=enabled \
    RAILS_ENV=production

WORKDIR /opt/nsiaf

COPY . .

RUN echo "America/La_Paz" > /etc/timezone && \
    dpkg-reconfigure -f noniteractive tzdata && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs imagemagick libmagickwand-dev cron && \
    wget -O /tmp/wkhtmltopdf.tar.xz -c https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    tar -xf /tmp/wkhtmltopdf.tar.xz -C /opt/ && \
    npm install -g yarn@1.5.1 && \
    bundle install --deployment --without development test && \
    yarn install && \
    mkdir log && \
    mkdir tmp && \
    touch log/production.log && \
    apt-get remove -y --purge curl wget g++ gcc make automake openssh-client mercurial && \
    apt-get autoremove --purge -y && \
    apt-get autoclean --dry-run && \
    rm -rf /tmp/*

COPY docker/almacenes/backend/database.yml docker/almacenes/backend/secrets.yml config/

COPY docker/almacenes/backend/run.sh /opt/run.sh

EXPOSE 3000

ENTRYPOINT ["/opt/run.sh"]
