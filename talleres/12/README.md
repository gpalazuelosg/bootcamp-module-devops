# Introducción a ECS

Configurar un cluster de ECS, desplegar el API de Mythical Mysfits y exponerlo a través de un Application Load Balancer

## Instrucciones

1. Crear repositorio de ECR. Busca el servicio **Elastic Container Registry**:

- Click en `Create repository`
- **Repository name**: `mythical-mysfits-api`
- Click en el nombre del repositorio
- Click en `View push commands` (Los utilizaremos más adelante)

2. Copiar el archivo **Dockerfile** a la carpeta `backend/`

3. Siguiendo los comandos de ECR del paso 1:

- Hacer login utilizando la AWS CLI
- Construir la imagen del contenedor
- Crear un tag de la imagen
- Hacer push de la imagen hacia ECR

4. Crear un **Application Load Balancer**:

- Ir a la consola de *EC2* y buscar *Load Balancers*
- Click en `Create Load Balancer`
- `Application Load Balancer`

Configure Load Balancer

- **Name**: `mythicalmysfits`
- **Scheme**: `internet-facing`
- **IP address type**: `ipv4`
- **Listeners**
  - **Load Balancer Protocol**: `HTTP`
  - **Load Balancer Port**: `80`
- **Availability Zones**: *Seleccionar todas*

Configure Security Groups

- `Create a new security group`
- **Security group name**: `ecs-lb-ythicalmysfits`
- Regla:
  - **Type**: `HTTP`
  - **Source**: `Anywhere`

Configure Routing

- **Target group**: `New target group`
- **Name**: `backend`
- **Target type**: `IP`
- **Protocol**: `HTTP`
- **Port**: `80`
- **Health checks**:
  - **Protocol**: `HTTP`
  - **Path**: `/`

5. Crear cluster de **ECS**:

- `Create Cluster`
- `Networking only` (Powered by AWS Fargate)
- **Cluster name**: `mythical-mysfits`
- `Create`
- `View cluster`

6. Crear un nuevo **Task Definition**:

- `Create new Task Definition`
- `Fargate`
- **Task Definition Name**: `mythicalmysfits-backend`
- **Task execution role**: `ecsTaskExecutionRole` (si no aparece, `Create new role`)
- **Task size**:
  - **Task memory (GB)**: `0.5GB`
  - **Task CPU (vCPU)**: `0.25 vCPU`
- `Add container`:
  - **Container name**: `backend`
  - **Image**: *Copiar Image URI de ECR*
  - **Port mappings**:
    - **Container port**: `80`
    - **Protocol**: `tcp`
  - `Add`
- `Create`
- `View task definition`

7. Crear un nuevo *ECS Service* desde el Cluster:

Configure service

- **Launch type**: `FARGATE`
- **Task Definition**:
  - **Family**: `mythicalmysfits-backend`
  - **Revision**: `latest`
- **Platform version**: `LATEST`
- **Cluster**: `mythical-mysfits`
- **Service name**: `backend`
- **Number of tasks**: `1`
- **Minimum healthy percent**: `100`
- **Maximum percent**: `200`
- **Deployment type**: `Rolling update`

Configure network

- **Cluster VPC**: *Default VPC*
- **Subnets**: *Seleccionar todas*
- **Security groups**:
  - `Create new security group`
  - **Security group name**: `ecs-app-ythicalmysfits`
  - **Rules**:
    - **Type**: `Custom TCP`
    - **Port range**: `80`
    - **Source**: `Anywhere`
- **Load balancer type**:
  - `Application Load Balancer`
  - **Load balancer name**: `mythicalmysfits`
  - **Container name : port**: `backend:80:80`
  - `Add to load balancer`
    - **Production listener port**: `80:HTTP`
    - **Target group name**: `backend`

Set Auto Scaling (optional)

- `Do not adjust the service’s desired count`

`Create Service`

`View Service`

## Validación

1. Revisar la URL del Load Balancer para validar el funcionamiento del API.

2. Copiar el contenido del archivo `backend/app-v2.py` al fichero `backend/app.py`

3. Construir una nueva versión de la imagen del contenedor

4. Actualizar el servicio activando `Force new deployment` sin cambiar nada más

5. Validar el funcionamiento del rolling update en la pestaña de *Tasks*

## Limpieza

Eliminar los siguientes recursos:

- Servicio ECS: `backend`
- Application Load Balancer: `mythicalmysfits`
- Target group: `backend`
- Security groups: `ecs-lb-ythicalmysfits` y `ecs-app-ythicalmysfits`
- Cluster de ECS: `mythical-mysfits`
- Repositorio de ECR: `mythical-mysfits-api`