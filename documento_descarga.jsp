<%--
    documento_descarga.jsp - Sirve el PDF real de un documento_solicitud.

    Esta ruta NO empieza por /cliente/, /inmobiliaria/ ni /admin/, asi que
    ControlAccesoFilter la deja pasar como "publica" sin exigir sesion. Por
    eso este archivo hace su PROPIA validacion antes de entregar el archivo:
    solo puede descargarlo (a) el cliente dueno de la solicitud, (b) el
    agente de la inmobiliaria que publico esa propiedad, o (c) un
    administrador. Cualquier otro caso se redirige a acceso_denegado.jsp,
    exactamente igual de estricto que si el Filter lo hubiera bloqueado.
--%>
<%@ page contentType="application/pdf" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.List" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String ctxDesc = request.getContextPath();
    Integer idUsuarioSesionDesc = (session == null) ? null : (Integer) session.getAttribute("idUsuario");
    if (idUsuarioSesionDesc == null) {
        response.sendRedirect(ctxDesc + "/login.jsp?error=sesion");
        return;
    }
    @SuppressWarnings("unchecked")
    List<String> rolesSesionDesc = (session == null) ? null : (List<String>) session.getAttribute("roles");
    boolean esAdmin = rolesSesionDesc != null && rolesSesionDesc.contains("ADMINISTRADOR");

    int idDocumento = aEntero(request.getParameter("id"), 0);

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String nombreArchivo = null, tipoDocumento = null;
    boolean autorizado = false;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT d.url_archivo, d.tipo_documento, s.id_cliente, "
            + "       inm.id_usuario AS id_usuario_agente "
            + "FROM documento_solicitud d "
            + "  JOIN solicitud s ON s.id_solicitud = d.id_solicitud "
            + "  JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
            + "  JOIN inmobiliaria inm ON inm.id_inmobiliaria = p.id_inmobiliaria "
            + "WHERE d.id_documento = ?");
        ps.setInt(1, idDocumento);
        rs = ps.executeQuery();
        if (rs.next()) {
            nombreArchivo = rs.getString("url_archivo");
            tipoDocumento = rs.getString("tipo_documento");
            int idClienteDueno = rs.getInt("id_cliente");
            int idAgenteDueno  = rs.getInt("id_usuario_agente");
            autorizado = esAdmin
                    || idUsuarioSesionDesc == idClienteDueno
                    || idUsuarioSesionDesc == idAgenteDueno;
        }
    } catch (SQLException ex) {
        nombreArchivo = null;
    } finally {
        cerrar(rs, ps, con);
    }

    if (nombreArchivo == null || !autorizado) {
        response.reset();
        response.setContentType("text/html; charset=UTF-8");
        response.sendRedirect(ctxDesc + "/acceso_denegado.jsp");
        return;
    }

    File archivo = new File(application.getRealPath("/WEB-INF/uploads/documentos"), nombreArchivo);
    if (!archivo.exists()) {
        response.reset();
        response.setContentType("text/html; charset=UTF-8");
        String tituloPagina = "Documento no disponible";
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="alert alert-warning mt-4">
    Este documento ("<%= esc(tipoDocumento) %>") no tiene un archivo cargado todavia.
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
<%
        return;
    }

    response.setHeader("Content-Disposition", "inline; filename=\"" + nombreArchivo + "\"");
    response.setContentLength((int) archivo.length());
    try (InputStream in = new FileInputStream(archivo); OutputStream salida = response.getOutputStream()) {
        byte[] buffer = new byte[8192];
        int leidos;
        while ((leidos = in.read(buffer)) != -1) salida.write(buffer, 0, leidos);
    }
%>
