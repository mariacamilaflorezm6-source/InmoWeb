<%--
    inmobiliaria/reportes.jsp - Consultas consolidadas SOLO de las
    propiedades de esta inmobiliaria: estado del inventario, ventas y
    arriendos cerrados, citas por estado y solicitudes por estado.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Reportes";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-graph-up"></i> Reportes de mi inmobiliaria</h3>

<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
%>

<div class="row g-4 mb-4">
  <!-- ==================== INVENTARIO POR ESTADO ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-house-gear"></i> Inventario por estado</div>
      <div class="card-body">
        <table class="table table-sm mb-0">
          <thead><tr><th>Estado</th><th class="text-end">Cantidad</th><th class="text-end">Valor total</th></tr></thead>
          <tbody>
<%
        ps = con.prepareStatement(
            "SELECT estado, COUNT(*) AS total, SUM(precio) AS valor "
            + "FROM propiedad "
            + "WHERE id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "GROUP BY estado ORDER BY total DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        int totalProps = 0;
        while (rs.next()) {
            totalProps++;
%>
          <tr>
            <td><span class="badge text-bg-<%= colorEstadoPropiedad(rs.getString("estado")) %>"><%= rs.getString("estado") %></span></td>
            <td class="text-end"><%= rs.getInt("total") %></td>
            <td class="text-end"><%= pesos(rs.getDouble("valor")) %></td>
          </tr>
<%      }
        cerrar(rs, ps);
        if (totalProps == 0) { %>
          <tr><td colspan="3" class="text-center text-muted py-3">Aun no tiene propiedades publicadas.</td></tr>
<%      } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ==================== VENTAS Y ARRIENDOS CERRADOS ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-cash-coin"></i> Ventas y arriendos cerrados</div>
      <div class="card-body">
        <table class="table table-sm mb-0">
          <thead><tr><th>Tipo de negocio</th><th class="text-end">Cantidad</th><th class="text-end">Valor total</th></tr></thead>
          <tbody>
<%
        ps = con.prepareStatement(
            "SELECT estado, COUNT(*) AS total, SUM(precio) AS valor "
            + "FROM propiedad "
            + "WHERE id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "  AND estado IN ('VENDIDA','ARRENDADA') "
            + "GROUP BY estado");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        int totalCerradas = 0;
        while (rs.next()) {
            totalCerradas++;
%>
          <tr>
            <td><%= rs.getString("estado") %></td>
            <td class="text-end"><%= rs.getInt("total") %></td>
            <td class="text-end"><%= pesos(rs.getDouble("valor")) %></td>
          </tr>
<%      }
        cerrar(rs, ps);
        if (totalCerradas == 0) { %>
          <tr><td colspan="3" class="text-center text-muted py-3">Aun no ha cerrado ventas ni arriendos.</td></tr>
<%      } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<div class="row g-4">
  <!-- ==================== CITAS POR ESTADO ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-calendar-check"></i> Citas por estado</div>
      <div class="card-body">
        <table class="table table-sm mb-0">
          <thead><tr><th>Estado</th><th class="text-end">Cantidad</th></tr></thead>
          <tbody>
<%
        ps = con.prepareStatement(
            "SELECT ci.estado, COUNT(*) AS total "
            + "FROM cita ci JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "GROUP BY ci.estado ORDER BY total DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        int totalCitas = 0;
        while (rs.next()) {
            totalCitas++;
%>
          <tr>
            <td><span class="badge text-bg-<%= colorEstadoTramite(rs.getString("estado")) %>"><%= rs.getString("estado") %></span></td>
            <td class="text-end"><%= rs.getInt("total") %></td>
          </tr>
<%      }
        cerrar(rs, ps);
        if (totalCitas == 0) { %>
          <tr><td colspan="2" class="text-center text-muted py-3">Aun no tiene citas agendadas.</td></tr>
<%      } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ==================== SOLICITUDES POR ESTADO ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-file-earmark-text"></i> Solicitudes por estado</div>
      <div class="card-body">
        <table class="table table-sm mb-0">
          <thead><tr><th>Estado</th><th class="text-end">Cantidad</th></tr></thead>
          <tbody>
<%
        ps = con.prepareStatement(
            "SELECT s.estado, COUNT(*) AS total "
            + "FROM solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "GROUP BY s.estado ORDER BY total DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        int totalSol = 0;
        while (rs.next()) {
            totalSol++;
%>
          <tr>
            <td><span class="badge text-bg-<%= colorEstadoTramite(rs.getString("estado")) %>"><%= rs.getString("estado") %></span></td>
            <td class="text-end"><%= rs.getInt("total") %></td>
          </tr>
<%      }
        cerrar(rs, ps, con);
        if (totalSol == 0) { %>
          <tr><td colspan="2" class="text-center text-muted py-3">Aun no ha recibido solicitudes.</td></tr>
<%      } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
<%
    } catch (SQLException ex) {
%>
<div class="alert alert-danger">Error: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
%>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
