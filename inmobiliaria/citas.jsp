<%--
    inmobiliaria/citas.jsp - Lista las citas agendadas sobre las
    propiedades de ESTA inmobiliaria, con botones para confirmar,
    rechazar o marcar como realizada.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Citas";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-calendar-check"></i> Citas de mis propiedades</h3>

<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %></div><% } %>

<div class="card shadow-sm">
<div class="table-responsive">
  <table class="table table-hover align-middle mb-0">
    <thead class="table-dark">
      <tr><th>Propiedad</th><th>Cliente</th><th>Fecha y hora</th><th>Estado</th><th>Observaciones</th><th></th></tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT ci.id_cita, ci.fecha_hora, ci.estado, ci.observaciones, "
            + "       p.titulo, pf.nombres || ' ' || pf.apellidos AS cliente, u.correo "
            + "FROM cita ci "
            + "  JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
            + "  JOIN usuario u ON u.id_usuario = ci.id_cliente "
            + "  JOIN perfil pf ON pf.id_usuario = u.id_usuario "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "ORDER BY CASE ci.estado WHEN 'SOLICITADA' THEN 1 WHEN 'CONFIRMADA' THEN 2 ELSE 3 END, "
            + "         ci.fecha_hora");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            String estado = rs.getString("estado");
%>
      <tr>
        <td><%= esc(rs.getString("titulo")) %></td>
        <td><%= esc(rs.getString("cliente")) %><br><small class="text-muted"><%= esc(rs.getString("correo")) %></small></td>
        <td><%= rs.getTimestamp("fecha_hora") %></td>
        <td><span class="badge text-bg-<%= colorEstadoTramite(estado) %>"><%= estado %></span></td>
        <td class="small text-muted"><%= rs.getString("observaciones") == null ? "-" : esc(rs.getString("observaciones")) %></td>
        <td class="text-nowrap">
<%
            if ("SOLICITADA".equals(estado)) {
%>
          <form method="post" action="<%= ctx %>/inmobiliaria/cita_controlador.jsp" class="d-inline">
            <input type="hidden" name="accion" value="confirmar">
            <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
            <button class="btn btn-sm btn-success"><i class="bi bi-check2"></i></button>
          </form>
          <form method="post" action="<%= ctx %>/inmobiliaria/cita_controlador.jsp" class="d-inline">
            <input type="hidden" name="accion" value="rechazar">
            <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
            <button class="btn btn-sm btn-outline-danger"><i class="bi bi-x"></i></button>
          </form>
<%
            } else if ("CONFIRMADA".equals(estado)) {
%>
          <form method="post" action="<%= ctx %>/inmobiliaria/cita_controlador.jsp" class="d-inline">
            <input type="hidden" name="accion" value="realizada">
            <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
            <button class="btn btn-sm btn-primary">Marcar realizada</button>
          </form>
<%
            }
%>
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
      <tr><td colspan="6" class="text-center text-muted py-4">No hay citas agendadas todavia.</td></tr>
<% } %>
    </tbody>
  </table>
</div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
