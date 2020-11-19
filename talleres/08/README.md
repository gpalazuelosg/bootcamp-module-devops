# Introducción a CodeDeploy

Crear una instancia de EC2 y desplegar el API ocupando CodeDeploy.

## Instrucciones

1. Revisa el [template de CloudFormation](./api-ec2-deploy.yaml):

- IAM Instance Profile
- IAM Service Role
- EC2 instance
- S3 Bucket

Y crea el stack de CloudFormation con el siguiente comando:

```bash
aws cloudformation create-stack --stack-name deploy-base --template-body file://api-ec2-deploy.yaml --capabilities CAPABILITY_IAM
```

Si existen problemas puedes actualizar el stack con el siguiente comando:

```bash
aws cloudformation update-stack --stack-name deploy-base --template-body file://api-ec2-deploy.yaml --capabilities CAPABILITY_IAM
```

2. Revisa los archivos que se encuentran en la carpeta [scripts](./scripts).

3. Consulta la doumentación sobre el archivo [appspec](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html#appspec-reference-server) y completa el fichero [appspec.yml](./appspec.yml) agregando los scripts en el lugar adecuado.

4. Copia el archivo `appspec.yml` a la carpeta raíz del proyecto.

5. En la consola de `CodeDeploy`, crea una aplicación con el botón `Create application`:

- **Application configuration**
  - *Application name*: `MythicalMysfitsEC2`
  - *Compute platform*: `EC2/On-premises`

6. Crea un nuevo grupo de despliegue con el botón `Create deployment group`:

- **Deployment group name**
  - *Name*: `Develop`
- **Service role**: 
  - *Role*: (Revisa la pestaña de *Outputs* del stack de CloudFormation y copia el valor de *ServiceRole* aquí)
- **Deployment type**: `In-place`
- **Environment configuration**: `Amazon EC2 instances`
  - *Key*: `Name`
  - *Value*: `DeployMythicalMysfits`
- **Agent configuration with AWS Systems Manager**: `Never`
- **Deployment settings**
  - *Deployment configuration*: `CodeDeployDefault.AllAtOnce`
- **Load Balancer**: *Deseleccionar casilla de Load Balancer*

7. Consulta el valor de `BucketName` en los *Outputs* del stack de CloudFormation y utilizalo para sustituirlo en el siguiente comando:

```bash
aws deploy push \
  --application-name MythicalMysfitsEC2 \
  --s3-location s3://BUCKETNAME/Mythical-1.zip \
  --ignore-hidden-files
```

Este comando empaqueta el directorio y lo sube al bucket de S3. También crea un nuevo *Revision* en tu aplicación de CodeDeploy.

8. Crea un nuevo despliegue desde tu *Deployment group* con el botón `Create deployment`:

- **Deployment settings**
  - *Deployment group*: `Develop`
  - *Revision type*: `My application is stored in Amazon S3`
  - *Revision location*: (Selecciona el Revision que creamos en el paso anterior)
- **Additional deployment behavior settings**
  - *Content options*: `Overwrite the content`

Click en el botón `Create deployment`


## Validación

Revisa los eventos del despliegue en la sección **Deployment lifecycle events**

En la pestaña de *Outputs* del stack de CloudFormation se encuentra la IP Pública del servidor EC2. Apunta tu frontend a esta dirección para validar que el API funciona correctamente.

Intenta actualizar el archivo `app.py` y crea una nueva revisión y despliegue en CodeDeploy.

## Limpieza

Borrar la aplicación `MythicalMysfitsEC2` en la consola de CodeDeploy y elimina el stack de CloudFormation con el siguiente comando:

```bash
aws cloudformation delete-stack --stack-name deploy-base
```