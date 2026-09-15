<%--
    cliente/agendar_cita.jsp - Formulario para agendar una visita a una
    propiedad especifica. Protegido por el Filter (requiere rol CLIENTE).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Agendar visita";
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    String titulo = null, ciudadNom = null, direccion = null;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.titulo, p.direccion, c.nombre AS ciudad "
            + "FROM propiedad p JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "WHERE p.id_propiedad = ? AND p.activo = 1");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        if (rs.next()) {
            titulo = rs.getString("titulo");
            direccion = rs.getString("direccion");
            ciudadNom = rs.getString("ciudad");
        }
        cerrar(rs, ps, con);
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<% if (titulo == null) { %>
<div class="alert alert-warning">Esa propiedad no existe o ya no esta disponible.</div>
<% } else { %>

<h3 class="mb-3"><i class="bi bi-calendar-plus"></i> Agendar visita</h3>

<% if (request.getParameter("err") != null) { %>
<div class="alert alert-danger"><%= esc(request.getParameter("err")) %></div>
<% } %>

<div class="row justify-content-center">
<div class="col-lg-6">
  <div class="card shadow-sm">
    <div class="card-body">
      <h5><%= esc(titulo) %></h5>
      <p class="text-muted small"><i class="bi bi-geo-alt"></i> <%= esc(direccion) %>, <%= esc(ciudadNom) %></p>
      <hr>
      <form method="post" action="<%= ctx %>/cliente/cita_controlador.jsp">
        <input type="hidden" name="accion" value="crear">
        <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
        <div class="row g-3 mb-3">
          <div class="col-md-6">
            <label class="form-label">Fecha</label>
            <input type="date" class="form-control" name="fecha" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Hora</label>
            <input type="time" class="form-control" name="hora" required>
          </div>
        </div>
        <div class="mb-3">
          <label class="form-label">Observaciones (opcional)</label>
          <textarea class="form-control" name="observaciones" rows="2"
                    placeholder="Ej: prefiero en la tarde, voy con mi familia..."></textarea>
        </div>
        <div class="d-grid">
          <button class="btn btn-primary fw-bold"><i class="bi bi-calendar-check"></i> Solicitar visita</button>
        </div>
      </form>
    </div>
  </div>
</div>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
