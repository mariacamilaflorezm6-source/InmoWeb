<%--
    inmobiliaria/propiedades.jsp - Lista SOLO las propiedades de la
    inmobiliaria que inicio sesion (nunca las de otra agencia).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mis propiedades";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0"><i class="bi bi-house-gear"></i> Mis propiedades</h3>
    <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i> Nueva propiedad</a>
</div>

<% if (msg != null) { %>
<div class="alert alert-success alert-dismissible fade show"><%= esc(msg) %>
    <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } %>
<% if (err != null) { %>
<div class="alert alert-danger alert-dismissible fade show"><%= esc(err) %>
    <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } %>

<div class="card shadow-sm">
<div class="table-responsive">
  <table class="table table-hover align-middle mb-0">
    <thead class="table-dark">
      <tr>
        <th>Matricula</th><th>Titulo</th><th>Ciudad</th><th>Tipo</th>
        <th class="text-end">Precio</th><th>Operacion</th><th>Estado</th><th></th>
      </tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.precio, "
            + "       p.operacion, p.estado, p.activo, c.nombre AS ciudad, t.nombre AS tipo "
            + "FROM propiedad p "
            + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "  JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "ORDER BY p.fecha_publicacion DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            boolean activa = rs.getBoolean("activo");
%>
      <tr class="<%= activa ? "" : "text-muted" %>">
        <td><code><%= esc(rs.getString("matricula_inmobiliaria")) %></code></td>
        <td><i class="bi <%= iconoTipo(rs.getString("tipo")) %> text-muted me-1"></i><%= esc(rs.getString("titulo")) %></td>
        <td><%= esc(rs.getString("ciudad")) %></td>
        <td><%= esc(rs.getString("tipo")) %></td>
        <td class="text-end"><%= pesos(rs.getDouble("precio")) %></td>
        <td><span class="badge text-bg-<%= "VENTA".equals(rs.getString("operacion")) ? "success" : "info" %>">
              <%= rs.getString("operacion") %></span></td>
        <td><span class="badge text-bg-<%= colorEstadoPropiedad(rs.getString("estado")) %>">
              <%= rs.getString("estado") %></span></td>
        <td class="text-end">
          <a class="btn btn-sm btn-outline-dark"
             href="<%= ctx %>/inmobiliaria/propiedad_form.jsp?id=<%= rs.getInt("id_propiedad") %>">
              <i class="bi bi-pencil"></i></a>
          <% if (activa) { %>
          <form method="post" action="<%= ctx %>/inmobiliaria/propiedad_controlador.jsp"
                class="d-inline" onsubmit="return confirm('¿Dar de baja esta propiedad?')">
            <input type="hidden" name="accion" value="baja">
            <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
            <button class="btn btn-sm btn-outline-danger"><i class="bi bi-eye-slash"></i></button>
          </form>
          <% } else { %>
          <form method="post" action="<%= ctx %>/inmobiliaria/propiedad_controlador.jsp" class="d-inline">
            <input type="hidden" name="accion" value="reactivar">
            <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
            <button class="btn btn-sm btn-outline-success"><i class="bi bi-eye"></i></button>
          </form>
          <% } %>
        </td>
      </tr>
<%      }
    } catch (SQLException ex) {
%>
      <tr><td colspan="8" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
      <tr><td colspan="8" class="text-center text-muted py-4">
          Aun no ha publicado propiedades. <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp">Cree la primera</a>.</td></tr>
<% } %>
    </tbody>
  </table>
</div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
