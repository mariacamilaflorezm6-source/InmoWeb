<%--
    inmobiliaria/panel.jsp - Panel principal del agente. Resumen rapido de
    sus propiedades, citas y solicitudes, con accesos directos.
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
<h3>Hola, <%= esc(nombreSesion) %> <span class="badge text-bg-info ms-2">INMOBILIARIA</span></h3>
<p class="text-muted">Este es tu panel. Aquí administras tus propiedades, citas, solicitudes y reportes.</p>

<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int totalPropias = 0, citasPorAtender = 0, solicitudesPorRevisar = 0;
    try {
        con = abrirConexion();

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM propiedad "
            + "WHERE id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "AND activo = 1");
        ps.setInt(1, idUsuarioPanel); rs = ps.executeQuery();
        if (rs.next()) totalPropias = rs.getInt(1);
        cerrar(rs, ps);

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM cita ci JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "AND ci.estado = 'SOLICITADA'");
        ps.setInt(1, idUsuarioPanel); rs = ps.executeQuery();
        if (rs.next()) citasPorAtender = rs.getInt(1);
        cerrar(rs, ps);

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "AND s.estado = 'PENDIENTE'");
        ps.setInt(1, idUsuarioPanel); rs = ps.executeQuery();
        if (rs.next()) solicitudesPorRevisar = rs.getInt(1);
        cerrar(rs, ps);
    } catch (SQLException ex) {
%>
<div class="alert alert-danger">Error al cargar el resumen: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
%>

<div class="row g-3 mb-4">
  <div class="col-md-3 col-6">
    <a href="<%= ctx %>/inmobiliaria/propiedades.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#2E7D32,#66BB6A);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><%= totalPropias %></div>
          <div class="small"><i class="bi bi-house-gear"></i> Mis propiedades</div>
        </div>
      </div>
    </a>
  </div>
  <div class="col-md-3 col-6">
    <a href="<%= ctx %>/inmobiliaria/citas.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#B8860B,#E0A94A);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><%= citasPorAtender %></div>
          <div class="small"><i class="bi bi-calendar-event"></i> Citas por atender</div>
        </div>
      </div>
    </a>
  </div>
  <div class="col-md-3 col-6">
    <a href="<%= ctx %>/inmobiliaria/solicitudes.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#6A1B9A,#9C64C2);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><%= solicitudesPorRevisar %></div>
          <div class="small"><i class="bi bi-file-earmark-text"></i> Solicitudes por revisar</div>
        </div>
      </div>
    </a>
  </div>
  <div class="col-md-3 col-6">
    <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="text-decoration-none">
      <div class="card shadow-sm border-0 text-white h-100" style="background:linear-gradient(135deg,#1F4E78,#2E7D9E);">
        <div class="card-body">
          <div class="fs-3 fw-bold"><i class="bi bi-plus-circle"></i></div>
          <div class="small">Publicar nueva propiedad</div>
        </div>
      </div>
    </a>
  </div>
</div>

<div class="text-center">
  <a href="<%= ctx %>/inmobiliaria/reportes.jsp" class="btn btn-outline-primary">
      <i class="bi bi-graph-up"></i> Ver reportes de ventas y arriendos</a>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
