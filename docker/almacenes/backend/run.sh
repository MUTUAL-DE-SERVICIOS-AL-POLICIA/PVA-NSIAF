#!/bin/bash

ARCHIVO=config/secrets.yml
VARIABLE=secret_key_base

if [ ! -f /opt/install.lock ]
then
  echo "Generando archivo de configuracion ..."
  echo -e "export MYSQL_DATABASE=$MYSQL_DATABASE\nexport MYSQL_HOST=$MYSQL_HOST\nexport MYSQL_USER=$MYSQL_USER\nexport MYSQL_PASSWORD=$MYSQL_PASSWORD\nexport MYSQL_PORT=$MYSQL_PORT" | tee /usr/local/etc/env
  A=$(sed -ne "s/$VARIABLE://p" $ARCHIVO | sed -e "s/ //g")
  if [[ "$A" == "" ]]
  then
    sed -i 's@secret_key_base:.*@'"secret_key_base: $(bundle exec rake secret)"'@' $ARCHIVO
  fi
  if [ ! -z "$CONVERT_API_URL" ]
  then
    export CONVERT_API_URL=https://intranet.adsib.gob.bo/conversion-formatos
  fi
  chmod -R 777 ./config ./log ./tmp
  bundle exec rake assets:clobber RAILS_ENV=production
  bundle exec rake assets:precompile RAILS_ENV=production
  bundle exec rake db:migrate RAILS_ENV=production
  bundle exec rake db:seed RAILS_ENV=production
  bundle exec whenever -s 'environment=production' --update-crontab
  touch /opt/install.lock
fi
service apache2 start
echo "Servidor iniciado"
tail -f log/production.log /var/log/apache2/error.log /var/log/apache2/access.log
