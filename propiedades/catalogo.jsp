<%--
    propiedades/catalogo.jsp - Listado publico de propiedades con filtros.
    Accesible para Visitante, Cliente, Inmobiliaria y Administrador
    (esta ruta NO empieza por /cliente/, /inmobiliaria/ ni /admin/, asi que
    el Filter de seguridad la deja pasar libremente).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Catalogo de propiedades";

    // ---------- Leer filtros de la URL (todos opcionales) ----------
    String idCiudadTxt = request.getParameter("id_ciudad");
    String idTipoTxt   = request.getParameter("id_tipo");
    String operacion   = request.getParameter("operacion");
    String precioMaxTxt = request.getParameter("precio_max");
    String texto       = request.getParameter("q");
    String[] caracteristicasSel = request.getParameterValues("caracteristica");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row g-4">
  <!-- ==================== PANEL DE FILTROS ==================== -->
  <div class="col-lg-3">
    <div class="card shadow-sm">
      <div class="card-header bg-white fw-bold"><i class="bi bi-funnel"></i> Filtros</div>
      <div class="card-body">
        <form method="get" action="<%= ctx %>/propiedades/catalogo.jsp">
          <div class="mb-3">
            <label class="form-label small text-muted">Buscar por palabra clave</label>
            <input type="text" class="form-control form-control-sm" name="q"
                   value="<%= esc(texto) %>" placeholder="Ej: apartamento, casa...">
          </div>
          <div class="mb-3">
            <label class="form-label small text-muted">Ciudad</label>
            <select class="form-select form-select-sm" name="id_ciudad">
              <option value="">Todas</option>
<%
    Connection con = null; Statement st = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
        while (rs.next()) {
            boolean sel = String.valueOf(rs.getInt("id_ciudad")).equals(idCiudadTxt);
%>
              <option value="<%= rs.getInt("id_ciudad") %>" <%= sel ? "selected" : "" %>>
                  <%= esc(rs.getString("nombre")) %></option>
<%      }
        cerrar(rs);
%>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label small text-muted">Tipo de inmueble</label>
            <select class="form-select form-select-sm" name="id_tipo">
              <option value="">Todos</option>
<%
        rs = st.executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
        while (rs.next()) {
            boolean sel = String.valueOf(rs.getInt("id_tipo")).equals(idTipoTxt);
%>
              <option value="<%= rs.getInt("id_tipo") %>" <%= sel ? "selected" : "" %>>
                  <%= esc(rs.getString("nombre")) %></option>
<%      }
        cerrar(rs);
%>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label small text-muted">Operacion</label>
            <select class="form-select form-select-sm" name="operacion">
              <option value="">Todas</option>
              <option value="VENTA" <%= "VENTA".equals(operacion) ? "selected" : "" %>>Venta</option>
              <option value="ARRIENDO" <%= "ARRIENDO".equals(operacion) ? "selected" : "" %>>Arriendo</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label small text-muted">Precio máximo</label>
            <input type="number" class="form-control form-control-sm" name="precio_max"
                   value="<%= esc(precioMaxTxt) %>" placeholder="Sin limite">
          </div>
          <div class="mb-3">
            <label class="form-label small text-muted d-block">Caracteristicas</label>
<%
        rs = st.executeQuery("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre");
        java.util.Set<String> seleccionadas = new java.util.HashSet<String>();
        if (caracteristicasSel != null) {
            for (String c : caracteristicasSel) seleccionadas.add(c);
        }
        while (rs.next()) {
            String idc = String.valueOf(rs.getInt("id_caracteristica"));
%>
            <div class="form-check">
              <input class="form-check-input" type="checkbox" name="caracteristica"
                     value="<%= idc %>" id="car<%= idc %>" <%= seleccionadas.contains(idc) ? "checked" : "" %>>
              <label class="form-check-label small" for="car<%= idc %>">
                  <%= esc(rs.getString("nombre")) %></label>
            </div>
<%      }
    } catch (SQLException ex) {
        out.println("<div class='text-danger small'>" + esc(ex.getMessage()) + "</div>");
    } finally { cerrar(rs, st, con); }
%>
          </div>
          <div class="d-grid">
            <button type="submit" class="btn btn-primary btn-sm fw-bold">
                <i class="bi bi-search"></i> Aplicar filtros</button>
          </div>
          <div class="d-grid mt-2">
            <a href="<%= ctx %>/propiedades/catalogo.jsp" class="btn btn-outline-secondary btn-sm">
                Limpiar filtros</a>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- ==================== RESULTADOS ==================== -->
  <div class="col-lg-9">
<%
    // ---------- Armar la consulta dinamica con los filtros presentes ----------
    StringBuilder sql = new StringBuilder(
        "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, p.area_m2, "
        + "       c.nombre AS ciudad, t.nombre AS tipo, "
        + "       (SELECT ip.url_imagen FROM imagen_propiedad ip "
        + "         WHERE ip.id_propiedad = p.id_propiedad "
        + "         ORDER BY ip.es_principal DESC, ip.orden LIMIT 1) AS imagen "
        + "FROM propiedad p "
        + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
        + "  JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo "
        + "WHERE p.activo = 1 ");

    java.util.List<Object> parametros = new java.util.ArrayList<Object>();

    int idCiudad = aEntero(idCiudadTxt, 0);
    if (idCiudad > 0) { sql.append(" AND p.id_ciudad = ? "); parametros.add(idCiudad); }

    int idTipo = aEntero(idTipoTxt, 0);
    if (idTipo > 0) { sql.append(" AND p.id_tipo = ? "); parametros.add(idTipo); }

    if ("VENTA".equals(operacion) || "ARRIENDO".equals(operacion)) {
        sql.append(" AND p.operacion = ? "); parametros.add(operacion);
    }

    double precioMax = aDoble(precioMaxTxt, 0);
    if (precioMax > 0) { sql.append(" AND p.precio <= ? "); parametros.add(precioMax); }

    if (texto != null && !texto.trim().isEmpty()) {
        sql.append(" AND (p.titulo ILIKE ? OR p.descripcion ILIKE ?) ");
        parametros.add("%" + texto.trim() + "%");
        parametros.add("%" + texto.trim() + "%");
    }

    if (caracteristicasSel != null && caracteristicasSel.length > 0) {
        sql.append(" AND p.id_propiedad IN ("
                 + "   SELECT pc.id_propiedad FROM propiedad_caracteristica pc "
                 + "   WHERE pc.id_caracteristica IN (");
        for (int i = 0; i < caracteristicasSel.length; i++) {
            sql.append(i == 0 ? "?" : ",?");
            parametros.add(aEntero(caracteristicasSel[i], 0));
        }
        sql.append(")  GROUP BY pc.id_propiedad HAVING COUNT(DISTINCT pc.id_caracteristica) = ?) ");
        parametros.add(caracteristicasSel.length);
    }

    sql.append(" ORDER BY p.fecha_publicacion DESC");

    PreparedStatement ps = null; ResultSet rsProp = null;
    int total = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < parametros.size(); i++) {
            ps.setObject(i + 1, parametros.get(i));
        }
        rsProp = ps.executeQuery();
%>
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h5 class="mb-0"><i class="bi bi-houses"></i> Resultados</h5>
    </div>
    <div class="row g-3">
<%
        while (rsProp.next()) {
            total++;
%>
      <div class="col-12 col-sm-6 col-xl-4">
        <div class="card card-propiedad h-100 shadow-sm">
<%        String imgProp = rsProp.getString("imagen");
          if (esUrlDeImagen(imgProp)) { %>
          <img src="<%= esc(urlImagen(imgProp, ctx)) %>" class="card-img-top"
               alt="<%= esc(rsProp.getString("titulo")) %>"
               onerror="imgFallback(this,'<%= iconoTipo(rsProp.getString("tipo")) %>','<%= colorTipo(rsProp.getString("tipo")) %>','card-img-top')">
<%        } else { %>
          <div class="img-tipo <%= colorTipo(rsProp.getString("tipo")) %> card-img-top">
            <i class="bi <%= iconoTipo(rsProp.getString("tipo")) %>"></i>
          </div>
<%        } %>
          <div class="card-body">
            <span class="badge text-bg-<%= "VENTA".equals(rsProp.getString("operacion")) ? "success" : "info" %> mb-2">
                <%= rsProp.getString("operacion") %></span>
            <span class="badge text-bg-<%= colorEstadoPropiedad(rsProp.getString("estado")) %> mb-2">
                <%= rsProp.getString("estado") %></span>
            <h6 class="card-title"><%= esc(rsProp.getString("titulo")) %></h6>
            <p class="card-text text-muted small mb-1">
                <i class="bi bi-geo-alt"></i> <%= esc(rsProp.getString("ciudad")) %> &middot;
                <%= esc(rsProp.getString("tipo")) %> &middot; <%= rsProp.getDouble("area_m2") %> m2
            </p>
            <p class="fw-bold fs-5 text-primary mb-2"><%= pesos(rsProp.getDouble("precio")) %></p>
            <a href="<%= ctx %>/propiedades/detalle.jsp?id=<%= rsProp.getInt("id_propiedad") %>"
               class="btn btn-outline-primary btn-sm w-100 fw-bold">
                <%= "VENTA".equals(rsProp.getString("operacion")) ? "Ver y comprar" : "Ver y arrendar" %></a>
          </div>
        </div>
      </div>
<%
        }
    } catch (SQLException ex) {
%>
      <div class="col-12"><div class="alert alert-danger"><%= esc(ex.getMessage()) %></div></div>
<%
    } finally { cerrar(rsProp, ps, con); }
    if (total == 0) {
%>
      <div class="col-12">
        <div class="alert alert-secondary text-center py-5">
            <i class="bi bi-search fs-1"></i>
            <p class="mb-0 mt-2">No se encontraron propiedades con esos filtros.</p>
        </div>
      </div>
<%  } %>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
