# CI/CD

El reto es crear un pipeline de CI/CD para el API de Mythical Mysfits ocupando CodeBuild, CodeDeploy y CodePipeline para desplegar la infraestructura y la aplicación.

## Instrucciones

1. Revisa los diferentes archivos que ocuparemos durante el ejercicio:

- [mythicalmysfits-infra.yaml](./mythicalmysfits-infra.yaml): Contiene los recursos de infraestructura necesarios para desplegar nuestra API

- [buildspec-cfn-validation.yaml](./buildspec-cfn-validation.yaml): Archivo de definición de CodeBuild que sirve para validar el template de CloudFormation y exportarlo para su despliegue

- [buildspec-unit-tests.yaml](./buildspec-unit-tests.yaml): Archivo de definición de CodeBuild para ejecutar los unit tests del API

- [appspec.yml](./appspec.yml): Archivo de definición de CodeDeploy con las instrucciones para ejecutar los scripts de instalación. **Copia este archivo a la raíz del proyecto**

- Carpeta [scripts](./scripts): Los scripts que ejecutará CodeDeploy como parte de los despliegues a las instancias EC2

2. Crear un nuevo proyecto de **CodePipeline** llamado `mythicalmysfits`:

- Configura la etapa de **Source** para conectar a tu repo de GitHub.

- En la etapa de **Build**, configura un nuevo proyecto de CodeBuild llamado `mythicalmysfits-validate-cfn` que haga uso del archivo `buildspec-cfn-validation.yaml`.

- En la etapa de **Deploy**, configura una acción de CloudFormation para desplegar un nuevo stack llamado `mythicalmysfits` usando el template que se encuentra en el archivo `mythicalmysfits-infra.yaml`. El stack requiere de permisos de `CAPABILITY_IAM`.

Con esta primera sección del pipeline, automatizamos el despliegue de la infraestructura para nuestra aplicación. Espera a que la primer ejecución sea exitosa para continuar con los siguientes pasos.

3. Crear una nueva aplicación de **CodeDeploy** llamada `mythicalmysfits` y agrega un *Deployment Group* llamado `production`:

- Utiliza el Service Role que creamos con CloudFormation
- Tipo de despliegue `In-place`
- Selecciona `Amazon EC2 Auto Scaling groups` para configurar el Auto Scaling Group que creamos con CloudFormation
- Elegir la configuración de despliegue llamada `CodeDeployDefault.OneAtATime`
- Configura el Load Balancer que creamos con CloudFormation
- En las opciones avanzadas, configura la opción `Roll back when a deployment fails`

4. Modifica el proyecto de CodePipeline y agrega una etapa de `Test` cuya acción es un nuevo proyecto de `CodeBuild` llamado `mythicalmysfits-unit-tests` que hace uso del archivo `buildspec-unit-tests.yaml`.

5. Agrega una nueva etapa al proyecto de CodePipeline llamada `DeployApp` que ocupe el proyecto de CodeDeploy que creamos durante el paso **3**.

## Validación

Utiliza la acción de `Release change` de CodePipeline para probar el flujo completo y observa cómo se despliega la aplicación en un Auto Scaling Group a través de CodeDeploy. Valida a través de la URL del Load Balancer que la API se ejecuta correctamente.

Realiza un cambio en tu aplicación y sube los cambios a GitHub, el pipeline debería activarse automáticamente y desplegar tus cambios utilizando la configuración de CodeDeploy.

## Limpieza

Borrar los proyectos de CodeDeploy, CodeBuild y CodePipeline.

Finalmente eliminar el stack de CloudFormation:

```bash
aws cloudformation delete-stack --stack-name mythicalmysfits
```