<%--
    inmobiliaria/cita_controlador.jsp - Confirma, rechaza o marca como
    realizada una cita, SOLO si la propiedad pertenece a esta inmobiliaria.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");
    int idCita = aEntero(request.getParameter("id_cita"), 0);

    // Mapea la accion recibida al estado esperado ANTES y al estado NUEVO,
    // para que el UPDATE incluya siempre la condicion del estado actual
    // (evita que dos empleados cambien la misma cita a la vez).
    String estadoNuevo = null, estadoEsperado = null;
    if ("confirmar".equals(accion)) { estadoNuevo = "CONFIRMADA"; estadoEsperado = "SOLICITADA"; }
    else if ("rechazar".equals(accion)) { estadoNuevo = "RECHAZADA"; estadoEsperado = "SOLICITADA"; }
    else if ("realizada".equals(accion)) { estadoNuevo = "REALIZADA"; estadoEsperado = "CONFIRMADA"; }

    Connection con = null; PreparedStatement ps = null;
    String destino;
    try {
        con = abrirConexion();

        if (estadoNuevo == null) {
            destino = ctx + "/inmobiliaria/citas.jsp";
        } else {
            // El WHERE valida tres cosas a la vez: que la cita exista, que su
            // propiedad sea de ESTA inmobiliaria, y que siga en el estado esperado.
            ps = con.prepareStatement(
                "UPDATE cita SET estado = ? "
                + "WHERE id_cita = ? AND estado = ? "
                + "  AND id_propiedad IN ("
                + "    SELECT id_propiedad FROM propiedad "
                + "    WHERE id_inmobiliaria = (SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?))");
            ps.setString(1, estadoNuevo);
            ps.setInt(2, idCita);
            ps.setString(3, estadoEsperado);
            ps.setInt(4, idUsuario);
            int filas = ps.executeUpdate();
            cerrar(ps);

            destino = filas > 0
                ? ctx + "/inmobiliaria/citas.jsp?msg=" + java.net.URLEncoder.encode("Cita actualizada.", "UTF-8")
                : ctx + "/inmobiliaria/citas.jsp?err=" + java.net.URLEncoder.encode(
                    "No se pudo actualizar (no es suya o ya cambio de estado).", "UTF-8");
        }
    } catch (SQLException ex) {
        destino = ctx + "/inmobiliaria/citas.jsp?err=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
