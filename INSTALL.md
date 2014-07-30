# Instalación

## Notas importantes

Para el deploy del sistema se está utilizando la gema `capistrano` que es una herramienta de automatización de servidores remotos.

`capistrano` permite realizar deploy directamente desde la máquina local sin necesidad de ingresar al servidor remoto (excepto en la configuración inicial), solamente necesita un repositorio `git` y un usuario del servidor remoto con acceso `SSH`.

Para el uso de `capistrano` es necesario que la aplicación esté instalado en la máquina local en modo `development`, lo que significa que solamente desde la carpeta de la aplicación se puede ejecutar los comandos de deploy.

También se utiliza la gema `passenger` (Phusion Passenger) que es un servidor web y servidor de aplicación libre con soporte para Ruby, Python y Node.js. Está diseñado para integrarse con el Servidor Apache HTTP o el servidor web nginx, pero también tiene un modo de funcionamiento independiente sin un servidor web externo.

Para el ejemplo de ésta instalación se cuenta con los siguientes datos:

* Sistema Operativo: Debian Wheezy
* Usuario: usuario1
* Servidor: 166.114.1.10
* Puerto SSH: 232
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

## Ruby

Instalando [Ruby Version Manager - RVM](https://rvm.io/)

```console
curl -L get.rvm.io | bash -s stable
```

Recargar el comando `rvm`

```console
source /home/usuario1/.rvm/scripts/rvm
```

Instalando [Ruby](https://www.ruby-lang.org/)

```console
rvm install 2.0.0
```

Estableciendo la versión de `Ruby` por defecto

```console
rvm use 2.0.0 --default
```

Evitar que se instale `ri` y `rdoc`

```console
echo "gem: --no-document" > ~/.gemrc
```

Instalar `RubyGems`

```console
rvm rubygems current
```

Instalar `Rails`

```console
gem install rails
```

## Node.js

Instalando [Node Version Manager - NVM](https://github.com/creationix/nvm)

```console
curl https://raw.github.com/creationix/nvm/master/install.sh | sh
```

Reabrir la terminal y escribir

```console
nvm install 0.10
nvm alias default 0.10
```

Para el entorno `production` se está utilizando la gema `capistrano`, el cual requiere que el comando `nvm` sea accesible por cualquier usuario. En entorno `development` no es necesario ejecutar el comando siguiente.

Configuramos `nvm` para que sea accesible por todos los usuarios del Sistema

```console
cd ~
n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; sudo cp -r $n/{bin,lib,share} /usr/local
```

Verificamos la configuración

```console
sudo su
which node
```

Se debe poder ver

```console
/usr/local/bin/node
```

## Base de Datos

Instalación de `MySQL`

```console
sudo apt-get install mysql-server
```

Creación de la base de datos

```console
mysql -u root -p

mysql> CREATE DATABASE IF NOT EXISTS `nsiaf_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
```

## Desarrollo

En la máquina local clonamos el repositorio del Sistema de Activos Fijos y Almacenes

```console
git clone git@gitlab.geo.gob.bo:adsib/nsiaf.git
```

Cambiar al branch `develop` que es el de desarrollo

```console
cd nsiaf
git checkout develop
```

Renombramos los archivos de ejemplo

```console
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml
```

Editar `database.yml` con el siguiente contenido

```yaml
development:
  adapter: mysql2
  encoding: utf8
  database: nsiaf_development
  pool: 5
  username: root
  password: root
  socket: /var/run/mysqld/mysqld.sock
```

Editar `secrets.yml` con el siguiente contenido

```yaml
development:
  secret_key_base: d7c345615c14afe85dd35d9169e9743c4f24de413990b3133b93865f1f5f490db6a3c1327e9a5af3fc845937a7f489bbda865a25caa424144580d2d106cb121c
```

Instalar las gemas

```console
bundle install
```

Crear la base de datos e inicializar con la configuración por defecto

```console
bundle exec rake db:create
bundle exec rake db:seed
```

Iniciar el servidor en modo desarrollo

```console
rails server
```

y visitar en el navegador el link `http://localhost:3000`

## Sistema de Activos Fijos y Almacenes

Iniciamos sesión en el servidor remoto

```console
ssh usuario1@166.114.1.10 -p 232
```

Creación de la carpeta donde se hará el deploy (`/var/www/nsiaf`)

```console
sudo mkdir -p /var/www/nsiaf/shared/config
sudo chown -R usuario1:usuario1 /var/www/nsiaf
```

Creamos el archivo `database.yml` con la configuración de la Base de Datos

```console
nano /var/www/nsiaf/shared/config/database.yml
```

Agregar el siguiente contenido

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

Generamos la llave secreta para las sesiones en la máquina local el cual lo pegamos dentro del archivo `secrets.yml` en el servidor

```console
bundle exec rake secret
```

Creamos el archivo `secrets.yml` con la llave secreta para las sesiones

```console
nano /var/www/nsiaf/shared/config/secrets.yml
```

Agregar al contenido generado con el comando `bundle exec rake secret`

```yaml
production:
  secret_key_base: 4a15a7504234fac45f1e921201fac377954cae6f2a19db0090429be9354447f36beb88aed403c83576e49a8e76671d7f0e9084b406945023921de2526d1aecd8
```

## Deploy

Desde la máquina local verificamos la configuración del deploy para el entorno `production`

```console
bundle exec cap production deploy:check
```

Realizamos el deploy

```console
bundle exec cap production deploy
```

Este comando demora de acuerdo a la velocidad de internet, porque descarga la aplicación del repositorio,  las gemas que necesita la aplicación, compila y comprime CSS y Javascript, y ejecuta las migraciones de base de datos.

Inicializar la aplicación con las configuraciones por defecto

```console
bundle exec cap production deploy:seed
```

Éste comando establece los datos del usuario `super administrador`

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
LoadModule passenger_module /home/usuario1/.rvm/gems/ruby-2.0.0-p353/gems/passenger-4.0.37/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /home/usuario1/.rvm/gems/ruby-2.0.0-p353/gems/passenger-4.0.37
  PassengerDefaultRuby /home/usuario1/.rvm/gems/ruby-2.0.0-p353/wrappers/ruby
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

Configuración de Apache para el sistema de activos

```console
sudo nano /etc/apache2/sites-available/activos.adsib.gob.bo
```

Adicionar el siguiente contenido

```apache
<VirtualHost *:80>
  ServerName 166.114.1.10
  DocumentRoot /var/www/nsiaf/current/public
  RailsEnv production
  <Directory /var/www/nsiaf/current/public>
    Allow from all
    Options -MultiViews
  </Directory>
</VirtualHost>
```

Habilitar el nuevo sitio y reiniciar Apache

```console
sudo a2dissite default
sudo a2ensite activos.adsib.gob.bo
sudo /etc/init.d/apache2 restart
```
