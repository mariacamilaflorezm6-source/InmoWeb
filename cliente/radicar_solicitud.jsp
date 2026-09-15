<%--
    cliente/radicar_solicitud.jsp - Formulario para radicar una solicitud
    de compra o arriendo sobre una propiedad, adjuntando documentos
    (se guardan como URL, igual que las fotos de las propiedades).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Radicar solicitud";
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    String titulo = null, operacion = null;
    double precio = 0;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT titulo, operacion, precio FROM propiedad WHERE id_propiedad = ? AND activo = 1");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        if (rs.next()) {
            titulo = rs.getString("titulo");
            operacion = rs.getString("operacion");
            precio = rs.getDouble("precio");
        }
        cerrar(rs, ps, con);
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
    // El tipo de solicitud queda fijo segun la operacion de la propiedad:
    // una propiedad en VENTA solo admite solicitudes de COMPRA, y una en
    // ARRIENDO solo admite solicitudes de ARRIENDO.
    String tipoSolicitud = "VENTA".equals(operacion) ? "COMPRA" : "ARRIENDO";
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<% if (titulo == null) { %>
<div class="alert alert-warning">Esa propiedad no existe o ya no esta disponible.</div>
<% } else { %>

<h3 class="mb-3"><i class="bi bi-file-earmark-text"></i> Radicar solicitud de <%= tipoSolicitud.toLowerCase() %></h3>

<% if (request.getParameter("err") != null) { %>
<div class="alert alert-danger"><%= esc(request.getParameter("err")) %></div>
<% } %>

<div class="row justify-content-center">
<div class="col-lg-7">
  <div class="card shadow-sm">
    <div class="card-body">
      <h5><%= esc(titulo) %></h5>
      <p class="text-muted"><%= pesos(precio) %> &middot;
          <span class="badge text-bg-<%= "VENTA".equals(operacion) ? "success" : "info" %>"><%= operacion %></span></p>
      <hr>
      <form method="post" action="<%= ctx %>/cliente/solicitud_controlador.jsp" enctype="multipart/form-data">
        <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
        <input type="hidden" name="tipo" value="<%= tipoSolicitud %>">

        <p class="small text-muted">Adjunte los documentos en <strong>PDF</strong> que la inmobiliaria le solicite
            (cedula, certificado laboral, extractos, etc). Puede dejar campos vacios si aun no los tiene.
            Cada archivo debe pesar menos de 10&nbsp;MB.</p>
<%
    String[] sugeridos = { "Cedula de ciudadania", "Certificado laboral", "Extracto bancario" };
    for (int i = 0; i < 3; i++) {
%>
        <div class="row g-2 mb-2 align-items-center">
          <div class="col-md-4">
            <input type="text" class="form-control form-control-sm" name="tipo_documento_<%= i %>"
                   value="<%= sugeridos[i] %>" placeholder="Tipo de documento">
          </div>
          <div class="col-md-8">
            <input type="file" class="form-control form-control-sm" name="documento_<%= i %>" accept="application/pdf">
          </div>
        </div>
<%  } %>

        <div class="d-grid mt-4">
          <button class="btn btn-primary fw-bold"><i class="bi bi-send-check"></i> Radicar solicitud</button>
        </div>
      </form>
    </div>
  </div>
</div>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
