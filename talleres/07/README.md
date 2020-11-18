# Introducción a CodePipeline

Configurar manualmente un proyecto de CodePipeline para probar y desplegar el API de Mythical Mysfits con Auto Scaling Groups.

## Instrucciones

1. Crear un proyecto en CodePipeline con los siguientes parámetros:

- **Pipeline settings**
  - *Pipeline name*: `mythicalmysfits`
  - *Service role*: `New service role`
  - Validar que se encuentra marcada la casilla `Allow AWS CodePipeline to create a service role so it can be used with this new pipeline`
- **Advanced settings**
  - *Artifact store*: `Default location`
  - *Encryption key*: `Default AWS Managed Key`

2. En la sección de *Source* especificamos el repositorio de GitHub:

- **Source**
  - *Source provider*: `GitHub`
  - `Connect to GitHub` -> Autorizar aws-codesuite -> *You have successfully configured the action with the provider.*
  - *Repository*: `bootcamp-module-devops`
  - *Branch*: `master`
  - *Change detection options*: `GitHub webhooks (recommended)`

3. En la sección de *Build* creamos un proyecto de CodeBuild para validar y exportar el template de CloudFormation:

- **Build**
  - *Build provider*: `AWS CodeBuild`
  - *Region*: (selecciona tu región)
  - *Project name*: Click en `Create Project`

En la ventana emergente llenar estos campos:

- **Project configuration**
  - *Project name*: `mythicalmysfits-cfn`
- **Environment**
  - *Environment image*: `Managed image`
  - *Operating system*: `Ubuntu`
  - *Runtime(s)*: `Standard`
  - *Image*: `aws/codebuild/standard:4.0`
  - *Image version*: `Always use the latest image for this runtime version`
  - *Environment type*: `Linux`
  - *Service role*: `New service role`
- **Buildspec**
  - *Build specifications*: `Use a buildspec file`
  - *Buildspec name*: `talleres/07/buildspec-cfn.yml`
- **Logs**: Validar que la casilla `CloudWatch logs` esté seleccionada

Click en `Continue to CodePipeline`

4. En la sección de *Deploy*:

- **Deploy**
  - *Deploy provider*: `AWS CloudFormation`
  - *Region*: (selecciona tu región)
  - *Action mode*: `Create or update stack`
  - *Stack name*: `mythical-mysfits-pipeline`
  - *Artifact name*: `BuildArtifact`
  - *File name*: `api-cfn-pipeline.yaml`
  - *Role name*: Crear un Role llamado `CFNAdminRole` para el servicio CloudFormation con permisos de Administrador

5. Completar el archivo `buildspec-cfn.yml`:

- Ejecutar el comando `aws cloudformation validate-template` en la fase de `build`

- Consultar la documentación de [artifacts](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html#build-spec.artifacts) y definir el template `api-cfn-pipeline.yaml` como archivo de salida para el paso de `Deploy`.

6. Validar que el Pipeline se ejecuta con cada cambio al repositorio

7. Agregar un paso a la etapa de *Build* para ejecutar el proyecto del [Taller 06](../06/) con los tests unitarios

## Validación

Hacer *push* a los cambios y validar que CodePipeline ejecuta las etapas de forma correcta.

Desplegar la versión 2 del API modificando el template de CloudFormation.

## Limpieza

Borrar el proyecto `mythicalmysfits-cfn` en la consola de CodeBuild y el proyecto `mythicalmysfits` en la consola de CodePipeline.