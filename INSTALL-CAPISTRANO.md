# Instalación

## Notas importantes

Para el deploy del sistema se está utilizando la gema `capistrano` que es una herramienta de automatización de servidores remotos.

`capistrano` permite realizar deploy directamente desde la máquina local sin necesidad de ingresar al servidor remoto (excepto en la configuración inicial), solamente necesita un repositorio `git` y un usuario del servidor remoto con acceso `SSH`.

Para el uso de `capistrano` es necesario que la aplicación esté instalado en la máquina local en modo `development`, lo que significa que solamente desde la carpeta de la aplicación se puede ejecutar los comandos de deploy.

También se utiliza la gema `passenger` (Phusion Passenger) que es un servidor web y servidor de aplicación libre con soporte para Ruby, Python y Node.js. Está diseñado para integrarse con el Servidor Apache HTTP o el servidor web nginx, pero también tiene un modo de funcionamiento independiente sin un servidor web externo.

Para el ejemplo de ésta instalación se cuenta con los siguientes datos:

* Sistema Operativo: Debian Wheezy
* Usuario: uactivos
* Servidor: www.dominio.com
* Puerto SSH: 23
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
source /home/uactivos/.rvm/scripts/rvm
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

## Sistema de Activos Fijos y Almacenes

Iniciamos sesión en el servidor remoto

```console
ssh uactivos@dominio.com -p 23
```

Creación de la carpeta donde se hará el deploy (`/var/www/nsiaf`)

```console
sudo mkdir -p /var/www/nsiaf/shared/config
sudo chown -R uactivos:uactivos /var/www/nsiaf
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
  convert_api_url: 'http://localhost/conversion-formatos'
  rails_relative_url_root: ''           # Deploy en la raíz del dominio (/)
  # rails_relative_url_root: '/activos' # Deploy en subdirectorio activos (/activos)
  secret_key_base: 4a15a7504234fac45f1e921201fac377954cae6f2a19db0090429be9354447f36beb88aed403c83576e49a8e76671d7f0e9084b406945023921de2526d1aecd8
```

donde:

* `convert_api_url` es la URL donde se encuentra instalado el API de [Conversión de Formatos](https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos)
* `rails_relative_url_root` es la ubicación del subdirectorio de deploy tal como: `www.dominio.com/nsiaf`
* `secret_key_base` se genera desde la línea de comandos con `rake secret`

Para configurar el servidor remoto, el repositorio, el entorno de despliegue se debe modificar los siguientes archivos:

```
config/deploy.rb
config/deploy/production.rb
config/deploy/staging.rb
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
LoadModule passenger_module /home/uactivos/.rvm/gems/ruby-2.0.0-p353/gems/passenger-4.0.37/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /home/uactivos/.rvm/gems/ruby-2.0.0-p353/gems/passenger-4.0.37
  PassengerDefaultRuby /home/uactivos/.rvm/gems/ruby-2.0.0-p353/wrappers/ruby
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
sudo nano /etc/apache2/sites-available/activos.dominio.com
```

Adicionar el siguiente contenido si se va instalar la aplicación en la raiz del dominio

```apache
<VirtualHost *:80>
  ServerName www.dominio.com
  DocumentRoot /var/www/nsiaf/current/public
  RailsEnv production
  <Directory /var/www/nsiaf/current/public>
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

Alias /activos /var/www/nsiaf/current/public
RailsBaseURI /activos
<Directory /var/www/nsiaf/current/public>
    RailsEnv production
    PassengerAppRoot /var/www/nsiaf/current
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

Para actualizar a una versión reciente del sistema realizar los siguientes pasos desde la máquina local:

```console
bundle exec cap production deploy
```

Éste comando descargará el código fuente desde el repositorio, instalar gemas, ejecutar migraciones, precompilar los JS y CSS, y reiniciar el servidor.