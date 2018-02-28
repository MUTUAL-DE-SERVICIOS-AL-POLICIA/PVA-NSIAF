# Levantar el sistema con Docker-Compose

## Requisitos

Para levantar este sistema se necesita tener instalado [Docker](https://docs.docker.com/install/linux/docker-ce/debian/) y [Docker-Compose](https://docs.docker.com/compose/install/). Las imagenes base del sistema son [ruby:2.3.6](https://hub.docker.com/_/ruby/) y [mysql:5.5](https://hub.docker.com/_/mysql/).

## Generar las variables de entorno

```sh
cp .env.ejemplo .env
```

`Editar el archivo de acuerdo a la siguiente tabla de variables disponibles`

## Variables de entorno

### MYSQL_DATABASE

Nombre de la base de datos que será creada en el volumen del contenedor de MySQL.

### MYSQL_HOST

Nombre del host que se asignará al contenedor de MySQL.

### MYSQL_USER

Usuario con privilegios para la base de datos del sistema.

### MYSQL_PASSWORD

Contraseña del usuario con privilegios para acceder a la base de datos del sistema.

### MYSQL_PORT

Puerto en el cual escucha la base de datos del contenedor MySQL.

### CONVERT_API_URL

URL de la [API de conversión de formatos](https://gitlab.geo.gob.bo/bolivia-libre/conversion-formatos). Por defecto esta API se encuentra disponible en [https://intranet.adsib.gob.bo/conversion-formatos](https://intranet.adsib.gob.bo/conversion-formatos).

### RAILS_HOST

Nombre del host que se asignará al contenedor de backend del sistema.

### EMAIL_SENDER_ADDRESS

Dirección de correo desde la cual se enviarán correos de notificacion de excepciones, por ejemplo: `"notificador <noreply@dominio.gob.bo>"`

### EMAIL_EXCEPTION_RECIPIENTS

Direcciones de correo a las cuales se enviarán correos de notificacion de excepciones, por ejemplo: `"desarrollador1@dominio.gob.bo, desarrollador2@dominio.gob.bo"`

### SMTP_ADDRESS

Dirección del servidor SMTP desde el cual se enviarán correos.

### SMTP_PORT

Puerto del servidor SMTP desde el cual se enviarán correos.

### SMTP_DOMAIN

Dominio del servidor SMTP desde el cual se enviarán correos.

### SMTP_USER

Usuario del servidor SMTP desde el cual se enviarán correos.

### SMTP_PASS

Contraseña del servidor SMTP desde el cual se enviarán correos.

### SMTP_AUTHENTICATION

Tipo de autentication del servidor SMTP desde el cual se enviarán correos. Por ejemplo: `"plain"`

### SMTP_TLS

Opción para utilizar el servicio SMTP mediante TLS. Por ejemplo: `true`

## Iniciar el sistema

```sh
docker-compose up -d
```

*Si se desean ver los logs a medida que la imagen es creada, se debe suprimir la opción -d*

* Una vez el sistema se encuentre iniciado y levantado, se puden inspeccionar los logs mediante:

```sh
docker-compose logs
```

* El sistema crea un volumen de docker que se puede inspeccionar mediante el comando:

```sh
docker volume inspect almacenes_nsiaf-bd
```

* El puerto que expone el sistema es el `3000`, que por defecto se redirecciona al puerto `8888` del host de Docker.

* Para iniciar los contenedores por separado se pueden utilizar los archivos Dockerfile de cada subsistema en este orden:

- [Base de datos](./db/README.md)
- [Backend](./backend/README.md)
