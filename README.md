# InmoWeb - Sistema de Gestión Inmobiliaria

InmoWeb es una aplicación web desarrollada para la gestión integral de inmuebles, agendamiento de citas, radicación de solicitudes y control de usuarios bajo un esquema de roles.

## Tecnologías Utilizadas
* **Backend:** Java (Servlets, JSP)
* **Frontend:** HTML5, CSS3, Bootstrap, JavaScript
* **Servidor Web:** Apache Tomcat (XAMPP)
* **Base de Datos:** PostgreSQL (16 tablas normalizadas en 3FN)

## Arquitectura del Sistema
El proyecto sigue el patrón de diseño **MVC (Modelo-Vista-Controlador)**:
1. **Vista:** Páginas JSP y fragmentos modulares (`.jspf`) encargados de la interfaz de usuario.
2. **Controlador:** Archivos de control y Filtros (`ControlAccesoFilter`) para la gestión de rutas y seguridad.
3. **Modelo:** Estructura relacional en PostgreSQL y conexión centralizada para el manejo de consultas y transacciones de datos.

## 📊 Estructura de la Base de Datos
El esquema consta de **16 tablas** diseñadas bajo estrictos principios relacionales:
* **Seguridad y Usuarios:** `rol`, `usuario`, `usuario_rol`, `perfil`, `inmobiliaria`, `auditoria`
* **Catálogos y Propiedades:** `ciudad`, `tipo_propiedad`, `propiedad`, `imagen_propiedad`, `caracteristica`, `propiedad_caracteristica`
* **Transacciones:** `cita`, `solicitud`, `documento_solicitud`, `favorito`

## 👥 Autor
* **Maria Camila**
