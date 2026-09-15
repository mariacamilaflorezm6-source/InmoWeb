<%--
    cliente/panel.jsp - Panel principal del cliente. Resumen rapido de su
    actividad (favoritos, citas y solicitudes) con accesos directos.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mi panel";
    if (session.getAttribute("idUsuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=sesion");
        return;
    }
    int idUsuarioPanel = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h3>Hola, <%= esc(nombreSesion) %> <span class="badge text-bg-info ms-2">CLIENTE</span></h3>
<p class="text-muted">Este es tu panel. Aquí ves tus favoritos, tus citas agendadas y el estado de tus solicitudes.</p>

<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int totalFavoritos = 0, citasActivas = 0, solicitudesPendientesCliente = 0;
    try {
        con = abrirConexion();

        ps = con.prepareStatement("SELECT COUNT(*) FROM favorito WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioPanel); rs = ps.executeQuery();
        if (rs.next()) totalFavoritos = rs.getInt(1);
        cerrar(rs, ps);

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM cita WHERE id_cliente = ? AND estado IN ('SOLICITADA','CONFIRMADA')");
        ps.setInt(1, idUsuarioPanel); rs = ps.executeQuery();
        if (rs.next()) citasActivas = rs.getInt(1);
        cerrar(rs, ps);

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM solicitud WHERE id_cliente = ? AND estado = 'PENDIENTE'");
        ps.setInt(1, idUsuarioPanel); rs = ps.executeQuery();
        if (rs.next()) solicitudesPendientesCliente = rs.getInt(1);
        cerrar(rs, ps);
    } catch (SQLException ex) {
%>
<div class="alert alert-danger">Error al cargar el resumen: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
%>

<div class="row g-3 mb-4">
  <div class="col-md-4">
    <a href="<%= ctx %>/cliente/favoritos.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#AD1457,#E0568C);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><%= totalFavoritos %></div>
          <div class="small"><i class="bi bi-heart-fill"></i> Propiedades favoritas</div>
        </div>
      </div>
    </a>
  </div>
  <div class="col-md-4">
    <a href="<%= ctx %>/cliente/citas.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#1F4E78,#2E7D9E);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><%= citasActivas %></div>
          <div class="small"><i class="bi bi-calendar-check"></i> Citas activas</div>
        </div>
      </div>
    </a>
  </div>
  <div class="col-md-4">
    <a href="<%= ctx %>/cliente/solicitudes.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#B8860B,#E0A94A);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><%= solicitudesPendientesCliente %></div>
          <div class="small"><i class="bi bi-file-earmark-text"></i> Solicitudes pendientes</div>
        </div>
      </div>
    </a>
  </div>
</div>

<div class="card shadow-sm border-0 bg-light">
  <div class="card-body text-center py-4">
    <i class="bi bi-search fs-2 text-primary"></i>
    <p class="mb-3 mt-2">¿Buscando tu próximo hogar o local? Explora el catálogo completo.</p>
    <a href="<%= ctx %>/propiedades/catalogo.jsp" class="btn btn-primary">
        <i class="bi bi-houses"></i> Ver catálogo de propiedades</a>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
