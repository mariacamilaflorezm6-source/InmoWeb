<%--
    admin/reportes.jsp - Consultas consolidadas de TODO el sistema:
    propiedades disponibles por ciudad, citas por estado (global) y
    solicitudes por inmobiliaria (los 3 reportes que pide el enunciado).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Reportes";
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-graph-up"></i> Reportes del sistema</h3>

<%
    Connection con = null; Statement st = null; ResultSet rs = null;
    try {
        con = abrirConexion();
%>

<!-- ==================== PROPIEDADES DISPONIBLES POR CIUDAD ==================== -->
<div class="card shadow-sm mb-4">
  <div class="card-header bg-white fw-bold"><i class="bi bi-geo-alt"></i> Propiedades disponibles por ciudad</div>
  <div class="card-body">
    <p class="small text-muted mb-2">
        <i class="bi bi-info-circle"></i> El precio promedio solo tiene en cuenta las propiedades en estado
        <span class="badge text-bg-success">DISPONIBLE</span>; por eso puede no coincidir con el promedio de
        <em>todas</em> las propiedades del catálogo (que también incluye reservadas, vendidas o arrendadas).</p>
    <table class="table table-sm mb-0">
      <thead><tr><th>Ciudad</th><th class="text-end">Disponibles</th><th class="text-end">Precio promedio</th></tr></thead>
      <tbody>
<%
        st = con.createStatement();
        rs = st.executeQuery(
            "SELECT c.nombre AS ciudad, COUNT(*) AS total, AVG(p.precio) AS promedio "
            + "FROM propiedad p JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "WHERE p.estado = 'DISPONIBLE' "
            + "GROUP BY c.nombre ORDER BY total DESC");
        int totalCiudades = 0;
        while (rs.next()) {
            totalCiudades++;
%>
      <tr>
        <td><%= esc(rs.getString("ciudad")) %></td>
        <td class="text-end"><%= rs.getInt("total") %></td>
        <td class="text-end"><%= pesos(rs.getDouble("promedio")) %></td>
      </tr>
<%      }
        cerrar(rs, st);
        if (totalCiudades == 0) { %>
      <tr><td colspan="3" class="text-center text-muted py-3">No hay propiedades disponibles.</td></tr>
<%      } %>
      </tbody>
    </table>
  </div>
</div>

<!-- ==================== CIUDADES CON MAS DE UNA PROPIEDAD PUBLICADA ====================
     Consulta de agregacion con GROUP BY + HAVING (requisito del parcial): a diferencia
     del reporte de arriba (que promedia SOLO las disponibles), esta cuenta TODAS las
     propiedades activas de cada ciudad y filtra, con HAVING, las ciudades donde la
     inmobiliaria ya tiene mas de una publicacion. Sirve para ver en que ciudades hay
     mas competencia/oferta acumulada, sin importar el estado actual del inmueble. -->
<div class="card shadow-sm mb-4">
  <div class="card-header bg-white fw-bold"><i class="bi bi-bar-chart-steps"></i> Ciudades con más de una propiedad publicada</div>
  <div class="card-body">
    <p class="small text-muted mb-2">
        <i class="bi bi-info-circle"></i> Cuenta todas las propiedades activas (no solo las
        disponibles) y solo muestra las ciudades con más de una publicación.</p>
    <table class="table table-sm mb-0">
      <thead><tr><th>Ciudad</th><th class="text-end">Propiedades publicadas</th></tr></thead>
      <tbody>
<%
        st = con.createStatement();
        rs = st.executeQuery(
            "SELECT c.nombre AS ciudad, COUNT(*) AS total "
            + "FROM propiedad p JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "WHERE p.activo = 1 "
            + "GROUP BY c.nombre "
            + "HAVING COUNT(*) > 1 "
            + "ORDER BY total DESC");
        int totalCiudadesActivas = 0;
        while (rs.next()) {
            totalCiudadesActivas++;
%>
      <tr>
        <td><%= esc(rs.getString("ciudad")) %></td>
        <td class="text-end"><%= rs.getInt("total") %></td>
      </tr>
<%      }
        cerrar(rs, st);
        if (totalCiudadesActivas == 0) { %>
      <tr><td colspan="2" class="text-center text-muted py-3">
          Todavía ninguna ciudad supera una propiedad publicada.</td></tr>
<%      } %>
      </tbody>
    </table>
  </div>
</div>

<div class="row g-4">
  <!-- ==================== CITAS POR ESTADO (GLOBAL) ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-calendar-check"></i> Citas por estado (todo el sistema)</div>
      <div class="card-body">
        <table class="table table-sm mb-0">
          <thead><tr><th>Estado</th><th class="text-end">Cantidad</th></tr></thead>
          <tbody>
<%
        st = con.createStatement();
        rs = st.executeQuery("SELECT estado, COUNT(*) AS total FROM cita GROUP BY estado ORDER BY total DESC");
        int totalCitas = 0;
        while (rs.next()) {
            totalCitas++;
%>
          <tr>
            <td><span class="badge text-bg-<%= colorEstadoTramite(rs.getString("estado")) %>"><%= rs.getString("estado") %></span></td>
            <td class="text-end"><%= rs.getInt("total") %></td>
          </tr>
<%      }
        cerrar(rs, st);
        if (totalCitas == 0) { %>
          <tr><td colspan="2" class="text-center text-muted py-3">No hay citas registradas.</td></tr>
<%      } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ==================== SOLICITUDES POR INMOBILIARIA ==================== -->
  <div class="col-lg-6">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-building"></i> Solicitudes por inmobiliaria</div>
      <div class="card-body">
        <table class="table table-sm mb-0">
          <thead><tr><th>Inmobiliaria</th><th class="text-end">Solicitudes</th><th class="text-end">Aprobadas</th></tr></thead>
          <tbody>
<%
        st = con.createStatement();
        rs = st.executeQuery(
            "SELECT i.nombre_comercial, COUNT(*) AS total, "
            + "       SUM(CASE WHEN s.estado = 'APROBADA' THEN 1 ELSE 0 END) AS aprobadas "
            + "FROM solicitud s "
            + "  JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
            + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
            + "GROUP BY i.nombre_comercial ORDER BY total DESC");
        int totalInmob = 0;
        while (rs.next()) {
            totalInmob++;
%>
          <tr>
            <td><%= esc(rs.getString("nombre_comercial")) %></td>
            <td class="text-end"><%= rs.getInt("total") %></td>
            <td class="text-end"><%= rs.getInt("aprobadas") %></td>
          </tr>
<%      }
        cerrar(rs, st, con);
        if (totalInmob == 0) { %>
          <tr><td colspan="3" class="text-center text-muted py-3">No hay solicitudes registradas.</td></tr>
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
    } finally { cerrar(rs, st, con); }
%>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
