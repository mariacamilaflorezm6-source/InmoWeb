<%--
    propiedades/detalle.jsp - Ficha de detalle de una propiedad.
    Publica para cualquiera (Visitante incluido), pero los datos de
    contacto de la inmobiliaria solo se muestran si hay sesion iniciada
    (asi lo exige el enunciado: el visitante no ve datos de contacto completos).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Detalle de la propiedad";
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    boolean existe = false;
    String titulo = "", descripcion = "", ciudadNom = "", tipoNom = "", operacion = "", estado = "";
    String nombreComercial = "", telefonoContacto = "", direccionAgencia = "";
    double precio = 0, areaM2 = 0;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.titulo, p.descripcion, p.precio, p.area_m2, p.operacion, p.estado, "
            + "       c.nombre AS ciudad, t.nombre AS tipo, "
            + "       i.nombre_comercial, i.telefono_contacto, i.direccion AS direccion_agencia "
            + "FROM propiedad p "
            + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "  JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo "
            + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
            + "WHERE p.id_propiedad = ? AND p.activo = 1");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        if (rs.next()) {
            existe = true;
            titulo = rs.getString("titulo");
            descripcion = rs.getString("descripcion");
            precio = rs.getDouble("precio");
            areaM2 = rs.getDouble("area_m2");
            operacion = rs.getString("operacion");
            estado = rs.getString("estado");
            ciudadNom = rs.getString("ciudad");
            tipoNom = rs.getString("tipo");
            nombreComercial = rs.getString("nombre_comercial");
            telefonoContacto = rs.getString("telefono_contacto");
            direccionAgencia = rs.getString("direccion_agencia");
        }
        cerrar(rs, ps);
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<% if (!existe) { %>
    <div class="alert alert-warning text-center py-5">
        <i class="bi bi-exclamation-triangle fs-1"></i>
        <p class="mb-0 mt-2">Esta propiedad no existe o ya no esta disponible.</p>
        <a href="<%= ctx %>/propiedades/catalogo.jsp" class="btn btn-primary mt-3">Volver al catálogo</a>
    </div>
<% } else { %>

<a href="<%= ctx %>/propiedades/catalogo.jsp" class="btn btn-outline-secondary btn-sm mb-3">
    <i class="bi bi-arrow-left"></i> Volver al catálogo</a>

<div class="row g-4">
  <!-- ==================== GALERIA ==================== -->
  <div class="col-lg-7">
    <div id="galeria" class="carousel slide shadow-sm rounded overflow-hidden" data-bs-ride="carousel">
      <div class="carousel-inner">
<%
    Statement st = null; ResultSet rsImg = null;
    int i = 0;
    try {
        st = con.createStatement();
        rsImg = st.executeQuery(
            "SELECT url_imagen FROM imagen_propiedad WHERE id_propiedad = " + idPropiedad
            + " ORDER BY es_principal DESC, orden");
        while (rsImg.next()) {
%>
        <div class="carousel-item <%= i == 0 ? "active" : "" %>">
<%          String urlImg = rsImg.getString("url_imagen");
            if (esUrlDeImagen(urlImg)) { %>
          <img src="<%= esc(urlImagen(urlImg, ctx)) %>"
               class="d-block w-100" style="height:420px;object-fit:cover" alt="Foto <%= (i+1) %>"
               onerror="imgFallback(this,'<%= iconoTipo(tipoNom) %>','<%= colorTipo(tipoNom) %>','img-tipo-lg')">
<%          } else { %>
          <div class="img-tipo img-tipo-lg <%= colorTipo(tipoNom) %>">
            <i class="bi <%= iconoTipo(tipoNom) %>"></i>
          </div>
<%          } %>
        </div>
<%
            i++;
        }
    } catch (SQLException ex) { /* silencioso: si falla, no se muestra galeria */ }
    finally { cerrar(rsImg, st); }
    if (i == 0) {
%>
        <div class="carousel-item active">
          <div class="img-tipo img-tipo-lg <%= colorTipo(tipoNom) %>">
            <i class="bi <%= iconoTipo(tipoNom) %>"></i>
          </div>
        </div>
<%  } %>
      </div>
      <% if (i > 1) { %>
      <button class="carousel-control-prev" type="button" data-bs-target="#galeria" data-bs-slide="prev">
        <span class="carousel-control-prev-icon"></span></button>
      <button class="carousel-control-next" type="button" data-bs-target="#galeria" data-bs-slide="next">
        <span class="carousel-control-next-icon"></span></button>
      <% } %>
    </div>

    <!-- ==================== CARACTERISTICAS ==================== -->
    <div class="card shadow-sm mt-4">
      <div class="card-header bg-white fw-bold"><i class="bi bi-list-check"></i> Caracteristicas</div>
      <div class="card-body">
        <div class="row row-cols-2 row-cols-md-3 g-2">
<%
    try {
        st = con.createStatement();
        rsImg = st.executeQuery(
            "SELECT car.nombre, pc.cantidad FROM propiedad_caracteristica pc "
            + "  JOIN caracteristica car ON car.id_caracteristica = pc.id_caracteristica "
            + "WHERE pc.id_propiedad = " + idPropiedad + " ORDER BY car.nombre");
        boolean hay = false;
        while (rsImg.next()) {
            hay = true;
%>
          <div class="col">
            <i class="bi bi-check-circle text-success"></i> <%= esc(rsImg.getString("nombre")) %>
            <% if (rsImg.getInt("cantidad") > 1) { %>(x<%= rsImg.getInt("cantidad") %>)<% } %>
          </div>
<%      }
        if (!hay) { %>
          <div class="col-12 text-muted small">No se registraron caracteristicas para este inmueble.</div>
<%      }
    } catch (SQLException ex) {
        out.println("<div class='text-danger small'>" + esc(ex.getMessage()) + "</div>");
    } finally { cerrar(rsImg, st, con); }
%>
        </div>
      </div>
    </div>
  </div>

  <!-- ==================== INFO Y CONTACTO ==================== -->
  <div class="col-lg-5">
    <div class="card shadow-sm">
      <div class="card-body">
        <span class="badge text-bg-<%= "VENTA".equals(operacion) ? "success" : "info" %> mb-2">
            <%= operacion %></span>
        <span class="badge text-bg-<%= colorEstadoPropiedad(estado) %> mb-2"><%= estado %></span>
        <h3><%= esc(titulo) %></h3>
        <p class="text-muted mb-2">
            <i class="bi bi-geo-alt"></i> <%= esc(ciudadNom) %> &middot; <%= esc(tipoNom) %> &middot;
            <%= areaM2 %> m2
        </p>
        <p class="display-6 text-primary fw-bold"><%= pesos(precio) %></p>
        <p><%= esc(descripcion) %></p>

        <hr>
        <h6 class="fw-bold"><i class="bi bi-building"></i> Publicado por</h6>
<%
    if (logueado) {
%>
        <p class="mb-1"><%= esc(nombreComercial) %></p>
        <p class="mb-1 text-muted small"><i class="bi bi-telephone"></i> <%= esc(telefonoContacto) %></p>
        <p class="mb-0 text-muted small"><i class="bi bi-geo"></i> <%= esc(direccionAgencia) %></p>
<%  } else { %>
        <div class="alert alert-light border small mb-0">
            <i class="bi bi-lock"></i> Inicia sesión para ver los datos de contacto completos de la inmobiliaria.
            <a href="<%= ctx %>/login.jsp">Iniciar sesión</a>
        </div>
<%  } %>

<%
    if (logueado && "CLIENTE".equals(rolPrincipal)) {
%>
        <hr>
        <a href="<%= ctx %>/cliente/radicar_solicitud.jsp?id=<%= idPropiedad %>"
           class="btn btn-success btn-lg w-100 mb-2 fw-bold">
            <i class="bi bi-send-check"></i> <%= "VENTA".equals(operacion) ? "Comprar esta propiedad" : "Arrendar esta propiedad" %></a>
        <a href="<%= ctx %>/cliente/agendar_cita.jsp?id=<%= idPropiedad %>" class="btn btn-outline-primary w-100 mb-2">
            <i class="bi bi-calendar-plus"></i> Agendar una visita</a>
        <form method="post" action="<%= ctx %>/cliente/favorito_controlador.jsp" class="d-grid">
          <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
          <button class="btn btn-outline-danger">
              <i class="bi bi-heart"></i> Guardar en favoritos</button>
        </form>
<%  } else if (!logueado) { %>
        <hr>
        <a href="<%= ctx %>/registro.jsp" class="btn btn-success btn-lg w-100 mb-2 fw-bold">
            <i class="bi bi-send-check"></i> <%= "VENTA".equals(operacion) ? "Comprar esta propiedad" : "Arrendar esta propiedad" %></a>
        <a href="<%= ctx %>/registro.jsp" class="btn btn-outline-primary w-100 mb-2">
            <i class="bi bi-calendar-plus"></i> Agendar una visita</a>
        <a href="<%= ctx %>/registro.jsp" class="btn btn-outline-danger w-100 mb-2">
            <i class="bi bi-heart"></i> Guardar en favoritos</a>
        <p class="text-center small text-muted mb-0">
            Crea tu cuenta gratis para continuar. ¿Ya tienes una?
            <a href="<%= ctx %>/login.jsp">Inicia sesión</a>.</p>
<%  } %>
      </div>
    </div>
  </div>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
