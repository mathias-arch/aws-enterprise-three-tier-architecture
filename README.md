# AWS 3-Tier Architecture with Terraform

Este proyecto despliega una infraestructura profesional de tres capas (Red, Aplicación y Datos) en AWS utilizando **Terraform**. Está diseñada siguiendo las mejores prácticas de seguridad, escalabilidad y alta disponibilidad.



## Resumen del Proyecto
He automatizado el despliegue de una arquitectura "Enterprise-Ready" que separa las responsabilidades en capas aisladas, garantizando que la base de datos nunca esté expuesta directamente a internet.

### Arquitectura Desplegada
* **VPC (Virtual Private Cloud):** Una red aislada con 6 subredes distribuidas en dos Zonas de Disponibilidad (Multi-AZ).
    * **2 Subredes Públicas:** Para el Balanceador de Carga (ALB) y el NAT Gateway.
    * **2 Subredes Privadas (App):** Para los servidores web (EC2) protegidos.
    * **2 Subredes Privadas (DB):** Para la base de datos gestionada (RDS).
* **Computación & Escalabilidad:**
    * **Application Load Balancer (ALB):** Distribuye el tráfico entrante de forma inteligente.
    * **Auto Scaling Group (ASG):** Mantiene siempre 2 instancias activas, con capacidad de escalar hasta 3.
* **Base de Datos:**
    * **Amazon RDS (MySQL):** Instancia de base de datos administrada y segura.
* **Conectividad Segura:**
    * **NAT Gateway:** Permite que los servidores en subredes privadas descarguen actualizaciones de internet sin recibir tráfico no solicitado.

---

## Desafíos Técnicos y Soluciones (The Debugging Journey)
Lo más valioso de este proyecto fue el proceso de resolución de problemas reales de infraestructura:

1.  **Error de Resolución de Host (`no such host`):**
    * **Problema:** Fallos en la comunicación con los endpoints de AWS por inestabilidad de red.
    * **Solución:** Se verificó la conexión y se aprovechó la **idempotencia** de Terraform para reintentar el comando sin duplicar recursos.

2.  **Disponibilidad de Instancias en Capa Gratuita:**
    * **Problema:** La instancia `t2.micro` no estaba disponible en ciertas zonas de la región `us-east-1`.
    * **Solución:** Se actualizó el código a `t3.micro`, una instancia más moderna y compatible con el Free Tier actual de AWS.

3.  **Error 502 Bad Gateway:**
    * **Problema:** El Balanceador no podía comunicar con los servidores porque el servicio Apache no arrancaba.
    * **Solución:** Se corrigió el script de `user_data` para usar `dnf` (compatible con Amazon Linux 2023) y se ajustaron las reglas de **Egress** en los Security Groups para permitir la descarga de paquetes.

---


## Comandos Principales

terraform init      # Prepara el entorno y descarga proveedores
terraform validate  # Comprueba que no hay errores de sintaxis
terraform plan      # Previsualiza la infraestructura a crear
terraform apply     # Construye la arquitectura en la nube
terraform destroy   # Elimina todos los recursos para evitar costes

---

##  Licencia

Este proyecto está bajo la **Licencia MIT**. Puedes consultar los términos legales en el siguiente enlace:

[Consultar Licencia MIT del Proyecto](./LICENSE)
