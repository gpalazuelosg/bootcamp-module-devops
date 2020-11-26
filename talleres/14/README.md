# Alarmas y métricas de CloudWatch

Configurar alarmas de métricas y logs para Mythical Mysfits

## Instrucciones

1. Levantar el stack de CloudFormation para Mythical Mysfits del [Taller 13](../13/)

2. Copiar los siguientes archivos a la carpeta `backend/`:

- Dockerfile
- app.py
- requirements.txt

3. Desplegar una versión de Mythical Mysfits en ECS:

- Construir imagen de Docker
- Subir imagen a ECR
- Crear una nueva versión del task definition para producción
- Actualizar el servicio de ECS de producción con la nueva versión del task definition

#### Auto-escalamiento de servicio ECS

4. Ir a la consola de ECS y actualizar el servicio `production-backend` en la sección de Auto Scaling:

`Configure Service Auto Scaling to adjust your service’s desired count`

- **Minimum number of tasks**: `1`
- **Desired number of tasks**: `1`
- **Maximum number of tasks**: `3`
- **IAM role for Service Auto Scaling**: `ecsAutoscaleRole` (*Seleccionar Create new role si no existe uno*)

`Add scaling policy`

- **Scaling policy type**: `Target tracking`
- **Policy name**: `CPUTracking`
- **ECS service metric**: `ECSServiceAverageCPUUtilization`
- **Target value**: `50`
- **Scale-out cooldown period**: `30`
- **Scale-in cooldown period**: `30`

`Save`

5. Revisa las alarmas creadas en CloudWatch por ECS Auto Scaling y valida su estado

6. Obtener la URL del Load Balancer de producción y ejecutar el siguiente comando para estresar el CPU de la aplicación: 

```bash
while true; do curl URL_DEL_LOAD_BALANCER/load ; sleep 1; done
```

7. Validar que la alarma del límite superior de CPU se dispara y esto desencadena una acción de auto-escalamiento en las tareas del servicio de ECS.

#### Métricas de logs

8. Buscar el Log Group llamado `/ecs/mythicalmysfits/prod/backend` en CloudWatch Logs.

9. `Actions` -> `Create metric filter`:

- **Create filter pattern**
  - *Filter pattern*: `ERROR`
- **Create filter name**
  - *Filter name*: `PythonErrorLogs`
- **Metric details**
  - *Metric namespace*: `LogErrors`
  - *Metric name*: `MythicalMysfits`
  - *Metric value*: `1`
  - *Default value*: `0`

10. Utiliza el endpoint `/error` para generar logs de errores en la aplicación y validar el funcionamiento de esta métrica.

```bash
curl URL_DEL_LOAD_BALANCER/error
```

- CloudWatch Metrics

11. Agregar una alarma sobre esta métrica en CloudWatch Alarms, `Create alarm`

- `Select metric`
- `LogErrors`
- `Metrics with no dimensions`
- `MythicalMysfits`
- Cambiar la estadística a `Sum`
- Cambiar el periodo a `1 minute`
- `Select metric`

Threshold

- `Greater/Equal`
- tha `1`

Notification

- `In alarm`
- `Create new topic`
- **Name**: `AlarmNotification`
- **Email**: **Introduce tu dirección de email**
- `Create topic`

- **Alarm name**: `MythicalMysfitsLogErrors`

#### Dashboard

12. Crea un nuevo dashboard llamado `MythicalMysfits` con los siguiente elementos:

- Conteo de Log Errors en gráfica y número
- Conteo de requests del load balancer en gráfica y número
- Gráfica de uso de CPU promedio en el servicio de ECS de producción
- Gráfica de uso de Memoria promedio en el servicio de ECS de producción
- Estado de las alarmas

Establecer el rango de tiempo por default a 1 hora y el periodo en 5 minutos.

## Limpieza

Eliminar el auto-escalamiento del servicio de ECS y todas las alarmas y dashboard de CloudWatch.
