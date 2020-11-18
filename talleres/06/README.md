# Introducción a CodeBuild

Configurar manualmente un proyecto de CodeBuild para ejecutar las pruebas unitarias de Mythical Mysfits en cada Pull Request de GitHub. [Documentación](https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-pull-request.html).

## Instrucciones

1. **Proyecto CodeBuild**

En la consola de CodeBuild, crear un proyecto con los siguientes parámetros:

- **Project name**: `mythicalmysfits-tests`
- **Source**:
  - *Source provider*: `GitHub`
    - Connect using OAuth -> `Connect to GitHub` -> Autorizar con GitHub -> `Confirm`
    - `Repository in my GitHub account`
    - Seleccionar repositorio: `bootcamp-module-devops`
- **Primary source webhook events**:
  - Marcar: `Rebuild every time a code change is pushed to this repository`
  - *Event type*: `PULL_REQUEST_CREATED`, `PULL_REQUEST_REOPENED` y `PULL_REQUEST_UPDATED`
- **Environment**
  - `Managed image`
  - *Operating system*: `Ubuntu`
  - *Runtime(s)*: `Standard`
  - *Image*: `aws/codebuild/standard:4.0`
  - *Image version*: `Always use the latest image for this runtime version`
  - *Environment type*: `Linux`
  - *Service role*: `New service role`
- **Buildspec**
  - *Build specifications*: `Use a buildspec file`
  - *Buildspec name*: `talleres/06/buildspec-tests.yml`
- **Logs**: Validar que la casilla `CloudWatch logs` esté seleccionada

2. **Archivo buildspec**

[Revisar la documentación del archivo buildspec](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) y completar el archivo [buildspec-tests.yml](./buildspec-tests.yml) con lo siguiente:

- *install*: Agregar el runtime adecuado para el proyecto. [Entornos disponibles](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html).

- *pre_build*: Instalar las dependencias de Python.

- *build*: Ejecutar los tests con el comando `pytest`.

3. **Pull Request en GitHub**

Hacer un Pull Request en GitHub y validar que se ejecuta una construcción en CodeBuild.

## Validación

Crear un branch y hacer algún cambio (esta rama no se va a unir con *master*). En GitHub abrir un Pull Request y esperar que se ejecute el proyecto de CodeBuild. Debería mostrar un check en verde.

Hacer un cambio que rompa el test en `backend/tests/test_app.py` y validar que el check en GitHub cambia a rojo.

En ambos casos ir a CodeBuild y ver los logs de la ejecución del archivo buildspec.

## Limpieza

**Advertencia**: este proyecto se utilizará en el siguiente taller.

Borrar el proyecto `mythicalmysfits-tests` en la consola de CodeBuild.