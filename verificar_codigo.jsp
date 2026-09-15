<%--
    verificar_codigo.jsp - Pagina publica donde el usuario escribe el
    codigo de 6 digitos que le llego por correo, para desbloquear su
    cuenta de inmediato (en vez de esperar un tiempo fijo).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String correo = request.getParameter("correo");
    String error = request.getParameter("error");
    String avisoCorreo = request.getParameter("avisoCorreo");
    String mensajeError = null;
    if ("codigo".equals(error)) mensajeError = "El codigo no es correcto o ya vencio. Intente de nuevo o pida uno nuevo.";
    if ("vacio".equals(error))  mensajeError = "Escriba el codigo de 6 digitos.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Verificar código | InmoWeb</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body class="bg-dark d-flex align-items-center" style="min-height:100vh">
<div class="container" style="max-width:440px">
  <div class="card shadow-lg border-0">
    <div class="card-body p-4 text-center">
      <i class="bi bi-envelope-check display-4 text-primary"></i>
      <h4 class="mt-2 fw-bold">Verifica tu identidad</h4>
      <p class="text-muted small">
          Detectamos 3 intentos fallidos en <b><%= esc(correo) %></b>.
          Le enviamos un código de 6 digitos a ese correo.</p>

      <% if (avisoCorreo != null) { %>
      <div class="alert alert-warning small text-start">
          <i class="bi bi-exclamation-triangle"></i> No pudimos confirmar el envio del correo
          (puede que el servidor de correo no este configurado). Si no le llega en unos minutos,
          intente iniciar sesión de nuevo mas tarde.</div>
      <% } %>
      <% if (mensajeError != null) { %>
      <div class="alert alert-danger small"><%= mensajeError %></div>
      <% } %>

      <form method="post" action="<%= ctx %>/verificar_codigo_controlador.jsp" class="text-start">
        <input type="hidden" name="correo" value="<%= esc(correo) %>">
        <label class="form-label small text-muted">Código de verificación</label>
        <input type="text" class="form-control form-control-lg text-center mb-3" name="codigo"
               maxlength="6" pattern="[0-9]{6}" inputmode="numeric" placeholder="000000"
               style="letter-spacing:8px;font-size:1.5rem" required autofocus>
        <button type="submit" class="btn btn-primary w-100 fw-bold mb-2">
            <i class="bi bi-unlock"></i> Verificar y desbloquear</button>
      </form>
      <form method="post" action="<%= ctx %>/verificar_codigo_controlador.jsp?accion=reenviar">
        <input type="hidden" name="correo" value="<%= esc(correo) %>">
        <button type="submit" class="btn btn-link btn-sm">
            <i class="bi bi-arrow-repeat"></i> No me llego, reenviar código</button>
      </form>
      <a href="<%= ctx %>/login.jsp" class="small text-muted d-block mt-2">Volver al inicio de sesión</a>
    </div>
  </div>
</div>
</body>
</html>
<%!
    public String esc(String texto) {
        if (texto == null) return "";
        return texto.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
