<%--
    inmobiliaria/propiedad_controlador.jsp - Controlador del CRUD de propiedades.
    Acciones: crear | editar | baja | reactivar
    Cada operacion verifica que la propiedad pertenezca a la inmobiliaria
    de la sesion actual (nunca se confia solo en el rol: se valida el dueno).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    String destino;

    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        // Resuelve el id_inmobiliaria del usuario en sesion (la agencia que administra)
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new SQLException("Su cuenta no tiene una agencia asociada.");
        }
        int idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        // ========== CREAR ==========
        if ("crear".equals(accion)) {
            String matricula   = request.getParameter("matricula_inmobiliaria");
            String titulo      = request.getParameter("titulo");
            String descripcion = request.getParameter("descripcion");
            String direccion   = request.getParameter("direccion");
            String operacion   = request.getParameter("operacion");
            int idCiudad = aEntero(request.getParameter("id_ciudad"), 0);
            int idTipo   = aEntero(request.getParameter("id_tipo"), 0);
            double precio = aDoble(request.getParameter("precio"), 0);
            double areaM2 = aDoble(request.getParameter("area_m2"), 0);

            if (matricula == null || matricula.trim().isEmpty() || titulo == null || titulo.trim().isEmpty()
                    || precio <= 0 || idCiudad == 0 || idTipo == 0) {
                throw new SQLException("Complete los campos obligatorios.");
            }

            ps = con.prepareStatement(
                "INSERT INTO propiedad (matricula_inmobiliaria, id_inmobiliaria, id_tipo, id_ciudad, "
                + "  titulo, descripcion, precio, area_m2, direccion, operacion) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, matricula.trim());
            ps.setInt(2, idInmobiliaria);
            ps.setInt(3, idTipo);
            ps.setInt(4, idCiudad);
            ps.setString(5, titulo.trim());
            ps.setString(6, descripcion == null ? null : descripcion.trim());
            ps.setDouble(7, precio);
            ps.setDouble(8, areaM2);
            ps.setString(9, direccion == null ? null : direccion.trim());
            ps.setString(10, operacion);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            rs.next();
            int idPropiedad = rs.getInt(1);
            cerrar(rs, ps);

            guardarCaracteristicas(con, idPropiedad, request.getParameterValues("caracteristica"));
            guardarImagenes(con, idPropiedad, request);

            con.commit();
            destino = ctx + "/inmobiliaria/propiedades.jsp?msg="
                    + java.net.URLEncoder.encode("Propiedad publicada correctamente.", "UTF-8");

        // ========== EDITAR ==========
        } else if ("editar".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);

            // Verifica que la propiedad sea de ESTA inmobiliaria antes de tocar nada
            ps = con.prepareStatement(
                "SELECT id_propiedad FROM propiedad WHERE id_propiedad = ? AND id_inmobiliaria = ?");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idInmobiliaria);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new SQLException("Esa propiedad no existe o no le pertenece.");
            }
            cerrar(rs, ps);

            String titulo      = request.getParameter("titulo");
            String descripcion = request.getParameter("descripcion");
            String direccion   = request.getParameter("direccion");
            String operacion   = request.getParameter("operacion");
            String estado      = request.getParameter("estado");
            int idCiudad = aEntero(request.getParameter("id_ciudad"), 0);
            int idTipo   = aEntero(request.getParameter("id_tipo"), 0);
            double precio = aDoble(request.getParameter("precio"), 0);
            double areaM2 = aDoble(request.getParameter("area_m2"), 0);

            ps = con.prepareStatement(
                "UPDATE propiedad SET titulo=?, descripcion=?, precio=?, area_m2=?, direccion=?, "
                + "  operacion=?, estado=?, id_ciudad=?, id_tipo=? "
                + "WHERE id_propiedad=? AND id_inmobiliaria=?");
            ps.setString(1, titulo.trim());
            ps.setString(2, descripcion == null ? null : descripcion.trim());
            ps.setDouble(3, precio);
            ps.setDouble(4, areaM2);
            ps.setString(5, direccion == null ? null : direccion.trim());
            ps.setString(6, operacion);
            ps.setString(7, estado);
            ps.setInt(8, idCiudad);
            ps.setInt(9, idTipo);
            ps.setInt(10, idPropiedad);
            ps.setInt(11, idInmobiliaria);
            ps.executeUpdate();
            cerrar(ps);

            // Reemplaza caracteristicas e imagenes por las nuevas seleccionadas
            ps = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);
            guardarCaracteristicas(con, idPropiedad, request.getParameterValues("caracteristica"));

            ps = con.prepareStatement("DELETE FROM imagen_propiedad WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);
            guardarImagenes(con, idPropiedad, request);

            con.commit();
            destino = ctx + "/inmobiliaria/propiedades.jsp?msg="
                    + java.net.URLEncoder.encode("Cambios guardados correctamente.", "UTF-8");

        // ========== BAJA (logica) ==========
        } else if ("baja".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            ps = con.prepareStatement(
                "UPDATE propiedad SET activo = 0, estado = 'INACTIVA' "
                + "WHERE id_propiedad = ? AND id_inmobiliaria = ?");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idInmobiliaria);
            int filas = ps.executeUpdate();
            cerrar(ps);
            if (filas == 0) throw new SQLException("Esa propiedad no le pertenece.");
            con.commit();
            destino = ctx + "/inmobiliaria/propiedades.jsp?msg="
                    + java.net.URLEncoder.encode("Propiedad dada de baja.", "UTF-8");

        // ========== REACTIVAR ==========
        } else if ("reactivar".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            ps = con.prepareStatement(
                "UPDATE propiedad SET activo = 1, estado = 'DISPONIBLE' "
                + "WHERE id_propiedad = ? AND id_inmobiliaria = ?");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idInmobiliaria);
            int filas = ps.executeUpdate();
            cerrar(ps);
            if (filas == 0) throw new SQLException("Esa propiedad no le pertenece.");
            con.commit();
            destino = ctx + "/inmobiliaria/propiedades.jsp?msg="
                    + java.net.URLEncoder.encode("Propiedad reactivada.", "UTF-8");
        } else {
            destino = ctx + "/inmobiliaria/propiedades.jsp";
        }

    } catch (SQLException ex) {
        deshacer(con);
        String m = ex.getMessage() == null ? "" : ex.getMessage();
        String amigable = "23505".equals(ex.getSQLState())
                ? "Ya existe una propiedad con esa matricula inmobiliaria."
                : m;
        destino = ctx + "/inmobiliaria/propiedades.jsp?err=" + java.net.URLEncoder.encode(amigable, "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
<%!
    /** Inserta en propiedad_caracteristica una fila por cada checkbox marcado. */
    void guardarCaracteristicas(Connection con, int idPropiedad, String[] idsCaracteristica)
            throws SQLException {
        if (idsCaracteristica == null) return;
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?, ?)");
        for (String idTxt : idsCaracteristica) {
            try {
                int idCaracteristica = Integer.parseInt(idTxt.trim());
                ps.setInt(1, idPropiedad);
                ps.setInt(2, idCaracteristica);
                ps.executeUpdate();
            } catch (NumberFormatException ignorado) { }
        }
        ps.close();
    }

    /** Inserta en imagen_propiedad una fila por cada URL no vacia (url_imagen_0..3). */
    void guardarImagenes(Connection con, int idPropiedad, HttpServletRequest request)
            throws SQLException {
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO imagen_propiedad (id_propiedad, url_imagen, es_principal, orden) "
            + "VALUES (?, ?, ?, ?)");
        int orden = 0;
        for (int i = 0; i < 4; i++) {
            String url = request.getParameter("url_imagen_" + i);
            if (url != null && !url.trim().isEmpty()) {
                ps.setInt(1, idPropiedad);
                ps.setString(2, url.trim());
                ps.setInt(3, orden == 0 ? 1 : 0);
                ps.setInt(4, orden + 1);
                ps.executeUpdate();
                orden++;
            }
        }
        ps.close();
    }
%>
