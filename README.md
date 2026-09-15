# InmoWeb - Sistema de Gestión Inmobiliaria

Proyecto académico desarrollado para la gestión integral de una plataforma inmobiliaria, aplicando arquitectura MVC, persistencia de datos y control de seguridad basado en roles.

---

## Tecnologías Utilizadas
* **Backend:** Java (JSP y Servlets aplicados exclusivamente en filtros de seguridad)
* **Frontend:** HTML5, CSS3, Bootstrap, JavaScript (Diseño 100% responsivo para computadoras, tabletas y celulares)
* **Servidor Web:** Apache Tomcat (XAMPP)
* **Base de Datos:** PostgreSQL (16 tablas normalizadas en Tercera Forma Normal - 3FN)
* **Control de Versiones:** Git / GitHub

---

## Seguridad y Control de Acceso
El sistema implementa un **Servlet Filter** para proteger las rutas privadas:
* **Intercepción de URLs:** El filtro intercepta cada solicitud HTTP antes de que llegue a los recursos protegidos.
* **Validación de Sesión y Roles:** Verifica si el usuario cuenta con una sesión activa y los permisos necesarios para acceder al módulo solicitado.
* **Redirección de Accesos No Autorizados:** Si un usuario intenta ingresar escribiendo la URL directamente sin estar autenticado o sin el rol requerido, el sistema lo bloquea y lo redirige automáticamente a una página de acceso denegado.

---

## Resumen de los Tres Sprints

### Sprint 1: Análisis, Base de Datos y Estructura Base
* Diseño y normalización de la base de datos en PostgreSQL con 16 tablas estructuradas en 3FN.
* Creación de la estructura base del proyecto web utilizando Java EE (JSP) y la integración de Bootstrap para el diseño visual responsivo.
* Configuración inicial del servidor Apache Tomcat y conexión a la base de datos mediante JDBC.

### Sprint 2: Desarrollo de Módulos y Funcionalidades Principales
* Implementación de las vistas y formularios para la gestión de inmuebles, clientes y transacciones.
* Desarrollo de la lógica en páginas JSP para el registro, consulta, actualización y eliminación de datos conectados a la base de datos.
* Pruebas de diseño adaptativo (responsive design) para garantizar una correcta visualización en computadores, tabletas y dispositivos móviles.

### Sprint 3: Seguridad, Pruebas y Entrega Final
* Desarrollo e integración del filtro de seguridad (`Filter`) en Java para la protección de rutas privadas basadas en roles de usuario.
* Validación de restricciones de URLs para impedir el acceso no autorizado mediante ingreso directo de enlaces.
* Depuración general de errores, organización del código fuente y documentación final en el repositorio público de GitHub.
