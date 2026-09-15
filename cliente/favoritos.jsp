<%--
    cliente/favoritos.jsp - Muestra las propiedades que el cliente en sesion
    ha marcado como favoritas (relacion N:M usuario<->propiedad, resuelta
    en la tabla intermedia "favorito"). Cada tarjeta permite ir al detalle
    o quitarla directamente de favoritos.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mis favoritos";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-heart-fill text-danger"></i> Mis favoritos</h3>

<% if ("agregado_a_favoritos".equals(msg)) { %>
<div class="alert alert-success alert-dismissible fade show">Propiedad agregada a tus favoritos.
    <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } else if ("quitado_de_favoritos".equals(msg)) { %>
<div class="alert alert-info alert-dismissible fade show">Propiedad quitada de tus favoritos.
    <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } %>
<% if (err != null) { %>
<div class="alert alert-danger"><%= esc(err) %></div>
<% } %>

<div class="row g-3">
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int total = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, p.area_m2, "
            + "       c.nombre AS ciudad, t.nombre AS tipo, f.fecha_agregado, "
            + "       (SELECT ip.url_imagen FROM imagen_propiedad ip "
            + "         WHERE ip.id_propiedad = p.id_propiedad "
            + "         ORDER BY ip.es_principal DESC, ip.orden LIMIT 1) AS imagen "
            + "FROM favorito f "
            + "  JOIN propiedad p ON p.id_propiedad = f.id_propiedad "
            + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "  JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo "
            + "WHERE f.id_usuario = ? "
            + "ORDER BY f.fecha_agregado DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        while (rs.next()) {
            total++;
            String imgFav = rs.getString("imagen");
%>
  <div class="col-12 col-sm-6 col-xl-4">
    <div class="card card-propiedad h-100 shadow-sm">
<%      if (esUrlDeImagen(imgFav)) { %>
      <img src="<%= esc(urlImagen(imgFav, ctx)) %>" class="card-img-top"
           alt="<%= esc(rs.getString("titulo")) %>"
           onerror="imgFallback(this,'<%= iconoTipo(rs.getString("tipo")) %>','<%= colorTipo(rs.getString("tipo")) %>','card-img-top')">
<%      } else { %>
      <div class="img-tipo <%= colorTipo(rs.getString("tipo")) %> card-img-top">
        <i class="bi <%= iconoTipo(rs.getString("tipo")) %>"></i>
      </div>
<%      } %>
      <div class="card-body d-flex flex-column">
        <span class="badge text-bg-<%= "VENTA".equals(rs.getString("operacion")) ? "success" : "info" %> mb-2 align-self-start">
            <%= rs.getString("operacion") %></span>
        <span class="badge text-bg-<%= colorEstadoPropiedad(rs.getString("estado")) %> mb-2 align-self-start ms-1">
            <%= rs.getString("estado") %></span>
        <h6 class="card-title"><%= esc(rs.getString("titulo")) %></h6>
        <p class="card-text text-muted small mb-1">
            <i class="bi bi-geo-alt"></i> <%= esc(rs.getString("ciudad")) %> &middot;
            <%= esc(rs.getString("tipo")) %> &middot; <%= rs.getDouble("area_m2") %> m2
        </p>
        <p class="fw-bold fs-5 text-primary mb-2"><%= pesos(rs.getDouble("precio")) %></p>
        <div class="mt-auto d-flex gap-2">
          <a href="<%= ctx %>/propiedades/detalle.jsp?id=<%= rs.getInt("id_propiedad") %>"
             class="btn btn-outline-primary btn-sm flex-fill">Ver detalle</a>
          <form method="post" action="<%= ctx %>/cliente/favorito_controlador.jsp">
            <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
            <input type="hidden" name="origen" value="favoritos">
            <button class="btn btn-outline-danger btn-sm" title="Quitar de favoritos">
                <i class="bi bi-heartbreak"></i></button>
          </form>
        </div>
      </div>
    </div>
  </div>
<%      }
    } catch (SQLException ex) {
%>
  <div class="col-12"><div class="alert alert-danger">Error: <%= esc(ex.getMessage()) %></div></div>
<%
    } finally { cerrar(rs, ps, con); }
    if (total == 0) {
%>
  <div class="col-12">
    <div class="alert alert-secondary text-center py-5">
        <i class="bi bi-heart fs-1"></i>
        <p class="mb-3 mt-2">Aún no has marcado propiedades como favoritas.</p>
        <a href="<%= ctx %>/propiedades/catalogo.jsp" class="btn btn-primary btn-sm">
            <i class="bi bi-search"></i> Explorar el catálogo</a>
    </div>
  </div>
<%  } %>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
