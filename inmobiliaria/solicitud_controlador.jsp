<%--
    inmobiliaria/solicitud_controlador.jsp - Aprueba o rechaza una
    solicitud, SOLO si la propiedad pertenece a esta inmobiliaria y la
    solicitud sigue PENDIENTE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");
    int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
    String observaciones = request.getParameter("observaciones");

    String estadoNuevo = "aprobar".equals(accion) ? "APROBADA"
                        : "rechazar".equals(accion) ? "RECHAZADA" : null;

    Connection con = null; PreparedStatement ps = null;
    String destino;
    try {
        con = abrirConexion();

        if (estadoNuevo == null) {
            destino = ctx + "/inmobiliaria/solicitudes.jsp";
        } else {
            con.setAutoCommit(false); // ---- inicia la transaccion ----

            ps = con.prepareStatement(
                "UPDATE solicitud SET estado = ?, observaciones_inmobiliaria = ? "
                + "WHERE id_solicitud = ? AND estado = 'PENDIENTE' "
                + "  AND id_propiedad IN ("
                + "    SELECT id_propiedad FROM propiedad "
                + "    WHERE id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?))");
            ps.setString(1, estadoNuevo);
            ps.setString(2, (observaciones == null || observaciones.trim().isEmpty()) ? null : observaciones.trim());
            ps.setInt(3, idSolicitud);
            ps.setInt(4, idUsuario);
            int filas = ps.executeUpdate();
            cerrar(ps);

            // Si la solicitud queda APROBADA, la propiedad pasa sola a
            // RESERVADA (solo si seguia DISPONIBLE). Asi el catalogo publico
            // deja de mostrarla como disponible mientras se formaliza el
            // negocio; el agente la marca VENDIDA/ARRENDADA mas adelante,
            // desde "Editar propiedad", cuando el negocio se cierre.
            if (filas > 0 && "APROBADA".equals(estadoNuevo)) {
                ps = con.prepareStatement(
                    "UPDATE propiedad SET estado = 'RESERVADA' "
                    + "WHERE estado = 'DISPONIBLE' "
                    + "  AND id_propiedad = (SELECT id_propiedad FROM solicitud WHERE id_solicitud = ?)");
                ps.setInt(1, idSolicitud);
                ps.executeUpdate();
                cerrar(ps);
            }

            con.commit();

            destino = filas > 0
                ? ctx + "/inmobiliaria/solicitudes.jsp?msg=" + java.net.URLEncoder.encode("Solicitud actualizada.", "UTF-8")
                : ctx + "/inmobiliaria/solicitudes.jsp?err=" + java.net.URLEncoder.encode(
                    "No se pudo actualizar (no es suya o ya fue procesada).", "UTF-8");
        }
    } catch (SQLException ex) {
        deshacer(con);
        destino = ctx + "/inmobiliaria/solicitudes.jsp?err=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
