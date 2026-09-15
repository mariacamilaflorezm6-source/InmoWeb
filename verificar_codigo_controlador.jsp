<%--
    verificar_codigo_controlador.jsp - Verifica el codigo de 6 digitos y
    desbloquea la cuenta de inmediato, o reenvia un codigo nuevo.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/correo.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String correo = request.getParameter("correo");
    String accionQuery = request.getParameter("accion"); // "reenviar" si aplica

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String destino;
    try {
        con = abrirConexion();

        if ("reenviar".equals(accionQuery)) {
            ps = con.prepareStatement("SELECT id_usuario FROM usuario WHERE correo = ?");
            ps.setString(1, correo);
            rs = ps.executeQuery();
            if (!rs.next()) {
                destino = ctx + "/login.jsp";
            } else {
                int idUsuario = rs.getInt("id_usuario");
                cerrar(rs, ps);

                String codigo = String.format("%06d", (int) (Math.random() * 1000000));
                ps = con.prepareStatement(
                    "UPDATE usuario SET codigo_verificacion = ?, "
                    + "  codigo_expira = CURRENT_TIMESTAMP + INTERVAL '30 minutes' WHERE id_usuario = ?");
                ps.setString(1, codigo);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
                cerrar(ps);

                boolean correoEnviado = true;
                try {
                    enviarCorreo(correo, "InmoWeb Seguridad - Nuevo codigo de verificacion",
                        "<div style='font-family:Arial,sans-serif'>"
                        + "<h2 style='color:#1F4E78'>InmoWeb</h2>"
                        + "<p>Su nuevo codigo de verificacion es:</p>"
                        + "<p style='font-size:32px;font-weight:bold;letter-spacing:6px;color:#1F4E78'>"
                        + codigo + "</p>"
                        + "<p>Vence en 30 minutos.</p></div>");
                } catch (MessagingException exCorreo) {
                    correoEnviado = false;
                }

                destino = ctx + "/verificar_codigo.jsp?correo=" + java.net.URLEncoder.encode(correo, "UTF-8")
                        + (correoEnviado ? "" : "&avisoCorreo=1");
            }

        } else {
            String codigoIngresado = request.getParameter("codigo");
            if (codigoIngresado == null || codigoIngresado.trim().isEmpty()) {
                destino = ctx + "/verificar_codigo.jsp?correo=" + java.net.URLEncoder.encode(correo, "UTF-8")
                        + "&error=vacio";
            } else {
                ps = con.prepareStatement(
                    "UPDATE usuario SET codigo_verificacion = NULL, codigo_expira = NULL, "
                    + "  intentos_fallidos = 0, bloqueado_hasta = NULL "
                    + "WHERE correo = ? AND codigo_verificacion = ? AND codigo_expira > CURRENT_TIMESTAMP");
                ps.setString(1, correo);
                ps.setString(2, codigoIngresado.trim());
                int filas = ps.executeUpdate();
                cerrar(ps);

                if (filas > 0) {
                    destino = ctx + "/login.jsp?msg=desbloqueado";
                } else {
                    destino = ctx + "/verificar_codigo.jsp?correo=" + java.net.URLEncoder.encode(correo, "UTF-8")
                            + "&error=codigo";
                }
            }
        }
    } catch (SQLException ex) {
        destino = ctx + "/verificar_codigo.jsp?correo=" + java.net.URLEncoder.encode(correo, "UTF-8")
                + "&error=codigo";
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
