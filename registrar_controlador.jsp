<%--
    registrar_controlador.jsp - Procesa el formulario de registro.
    Crea, dentro de UNA transaccion: usuario, perfil, usuario_rol y,
    si el tipo de cuenta es INMOBILIARIA, tambien el registro en inmobiliaria.
    No genera HTML: siempre redirige.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String tipoCuenta   = request.getParameter("tipo_cuenta");
    String correo       = request.getParameter("correo");
    String telefono     = request.getParameter("telefono");
    String clave        = request.getParameter("clave");
    String confirmar    = request.getParameter("confirmar");
    String documento    = request.getParameter("documento");
    String nombres      = request.getParameter("nombres");
    String apellidos    = request.getParameter("apellidos");
    String direccion    = request.getParameter("direccion");
    String nombreComercial   = request.getParameter("nombre_comercial");
    String nit               = request.getParameter("nit");
    String direccionComercial = request.getParameter("direccion_comercial");

    // ---------- 1) Validaciones de servidor (obligatorias, no basta con el HTML) ----------
    boolean esInmobiliaria = "INMOBILIARIA".equals(tipoCuenta);
    boolean camposBasicosOk = correo != null && telefono != null && clave != null
            && confirmar != null && documento != null && nombres != null && apellidos != null
            && !correo.trim().isEmpty() && !documento.trim().isEmpty()
            && !nombres.trim().isEmpty() && !apellidos.trim().isEmpty()
            && esCorreoValido(correo) && esTelefonoValido(telefono);

    boolean camposInmobiliariaOk = !esInmobiliaria || (nombreComercial != null && nit != null
            && !nombreComercial.trim().isEmpty() && !nit.trim().isEmpty());

    if (!camposBasicosOk || !camposInmobiliariaOk) {
        response.sendRedirect(ctx + "/registro.jsp?error=campos");
        return;
    }
    if (clave.length() < 6 || !clave.equals(confirmar)) {
        response.sendRedirect(ctx + "/registro.jsp?error=clave");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        // ---------- 2) Crear usuario ----------
        ps = con.prepareStatement(
            "INSERT INTO usuario (correo, password_hash) VALUES (?, ?)",
            Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, correo.trim().toLowerCase());
        ps.setString(2, claveCifrada(correo, clave));
        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        rs.next();
        int idUsuario = rs.getInt(1);
        cerrar(rs, ps);

        // ---------- 3) Crear perfil (relacion 1:1) ----------
        ps = con.prepareStatement(
            "INSERT INTO perfil (id_usuario, documento, nombres, apellidos, telefono, direccion) "
            + "VALUES (?, ?, ?, ?, ?, ?)");
        ps.setInt(1, idUsuario);
        ps.setString(2, documento.trim());
        ps.setString(3, nombres.trim());
        ps.setString(4, apellidos.trim());
        ps.setString(5, telefono.trim());
        ps.setString(6, direccion == null ? null : direccion.trim());
        ps.executeUpdate();
        cerrar(ps);

        // ---------- 4) Asignar el rol elegido (relacion N:M usuario_rol) ----------
        ps = con.prepareStatement("SELECT id_rol FROM rol WHERE nombre = ?");
        ps.setString(1, tipoCuenta);
        rs = ps.executeQuery();
        rs.next();
        int idRol = rs.getInt("id_rol");
        cerrar(rs, ps);

        ps = con.prepareStatement("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)");
        ps.setInt(1, idUsuario);
        ps.setInt(2, idRol);
        ps.executeUpdate();
        cerrar(ps);

        // ---------- 5) Si es INMOBILIARIA, crear tambien esa fila ----------
        if (esInmobiliaria) {
            ps = con.prepareStatement(
                "INSERT INTO inmobiliaria (id_usuario, nombre_comercial, nit, telefono_contacto, direccion) "
                + "VALUES (?, ?, ?, ?, ?)");
            ps.setInt(1, idUsuario);
            ps.setString(2, nombreComercial.trim());
            ps.setString(3, nit.trim());
            ps.setString(4, telefono.trim());
            ps.setString(5, direccionComercial == null ? null : direccionComercial.trim());
            ps.executeUpdate();
            cerrar(ps);
        }

        // ---------- 6) Bitacora ----------
        ps = con.prepareStatement(
            "INSERT INTO auditoria (id_usuario, accion, detalle, ip_origen) VALUES (?, 'REGISTRO', ?, ?)");
        ps.setInt(1, idUsuario);
        ps.setString(2, "Cuenta creada como " + tipoCuenta);
        ps.setString(3, request.getRemoteAddr());
        ps.executeUpdate();
        cerrar(ps);

        con.commit();
        response.sendRedirect(ctx + "/login.jsp?msg=registrado");

    } catch (SQLException ex) {
        deshacer(con);
        String estadoSql = ex.getSQLState();
        String m = ex.getMessage() == null ? "" : ex.getMessage();
        if ("23505".equals(estadoSql) && m.contains("uk_usuario_correo")) {
            response.sendRedirect(ctx + "/registro.jsp?error=correo");
        } else if ("23505".equals(estadoSql) && m.contains("uk_perfil_documento")) {
            response.sendRedirect(ctx + "/registro.jsp?error=documento");
        } else if ("23505".equals(estadoSql) && m.contains("uk_inmobiliaria_nit")) {
            response.sendRedirect(ctx + "/registro.jsp?error=nit");
        } else {
            response.sendRedirect(ctx + "/registro.jsp?error=bd");
        }
    } finally {
        cerrar(rs, ps, con);
    }
%>
