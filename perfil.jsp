<%--
    perfil.jsp - Edicion del perfil (relacion 1:1 usuario <-> perfil).
    Disponible para CUALQUIER rol autenticado (Cliente, Inmobiliaria o
    Administrador). Como no vive bajo /cliente/, /inmobiliaria/ ni /admin/,
    el Filter no la protege por rol; aqui solo exigimos que haya sesion,
    sin importar cual sea el rol.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mi perfil";
    if (session.getAttribute("idUsuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=sesion");
        return;
    }
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");

    String correo = "", documento = "", nombres = "", apellidos = "", telefono = "", direccion = "";
    boolean esInmobiliaria = false;
    String nombreComercial = "", nit = "", telefonoContacto = "", direccionAgencia = "";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT u.correo, p.documento, p.nombres, p.apellidos, p.telefono, p.direccion "
            + "FROM usuario u JOIN perfil p ON p.id_usuario = u.id_usuario WHERE u.id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        if (rs.next()) {
            correo = rs.getString("correo");
            documento = rs.getString("documento");
            nombres = rs.getString("nombres");
            apellidos = rs.getString("apellidos");
            telefono = rs.getString("telefono");
            direccion = rs.getString("direccion");
        }
        cerrar(rs, ps);

        // Si ademas administra una agencia, tambien cargamos esos datos
        ps = con.prepareStatement(
            "SELECT nombre_comercial, nit, telefono_contacto, direccion FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        if (rs.next()) {
            esInmobiliaria = true;
            nombreComercial = rs.getString("nombre_comercial");
            nit = rs.getString("nit");
            telefonoContacto = rs.getString("telefono_contacto");
            direccionAgencia = rs.getString("direccion");
        }
        cerrar(rs, ps);
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-person-circle"></i> Mi perfil</h3>

<% if (msg != null) { %>
<div class="alert alert-success"><%= esc(msg) %></div>
<% } %>
<% if (err != null) { %>
<div class="alert alert-danger"><%= esc(err) %></div>
<% } %>
<% if (request.getAttribute("errorBD") != null) { %>
<div class="alert alert-danger">Error: <%= esc((String) request.getAttribute("errorBD")) %></div>
<% } %>

<div class="row g-4">
  <!-- ==================== DATOS PERSONALES ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm">
      <div class="card-header bg-white fw-bold"><i class="bi bi-person"></i> Datos personales</div>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/perfil_controlador.jsp">
          <input type="hidden" name="accion" value="datos">
          <div class="mb-3">
            <label class="form-label">Correo (no se puede cambiar)</label>
            <input type="email" class="form-control" value="<%= esc(correo) %>" disabled>
          </div>
          <div class="row g-2 mb-3">
            <div class="col-6">
              <label class="form-label">Documento</label>
              <input type="text" class="form-control" name="documento" required maxlength="20"
                     value="<%= esc(documento) %>">
            </div>
            <div class="col-6">
              <label class="form-label">Teléfono</label>
              <input type="tel" class="form-control" name="telefono" required
                     pattern="[0-9]{7,15}" value="<%= esc(telefono) %>">
            </div>
          </div>
          <div class="row g-2 mb-3">
            <div class="col-6">
              <label class="form-label">Nombres</label>
              <input type="text" class="form-control" name="nombres" required maxlength="60"
                     value="<%= esc(nombres) %>">
            </div>
            <div class="col-6">
              <label class="form-label">Apellidos</label>
              <input type="text" class="form-control" name="apellidos" required maxlength="60"
                     value="<%= esc(apellidos) %>">
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label">Dirección</label>
            <input type="text" class="form-control" name="direccion" maxlength="150"
                   value="<%= esc(direccion) %>">
          </div>
          <div class="d-grid">
            <button class="btn btn-primary fw-bold"><i class="bi bi-save"></i> Guardar datos personales</button>
          </div>
        </form>
      </div>
    </div>

<% if (esInmobiliaria) { %>
    <!-- ==================== DATOS DE LA AGENCIA (solo INMOBILIARIA) ==================== -->
    <div class="card shadow-sm mt-4">
      <div class="card-header bg-white fw-bold"><i class="bi bi-building"></i> Datos de mi agencia</div>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/perfil_controlador.jsp">
          <input type="hidden" name="accion" value="agencia">
          <div class="mb-3">
            <label class="form-label">NIT (no se puede cambiar)</label>
            <input type="text" class="form-control" value="<%= esc(nit) %>" disabled>
          </div>
          <div class="mb-3">
            <label class="form-label">Nombre comercial</label>
            <input type="text" class="form-control" name="nombre_comercial" required maxlength="100"
                   value="<%= esc(nombreComercial) %>">
          </div>
          <div class="mb-3">
            <label class="form-label">Teléfono de contacto</label>
            <input type="tel" class="form-control" name="telefono_contacto" required
                   value="<%= esc(telefonoContacto) %>">
          </div>
          <div class="mb-3">
            <label class="form-label">Dirección de la agencia</label>
            <input type="text" class="form-control" name="direccion_agencia" maxlength="150"
                   value="<%= esc(direccionAgencia) %>">
          </div>
          <div class="d-grid">
            <button class="btn btn-primary fw-bold"><i class="bi bi-save"></i> Guardar datos de la agencia</button>
          </div>
        </form>
      </div>
    </div>
<% } %>
  </div>

  <!-- ==================== CAMBIAR CONTRASENA ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm">
      <div class="card-header bg-white fw-bold"><i class="bi bi-key"></i> Cambiar contraseña</div>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/perfil_controlador.jsp">
          <input type="hidden" name="accion" value="clave">
          <div class="mb-3">
            <label class="form-label">Contraseña actual</label>
            <input type="password" class="form-control" name="clave_actual" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Contraseña nueva</label>
            <input type="password" class="form-control" name="clave_nueva" required minlength="6">
          </div>
          <div class="mb-3">
            <label class="form-label">Confirmar contraseña nueva</label>
            <input type="password" class="form-control" name="clave_confirmar" required minlength="6">
          </div>
          <div class="d-grid">
            <button class="btn btn-outline-primary fw-bold"><i class="bi bi-shield-lock"></i> Cambiar contraseña</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
