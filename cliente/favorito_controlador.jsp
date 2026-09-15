<%--
    cliente/favorito_controlador.jsp - Marca o desmarca una propiedad como
    favorita para el cliente autenticado (relacion N:M usuario<->propiedad).
    Esta ruta empieza por /cliente/, asi que ControlAccesoFilter YA garantiza
    que solo llega aqui un usuario con sesion y rol CLIENTE: no hace falta
    repetir esa validacion en este archivo.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    String origen = request.getParameter("origen");

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String mensaje = "msg=favorito_actualizado";
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT 1 FROM favorito WHERE id_usuario = ? AND id_propiedad = ?");
        ps.setInt(1, idUsuario);
        ps.setInt(2, idPropiedad);
        rs = ps.executeQuery();
        boolean yaExiste = rs.next();
        cerrar(rs, ps);

        if (yaExiste) {
            ps = con.prepareStatement(
                "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
            mensaje = "msg=quitado_de_favoritos";
        } else {
            ps = con.prepareStatement(
                "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
            mensaje = "msg=agregado_a_favoritos";
        }
        cerrar(ps);
    } catch (SQLException ex) {
        String amigable = "23505".equals(ex.getSQLState())
                ? "Ya tenia esa propiedad en favoritos."
                : ex.getMessage();
        mensaje = "error=" + java.net.URLEncoder.encode(amigable, "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(ctx + ("favoritos".equals(origen)
            ? "/cliente/favoritos.jsp?" + mensaje
            : "/propiedades/detalle.jsp?id=" + idPropiedad + "&" + mensaje));
%>
