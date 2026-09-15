<%--
    login.jsp - Formulario de inicio de sesion. Pagina publica.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
    String mensajeError = null, mensajeOk = null;
    if ("clave".equals(error))     mensajeError = "Correo o contrasena incorrectos.";
    if ("vacio".equals(error))     mensajeError = "Escriba el correo y la contrasena.";
    if ("inactivo".equals(error))  mensajeError = "Su cuenta esta inhabilitada. Contacte al administrador.";
    if ("bloqueado".equals(error)) mensajeError = "Cuenta bloqueada temporalmente por varios intentos fallidos. Intente en unos minutos.";
    if ("sesion".equals(error))    mensajeError = "Debe iniciar sesion para continuar.";
    if ("permiso".equals(error))   mensajeError = "No tiene permisos para acceder a esa seccion.";
    if ("registrado".equals(msg))  mensajeOk = "Cuenta creada con exito. Ya puede iniciar sesion.";
    if ("desbloqueado".equals(msg)) mensajeOk = "Identidad verificada. Su cuenta quedo desbloqueada, ya puede iniciar sesion.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesión | InmoWeb</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<%= ctx %>/css/estilos.css" rel="stylesheet">
</head>
<body class="bg-dark d-flex align-items-center" style="min-height:100vh">
<div class="container" style="max-width:420px">
  <div class="card shadow-lg border-0">
    <div class="card-body p-4">
      <div class="text-center mb-4">
        <i class="bi bi-buildings display-4 text-primary"></i>
        <h4 class="mt-2 mb-0 fw-bold">InmoWeb</h4>
        <small class="text-muted">Inicia sesión en tu cuenta</small>
      </div>
      <% if (mensajeError != null) { %>
      <div class="alert alert-danger py-2"><i class="bi bi-exclamation-triangle"></i> <%= mensajeError %></div>
      <% } %>
      <% if (mensajeOk != null) { %>
      <div class="alert alert-success py-2"><i class="bi bi-check-circle"></i> <%= mensajeOk %></div>
      <% } %>
      <form method="post" action="<%= ctx %>/acceso.jsp">
        <div class="mb-3">
          <label class="form-label" for="correo">Correo</label>
          <div class="input-group">
            <span class="input-group-text"><i class="bi bi-envelope"></i></span>
            <input type="email" class="form-control" id="correo" name="correo" required autofocus>
          </div>
        </div>
        <div class="mb-4">
          <label class="form-label" for="clave">Contraseña</label>
          <div class="input-group">
            <span class="input-group-text"><i class="bi bi-key"></i></span>
            <input type="password" class="form-control" id="clave" name="clave" required>
          </div>
        </div>
        <button type="submit" class="btn btn-primary w-100 fw-bold">
            <i class="bi bi-box-arrow-in-right"></i> Ingresar</button>
      </form>
      <p class="text-center small text-muted mt-3">
          ¿No tienes cuenta? <a href="<%= ctx %>/registro.jsp">Registrate aquí</a></p>
    </div>
  </div>
</div>
</body>
</html>
