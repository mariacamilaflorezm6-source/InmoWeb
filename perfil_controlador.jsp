<%--
    perfil_controlador.jsp - Procesa las 3 acciones del perfil:
    datos | agencia | clave
    Disponible para cualquier rol autenticado (misma logica de sesion
    manual que perfil.jsp, ya que no vive bajo un prefijo de rol).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    if (session.getAttribute("idUsuario") == null) {
        response.sendRedirect(ctx + "/login.jsp?error=sesion");
        return;
    }
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String destino;

    try {
        con = abrirConexion();

        // ========== Datos personales (tabla perfil, 1:1) ==========
        if ("datos".equals(accion)) {
            String documento = request.getParameter("documento");
            String nombres   = request.getParameter("nombres");
            String apellidos = request.getParameter("apellidos");
            String telefono  = request.getParameter("telefono");
            String direccion = request.getParameter("direccion");

            if (documento == null || documento.trim().isEmpty() || nombres == null || nombres.trim().isEmpty()
                    || apellidos == null || apellidos.trim().isEmpty() || !esTelefonoValido(telefono)) {
                destino = ctx + "/perfil.jsp?err=" + java.net.URLEncoder.encode(
                        "Revise los campos: documento, nombres, apellidos y telefono son obligatorios.", "UTF-8");
            } else {
                ps = con.prepareStatement(
                    "UPDATE perfil SET documento=?, nombres=?, apellidos=?, telefono=?, direccion=? "
                    + "WHERE id_usuario=?");
                ps.setString(1, documento.trim());
                ps.setString(2, nombres.trim());
                ps.setString(3, apellidos.trim());
                ps.setString(4, telefono.trim());
                ps.setString(5, direccion == null ? null : direccion.trim());
                ps.setInt(6, idUsuario);
                ps.executeUpdate();
                cerrar(ps);

                // Actualiza tambien el nombre que se muestra en la sesion (navbar)
                session.setAttribute("nombre", nombres.trim() + " " + apellidos.trim());

                destino = ctx + "/perfil.jsp?msg=" + java.net.URLEncoder.encode(
                        "Datos personales actualizados.", "UTF-8");
            }

        // ========== Datos de la agencia (tabla inmobiliaria, 1:1) ==========
        } else if ("agencia".equals(accion)) {
            String nombreComercial   = request.getParameter("nombre_comercial");
            String telefonoContacto  = request.getParameter("telefono_contacto");
            String direccionAgencia  = request.getParameter("direccion_agencia");

            ps = con.prepareStatement(
                "UPDATE inmobiliaria SET nombre_comercial=?, telefono_contacto=?, direccion=? "
                + "WHERE id_usuario=?");
            ps.setString(1, nombreComercial == null ? null : nombreComercial.trim());
            ps.setString(2, telefonoContacto == null ? null : telefonoContacto.trim());
            ps.setString(3, direccionAgencia == null ? null : direccionAgencia.trim());
            ps.setInt(4, idUsuario);
            int filas = ps.executeUpdate();
            cerrar(ps);

            destino = filas > 0
                ? ctx + "/perfil.jsp?msg=" + java.net.URLEncoder.encode("Datos de la agencia actualizados.", "UTF-8")
                : ctx + "/perfil.jsp?err=" + java.net.URLEncoder.encode("Su cuenta no tiene una agencia asociada.", "UTF-8");

        // ========== Cambio de contrasena ==========
        } else if ("clave".equals(accion)) {
            String claveActual    = request.getParameter("clave_actual");
            String claveNueva     = request.getParameter("clave_nueva");
            String claveConfirmar = request.getParameter("clave_confirmar");

            ps = con.prepareStatement("SELECT correo, password_hash FROM usuario WHERE id_usuario = ?");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            rs.next();
            String correo = rs.getString("correo");
            String hashGuardado = rs.getString("password_hash");
            cerrar(rs, ps);

            if (!hashGuardado.equals(claveCifrada(correo, claveActual))) {
                destino = ctx + "/perfil.jsp?err=" + java.net.URLEncoder.encode(
                        "La contrasena actual no es correcta.", "UTF-8");
            } else if (claveNueva == null || claveNueva.length() < 6 || !claveNueva.equals(claveConfirmar)) {
                destino = ctx + "/perfil.jsp?err=" + java.net.URLEncoder.encode(
                        "La contrasena nueva debe tener minimo 6 caracteres y coincidir con la confirmacion.", "UTF-8");
            } else {
                ps = con.prepareStatement("UPDATE usuario SET password_hash = ? WHERE id_usuario = ?");
                ps.setString(1, claveCifrada(correo, claveNueva));
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
                cerrar(ps);
                destino = ctx + "/perfil.jsp?msg=" + java.net.URLEncoder.encode(
                        "Contrasena actualizada correctamente.", "UTF-8");
            }
        } else {
            destino = ctx + "/perfil.jsp";
        }

    } catch (SQLException ex) {
        String amigable = "23505".equals(ex.getSQLState())
                ? "Ese documento ya esta registrado por otro usuario."
                : ex.getMessage();
        destino = ctx + "/perfil.jsp?err=" + java.net.URLEncoder.encode(amigable, "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
