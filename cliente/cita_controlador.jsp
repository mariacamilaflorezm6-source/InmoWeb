<%--
    cliente/cita_controlador.jsp - Crea o cancela una cita, desde el lado
    del cliente. Protegido por el Filter (requiere rol CLIENTE).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");

    Connection con = null; PreparedStatement ps = null;
    String destino;
    try {
        con = abrirConexion();

        if ("crear".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            String fecha = request.getParameter("fecha");
            String hora  = request.getParameter("hora");
            String observaciones = request.getParameter("observaciones");

            // parseFechaHora devuelve null si el formato no sirve (evita el
            // IllegalArgumentException de Timestamp.valueOf, que no captura
            // el catch de SQLException y romperia la pagina con error 500).
            Timestamp fechaHora = parseFechaHora(fecha, hora);

            if (idPropiedad <= 0 || fechaHora == null) {
                destino = ctx + "/cliente/agendar_cita.jsp?id=" + idPropiedad
                        + "&err=" + java.net.URLEncoder.encode(
                            idPropiedad <= 0 ? "La propiedad indicada no es valida." : "Debe elegir fecha y hora validas.", "UTF-8");
            } else {
                ps = con.prepareStatement(
                    "INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, observaciones) "
                    + "VALUES (?, ?, ?, ?)");
                ps.setInt(1, idPropiedad);
                ps.setInt(2, idUsuario);
                ps.setTimestamp(3, fechaHora);
                ps.setString(4, (observaciones == null || observaciones.trim().isEmpty()) ? null : observaciones.trim());
                ps.executeUpdate();
                cerrar(ps);
                destino = ctx + "/cliente/citas.jsp?msg=" + java.net.URLEncoder.encode(
                        "Visita solicitada. Espera la confirmacion de la inmobiliaria.", "UTF-8");
            }

        } else if ("cancelar".equals(accion)) {
            int idCita = aEntero(request.getParameter("id_cita"), 0);
            ps = con.prepareStatement(
                "UPDATE cita SET estado = 'CANCELADA' "
                + "WHERE id_cita = ? AND id_cliente = ? AND estado IN ('SOLICITADA','CONFIRMADA')");
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);
            int filas = ps.executeUpdate();
            cerrar(ps);
            destino = filas > 0
                ? ctx + "/cliente/citas.jsp?msg=" + java.net.URLEncoder.encode("Cita cancelada.", "UTF-8")
                : ctx + "/cliente/citas.jsp?err=" + java.net.URLEncoder.encode(
                    "No se pudo cancelar (no es suya o ya no admite cancelacion).", "UTF-8");
        } else {
            destino = ctx + "/cliente/citas.jsp";
        }
    } catch (SQLException ex) {
        String estadoSql = ex.getSQLState();
        String amigable;
        if ("23505".equals(estadoSql)) {
            amigable = "Ya existe una cita agendada para esa propiedad en ese mismo horario. Elija otra hora.";
        } else if ("23503".equals(estadoSql)) {
            amigable = "La propiedad indicada no existe o ya no esta disponible.";
        } else {
            amigable = ex.getMessage();
        }
        int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
        destino = ctx + "/cliente/agendar_cita.jsp?id=" + idPropiedad
                + "&err=" + java.net.URLEncoder.encode(amigable, "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
<%!
    /** Convierte fecha ("YYYY-MM-DD") + hora ("HH:MM") en un Timestamp valido;
     *  devuelve null si el formato es invalido para mostrar un mensaje claro. */
    public Timestamp parseFechaHora(String fecha, String hora) {
        if (fecha == null || hora == null) return null;
        try { return Timestamp.valueOf(fecha.trim() + " " + hora.trim() + ":00"); }
        catch (Exception ex) { return null; }
    }
%>
