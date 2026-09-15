<%--
    admin/auditoria.jsp - Consulta la bitacora de auditoria del sistema,
    con un filtro opcional por correo del usuario.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Auditoria";
    String filtroCorreo = request.getParameter("correo");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-shield-check"></i> Auditoria del sistema</h3>

<form method="get" action="<%= ctx %>/admin/auditoria.jsp" class="row g-2 mb-3">
  <div class="col-md-4">
    <input type="text" class="form-control" name="correo" placeholder="Filtrar por correo..."
           value="<%= esc(filtroCorreo) %>">
  </div>
  <div class="col-md-2">
    <button class="btn btn-primary w-100">Filtrar</button>
  </div>
</form>

<div class="card shadow-sm">
<div class="table-responsive">
  <table class="table table-sm table-hover align-middle mb-0">
    <thead class="table-dark">
      <tr><th>Fecha y hora</th><th>Usuario</th><th>Accion</th><th>Detalle</th><th>IP</th></tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        String sql =
            "SELECT a.fecha_hora, a.accion, a.detalle, a.ip_origen, u.correo "
            + "FROM auditoria a LEFT JOIN usuario u ON u.id_usuario = a.id_usuario ";
        boolean hayFiltro = filtroCorreo != null && !filtroCorreo.trim().isEmpty();
        if (hayFiltro) sql += "WHERE u.correo ILIKE ? ";
        sql += "ORDER BY a.fecha_hora DESC LIMIT 200";

        ps = con.prepareStatement(sql);
        if (hayFiltro) ps.setString(1, "%" + filtroCorreo.trim() + "%");
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
%>
      <tr>
        <td class="small"><%= rs.getTimestamp("fecha_hora") %></td>
        <td class="small"><%= rs.getString("correo") == null ? "(usuario eliminado)" : esc(rs.getString("correo")) %></td>
        <td><span class="badge text-bg-secondary"><%= esc(rs.getString("accion")) %></span></td>
        <td class="small"><%= rs.getString("detalle") == null ? "-" : esc(rs.getString("detalle")) %></td>
        <td class="small text-muted"><%= rs.getString("ip_origen") == null ? "-" : esc(rs.getString("ip_origen")) %></td>
      </tr>
<%      }
    } catch (SQLException ex) {
%>
      <tr><td colspan="5" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
      <tr><td colspan="5" class="text-center text-muted py-4">No hay registros de auditoria que coincidan.</td></tr>
<% } %>
    </tbody>
  </table>
</div>
</div>
<p class="small text-muted mt-2">Se muestran los ultimos 200 registros como máximo.</p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
