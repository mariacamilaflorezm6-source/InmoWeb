<%--
    admin/usuario_controlador.jsp - Activa/desactiva cuentas y sincroniza
    los roles asignados (usuario_rol) segun los checkboxes marcados.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String accion = request.getParameter("accion");
    int idUsuarioFila = aEntero(request.getParameter("id_usuario"), 0);
    int idUsuarioAdmin = (Integer) session.getAttribute("idUsuario");

    Connection con = null; PreparedStatement ps = null;
    String destino;
    try {
        con = abrirConexion();

        if ("toggle_activo".equals(accion)) {
            if (idUsuarioFila == idUsuarioAdmin) {
                throw new SQLException("No puede desactivar su propia cuenta de administrador.");
            }
            ps = con.prepareStatement(
                "UPDATE usuario SET activo = CASE WHEN activo = 1 THEN 0 ELSE 1 END WHERE id_usuario = ?");
            ps.setInt(1, idUsuarioFila);
            ps.executeUpdate();
            cerrar(ps);

            ps = con.prepareStatement(
                "INSERT INTO auditoria (id_usuario, accion, detalle) VALUES (?, 'CAMBIO_ESTADO_CUENTA', "
                + "  'El administrador ' || ? || ' cambio el estado de la cuenta')");
            ps.setInt(1, idUsuarioFila);
            ps.setInt(2, idUsuarioAdmin);
            ps.executeUpdate();
            cerrar(ps);

            destino = ctx + "/admin/usuarios.jsp?msg=" + java.net.URLEncoder.encode("Estado actualizado.", "UTF-8");

        } else if ("guardar_roles".equals(accion)) {
            String[] roles = request.getParameterValues("rol");

            // Evita que el administrador se quite a si mismo el rol ADMINISTRADOR
            // por accidente (se quedaria sin poder volver a entrar al panel admin)
            if (idUsuarioFila == idUsuarioAdmin) {
                ps = con.prepareStatement("SELECT id_rol FROM rol WHERE nombre = 'ADMINISTRADOR'");
                ResultSet rsAdmin = ps.executeQuery();
                rsAdmin.next();
                int idRolAdmin = rsAdmin.getInt("id_rol");
                cerrar(rsAdmin, ps);
                boolean conservaAdmin = false;
                if (roles != null) {
                    for (String r : roles) if (Integer.parseInt(r) == idRolAdmin) conservaAdmin = true;
                }
                if (!conservaAdmin) {
                    throw new SQLException("No puede quitarse a si mismo el rol ADMINISTRADOR.");
                }
            }

            ps = con.prepareStatement("DELETE FROM usuario_rol WHERE id_usuario = ?");
            ps.setInt(1, idUsuarioFila);
            ps.executeUpdate();
            cerrar(ps);

            if (roles != null) {
                // Deduplica los roles recibidos: si el mismo checkbox llega dos
                // veces, el INSERT compuesto fallaria por la llave primaria
                // usuario_rol(id_usuario, id_rol) y mostraria una excepcion Java.
                java.util.LinkedHashSet<String> rolesUnicos = new java.util.LinkedHashSet<String>();
                for (String r : roles) rolesUnicos.add(r);
                ps = con.prepareStatement("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)");
                for (String r : rolesUnicos) {
                    ps.setInt(1, idUsuarioFila);
                    ps.setInt(2, Integer.parseInt(r));
                    ps.executeUpdate();
                }
                cerrar(ps);
            }

            ps = con.prepareStatement(
                "INSERT INTO auditoria (id_usuario, accion, detalle) VALUES (?, 'CAMBIO_ROLES', "
                + "  'Roles actualizados por el administrador ' || ?)");
            ps.setInt(1, idUsuarioFila);
            ps.setInt(2, idUsuarioAdmin);
            ps.executeUpdate();
            cerrar(ps);

            destino = ctx + "/admin/usuarios.jsp?msg=" + java.net.URLEncoder.encode("Roles actualizados.", "UTF-8");
        } else {
            destino = ctx + "/admin/usuarios.jsp";
        }
    } catch (SQLException ex) {
        destino = ctx + "/admin/usuarios.jsp?err=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
