<%--
    acceso.jsp - Valida las credenciales contra la tabla usuario.
    Incluye bloqueo temporal tras 3 intentos fallidos (valor agregado
    sugerido en el enunciado del parcial). No genera HTML: solo redirige.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/correo.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String correo = request.getParameter("correo");
    String clave  = request.getParameter("clave");

    if (correo == null || clave == null || correo.trim().isEmpty() || clave.trim().isEmpty()) {
        response.sendRedirect(ctx + "/login.jsp?error=vacio");
        return;
    }
    correo = correo.trim().toLowerCase();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = abrirConexion();

        ps = con.prepareStatement(
            "SELECT id_usuario, password_hash, activo, intentos_fallidos, "
            + "  (codigo_verificacion IS NOT NULL AND codigo_expira > CURRENT_TIMESTAMP) AS verificacion_pendiente "
            + "FROM usuario WHERE correo = ?");
        ps.setString(1, correo);
        rs = ps.executeQuery();

        if (!rs.next()) {
            response.sendRedirect(ctx + "/login.jsp?error=clave");
            return;
        }

        int idUsuario = rs.getInt("id_usuario");
        String hashGuardado = rs.getString("password_hash");
        boolean activo = rs.getBoolean("activo");
        int intentosFallidos = rs.getInt("intentos_fallidos");
        boolean verificacionPendiente = rs.getBoolean("verificacion_pendiente");
        cerrar(rs, ps);

        if (!activo) {
            response.sendRedirect(ctx + "/login.jsp?error=inactivo");
            return;
        }

        // ---------- Si ya hay un codigo de verificacion pendiente ----------
        // (por ejemplo, cerro la pestana antes de escribirlo), lo manda
        // directo a esa pantalla en vez de dejarlo repetir la clave.
        if (verificacionPendiente) {
            response.sendRedirect(ctx + "/verificar_codigo.jsp?correo="
                    + java.net.URLEncoder.encode(correo, "UTF-8"));
            return;
        }

        boolean claveCorrecta = hashGuardado.equals(claveCifrada(correo, clave));

        if (!claveCorrecta) {
            int nuevosIntentos = intentosFallidos + 1;
            if (nuevosIntentos >= 3) {
                // Genera un codigo de 6 digitos y lo guarda con una ventana
                // de seguridad de 30 minutos (si el usuario nunca llega a
                // verificarlo, la cuenta no queda bloqueada para siempre:
                // acceso.jsp mas abajo trata ese caso como "codigo vencido").
                String codigo = String.format("%06d", (int) (Math.random() * 1000000));
                ps = con.prepareStatement(
                    "UPDATE usuario SET intentos_fallidos = 0, "
                    + "  codigo_verificacion = ?, "
                    + "  codigo_expira = CURRENT_TIMESTAMP + INTERVAL '30 minutes' "
                    + "WHERE id_usuario = ?");
                ps.setString(1, codigo);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
                cerrar(ps);

                boolean correoEnviado = true;
                try {
                    enviarCorreo(correo, "InmoWeb Seguridad - Codigo de verificacion",
                        "<div style='font-family:Arial,sans-serif'>"
                        + "<h2 style='color:#1F4E78'>InmoWeb</h2>"
                        + "<p>Hola,</p>"
                        + "<p>Detectamos <b>3 intentos fallidos</b> de inicio de sesion en su cuenta "
                        + "(" + esc(correo) + "). Por seguridad, debe verificar su identidad para continuar.</p>"
                        + "<p>Su codigo de verificacion es:</p>"
                        + "<p style='font-size:32px;font-weight:bold;letter-spacing:6px;color:#1F4E78'>"
                        + codigo + "</p>"
                        + "<p>Este codigo vence en 30 minutos. Si no fue usted quien intento ingresar, "
                        + "cambie su contrasena apenas pueda acceder a su cuenta.</p>"
                        + "<p><small>Este es un mensaje automatico de InmoWeb Seguridad, por favor no responda.</small></p>"
                        + "</div>");
                } catch (MessagingException exCorreo) {
                    correoEnviado = false;
                }

                response.sendRedirect(ctx + "/verificar_codigo.jsp?correo="
                        + java.net.URLEncoder.encode(correo, "UTF-8")
                        + (correoEnviado ? "" : "&avisoCorreo=1"));
            } else {
                ps = con.prepareStatement(
                    "UPDATE usuario SET intentos_fallidos = ? WHERE id_usuario = ?");
                ps.setInt(1, nuevosIntentos);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
                cerrar(ps);
                response.sendRedirect(ctx + "/login.jsp?error=clave");
            }
            return;
        }

        // ---------- Login correcto: limpiar contador de intentos ----------
        ps = con.prepareStatement(
            "UPDATE usuario SET intentos_fallidos = 0, bloqueado_hasta = NULL, "
            + "  codigo_verificacion = NULL, codigo_expira = NULL WHERE id_usuario = ?");
        ps.setInt(1, idUsuario);
        ps.executeUpdate();
        cerrar(ps);

        // ---------- Cargar nombre (perfil) ----------
        ps = con.prepareStatement("SELECT nombres, apellidos FROM perfil WHERE id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        String nombreCompleto = correo;
        if (rs.next()) {
            nombreCompleto = rs.getString("nombres") + " " + rs.getString("apellidos");
        }
        cerrar(rs, ps);

        // ---------- Cargar TODOS los roles del usuario (relacion N:M) ----------
        ps = con.prepareStatement(
            "SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol "
            + "WHERE ur.id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        java.util.List<String> roles = new java.util.ArrayList<String>();
        while (rs.next()) roles.add(rs.getString("nombre"));
        cerrar(rs, ps);

        // El rol principal define el panel al que se redirige.
        // Prioridad: ADMINISTRADOR > INMOBILIARIA > CLIENTE
        String rolPrincipal = roles.contains("ADMINISTRADOR") ? "ADMINISTRADOR"
                : roles.contains("INMOBILIARIA") ? "INMOBILIARIA"
                : "CLIENTE";

        session.setAttribute("idUsuario", idUsuario);
        session.setAttribute("correo", correo);
        session.setAttribute("nombre", nombreCompleto);
        session.setAttribute("roles", roles);
        session.setAttribute("rolPrincipal", rolPrincipal);
        session.setMaxInactiveInterval(30 * 60);

        // Bitacora
        ps = con.prepareStatement(
            "INSERT INTO auditoria (id_usuario, accion, detalle, ip_origen) "
            + "VALUES (?, 'LOGIN', 'Inicio de sesion exitoso', ?)");
        ps.setInt(1, idUsuario);
        ps.setString(2, request.getRemoteAddr());
        ps.executeUpdate();
        cerrar(ps);

        if ("ADMINISTRADOR".equals(rolPrincipal)) {
            response.sendRedirect(ctx + "/admin/panel.jsp");
        } else if ("INMOBILIARIA".equals(rolPrincipal)) {
            response.sendRedirect(ctx + "/inmobiliaria/panel.jsp");
        } else {
            response.sendRedirect(ctx + "/cliente/panel.jsp");
        }

    } catch (SQLException ex) {
        out.println("<div style='font-family:sans-serif;padding:20px'>"
                + "<h3>Error de conexion con la base de datos</h3><pre>" + ex.getMessage() + "</pre></div>");
    } finally {
        cerrar(rs, ps, con);
    }
%>
