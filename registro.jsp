<%--
    registro.jsp - Formulario publico de registro.
    Permite crear una cuenta como CLIENTE o como INMOBILIARIA.
    Segun la opcion elegida, muestra/oculta los campos propios de la agencia
    (nombre comercial, NIT) con JavaScript sencillo (sin frameworks extra).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String error = request.getParameter("error");
    String mensaje = null;
    if ("correo".equals(error))     mensaje = "Ese correo ya esta registrado.";
    if ("nit".equals(error))        mensaje = "Ese NIT ya esta registrado.";
    if ("documento".equals(error))  mensaje = "Ese documento ya esta registrado.";
    if ("clave".equals(error))      mensaje = "Las contrasenas no coinciden o son muy cortas (minimo 6 caracteres).";
    if ("campos".equals(error))     mensaje = "Complete todos los campos obligatorios con un formato valido.";
    if ("bd".equals(error))         mensaje = "No se pudo completar el registro. Intente de nuevo.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Crear cuenta | InmoWeb</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<%= ctx %>/css/estilos.css" rel="stylesheet">
</head>
<body class="bg-light py-5">
<div class="container" style="max-width:640px">
  <div class="text-center mb-4">
    <i class="bi bi-buildings display-5 text-primary"></i>
    <h3 class="fw-bold mt-2">Crear cuenta en InmoWeb</h3>
  </div>

  <% if (mensaje != null) { %>
  <div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i> <%= mensaje %></div>
  <% } %>

  <div class="card shadow-sm">
    <div class="card-body p-4">
      <form method="post" action="<%= ctx %>/registrar_controlador.jsp" id="formRegistro">

        <!-- ============ Tipo de cuenta ============ -->
        <label class="form-label fw-bold">¿Como te vas a registrar?</label>
        <div class="btn-group w-100 mb-4" role="group">
          <input type="radio" class="btn-check" name="tipo_cuenta" id="tipoCliente" value="CLIENTE" checked>
          <label class="btn btn-outline-primary" for="tipoCliente"><i class="bi bi-person"></i> Cliente</label>

          <input type="radio" class="btn-check" name="tipo_cuenta" id="tipoInmobiliaria" value="INMOBILIARIA">
          <label class="btn btn-outline-primary" for="tipoInmobiliaria"><i class="bi bi-building"></i> Inmobiliaria</label>
        </div>

        <!-- ============ Datos de acceso ============ -->
        <div class="row g-3 mb-2">
          <div class="col-md-6">
            <label class="form-label" for="correo">Correo electrónico</label>
            <input type="email" class="form-control" id="correo" name="correo" required
                   placeholder="correo@ejemplo.com">
          </div>
          <div class="col-md-6">
            <label class="form-label" for="telefono">Teléfono</label>
            <input type="tel" class="form-control" id="telefono" name="telefono" required
                   pattern="[0-9]{7,15}" placeholder="3001234567">
          </div>
        </div>
        <div class="row g-3 mb-2">
          <div class="col-md-6">
            <label class="form-label" for="clave">Contraseña</label>
            <input type="password" class="form-control" id="clave" name="clave" required minlength="6">
          </div>
          <div class="col-md-6">
            <label class="form-label" for="confirmar">Confirmar contraseña</label>
            <input type="password" class="form-control" id="confirmar" name="confirmar" required minlength="6">
          </div>
        </div>

        <hr class="my-4">

        <!-- ============ Datos personales (perfil) ============ -->
        <div class="row g-3 mb-2">
          <div class="col-md-4">
            <label class="form-label" for="documento">Documento</label>
            <input type="text" class="form-control" id="documento" name="documento" required maxlength="20">
          </div>
          <div class="col-md-4">
            <label class="form-label" for="nombres">Nombres</label>
            <input type="text" class="form-control" id="nombres" name="nombres" required maxlength="60">
          </div>
          <div class="col-md-4">
            <label class="form-label" for="apellidos">Apellidos</label>
            <input type="text" class="form-control" id="apellidos" name="apellidos" required maxlength="60">
          </div>
        </div>
        <div class="mb-2">
          <label class="form-label" for="direccion">Dirección</label>
          <input type="text" class="form-control" id="direccion" name="direccion" maxlength="150">
        </div>

        <!-- ============ Datos de la inmobiliaria (solo si aplica) ============ -->
        <div id="bloqueInmobiliaria" class="d-none">
          <hr class="my-4">
          <p class="fw-bold text-primary"><i class="bi bi-building"></i> Datos de la agencia</p>
          <div class="row g-3 mb-2">
            <div class="col-md-7">
              <label class="form-label" for="nombre_comercial">Nombre comercial</label>
              <input type="text" class="form-control" id="nombre_comercial" name="nombre_comercial" maxlength="100">
            </div>
            <div class="col-md-5">
              <label class="form-label" for="nit">NIT</label>
              <input type="text" class="form-control" id="nit" name="nit" maxlength="20">
            </div>
          </div>
          <div class="mb-2">
            <label class="form-label" for="direccion_comercial">Dirección de la agencia</label>
            <input type="text" class="form-control" id="direccion_comercial" name="direccion_comercial" maxlength="150">
          </div>
        </div>

        <div class="d-grid mt-4">
          <button type="submit" class="btn btn-primary btn-lg fw-bold">
              <i class="bi bi-check2-circle"></i> Crear cuenta</button>
        </div>
      </form>
      <p class="text-center small text-muted mt-3">
          ¿Ya tienes cuenta? <a href="<%= ctx %>/login.jsp">Inicia sesión aquí</a></p>
    </div>
  </div>
</div>

<script>
// Muestra/oculta los campos de la agencia segun el tipo de cuenta elegido.
// Es JavaScript plano del lado del navegador: solo mejora la experiencia,
// la validacion real y obligatoria siempre se hace en el servidor
// (registrar_controlador.jsp), tal como exige el enunciado.
var radios = document.getElementsByName('tipo_cuenta');
var bloque = document.getElementById('bloqueInmobiliaria');
var camposInmobiliaria = ['nombre_comercial', 'nit', 'direccion_comercial'];

function actualizarBloque() {
    var esInmobiliaria = document.getElementById('tipoInmobiliaria').checked;
    bloque.classList.toggle('d-none', !esInmobiliaria);
    camposInmobiliaria.forEach(function (id) {
        document.getElementById(id).required = esInmobiliaria;
    });
}
radios.forEach(function (r) { r.addEventListener('change', actualizarBloque); });
actualizarBloque();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
