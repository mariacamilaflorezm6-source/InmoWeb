package com.inmoweb.filtro;

import java.io.IOException;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * ControlAccesoFilter - Filtro de servlet que protege las rutas privadas
 * de InmoWeb segun el rol del usuario autenticado.
 *
 * Se declara en web.xml con url-pattern "/*", es decir que TODA peticion
 * pasa primero por aqui antes de llegar a cualquier JSP. El filtro decide,
 * segun el prefijo de la URL, si la ruta es publica o requiere un rol
 * especifico:
 *
 *   /cliente/*       -> requiere el rol CLIENTE
 *   /inmobiliaria/*  -> requiere el rol INMOBILIARIA
 *   /admin/*         -> requiere el rol ADMINISTRADOR
 *   cualquier otra    -> publica, no se exige sesion
 *
 * Esto cumple el requisito del enunciado: "si un usuario no autenticado,
 * o autenticado sin el rol requerido, intenta ingresar escribiendo la URL
 * directamente, el sistema lo redirige a una pagina de acceso denegado".
 *
 * Ocultar los menus en el HTML (como ya hace cabecera.jspf) NO es control
 * de acceso real: por eso esta validacion se hace aqui, en el servidor,
 * antes de que el JSP protegido siquiera se ejecute.
 */
public class ControlAccesoFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No requiere inicializacion especial.
    }

    @Override
    public void destroy() {
        // No requiere liberar recursos.
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request   = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Fija UTF-8 en TODA peticion y respuesta, en un solo lugar central.
        // Sin esto, un formulario enviado por POST (por ejemplo, una direccion
        // con tilde o una "n" en un nombre) se puede guardar mal en la base
        // de datos aunque las paginas ya declaren pageEncoding UTF-8, porque
        // ese atributo solo controla como se LEE el .jsp, no como se leen
        // los parametros que llegan del navegador.
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String ctx  = request.getContextPath();
        String uri  = request.getRequestURI();
        // "path" queda relativo a la aplicacion, ej: /cliente/panel.jsp
        String path = uri.substring(ctx.length());

        String rolRequerido = rolRequeridoParaLaRuta(path);

        // Ruta publica (landing, login, registro, catalogo publico, css, etc.)
        if (rolRequerido == null) {
            chain.doFilter(req, res);
            return;
        }

        // A partir de aqui la ruta SI requiere sesion y un rol especifico.
        HttpSession session = request.getSession(false); // false: no crea una sesion nueva
        Integer idUsuario = (session == null) ? null : (Integer) session.getAttribute("idUsuario");

        if (idUsuario == null) {
            // No hay sesion activa: no hay diferencia entre "no autenticado"
            // y "sesion expirada", en ambos casos se manda al login.
            response.sendRedirect(ctx + "/login.jsp?error=sesion");
            return;
        }

        @SuppressWarnings("unchecked")
        List<String> rolesDelUsuario = (List<String>) session.getAttribute("roles");
        boolean autorizado = rolesDelUsuario != null && rolesDelUsuario.contains(rolRequerido);

        if (!autorizado) {
            // Esta autenticado, pero con un rol que no corresponde a esta ruta.
            response.sendRedirect(ctx + "/acceso_denegado.jsp");
            return;
        }

        // Autenticado y con el rol correcto: continua hacia el JSP solicitado.
        chain.doFilter(req, res);
    }

    /**
     * Determina que rol exige una ruta, a partir de su prefijo de carpeta.
     * Devuelve null si la ruta es publica (no requiere sesion).
     */
    private String rolRequeridoParaLaRuta(String path) {
        if (path.startsWith("/cliente/"))      return "CLIENTE";
        if (path.startsWith("/inmobiliaria/")) return "INMOBILIARIA";
        if (path.startsWith("/admin/"))        return "ADMINISTRADOR";
        return null;
    }
}
