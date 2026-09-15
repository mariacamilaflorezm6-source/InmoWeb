<%--
    cliente/solicitud_controlador.jsp - Crea una solicitud de compra/arriendo
    junto con los documentos adjuntos (ahora PDF reales, no enlaces), dentro
    de una transaccion.

    Los archivos se guardan FUERA del directorio publico de la aplicacion
    (en WEB-INF/uploads/documentos), para que nadie pueda abrirlos con una
    URL directa: solo se pueden descargar a traves de documento_descarga.jsp,
    que valida que quien pide el archivo sea el cliente dueno de la
    solicitud, el agente de la inmobiliaria correspondiente, o un
    administrador.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, javax.servlet.http.Part" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    String tipo = request.getParameter("tipo");

    // Carpeta real en el servidor donde quedan los PDF. No esta dentro de
    // ninguna carpeta publica (webapp root), asi que Tomcat NUNCA la sirve
    // directamente por URL: solo documento_descarga.jsp puede leerla.
    String carpetaSubidas = application.getRealPath("/WEB-INF/uploads/documentos");

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String destino;
    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        ps = con.prepareStatement(
            "INSERT INTO solicitud (id_propiedad, id_cliente, tipo) VALUES (?, ?, ?)",
            Statement.RETURN_GENERATED_KEYS);
        ps.setInt(1, idPropiedad);
        ps.setInt(2, idUsuario);
        ps.setString(3, tipo);
        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        rs.next();
        int idSolicitud = rs.getInt(1);
        cerrar(rs, ps);

        File dirDestino = new File(carpetaSubidas);
        if (!dirDestino.exists()) dirDestino.mkdirs();

        ps = con.prepareStatement(
            "INSERT INTO documento_solicitud (id_solicitud, tipo_documento, url_archivo) VALUES (?, ?, ?)");
        for (int i = 0; i < 3; i++) {
            Part parte = request.getPart("documento_" + i);
            if (parte == null || parte.getSize() == 0) continue; // el cliente no adjunto este

            String contentType = parte.getContentType();
            if (contentType == null || !contentType.equals("application/pdf")) {
                throw new IOException("El archivo \"" + parte.getSubmittedFileName()
                        + "\" no es un PDF. Solo se aceptan documentos en formato PDF.");
            }

            String tipoDoc = request.getParameter("tipo_documento_" + i);
            if (tipoDoc == null || tipoDoc.trim().isEmpty()) tipoDoc = "Documento";

            // Nombre de archivo predecible y sin datos del cliente, para evitar
            // colisiones y no depender del nombre original que subio el usuario.
            String nombreArchivo = "sol" + idSolicitud + "_doc" + i + ".pdf";
            try (InputStream in = parte.getInputStream();
                 FileOutputStream salida = new FileOutputStream(new File(dirDestino, nombreArchivo))) {
                byte[] buffer = new byte[8192];
                int leidos;
                while ((leidos = in.read(buffer)) != -1) salida.write(buffer, 0, leidos);
            }

            ps.setInt(1, idSolicitud);
            ps.setString(2, tipoDoc.trim());
            ps.setString(3, nombreArchivo); // guardamos solo el nombre de archivo, no una URL externa
            ps.executeUpdate();
        }
        cerrar(ps);

        con.commit();
        destino = ctx + "/cliente/solicitudes.jsp?msg=" + java.net.URLEncoder.encode(
                "Solicitud radicada. La inmobiliaria la revisara pronto.", "UTF-8");
    } catch (Exception ex) {
        deshacer(con);
        destino = ctx + "/cliente/radicar_solicitud.jsp?id=" + idPropiedad
                + "&err=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
