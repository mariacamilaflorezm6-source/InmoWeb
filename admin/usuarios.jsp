<%--
    admin/usuarios.jsp - Gestion de usuarios: activar/desactivar cuentas
    y asignar/revocar roles (relacion N:M usuario_rol).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Usuarios";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-people"></i> Gestión de usuarios</h3>
<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %></div><% } %>

<%
    Connection con = null; Statement st = null; ResultSet rs = null;
    // Trae los 3 roles una sola vez para dibujar los checkboxes en cada fila
    java.util.List<int[]> rolesDisponibles = new java.util.ArrayList<int[]>();
    java.util.Map<Integer,String> nombreRol = new java.util.HashMap<Integer,String>();
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT id_rol, nombre FROM rol ORDER BY id_rol");
        while (rs.next()) {
            nombreRol.put(rs.getInt("id_rol"), rs.getString("nombre"));
        }
        cerrar(rs);
%>
<div class="card shadow-sm">
<div class="table-responsive">
  <table class="table table-hover align-middle mb-0">
    <thead class="table-dark">
      <tr><th>Correo</th><th>Nombre</th><th>Roles</th><th>Estado</th><th></th></tr>
    </thead>
    <tbody>
<%
        rs = st.executeQuery(
            "SELECT u.id_usuario, u.correo, u.activo, "
            + "       COALESCE(pf.nombres || ' ' || pf.apellidos, '(sin perfil)') AS nombre "
            + "FROM usuario u LEFT JOIN perfil pf ON pf.id_usuario = u.id_usuario "
            + "ORDER BY u.id_usuario");
        while (rs.next()) {
            int idUsuarioFila = rs.getInt("id_usuario");
            boolean activo = rs.getBoolean("activo");

            java.util.Set<Integer> rolesUsuario = new java.util.HashSet<Integer>();
            PreparedStatement psRol = con.prepareStatement(
                "SELECT id_rol FROM usuario_rol WHERE id_usuario = ?");
            psRol.setInt(1, idUsuarioFila);
            ResultSet rsRol = psRol.executeQuery();
            while (rsRol.next()) rolesUsuario.add(rsRol.getInt("id_rol"));
            cerrar(rsRol, psRol);
%>
      <tr class="<%= activo ? "" : "text-muted" %>">
        <td><%= esc(rs.getString("correo")) %></td>
        <td><%= esc(rs.getString("nombre")) %></td>
        <td>
          <form method="post" action="<%= ctx %>/admin/usuario_controlador.jsp" class="d-flex flex-wrap gap-2 align-items-center">
            <input type="hidden" name="accion" value="guardar_roles">
            <input type="hidden" name="id_usuario" value="<%= idUsuarioFila %>">
<%
            for (java.util.Map.Entry<Integer,String> e : nombreRol.entrySet()) {
                int idRol = e.getKey();
                boolean marcado = rolesUsuario.contains(idRol);
%>
            <div class="form-check form-check-inline m-0">
              <input class="form-check-input" type="checkbox" name="rol" value="<%= idRol %>"
                     id="r<%= idUsuarioFila %>_<%= idRol %>" <%= marcado ? "checked" : "" %>>
              <label class="form-check-label small" for="r<%= idUsuarioFila %>_<%= idRol %>">
                  <%= e.getValue() %></label>
            </div>
<%          } %>
            <button class="btn btn-sm btn-outline-primary">Guardar</button>
          </form>
        </td>
        <td><span class="badge text-bg-<%= activo ? "success" : "secondary" %>">
              <%= activo ? "ACTIVO" : "INACTIVO" %></span></td>
        <td>
          <form method="post" action="<%= ctx %>/admin/usuario_controlador.jsp"
                onsubmit="return confirm('¿<%= activo ? "Desactivar" : "Activar" %> esta cuenta?')">
            <input type="hidden" name="accion" value="toggle_activo">
            <input type="hidden" name="id_usuario" value="<%= idUsuarioFila %>">
            <button class="btn btn-sm btn-outline-<%= activo ? "danger" : "success" %>">
                <i class="bi bi-power"></i></button>
          </form>
        </td>
      </tr>
<%      }
    } catch (SQLException ex) {
%>
      <tr><td colspan="5" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, st, con); }
%>
    </tbody>
  </table>
</div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
