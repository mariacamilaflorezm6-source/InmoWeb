<%--
    acceso_denegado.jsp - A esta pagina redirige ControlAccesoFilter cuando
    el usuario esta autenticado pero su rol no corresponde a la ruta
    solicitada (por ejemplo, un CLIENTE intentando entrar a /admin/*).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String rolPrincipal = (String) session.getAttribute("rolPrincipal");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Acceso denegado | InmoWeb</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh">
<div class="container text-center" style="max-width:520px">
    <i class="bi bi-shield-lock display-1 text-danger"></i>
    <h2 class="mt-3">Acceso denegado</h2>
    <p class="text-muted">
        Su cuenta <% if (rolPrincipal != null) { %>(rol <b><%= rolPrincipal %></b>)<% } %>
        no tiene permiso para ver esa sección. El servidor bloqueo el acceso
        antes de mostrar cualquier información, sin importar la URL que haya escrito.
    </p>
    <a href="<%= ctx %>/index.jsp" class="btn btn-primary mt-3">
        <i class="bi bi-house"></i> Volver al inicio</a>
</div>
</body>
</html>
