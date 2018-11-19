FROM node:10.13.0-alpine

LABEL maintainer="djimenez@muserpol.gob.bo" \
      version="1.0.0" \
      description="Sincronizador de UFV para el sistema de activos y almacenes NSIAF"

ENV TZ=America/La_Paz

WORKDIR /opt/nsiaf-ufv

COPY docker/almacenes/ufv/* ./

RUN apk update && \
    apk add --update --no-cache tzdata && \
    rm -rf /var/cache/apk/* && \
    npm install && \
    rm -rf /tmp/*

CMD ["npm", "start"]