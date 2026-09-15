<%--
    admin/panel.jsp - Panel principal del administrador. Muestra un resumen
    rapido del sistema (conteos) y accesos directos a las secciones que ya
    existen (usuarios, catalogos, reportes, auditoria).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Panel de administración";
    if (session.getAttribute("idUsuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=sesion");
        return;
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h3>Hola, <%= esc(nombreSesion) %> <span class="badge text-bg-info ms-2">ADMINISTRADOR</span></h3>
<p class="text-muted">Este es tu panel. Desde aquí gestionas usuarios, roles, catálogos y la auditoría del sistema.</p>

<%
    Connection con = null; Statement st = null; ResultSet rs = null;
    int totalUsuarios = 0, totalPropiedades = 0, citasPendientes = 0, solicitudesPendientes = 0;
    try {
        con = abrirConexion();
        st = con.createStatement();

        rs = st.executeQuery("SELECT COUNT(*) FROM usuario WHERE activo = 1");
        if (rs.next()) totalUsuarios = rs.getInt(1);
        cerrar(rs);

        rs = st.executeQuery("SELECT COUNT(*) FROM propiedad WHERE activo = 1");
        if (rs.next()) totalPropiedades = rs.getInt(1);
        cerrar(rs);

        rs = st.executeQuery("SELECT COUNT(*) FROM cita WHERE estado = 'SOLICITADA'");
        if (rs.next()) citasPendientes = rs.getInt(1);
        cerrar(rs);

        rs = st.executeQuery("SELECT COUNT(*) FROM solicitud WHERE estado = 'PENDIENTE'");
        if (rs.next()) solicitudesPendientes = rs.getInt(1);
        cerrar(rs, st);
    } catch (SQLException ex) {
%>
<div class="alert alert-danger">Error al cargar el resumen: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, st, con); }
%>

<!-- ==================== TARJETAS DE RESUMEN ==================== -->
<div class="row g-3 mb-4">
  <div class="col-6 col-lg-3">
    <div class="card shadow-sm border-0 text-white" style="background:linear-gradient(135deg,#1F4E78,#2E7D9E);">
      <div class="card-body">
        <div class="fs-3 fw-bold"><%= totalUsuarios %></div>
        <div class="small"><i class="bi bi-people"></i> Usuarios activos</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="card shadow-sm border-0 text-white" style="background:linear-gradient(135deg,#2E7D32,#66BB6A);">
      <div class="card-body">
        <div class="fs-3 fw-bold"><%= totalPropiedades %></div>
        <div class="small"><i class="bi bi-houses"></i> Propiedades publicadas</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="card shadow-sm border-0 text-white" style="background:linear-gradient(135deg,#B8860B,#E0A94A);">
      <div class="card-body">
        <div class="fs-3 fw-bold"><%= citasPendientes %></div>
        <div class="small"><i class="bi bi-calendar-event"></i> Citas por confirmar</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="card shadow-sm border-0 text-white" style="background:linear-gradient(135deg,#6A1B9A,#9C64C2);">
      <div class="card-body">
        <div class="fs-3 fw-bold"><%= solicitudesPendientes %></div>
        <div class="small"><i class="bi bi-file-earmark-text"></i> Solicitudes pendientes</div>
      </div>
    </div>
  </div>
</div>

<!-- ==================== ACCESOS DIRECTOS ==================== -->
<h5 class="mb-3">Secciones del administrador</h5>
<div class="row g-3">
  <div class="col-md-6 col-lg-3">
    <a href="<%= ctx %>/admin/usuarios.jsp" class="text-decoration-none">
      <div class="card shadow-sm h-100 text-center py-4 card-propiedad">
        <i class="bi bi-people fs-1 text-primary"></i>
        <div class="fw-bold mt-2">Usuarios</div>
        <p class="small text-muted mb-0 px-2">Asignar roles, activar o inhabilitar cuentas</p>
      </div>
    </a>
  </div>
  <div class="col-md-6 col-lg-3">
    <a href="<%= ctx %>/admin/catalogos.jsp" class="text-decoration-none">
      <div class="card shadow-sm h-100 text-center py-4 card-propiedad">
        <i class="bi bi-tags fs-1 text-success"></i>
        <div class="fw-bold mt-2">Catálogos</div>
        <p class="small text-muted mb-0 px-2">Ciudades, tipos de inmueble y características</p>
      </div>
    </a>
  </div>
  <div class="col-md-6 col-lg-3">
    <a href="<%= ctx %>/admin/reportes.jsp" class="text-decoration-none">
      <div class="card shadow-sm h-100 text-center py-4 card-propiedad">
        <i class="bi bi-graph-up fs-1 text-warning"></i>
        <div class="fw-bold mt-2">Reportes</div>
        <p class="small text-muted mb-0 px-2">Consultas consolidadas de todo el sistema</p>
      </div>
    </a>
  </div>
  <div class="col-md-6 col-lg-3">
    <a href="<%= ctx %>/admin/auditoria.jsp" class="text-decoration-none">
      <div class="card shadow-sm h-100 text-center py-4 card-propiedad">
        <i class="bi bi-shield-check fs-1 text-secondary"></i>
        <div class="fw-bold mt-2">Auditoría</div>
        <p class="small text-muted mb-0 px-2">Historial de accesos y cambios del sistema</p>
      </div>
    </a>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
