# Instalación

## Requisitos

Esta instalación se la realizó sobre lo siguiente:

* Sistema Operativo: Debian Wheezy
* Usuario: uactivos
* Servidor: www.dominio.com
* Usuario base de datos: root
* Contraseña base de datos: root

## Paquetes y dependencias

La instalación de paquetes en el servidor remoto

```console
sudo apt-get install apache2 curl git build-essential zlibc zlib1g-dev zlib1g libcurl4-openssl-dev apache2-threaded-dev libssl-dev libopenssl-ruby apache2-prefork-dev libapr1-dev libaprutil1-dev libreadline6 libreadline6-dev
```

Instalar [Redis](http://redis.io/)

```console
sudo apt-get install redis-server
```

Instalar [Git](http://git-scm.com/)

```console
sudo apt-get install git git-core
```

Instalar [ImageMagick](http://www.imagemagick.org/)

```console
sudo apt-get install imagemagick
```

### wkhtmltopdf

[wkhtmltopdf](http://wkhtmltopdf.org/) permite la conversión de HTML a PDF. En los respositorios oficiales de Debian está la versión `0.9.9` el cual no cumple correctamente con su función, debido a que estamos utilizando funciones nuevas. Se recomienda la versión `0.12.0` o superiores, el cual se puede descargar manualmente desde http://wkhtmltopdf.org/downloads.html

Para el caso de Debian Wheezy descargué la versión de 64-bit:

```
wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1_linux-wheezy-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-wheezy-amd64.deb
```

La instalación se hará en `/usr/local/bin/wkhtmltopdf`

### Conversión de formatos

Éste sistema depende del API de Conversión de Formatos para la importación de archivos `DBF`, cuyo repositorio es https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos

La instalación del API de Conversión de Formatos está descrita en el archivo [INSTALL.md](https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos/blob/master/INSTALL.md)

## Ruby

Instalando [Ruby Version Manager - RVM](https://rvm.io/)

```console
curl -L get.rvm.io | bash -s stable
```

Recargar el comando `rvm`

```console
source ~/.rvm/scripts/rvm
```

Instalando [Ruby](https://www.ruby-lang.org/)

```console
rvm install 2.1
```

Estableciendo la versión de `Ruby` por defecto

```console
rvm use 2.1 --default
```

Evitar que se instale `ri` y `rdoc`

```console
echo "gem: --no-document" > ~/.gemrc
```

Instalar `RubyGems`

```console
rvm rubygems current
```

## Base de Datos

Instalación de `MySQL`

```console
sudo apt-get install mysql-server libmysqlclient-dev
```

Creación de la base de datos

```console
mysql -u root -p

mysql> CREATE DATABASE IF NOT EXISTS `nsiaf_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
```

## Deploy

Clonamos el repositorio del Sistema de Activos Fijos y Almacenes

```console
cd ~
git clone git@gitlab.geo.gob.bo:adsib/nsiaf.git
cd nsiaf
```

Instalar las gemas

```console
bundle install --without development test
```

Renombramos los archivos de ejemplo

```console
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml
```

Editar `database.yml` con el siguiente contenido

```yaml
production:
  adapter: mysql2
  encoding: utf8
  database: nsiaf_production
  pool: 5
  username: root
  password: root
  socket: /var/run/mysqld/mysqld.sock
```

Editar `secrets.yml` con el siguiente contenido

```yml
production:
  convert_api_url: 'http://localhost/conversion-formatos'
  rails_relative_url_root: ''           # Deploy en la raíz del dominio (/)
  # rails_relative_url_root: '/activos' # Deploy en subdirectorio activos (/activos)
  secret_key_base: d7c345615c14afe85dd35d9169e9743c4f24de413990b3133b93865f1f5f490db6a3c1327e9a5af3fc845937a7f489bbda865a25caa424144580d2d106cb121c
```

donde:

* `convert_api_url` es la URL donde se encuentra instalado el API de [Conversión de Formatos](https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos)
* `rails_relative_url_root` es la ubicación del subdirectorio de deploy tal como: `www.dominio.com/nsiaf`
* `secret_key_base` se **DEBE** volver a generar desde la línea de comandos con `rake secret`

Compilamos los archivos CSS y JS

```console
RAILS_ENV=production bundle exec rake assets:clobber
RAILS_ENV=production bundle exec rake assets:precompile
```

Crear la base de datos e inicializar con la configuración por defecto

```console
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:seed
```

El último comando establece los datos del usuario `super administrador`

* Usuario: `admin`
* Contraseña: `demo123`

## Apache

Instalar `passenger` en el servidor remoto

```console
gem install passenger
```

Instalar el módulo de `passenger` para `apache2`

```console
rvmsudo passenger-install-apache2-module
```

Después de instalar el módulo de `passenger`, es necesario adicionar a la configuración de Apache las líneas que indica al final de la instalación del módulo. Esto depende de la versión de `Ruby` instalado con `rvm` y la versión de la gema `passenger`.

```console
sudo nano /etc/apache2/apache2.conf
```

Agregamos al final las siguientes líneas:

```apache
LoadModule passenger_module /home/uactivos/.rvm/gems/ruby-2.1.2/gems/passenger-4.0.50/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /home/uactivos/.rvm/gems/ruby-2.1.2/gems/passenger-4.0.50
  PassengerDefaultRuby /home/uactivos/.rvm/gems/ruby-2.1.2/wrappers/ruby
</IfModule>
```

Reiniciamos el servidor Apache

```console
sudo /etc/init.d/apache2 restart
```

Habilitamos el módulo `mod_rewrite` para Apache

```console
sudo a2enmod rewrite
```

Movemos el sistema al directorio `/var/www`

```
cd ~
sudo mv nsiaf /var/www
```

Configuración de Apache para el sistema de activos

```console
sudo nano /etc/apache2/sites-available/activos.dominio.com
```

Adicionar el siguiente contenido si se va instalar la aplicación en la raiz del dominio

```apache
<VirtualHost *:80>
  ServerName www.dominio.com
  DocumentRoot /var/www/nsiaf/public
  RailsEnv production
  <Directory /var/www/nsiaf/public>
    Allow from all
    Options -MultiViews
  </Directory>
</VirtualHost>
```

Contenido para deploy de la aplicación en un subdirectorio llamado `/activos`

```apache
<IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteRule ^/activos$ /activos/ [R]
</IfModule>

Alias /activos /var/www/nsiaf/public
RailsBaseURI /activos
<Directory /var/www/nsiaf/public>
    RailsEnv production
    PassengerAppRoot /var/www/nsiaf/
    PassengerUser uactivos

    Options FollowSymLinks -MultiViews
    AllowOverride All
    Order deny,allow
    allow from all
</Directory>
```

Habilitar el nuevo sitio y reiniciar Apache

```console
sudo a2ensite activos.dominio.com
sudo /etc/init.d/apache2 restart
```

Visitamos el sitio http://activos.dominio.com o http://dominio.com/activos depende de la configuración que se haya elegido para el deploy.

## Actualización

Para actualizar a una versión reciente del sistema realizar los siguientes pasos:

Actualización del repositorio:

```console
cd /var/www/nsiaf
git pull origin master
```
Actualización de gemas:

```console
bundle install --without development test
```

Ejecución de migraciones:

```console
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:seed
```

Compilación de archivos CSS y JS:

```console
RAILS_ENV=production bundle exec rake assets:clobber
RAILS_ENV=production bundle exec rake assets:precompile
```

Reinicio del servidor mediante `passenger`:

```console
touch tmp/restart.txt
```
