<%--
    inmobiliaria/propiedad_form.jsp - Formulario de alta/edicion de propiedad.
    Si llega ?id=N, carga esa propiedad para editar (solo si pertenece a la
    inmobiliaria de la sesion). Sin el parametro, es un formulario en blanco
    para crear una propiedad nueva.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Propiedad";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    boolean editando = idPropiedad > 0;

    // Valores por defecto (formulario en blanco)
    String matricula = "", titulo = "", descripcion = "", direccion = "", operacion = "VENTA", estado = "DISPONIBLE";
    double precio = 0, areaM2 = 0;
    int idTipoSel = 0, idCiudadSel = 0;
    java.util.Set<Integer> caracSeleccionadas = new java.util.HashSet<Integer>();
    java.util.List<String> urlsImagenes = new java.util.ArrayList<String>();

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String errorCarga = null;
    try {
        con = abrirConexion();

        if (editando) {
            // Verifica que la propiedad exista Y pertenezca a esta inmobiliaria
            ps = con.prepareStatement(
                "SELECT p.* FROM propiedad p "
                + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
                + "WHERE p.id_propiedad = ? AND i.id_usuario = ?");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            rs = ps.executeQuery();
            if (rs.next()) {
                matricula = rs.getString("matricula_inmobiliaria");
                titulo = rs.getString("titulo");
                descripcion = rs.getString("descripcion");
                precio = rs.getDouble("precio");
                areaM2 = rs.getDouble("area_m2");
                direccion = rs.getString("direccion");
                operacion = rs.getString("operacion");
                estado = rs.getString("estado");
                idTipoSel = rs.getInt("id_tipo");
                idCiudadSel = rs.getInt("id_ciudad");
            } else {
                errorCarga = "Esa propiedad no existe o no le pertenece.";
            }
            cerrar(rs, ps);

            if (errorCarga == null) {
                ps = con.prepareStatement(
                    "SELECT id_caracteristica FROM propiedad_caracteristica WHERE id_propiedad = ?");
                ps.setInt(1, idPropiedad);
                rs = ps.executeQuery();
                while (rs.next()) caracSeleccionadas.add(rs.getInt("id_caracteristica"));
                cerrar(rs, ps);

                ps = con.prepareStatement(
                    "SELECT url_imagen FROM imagen_propiedad WHERE id_propiedad = ? ORDER BY es_principal DESC, orden");
                ps.setInt(1, idPropiedad);
                rs = ps.executeQuery();
                while (rs.next()) urlsImagenes.add(rs.getString("url_imagen"));
                cerrar(rs, ps);
            }
        }
    } catch (SQLException ex) {
        errorCarga = ex.getMessage();
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3">
    <i class="bi bi-house-gear"></i> <%= editando ? "Editar propiedad" : "Nueva propiedad" %></h3>

<% if (errorCarga != null) { %>
<div class="alert alert-danger"><%= esc(errorCarga) %></div>
<a href="<%= ctx %>/inmobiliaria/propiedades.jsp" class="btn btn-secondary">Volver</a>
<% } else { %>

<% if (request.getParameter("err") != null) { %>
<div class="alert alert-danger"><%= esc(request.getParameter("err")) %></div>
<% } %>

<div class="card shadow-sm">
<div class="card-body">
  <form method="post" action="<%= ctx %>/inmobiliaria/propiedad_controlador.jsp">
    <input type="hidden" name="accion" value="<%= editando ? "editar" : "crear" %>">
    <% if (editando) { %><input type="hidden" name="id_propiedad" value="<%= idPropiedad %>"><% } %>

    <div class="row g-3 mb-2">
      <div class="col-md-4">
        <label class="form-label">Matricula inmobiliaria</label>
        <input type="text" class="form-control" name="matricula_inmobiliaria" required maxlength="30"
               value="<%= esc(matricula) %>" placeholder="MI-0016">
      </div>
      <div class="col-md-8">
        <label class="form-label">Titulo</label>
        <input type="text" class="form-control" name="titulo" required maxlength="150" value="<%= esc(titulo) %>">
      </div>
    </div>

    <div class="mb-2">
      <label class="form-label">Descripción</label>
      <textarea class="form-control" name="descripcion" rows="3"><%= esc(descripcion) %></textarea>
    </div>

    <div class="row g-3 mb-2">
      <div class="col-md-3">
        <label class="form-label">Ciudad</label>
        <select class="form-select" name="id_ciudad" required>
<%
    Statement st = null; ResultSet rsSel = null;
    try {
        st = con.createStatement();
        rsSel = st.executeQuery("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
        while (rsSel.next()) {
%>
          <option value="<%= rsSel.getInt("id_ciudad") %>"
              <%= rsSel.getInt("id_ciudad") == idCiudadSel ? "selected" : "" %>>
              <%= esc(rsSel.getString("nombre")) %></option>
<%      }
        cerrar(rsSel);
%>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label">Tipo</label>
        <select class="form-select" name="id_tipo" required>
<%
        rsSel = st.executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
        while (rsSel.next()) {
%>
          <option value="<%= rsSel.getInt("id_tipo") %>"
              <%= rsSel.getInt("id_tipo") == idTipoSel ? "selected" : "" %>>
              <%= esc(rsSel.getString("nombre")) %></option>
<%      }
        cerrar(rsSel, st);
    } catch (SQLException ex) {
        out.println("<option>Error: " + esc(ex.getMessage()) + "</option>");
    }
%>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label">Operacion</label>
        <select class="form-select" name="operacion" required>
          <option value="VENTA" <%= "VENTA".equals(operacion) ? "selected" : "" %>>Venta</option>
          <option value="ARRIENDO" <%= "ARRIENDO".equals(operacion) ? "selected" : "" %>>Arriendo</option>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label">Estado</label>
        <select class="form-select" name="estado" <%= editando ? "" : "disabled" %>>
          <option value="DISPONIBLE" <%= "DISPONIBLE".equals(estado) ? "selected" : "" %>>Disponible</option>
          <option value="RESERVADA" <%= "RESERVADA".equals(estado) ? "selected" : "" %>>Reservada</option>
          <option value="VENDIDA" <%= "VENDIDA".equals(estado) ? "selected" : "" %>>Vendida</option>
          <option value="ARRENDADA" <%= "ARRENDADA".equals(estado) ? "selected" : "" %>>Arrendada</option>
        </select>
        <% if (!editando) { %>
        <input type="hidden" name="estado" value="DISPONIBLE">
        <small class="text-muted">Toda propiedad nueva inicia Disponible.</small>
        <% } %>
      </div>
    </div>

    <div class="row g-3 mb-2">
      <div class="col-md-4">
        <label class="form-label">Precio (COP)</label>
        <input type="number" class="form-control" name="precio" required min="1" step="1000"
               value="<%= precio > 0 ? (long) precio : "" %>">
      </div>
      <div class="col-md-4">
        <label class="form-label">Area (m2)</label>
        <input type="number" class="form-control" name="area_m2" step="0.1" min="0"
               value="<%= areaM2 > 0 ? areaM2 : "" %>">
      </div>
      <div class="col-md-4">
        <label class="form-label">Dirección</label>
        <input type="text" class="form-control" name="direccion" required maxlength="150" value="<%= esc(direccion) %>">
      </div>
    </div>

    <hr class="my-4">
    <h6 class="fw-bold"><i class="bi bi-list-check"></i> Caracteristicas</h6>
    <div class="row row-cols-2 row-cols-md-4 g-2 mb-3">
<%
    try {
        st = con.createStatement();
        rsSel = st.executeQuery("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre");
        while (rsSel.next()) {
            int idc = rsSel.getInt("id_caracteristica");
%>
      <div class="col">
        <div class="form-check">
          <input class="form-check-input" type="checkbox" name="caracteristica" value="<%= idc %>"
                 id="fc<%= idc %>" <%= caracSeleccionadas.contains(idc) ? "checked" : "" %>>
          <label class="form-check-label small" for="fc<%= idc %>"><%= esc(rsSel.getString("nombre")) %></label>
        </div>
      </div>
<%  }
        cerrar(rsSel, st);
    } catch (SQLException ex) {
        out.println("<div class='text-danger small'>" + esc(ex.getMessage()) + "</div>");
    }
%>
    </div>

    <hr class="my-4">
    <h6 class="fw-bold"><i class="bi bi-images"></i> Fotos (URL de la imagen)</h6>
    <p class="small text-muted">Pegue enlaces de imagenes (puede dejar vacios los que no use). La primera es la foto de portada.</p>
<%
    for (int i = 0; i < 4; i++) {
        String valor = i < urlsImagenes.size() ? urlsImagenes.get(i) : "";
%>
    <div class="mb-2">
      <input type="url" class="form-control" name="url_imagen_<%= i %>"
             placeholder="https://... (foto <%= (i+1) %><%= i == 0 ? ", portada" : "" %>)"
             value="<%= esc(valor) %>">
    </div>
<%  } %>

    <div class="d-grid mt-4">
      <button type="submit" class="btn btn-primary btn-lg fw-bold">
          <i class="bi bi-save"></i> <%= editando ? "Guardar cambios" : "Publicar propiedad" %></button>
    </div>
    <div class="d-grid mt-2">
      <a href="<%= ctx %>/inmobiliaria/propiedades.jsp" class="btn btn-link">Cancelar</a>
    </div>
  </form>
</div>
</div>
<% } %>
<% cerrar(con); %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
