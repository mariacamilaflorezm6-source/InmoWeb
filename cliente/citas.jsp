<%--
    cliente/citas.jsp - Lista las citas agendadas por el cliente en sesion.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mis citas";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-calendar-check"></i> Mis citas</h3>

<% if (msg != null) { %>
<div class="alert alert-success"><%= esc(msg) %></div>
<% } %>
<% if (err != null) { %>
<div class="alert alert-danger"><%= esc(err) %></div>
<% } %>

<div class="card shadow-sm">
<div class="table-responsive">
  <table class="table table-hover align-middle mb-0">
    <thead class="table-dark">
      <tr><th>Propiedad</th><th>Ciudad</th><th>Fecha y hora</th><th>Estado</th><th>Observaciones</th><th></th></tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT ci.id_cita, ci.fecha_hora, ci.estado, ci.observaciones, "
            + "       p.titulo, p.id_propiedad, c.nombre AS ciudad "
            + "FROM cita ci "
            + "  JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
            + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "WHERE ci.id_cliente = ? "
            + "ORDER BY ci.fecha_hora DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            String estado = rs.getString("estado");
            boolean puedeCancelar = "SOLICITADA".equals(estado) || "CONFIRMADA".equals(estado);
%>
      <tr>
        <td>
          <a href="<%= ctx %>/propiedades/detalle.jsp?id=<%= rs.getInt("id_propiedad") %>">
              <%= esc(rs.getString("titulo")) %></a>
        </td>
        <td><%= esc(rs.getString("ciudad")) %></td>
        <td><%= rs.getTimestamp("fecha_hora") %></td>
        <td><span class="badge text-bg-<%= colorEstadoTramite(estado) %>"><%= estado %></span></td>
        <td class="small text-muted"><%= rs.getString("observaciones") == null ? "-" : esc(rs.getString("observaciones")) %></td>
        <td>
          <% if (puedeCancelar) { %>
          <form method="post" action="<%= ctx %>/cliente/cita_controlador.jsp"
                onsubmit="return confirm('¿Cancelar esta cita?')">
            <input type="hidden" name="accion" value="cancelar">
            <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
            <button class="btn btn-sm btn-outline-danger"><i class="bi bi-x-circle"></i> Cancelar</button>
          </form>
          <% } %>
        </td>
      </tr>
<%      }
    } catch (SQLException ex) {
%>
      <tr><td colspan="6" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
      <tr><td colspan="6" class="text-center text-muted py-4">
          Aun no ha agendado ninguna visita. <a href="<%= ctx %>/propiedades/catalogo.jsp">Explore el catálogo</a>.</td></tr>
<% } %>
    </tbody>
  </table>
</div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
