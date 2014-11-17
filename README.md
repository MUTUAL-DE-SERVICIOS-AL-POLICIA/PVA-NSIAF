# NSIAF

Sistema de Activos Fijos y Almacenes desarrollado por [ADSIB](http://adsib.gob.bo)

## Instalación

La instalación en modo `production` del Sistema está descrito en el archivo [`INSTALL.md`](INSTALL.md)

## Primeros pasos

Después del despliegue de la aplicación (en el paso anterior), se define algunos pasos iniciales que se debe seguir en el sistema los cuales están descritos en el archivo [`MANUAL.md`](MANUAL.md)

## Desarrollo

Para realizar desarrollo de nuevas caraterísticas del sistema en la máquina local, es necesario realizar la configuración del ambiente de desarrollo con `Ruby On Rails`.

### Lenguaje de programación y base de datos

* Lenguaje de programación: `Ruby 2.1`
* Framework para Web: `Ruby On Rails 4.1`
* Base de datos: `MySQL`

### git-flow

El flujo de trabajo se está manejando con [git-flow](https://github.com/nvie/gitflow). El desarrollo se organiza en dos ramas principales:

* Rama `master`: cualquier commit que pongamos en esta rama debe estar preparado para subir a producción
* Rama `develop`: rama en la que está el código que conformará la siguiente versión planificada del proyecto

### Ruby

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

### Conversión de formatos

Éste sistema depende del API de Conversión de Formatos para la importación de archivos `DBF`, cuyo repositorio es https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos

La instalación del API de Conversión de Formatos está descrita en el archivo [INSTALL.md](https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos/blob/master/INSTALL.md)

### Código fuente

En la máquina local clonamos el repositorio del Sistema de Activos Fijos y Almacenes

```console
git clone git@gitlab.geo.gob.bo:adsib/nsiaf.git
```

Cambiar al branch `develop` que es el de desarrollo

```console
cd nsiaf
git checkout develop
```

Creación de un `gemset` para las gemas con `RVM`

```console
rvm use 2.1@nsiaf --create --ruby-version
```

Copiamos los archivos de ejemplo

```console
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml
```

Editar `config/database.yml` con el siguiente contenido

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

Editar `config/secrets.yml` con el siguiente contenido

```yaml
development:
  convert_api_url: 'http://localhost/conversion-formatos'
  rails_relative_url_root: ''
  secret_key_base: d7c345615c14afe85dd35d9169e9743c4f24de413990b3133b93865f1f5f490db6a3c1327e9a5af3fc845937a7f489bbda865a25caa424144580d2d106cb121c
```

Instalar las gemas

```console
bundle install
```

Crear la base de datos e inicializar con la configuración por defecto

```console
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
```

### Servidor web

Iniciar el servidor en modo desarrollo

```console
rails server
```

y visitar en el navegador el link `http://localhost:3000`
