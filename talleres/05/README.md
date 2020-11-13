# Blue/Green deployments con CloudFormation y Auto Scaling Groups

Mantener dos stacks con el API de Mythical Mysfits durante un despliegue y hacer el cambio de tráfico ocupando un Application Load Balancer.

## Instrucciones

1. **Parámetros**

Llenar los parámetros requeridos en los archivos [params-stacks.json](./params-stacks.json) y [params-lb.json](./params-lb.json).

2. **Templates**

Para este ejercicio necesitamos 3 plantillas de CloudFormation:

- *Stack01*: [stack-01.yaml](./stack-01.yaml) contiene los siguientes recursos para levantar la versión 1 del API: Security Group, Target Group, Launch Configuration y Auto Scaling Group. También contiene un par de `Outputs` para exportar los valores del Security Group y Target Group que necesita el Load Balancer en otro stack.

- *Stack02*: Crear la plantilla `stack-02.yaml` tomando el stack01 como referencia y haciendo los cambios necesarios para desplegar la versión 2 del API. En esta plantilla el número de servidores debe ser 0 inicialmente.

3. **Despliegue inicial**

Levantar los 3 stacks dejando el `load-balancer` al último:

```bash
aws cloudformation create-stack --stack-name stack01 --template-body file://stack-01.yaml --parameters file://params-stacks.json
```

```bash
aws cloudformation create-stack --stack-name stack02 --template-body file://stack-02.yaml --parameters file://params-stacks.json
```

Es importante esperar a que terminen los 2 stacks antes de continuar con el load balancer, ya que requiere de los valores exportados:

```bash
aws cloudformation create-stack --stack-name load-balancer --template-body file://load-balancer.yaml --parameters file://params-lb.json
```

4. **Versión 2**

- Incrementa el número de servidores en el stack-02
- Cuando los servidores se encuentren en servicio de acuerdo al Target Group, hacer el switch en la propiedad `ForwardConfig` del Load Balancer
- Validar que el servicio se encuentra funcionando
- Destruir los servidores del stack-01

## Validación

Haciendo llamadas a través de curl al endpoint raíz del API se puede notar el cambio limpio de versiones sin downtime.

## Limpieza

Eliminar los stacks en el siguiente orden:

```bash
aws cloudformation delete-stack --stack-name load-balancer
```

Al finalizar, borrar los stacks de ASG:

```bash
aws cloudformation delete-stack --stack-name stack01
aws cloudformation delete-stack --stack-name stack02
```