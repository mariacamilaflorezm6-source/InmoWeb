<%--
    inmobiliaria/solicitudes.jsp - Lista las solicitudes sobre las
    propiedades de ESTA inmobiliaria, con sus documentos y botones
    para aprobar o rechazar (solo si estan PENDIENTE).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Solicitudes";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-file-earmark-text"></i> Solicitudes recibidas</h3>
<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %></div><% } %>

<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT s.id_solicitud, s.tipo, s.estado, s.fecha_solicitud, "
            + "       p.titulo, pf.nombres || ' ' || pf.apellidos AS cliente, u.correo "
            + "FROM solicitud s "
            + "  JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
            + "  JOIN usuario u ON u.id_usuario = s.id_cliente "
            + "  JOIN perfil pf ON pf.id_usuario = u.id_usuario "
            + "WHERE p.id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?) "
            + "ORDER BY CASE s.estado WHEN 'PENDIENTE' THEN 1 ELSE 2 END, s.fecha_solicitud DESC");
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
            <h6 class="mb-1"><%= esc(rs.getString("titulo")) %>
                <span class="badge text-bg-secondary"><%= rs.getString("tipo") %></span></h6>
            <p class="small text-muted mb-1">
                <%= esc(rs.getString("cliente")) %> &middot; <%= esc(rs.getString("correo")) %> &middot;
                <%= rs.getTimestamp("fecha_solicitud") %></p>
          </div>
          <span class="badge text-bg-<%= colorEstadoTramite(estado) %> fs-6"><%= estado %></span>
        </div>

        <p class="small fw-bold mb-1 mt-2">Documentos:</p>
        <ul class="small">
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
          <li class="text-muted">El cliente no adjunto documentos.</li>
<%      } %>
        </ul>

<%
            if ("PENDIENTE".equals(estado)) {
%>
        <form method="post" action="<%= ctx %>/inmobiliaria/solicitud_controlador.jsp" class="row g-2 mt-2">
          <input type="hidden" name="id_solicitud" value="<%= idSolicitud %>">
          <div class="col-md-8">
            <input type="text" class="form-control form-control-sm" name="observaciones"
                   placeholder="Observaciones para el cliente (opcional)">
          </div>
          <div class="col-md-4 d-flex gap-2">
            <button type="submit" name="accion" value="aprobar" class="btn btn-sm btn-success flex-fill">
                <i class="bi bi-check2"></i> Aprobar</button>
            <button type="submit" name="accion" value="rechazar" class="btn btn-sm btn-outline-danger flex-fill">
                <i class="bi bi-x"></i> Rechazar</button>
          </div>
        </form>
<%      } %>
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
    <div class="alert alert-secondary text-center py-4">No ha recibido solicitudes todavia.</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
