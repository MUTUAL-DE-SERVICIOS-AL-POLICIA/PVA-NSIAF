# Base de datos del sistema NSIAF

* Crear la imagen de la base de datos

```sh
docker build -t mysql-nsiaf -f ./Dockerfile .
```

* Crear un volumen para no perder la base de datos al momento de eliminar el contenedor

```sh
docker volume create nsiaf-bd
```

* Iniciar un contenedor del subsistema

```sh
docker run --name nsiaf-bd -p 3306:3306 -v mysql-nsiaf:/var/lib/mysql --restart=always -d mysql:5.5
```
