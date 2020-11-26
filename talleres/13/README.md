# CI/CD con ECS

Configurar un flujo de integración y entrega continua utilizando Docker y ECS

## Instrucciones

1. Revisar y ejecutar el template de CloudFormation [ecs-infra.yaml](./ecs-infra.yaml) con:

```bash
aws cloudformation create-stack --stack-name mysfits-ecs --template-body file://ecs-infra.yaml --capabilities CAPABILITY_IAM
```

2. En los *Outputs* del stack se encuentran las URLs de los Load Balancers de desarrollo y producción. Validar que ambos funcionan.

3. Copiar los siguientes archivos a la carpeta `backend/`:

- Dockerfile
- buildspec.yml
- appspec.yaml
- taskdef.json

4. Obtener el valor del ARN del IAM Role para los tasks de ECS en los *Outputs* del stack con el nombre `TaskExecutionRoleARN` y actualizarlo en el archivo `taskdef.json` en lugar de **REPLACE_ME_TASK_EXECUTION_ARN**.

5. Ir al servicio *ECR* y copiar el valor de `URI` del repositorio llamado `mysfits-ecs-backend` y remplazarlo en el archivo `buildspec.yml` en lugar de **REPLACE_ME_ECR_URI**.

6. Agregar los cambios y empujarlos a GitHub:

```bash
git add backend/
git commit -m 'Agregar archivos para cicd de Docker'
git push
```

7. Crear un proyecto en CodePipeline con los siguientes parámetros:

- **Pipeline settings**
  - *Pipeline name*: `mysfits-ecs`
  - *Service role*: `New service role`
  - Validar que se encuentra marcada la casilla `Allow AWS CodePipeline to create a service role so it can be used with this new pipeline`
- **Advanced settings**
  - *Artifact store*: `Default location`
  - *Encryption key*: `Default AWS Managed Key`

8. En la sección de *Source* especificamos el repositorio de GitHub:

- **Source**
  - *Source provider*: `GitHub`
  - `Connect to GitHub` -> Autorizar aws-codesuite -> *You have successfully configured the action with the provider.*
  - *Repository*: `bootcamp-module-devops`
  - *Branch*: `master`
  - *Change detection options*: `GitHub webhooks (recommended)`

9. En la sección de *Build* creamos un proyecto de CodeBuild para construir y publicar una imagen de Docker:

- **Build**
  - *Build provider*: `AWS CodeBuild`
  - *Region*: (selecciona tu región)
  - *Project name*: Click en `Create Project`

En la ventana emergente llenar estos campos:

- **Project configuration**
  - *Project name*: `mysfits-ecs`
- **Environment**
  - *Environment image*: `Managed image`
  - *Operating system*: `Ubuntu`
  - *Runtime(s)*: `Standard`
  - *Image*: `aws/codebuild/standard:4.0`
  - *Image version*: `Always use the latest image for this runtime version`
  - *Environment type*: `Linux`
  - *Privileged*: **Seleccionar casilla**
  - *Service role*: `New service role`
- **Buildspec**
  - *Build specifications*: `Use a buildspec file`
  - *Buildspec name*: `backend/buildspec.yml`
- **Logs**: Validar que la casilla `CloudWatch logs` esté seleccionada

Click en `Continue to CodePipeline`

10. En la sección de *Deploy*:

- **Deploy**
  - *Deploy provider*: `Amazon ECS`
  - *Region*: (selecciona tu región)
  - *Cluster name*: `mysfits-ecs`
  - *Service name*: `development-backend`
  - *Image definitions file*: `imagedefinitions.json`

Revisar y crear el proyecto.

11. Agregar la política administrada `AmazonEC2ContainerRegistryPowerUser` al Role de CodeBuild.

12. Reintentar la ejecución y validar que el serivicio se despliega correctamente en el ambiente de desarrollo.

13. Crear una nueva aplicación de **CodeDeploy** llamada `mysfits-ecs` con la plataforma `Amazon ECS` y agrega un *Deployment Group* llamado `production`:

- **Service role**: *Utiliza el Service Role que creamos con CloudFormation y que inicia con* `mysfits-ecs-`
- **Environment configuration**
  - *Choose an ECS cluster name*: `mysfits-ecs`
  - *Choose an ECS service name*: `production-backend`
- **Load balancers**:
  - *Choose a load balancer*: `mysfits-ecs-prod`
  - *Production listener port*: `HTTP:80`
  - *Test listener port*: `HTTP:8080`
  - *Target group 1 name*: `mysfits-ecs-prod-backend1`
  - *Target group 2 name*: `mysfits-ecs-prod-backend2`
- **Deployment settings**
  - *Traffic rerouting*: `Specify when to reroute traffic` (5 minutes)
  - *Deployment configuration*: `CodeDeployDefault.ECSAllAtOnce`
  - *Original revision termination*: (5 minutes)

14. Modificar el proyecto de CodePipeline para agregar una nueva etapa llamada `DeployProd`:

- **Action name**: `ECSDeploy`
- **Action provider**: `Amazon ECS (Blue/Green)`
- **Region**: *Seleccionar tu región*
- **Input artifacts**: `BuildArtifact`
- **AWS CodeDeploy application name**: `mysfits-ecs`
- **AWS CodeDeploy deployment group**: `production`
- **Amazon ECS task definition**
  - *BuildArtifact*: `taskdef.json`
- **AWS CodeDeploy AppSpec file**
  - *BuildArtifact*: `appspec.yaml`

Guardar los cambios en el proyecto y ejecutar el Pipeline.


## Validación

Copiar el contenido de `app-v2.py` a `app.py` y empujar los cambios al repositorio de GitHub. Validar el funcionamiento del Pipeline.

Durante el despliegue de CodeDeploy, validar el funcionamiento del Test Listener en el puerto `8080` del Load Balancer de producción.

## Limpieza

Eliminar los proyectos de CodeBuild, CodeDeploy y CodePipeline.

Vaciar el repositorio de ECR y después eliminar el stack de CloudFormation con:

```bash
aws cloudformation delete-stack --stack-name mysfits-ecs
```