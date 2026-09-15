<%--
    index.jsp - Landing page publica de InmoWeb.
    Visible para CUALQUIERA, sin necesidad de iniciar sesion (rol Visitante).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String tituloPagina = "Inicio"; %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<!-- ================= HERO + BUSCADOR ================= -->
<div class="hero text-center" id="inicio">
  <div class="container">
    <h1 class="display-5">Encuentra el inmueble perfecto</h1>
    <p class="lead">Compra, vende o arrienda casas, apartamentos, locales y oficinas en Santander.</p>
  </div>
</div>

<div class="container buscador-flotante">
  <div class="card shadow-lg border-0">
    <div class="card-body p-4">
      <form method="get" action="<%= ctx %>/propiedades/catalogo.jsp" class="row g-3 align-items-end">
        <div class="col-md-3">
          <label class="form-label small text-muted">Ciudad</label>
          <select class="form-select" name="id_ciudad">
            <option value="">Todas</option>
<%
    Connection con = null; Statement st = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
        while (rs.next()) {
%>
            <option value="<%= rs.getInt("id_ciudad") %>"><%= esc(rs.getString("nombre")) %></option>
<%      }
        cerrar(rs);

        rs = st.executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
%>
          </select>
        </div>
        <div class="col-md-3">
          <label class="form-label small text-muted">Tipo de inmueble</label>
          <select class="form-select" name="id_tipo">
            <option value="">Todos</option>
<%
        while (rs.next()) {
%>
            <option value="<%= rs.getInt("id_tipo") %>"><%= esc(rs.getString("nombre")) %></option>
<%      }
    } catch (SQLException ex) {
        out.println("<option>Error: " + esc(ex.getMessage()) + "</option>");
    } finally { cerrar(rs, st, con); }
%>
          </select>
        </div>
        <div class="col-md-2">
          <label class="form-label small text-muted">Operacion</label>
          <select class="form-select" name="operacion">
            <option value="">Todas</option>
            <option value="VENTA">Venta</option>
            <option value="ARRIENDO">Arriendo</option>
          </select>
        </div>
        <div class="col-md-2">
          <label class="form-label small text-muted">Precio máximo</label>
          <input type="number" class="form-control" name="precio_max" placeholder="Sin limite">
        </div>
        <div class="col-md-2 d-grid">
          <button type="submit" class="btn btn-primary fw-bold">
              <i class="bi bi-search"></i> Buscar</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- ================= FRANJA DE CONFIANZA ================= -->
<div class="container mt-5">
  <div class="row g-3 text-center">
<%
    int nProp = 0, nCiudades = 0, nInmob = 0;
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT COUNT(*) FROM propiedad WHERE activo = 1 AND estado = 'DISPONIBLE'");
        if (rs.next()) nProp = rs.getInt(1);
        cerrar(rs);
        rs = st.executeQuery("SELECT COUNT(DISTINCT id_ciudad) FROM propiedad WHERE activo = 1");
        if (rs.next()) nCiudades = rs.getInt(1);
        cerrar(rs);
        rs = st.executeQuery("SELECT COUNT(*) FROM inmobiliaria");
        if (rs.next()) nInmob = rs.getInt(1);
        cerrar(rs, st, con);
    } catch (SQLException ex) { /* si falla, simplemente no se muestran cifras */ }
%>
    <div class="col-4">
      <div class="fs-2 fw-bold text-primary"><%= nProp %>+</div>
      <div class="text-muted small">Propiedades disponibles</div>
    </div>
    <div class="col-4">
      <div class="fs-2 fw-bold text-primary"><%= nCiudades %></div>
      <div class="text-muted small">Ciudades cubiertas</div>
    </div>
    <div class="col-4">
      <div class="fs-2 fw-bold text-primary"><%= nInmob %></div>
      <div class="text-muted small">Inmobiliarias aliadas</div>
    </div>
  </div>
</div>

<!-- ================= EXPLORA POR TIPO DE INMUEBLE ================= -->
<div class="container mt-5">
  <h3 class="mb-4"><i class="bi bi-grid-3x3-gap-fill text-primary"></i> Explora por tipo de inmueble</h3>
  <div class="row g-3 text-center">
<%
    String[][] tiposRapidos = {
        {"Casa", "bi-house-door-fill", "tipo-1"},
        {"Apartamento", "bi-building", "tipo-2"},
        {"Local comercial", "bi-shop", "tipo-3"},
        {"Oficina", "bi-briefcase-fill", "tipo-4"},
        {"Terreno", "bi-map-fill", "tipo-5"},
    };
    try {
        con = abrirConexion();
        ps = con.prepareStatement("SELECT id_tipo FROM tipo_propiedad WHERE nombre = ?");
        for (String[] tr : tiposRapidos) {
            ps.setString(1, tr[0]);
            rs = ps.executeQuery();
            int idTipoRapido = rs.next() ? rs.getInt(1) : 0;
            cerrar(rs);
%>
    <div class="col-6 col-md-4 col-lg-2">
      <a href="<%= ctx %>/propiedades/catalogo.jsp<%= idTipoRapido > 0 ? "?id_tipo=" + idTipoRapido : "" %>"
         class="text-decoration-none">
        <div class="card card-propiedad shadow-sm h-100">
          <div class="img-tipo <%= tr[2] %> img-tipo-sm">
            <i class="bi <%= tr[1] %>"></i>
          </div>
          <div class="card-body py-2">
            <span class="small fw-bold text-dark"><%= tr[0] %></span>
          </div>
        </div>
      </a>
    </div>
<%      }
        cerrar(ps, con);
    } catch (SQLException ex) { /* si falla, simplemente no se muestran las categorias */ }
%>
  </div>
</div>

<!-- ================= SOBRE NOSOTROS ================= -->
<div class="seccion-alterna py-5 mt-5" id="sobre-nosotros">
  <div class="container">
    <div class="row g-4 align-items-center">
      <div class="col-lg-6">
        <h3 class="mb-3"><i class="bi bi-buildings text-primary"></i> Sobre nosotros</h3>
        <p class="text-muted">
            InmoWeb es una inmobiliaria digital que ayuda a las personas a
            <b>encontrar, comprar y arrendar</b> propiedades de forma sencilla y
            confiable. Conectamos a nuestros clientes con inmobiliarias aliadas
            en distintas ciudades, para que todo el proceso —desde la búsqueda
            hasta la firma— sea claro y sin complicaciones.</p>
        <p class="text-muted mb-0">
            Nuestro equipo acompaña cada trámite para que compres, vendas o
            arriendes con la tranquilidad de estar bien asesorado.</p>
      </div>
      <div class="col-lg-6">
        <div class="row g-3 text-center">
          <div class="col-4">
            <div class="card card-nosotros shadow-sm h-100 p-3">
              <div class="icono-circulo"><i class="bi bi-shield-check"></i></div>
              <h6 class="mb-1">Confianza</h6>
              <p class="small text-muted mb-0">Inmobiliarias verificadas</p>
            </div>
          </div>
          <div class="col-4">
            <div class="card card-nosotros shadow-sm h-100 p-3">
              <div class="icono-circulo"><i class="bi bi-people"></i></div>
              <h6 class="mb-1">Acompañamiento</h6>
              <p class="small text-muted mb-0">En cada paso del proceso</p>
            </div>
          </div>
          <div class="col-4">
            <div class="card card-nosotros shadow-sm h-100 p-3">
              <div class="icono-circulo"><i class="bi bi-geo"></i></div>
              <h6 class="mb-1">Cobertura</h6>
              <p class="small text-muted mb-0">Varias ciudades de Santander</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ================= SERVICIOS ================= -->
<div class="container mt-5" id="servicios">
  <h3 class="mb-4 text-center"><i class="bi bi-gear-fill text-primary"></i> Nuestros servicios</h3>
  <div class="row g-4">
    <div class="col-md-6 col-lg-3">
      <div class="card card-servicio shadow-sm h-100 text-center p-3">
        <div class="icono-circulo"><i class="bi bi-cart-check"></i></div>
        <h6>Compra de propiedades</h6>
        <p class="small text-muted mb-0">Encuentra casas, apartamentos y locales
            listos para comprar.</p>
      </div>
    </div>
    <div class="col-md-6 col-lg-3">
      <div class="card card-servicio shadow-sm h-100 text-center p-3">
        <div class="icono-circulo"><i class="bi bi-key"></i></div>
        <h6>Arriendo de propiedades</h6>
        <p class="small text-muted mb-0">Opciones de arriendo que se ajustan a
            tu presupuesto.</p>
      </div>
    </div>
    <div class="col-md-6 col-lg-3">
      <div class="card card-servicio shadow-sm h-100 text-center p-3">
        <div class="icono-circulo"><i class="bi bi-megaphone"></i></div>
        <h6>Publicación de inmuebles</h6>
        <p class="small text-muted mb-0">Si eres inmobiliaria, publica y
            gestiona tus propiedades.</p>
      </div>
    </div>
    <div class="col-md-6 col-lg-3">
      <div class="card card-servicio shadow-sm h-100 text-center p-3">
        <div class="icono-circulo"><i class="bi bi-calendar-check"></i></div>
        <h6>Agendamiento de visitas</h6>
        <p class="small text-muted mb-0">Agenda la visita al inmueble en el
            horario que prefieras.</p>
      </div>
    </div>
  </div>
</div>

<!-- ================= COMO FUNCIONA ================= -->
<div class="container mt-5">
  <h3 class="mb-4 text-center"><i class="bi bi-signpost-split text-primary"></i> ¿Cómo funciona?</h3>
  <div class="row g-4 text-center">
    <div class="col-md-4">
      <div class="fs-1 text-primary mb-2"><i class="bi bi-search"></i></div>
      <h5>1. Busca</h5>
      <p class="text-muted small">Filtra por ciudad, tipo de inmueble, precio y características hasta
          encontrar justo lo que necesitas.</p>
    </div>
    <div class="col-md-4">
      <div class="fs-1 text-primary mb-2"><i class="bi bi-calendar-check"></i></div>
      <h5>2. Agenda una visita</h5>
      <p class="text-muted small">Con tu cuenta gratis, agenda la visita al inmueble en el horario que
          más te convenga.</p>
    </div>
    <div class="col-md-4">
      <div class="fs-1 text-primary mb-2"><i class="bi bi-file-earmark-check"></i></div>
      <h5>3. Formaliza tu compra o arriendo</h5>
      <p class="text-muted small">Radica tus documentos en línea y haz seguimiento al estado de tu
          solicitud desde tu panel.</p>
    </div>
  </div>
</div>

<!-- ================= PROPIEDADES DESTACADAS ================= -->
<div class="container mt-5" id="propiedades">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="mb-0"><i class="bi bi-star-fill text-warning"></i> Propiedades disponibles</h3>
  </div>
  <div class="row g-4">
<%
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery(
            "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.area_m2, "
            + "       c.nombre AS ciudad, t.nombre AS tipo, "
            + "       (SELECT ip.url_imagen FROM imagen_propiedad ip "
            + "         WHERE ip.id_propiedad = p.id_propiedad "
            + "         ORDER BY ip.es_principal DESC, ip.orden LIMIT 1) AS imagen "
            + "FROM propiedad p "
            + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
            + "  JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo "
            + "WHERE p.activo = 1 AND p.estado = 'DISPONIBLE' "
            + "ORDER BY p.fecha_publicacion DESC LIMIT 9");
        int total = 0;
        while (rs.next()) {
            total++;
%>
    <div class="col-md-4">
      <div class="card card-propiedad h-100 shadow-sm">
<%      String imgDestacada = rs.getString("imagen");
        if (esUrlDeImagen(imgDestacada)) { %>
        <img src="<%= esc(urlImagen(imgDestacada, ctx)) %>" class="card-img-top"
             alt="<%= esc(rs.getString("titulo")) %>"
             onerror="imgFallback(this,'<%= iconoTipo(rs.getString("tipo")) %>','<%= colorTipo(rs.getString("tipo")) %>','card-img-top')">
<%      } else { %>
        <div class="img-tipo <%= colorTipo(rs.getString("tipo")) %> card-img-top">
          <i class="bi <%= iconoTipo(rs.getString("tipo")) %>"></i>
        </div>
<%      } %>
        <div class="card-body">
          <span class="badge text-bg-<%= "VENTA".equals(rs.getString("operacion")) ? "success" : "info" %> mb-2">
              <%= rs.getString("operacion") %></span>
          <h5 class="card-title"><%= esc(rs.getString("titulo")) %></h5>
          <p class="card-text text-muted small mb-1">
              <i class="bi bi-geo-alt"></i> <%= esc(rs.getString("ciudad")) %> &middot; <%= esc(rs.getString("tipo")) %>
          </p>
          <p class="fw-bold fs-5 text-primary mb-2"><%= pesos(rs.getDouble("precio")) %></p>
          <a href="<%= ctx %>/propiedades/detalle.jsp?id=<%= rs.getInt("id_propiedad") %>"
             class="btn btn-outline-primary btn-sm w-100 fw-bold">
              <%= "VENTA".equals(rs.getString("operacion")) ? "Ver y comprar" : "Ver y arrendar" %></a>
        </div>
      </div>
    </div>
<%
        }
        if (total == 0) {
%>
    <div class="col-12">
      <div class="alert alert-secondary text-center py-4">Aun no hay propiedades publicadas.</div>
    </div>
<%
        }
    } catch (SQLException ex) {
%>
    <div class="col-12"><div class="alert alert-danger"><%= esc(ex.getMessage()) %></div></div>
<%
    } finally { cerrar(rs, st, con); }
%>
  </div>
  <div class="text-center mt-4">
    <a href="<%= ctx %>/propiedades/catalogo.jsp" class="btn btn-outline-primary btn-lg fw-bold">
        <i class="bi bi-grid-3x3-gap"></i> Ver todas las propiedades</a>
  </div>
</div>

<!-- ================= OPINIONES ================= -->
<div class="seccion-alterna py-5 mt-5" id="opiniones">
  <div class="container">
    <h3 class="mb-4 text-center"><i class="bi bi-chat-quote-fill text-primary"></i> Lo que dicen nuestros clientes</h3>
    <div class="row g-4">
      <div class="col-md-4">
        <div class="card card-opinion shadow-sm h-100 p-4">
          <div class="d-flex align-items-center mb-3">
            <div class="avatar-inicial me-3">M</div>
            <div>
              <h6 class="mb-0">Mariana Gómez</h6>
              <small class="text-muted">Compró un apartamento</small>
            </div>
          </div>
          <p class="text-muted small mb-0">
              "Encontré el apartamento ideal en pocos días. El proceso de
              agendar la visita y hacer seguimiento a mi solicitud fue muy
              claro."</p>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card card-opinion shadow-sm h-100 p-4">
          <div class="d-flex align-items-center mb-3">
            <div class="avatar-inicial me-3">J</div>
            <div>
              <h6 class="mb-0">Julián Rodríguez</h6>
              <small class="text-muted">Arrendó una oficina</small>
            </div>
          </div>
          <p class="text-muted small mb-0">
              "El catálogo con filtros me ayudó a comparar varias opciones
              rápido. Recomiendo InmoWeb para buscar oficinas en la ciudad."</p>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card card-opinion shadow-sm h-100 p-4">
          <div class="d-flex align-items-center mb-3">
            <div class="avatar-inicial me-3">L</div>
            <div>
              <h6 class="mb-0">Laura Pinzón</h6>
              <small class="text-muted">Publicó propiedades</small>
            </div>
          </div>
          <p class="text-muted small mb-0">
              "Como inmobiliaria, publicar y administrar nuestras propiedades
              desde el panel es muy sencillo y organizado."</p>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ================= HABLA CON UN ASESOR ================= -->
<div class="container mt-5" id="contacto">
  <div class="card cta-asesor text-white text-center border-0 shadow">
    <div class="card-body py-5">
      <i class="bi bi-headset fs-1 mb-2 d-block"></i>
      <h3>¿Necesitas ayuda para encontrar tu propiedad ideal?</h3>
      <p class="mb-4">Escríbenos y uno de nuestros asesores te acompañará en
          todo el proceso de compra o arriendo.</p>
      <a href="mailto:contacto@inmoweb.com" class="btn btn-light btn-lg fw-bold">
          <i class="bi bi-chat-dots"></i> Hablar con un asesor</a>
    </div>
  </div>
</div>

<!-- ================= LLAMADO A REGISTRO ================= -->
<div class="container mt-5 mb-5">
  <div class="card bg-primary text-white text-center border-0 shadow">
    <div class="card-body py-5">
      <h3>¿Vas a comprar, vender o arrendar?</h3>
      <p class="mb-4">Crea tu cuenta gratis y accede a favoritos, citas y seguimiento de tus solicitudes.</p>
      <a href="<%= ctx %>/registro.jsp" class="btn btn-light btn-lg fw-bold">
          <i class="bi bi-person-plus"></i> Crear cuenta gratis</a>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
