# Levantar el sistema con Docker-Compose

## Requisitos

Para levantar este sistema se necesita tener instalado [Docker](https://docs.docker.com/install/linux/docker-ce/debian/) y [Docker-Compose](https://docs.docker.com/compose/install/). Las imagenes base del sistema son [ruby:2.3.6+Node.JS](https://hub.docker.com/r/scardon/ruby-node-alpine/) y [mysql:5.5](https://hub.docker.com/_/mysql/).

## Clonar los archivos base mediante GIT

Si ya clonaste el proyecto puedes pasar al punto siguiente.

```sh
git -c http.sslVerify=false clone --branch=agetic-mysql https://gitlab.geo.gob.bo/adsib/nsiaf.git
```

## Entrar a la carpeta `docker/almacenes` del repositorio recién clonado

```sh
cd docker/almacenes
```

## Generar las variables de entorno desde el archivo de ejemplo

```sh
cp .env.ejemplo .env
```

el contenido del archivo `.env` es del siguiente tipo:

```
# Nombre de usuario del administrador de la aplicacion
ADMIN_USUARIO=admin

# Password del administrador de la aplicacion
ADMIN_PASSWORD=admin

# Nombre de la base de datos que será creada en el volumen del contenedor de MySQL.
MYSQL_DATABASE=nsiaf_production

# Nombre del host que se asignará al contenedor de MySQL.
MYSQL_HOST=nsiaf-db

# Usuario con privilegios para la base de datos del sistema.
MYSQL_USER=admin

# Contraseña del usuario con privilegios para acceder a la base de datos del sistema.
MYSQL_PASSWORD=admin

# Contraseña del usuario con privilegios de root.
MYSQL_ROOT_PASSWORD=root

# Puerto en el cual escucha la base de datos del contenedor MySQL.
MYSQL_PORT=3306

# URL de la API de conversión de formatos. Por defecto esta API se encuentra disponible en https://intranet.adsib.gob.bo/conversion-formatos.
# CONVERT_API_URL=https://intranet.adsib.gob.bo/conversion-formatos

# Nombre del host que se asignará al contenedor de backend del sistema.
RAILS_HOST=dominio.gob.bo

# Dirección de correo desde la cual se enviarán correos de notificacion de excepciones, por ejemplo: `"notificador <noreply@dominio.gob.bo>"`
# EMAIL_SENDER_ADDRESS=

# Direcciones de correo a las cuales se enviarán correos de notificacion de excepciones, por ejemplo: `"desarrollador1@dominio.gob.bo, desarrollador2@dominio.gob.bo"`
# EMAIL_EXCEPTION_RECIPIENTS=

# Dirección del servidor SMTP desde el cual se enviarán correos.
# SMTP_ADDRESS=

# Puerto del servidor SMTP desde el cual se enviarán correos.
# SMTP_PORT=

# Dominio del servidor SMTP desde el cual se enviarán correos.
# SMTP_DOMAIN=

# Usuario del servidor SMTP desde el cual se enviarán correos.
# SMTP_USER=

# Contraseña del servidor SMTP desde el cual se enviarán correos.
# SMTP_PASS=

# Tipo de autentication del servidor SMTP desde el cual se enviarán correos. Por ejemplo: `"plain"`
# SMTP_AUTHENTICATION=

# Opción para utilizar el servicio SMTP mediante TLS. Por ejemplo: `true`
# SMTP_TLS=

# Clave secreta de la aplicacion - ese valor DEBE ser cambiado en produccion - la puedes generar por ejemplos con comandos como `rake secret` o `openssl rand -hex 64` 
SECRET_KEY_BASE=este-valor-tiene-que-cambiar-en-produccion
```

Cada linea no comentada del archivo `.env` representa una variable de entorno que es adoptada por el contenedor al momento del despliegue.

En entornos de producción es muy importante modificar las credenciales de administrador y de mysql. También es importante modificar el valor de la clave secreta con una cadena aleatoria.


## Iniciar el sistema

```sh
docker-compose up -d
```

Si se desean ver los logs a medida que la imagen es creada, se debe suprimir la opción `-d`

Una vez el sistema se encuentre iniciado y levantado, se pueden inspeccionar los logs mediante:

```sh
docker-compose logs --follow
```

El sistema crea un volumen de Docker que se puede inspeccionar mediante el comando:

```sh
docker volume inspect almacenes_nsiaf-db
```

El puerto que expone el sistema es el `3000`, que por defecto se redirecciona al puerto `8888` del host de Docker.

Para abrir el puerto 3306 de MySQL, se debe modificar el archivo [docker-compose.yml](./docker-compose.yml) y aumentar la opción `ports`  del contenedor `nsiaf-db`.

Para iniciar los contenedores por separado se pueden utilizar los archivos Dockerfile de cada servicio en este orden:

- [Base de datos](./db/README.md)
- [Backend](./backend/README.md)
