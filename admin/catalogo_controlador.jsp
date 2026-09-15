<%--
    admin/catalogo_controlador.jsp - Inserta valores nuevos en ciudad,
    tipo_propiedad o caracteristica, traduciendo la violacion de UNIQUE
    a un mensaje claro.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String accion = request.getParameter("accion");
    String nombre = request.getParameter("nombre");
    // Si el usuario eligio "Otro (escribir)..." en el select, se usa lo que
    // escribio en el campo de texto que aparece al lado.
    if ("__otro__".equals(nombre)) {
        nombre = request.getParameter("nombre_otro");
    }

    Connection con = null; PreparedStatement ps = null;
    String destino;
    try {
        con = abrirConexion();

        if (nombre == null || nombre.trim().isEmpty()) {
            throw new SQLException("El nombre es obligatorio.");
        }

        if ("agregar_ciudad".equals(accion)) {
            String departamento = request.getParameter("departamento");
            ps = con.prepareStatement("INSERT INTO ciudad (nombre, departamento) VALUES (?, ?)");
            ps.setString(1, nombre.trim());
            ps.setString(2, departamento == null ? null : departamento.trim());
            ps.executeUpdate();

        } else if ("agregar_tipo".equals(accion)) {
            ps = con.prepareStatement("INSERT INTO tipo_propiedad (nombre) VALUES (?)");
            ps.setString(1, nombre.trim());
            ps.executeUpdate();

        } else if ("agregar_caracteristica".equals(accion)) {
            ps = con.prepareStatement("INSERT INTO caracteristica (nombre) VALUES (?)");
            ps.setString(1, nombre.trim());
            ps.executeUpdate();
        }
        cerrar(ps);
        destino = ctx + "/admin/catalogos.jsp?msg=" + java.net.URLEncoder.encode("Agregado correctamente.", "UTF-8");

    } catch (SQLException ex) {
        String amigable = "23505".equals(ex.getSQLState())
                ? "Ya existe un valor igual en ese catalogo."
                : ex.getMessage();
        destino = ctx + "/admin/catalogos.jsp?err=" + java.net.URLEncoder.encode(amigable, "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
