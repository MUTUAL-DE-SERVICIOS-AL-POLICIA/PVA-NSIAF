# API

## Servicio Web: Creación de documentos serializados

Permite almacenar un documento serializado en formato JSON u otro especificado. Los parámetros deben ser enviados en formato `JSON` y en la cabecera de la petición incluir

```bash
Content-Type: application/json
```

La URL para consumir el servicio:

```bash
POST /api/documentos
```

Parámetros de entrada y salida:

| Tipo    | Parámetro   | Descripción                                                 |
|---------|-------------|-------------------------------------------------------------|
| Entrada | `titulo     | Nombre del documento                                        |
| Entrada | `contenido` | Es el documento serializado en determinado formato.         |
| Entrada | `formato`   | Es el formato del documento serializado: `JSON`, `XML`, etc |
| Entrada | `etiquetas` | Etiquetas del documento están separados por comas.          |
| Salida  | `mensaje`   | Mensaje que describe el estado de la respuesta.             |

Ejemplo con `curl`:

Crear un documento serializado con los siguientes parámetros:

```bash
{
  documento: {
    titulo: "Nombre de una persona",
    contenido: "{\"usuario\":{\"nombre\":\"Pepito\",\"apellido\":\"de los Palotes\"}}",
    formato: "JSON",
    etiquetas: "nombre completo,acta"
  }
}
```

```bash
curl -H "Content-Type: application/json" -X POST http://intranet.adsib.gob.bo/activos/api/documentos -d '{"documento":{"titulo":"Nombre de una persona","contenido":"{\"usuario\":{\"nombre\":\"Pepito\",\"apellido\":\"de los Palotes\"}}","formato":"JSON","etiquetas":"nombre completo,acta"}}'
```

Respuesta con la petición creada, retorna el `id` del documento creado:

```bash
HTTP/1.1 201 Created
{
  "id": 1,
  "mensaje": "Se creó el documento correctamente"
}
```

Respuesta en el caso que el formato los parámetros sea incorrecto:

```bash
HTTP/1.1 400 Bad Request
{
  "mensaje": "Error al guardar el documento"
}
```

## Servicio Web: Obtener el contenido de un documento estructurado

Permite retornar el contenido de un documento almacenado previamente. Los parámetros deben ser enviados en formato `JSON` y en la cabecera de la petición incluir:

```bash
Content-Type: application/json
```

La URL para consumir el servicio:

```bash
GET /api/documentos/:id
```

Parámetros de entrada y salida:

| Tipo            | Parámetro   | Descripción                                                 |
|-----------------|-------------|-------------------------------------------------------------|
| Entrada/Salida  | `id`        | Es el identificador del documento generado                  |
| Salida          | `titulo`    | Nombre del documento                                        |
| Salida          | `contenido` | Es el documento serializado en determinado formato.         |
| Salida          | `formato`   | Es el formato del documento serializado: `JSON`, `XML`, etc |
| Salida          | `etiquetas` | Etiquetas del documento están separados por comas.          |
| Salida          | `creado_el` | Fecha de creación del documento, en formato ISO8601         |
| Salida          | `mensaje`   | Mensaje que describe el estado de la respuesta              |

Ejemplo con `curl`:

Obtener el documento con `id = 1`:

```bash
curl -H "Content-Type: application/json" -i http://intranet.adsib.gob.bo/activos/api/documentos/1
```

Respuesta con el contenido del documento:

```bash
HTTP/1.1 200 OK
{
  id: 1,
  titulo: "Nombre de una persona",
  contenido: "{\"usuario\":{\"nombre\":\"Pepito\",\"apellido\":\"de los Palotes\"}}",
  formato: "JSON",
  etiquetas: "nombre completo,acta",
  creado_el: "2015-07-18T20:26:43.511Z"
}
```

Respuesta en el caso que el documento solicitado no exista:

```bash
HTTP/1.1 404 Not Found
{
  "mensaje": "El documento solicitado no existe"
}
```
