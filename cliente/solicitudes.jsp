<%--
    cliente/solicitudes.jsp - Lista las solicitudes del cliente en sesion,
    con sus documentos adjuntos y el estado de revision.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mis solicitudes";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-file-earmark-text"></i> Mis solicitudes</h3>
<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>

<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT s.id_solicitud, s.tipo, s.estado, s.fecha_solicitud, s.observaciones_inmobiliaria, "
            + "       p.titulo, p.id_propiedad "
            + "FROM solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
            + "WHERE s.id_cliente = ? ORDER BY s.fecha_solicitud DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            int idSolicitud = rs.getInt("id_solicitud");
            String estado = rs.getString("estado");
%>
    <div class="card shadow-sm mb-3">
      <div class="card-body">
        <div class="d-flex justify-content-between align-items-start">
          <div>
            <h6 class="mb-1">
                <a href="<%= ctx %>/propiedades/detalle.jsp?id=<%= rs.getInt("id_propiedad") %>">
                    <%= esc(rs.getString("titulo")) %></a></h6>
            <p class="small text-muted mb-1">
                Solicitud de <b><%= rs.getString("tipo") %></b> &middot; <%= rs.getTimestamp("fecha_solicitud") %></p>
          </div>
          <span class="badge text-bg-<%= colorEstadoTramite(estado) %> fs-6"><%= estado %></span>
        </div>
        <% if (rs.getString("observaciones_inmobiliaria") != null) { %>
        <div class="alert alert-light border small mt-2 mb-2">
            <i class="bi bi-chat-left-text"></i> <%= esc(rs.getString("observaciones_inmobiliaria")) %></div>
        <% } %>
        <p class="small fw-bold mb-1 mt-2">Documentos adjuntos:</p>
        <ul class="small mb-0">
<%
            PreparedStatement psDoc = con.prepareStatement(
                "SELECT id_documento, tipo_documento, url_archivo FROM documento_solicitud WHERE id_solicitud = ?");
            psDoc.setInt(1, idSolicitud);
            ResultSet rsDoc = psDoc.executeQuery();
            boolean hayDocs = false;
            while (rsDoc.next()) {
                hayDocs = true;
%>
          <li><%= esc(rsDoc.getString("tipo_documento")) %>:
              <a href="<%= ctx %>/documento_descarga.jsp?id=<%= rsDoc.getInt("id_documento") %>" target="_blank">
                  <i class="bi bi-file-earmark-pdf"></i> ver PDF</a></li>
<%
            }
            cerrar(rsDoc, psDoc);
            if (!hayDocs) { %>
          <li class="text-muted">No adjunto documentos.</li>
<%      } %>
        </ul>
      </div>
    </div>
<%      }
    } catch (SQLException ex) {
%>
    <div class="alert alert-danger">Error: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
    <div class="alert alert-secondary text-center py-4">
        Aun no ha radicado ninguna solicitud. <a href="<%= ctx %>/propiedades/catalogo.jsp">Explore el catálogo</a>.</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
