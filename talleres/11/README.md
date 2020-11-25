# Introducción a Docker

Completar el archivo Dockerfile para el API y probarlo de forma local

## Instrucciones

1. Revisar la documentación sobre [Dockerfile](https://docs.docker.com/engine/reference/builder/)

2. Modificar el Dockerfile y llena las instrucciones faltantes:

- **FROM**: `python:3.7-alpine`

- **EXPOSE**: `8000`

- **WORKDIR**: `/opt/app`

- **COPY**: `. .`

- **RUN**: `pip install -r requirements.txt`

3. Construir la imagen del contenedor con:

```bash
docker build -t mythical-api .
```

4. Ejecutar el contenedor y exponer el puerto con:

```bash
docker run -d -p 8000:8000 mythical-api
```

Visitar la URL http://localhost:8000 y validar el funcionamiento del API

5. Ver el proceso en ejecución con:

```bash
docker ps
```

6. Utilizando el ID obtenido en el paso anterior, detener el contenedor:

```bash
docker stop ID
```

7. Eliminar el contenedor:

```bash
docker rm ID
```

## Reto

Contenerizar el frontend y crear un archivo `docker-compose.yaml` para levantar ambos servicios