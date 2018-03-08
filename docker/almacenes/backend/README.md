# Backend del sistema NSIAF

`Antes de iniciar un contenedor de esta imagen debe estar funcionando primero el [contenedor de la base de datos](../db/README.md)`

* Crear la imagen de nsiaf

```sh
docker build -t nsiaf:1.0.0 -f ./Dockerfile .
```

* Iniciar un contenedor del subsistema

```sh
docker run --name nsiaf-backend --link nsiaf-bd -e RAILS_HOST=presidencia -e MYSQL_DATABASE=nsiaf_production -e MYSQL_HOST=nsiaf_bd -e MYSQL_USER=admin -e MYSQL_PASSWORD=admin -e MYSQL_PORT=3306 -p 8888:80 --rm -it nsiaf:1.0.0
```

* Los volumenes que expone el contenedor son `"/var/www/html/nsiaf", "/var/log/apache2"`

* El puerto que expone el contenedor es `3000`.
