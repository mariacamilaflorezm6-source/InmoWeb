<%--
    admin/catalogos.jsp - Alta de valores en los catalogos del sistema:
    ciudad, tipo_propiedad y caracteristica. Son catalogos de solo
    agregar (no se editan ni se borran, para no romper las propiedades
    que ya los usan mediante llave foranea).

    Los 3 campos de "nombre" se eligen de un desplegable con sugerencias
    (las que ya existen en la base de datos se excluyen automaticamente),
    con una opcion "Otro (escribir)..." que revela un campo de texto libre
    solo cuando de verdad se necesita algo fuera de la lista.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Catalogos";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");

    Connection con = null;
    try {
        con = abrirConexion();
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><i class="bi bi-tags"></i> Catálogos del sistema</h3>
<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>
<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %></div><% } %>
<% if (request.getAttribute("errorBD") != null) { %>
<div class="alert alert-danger">Error: <%= esc((String) request.getAttribute("errorBD")) %></div>
<% } %>

<div class="row g-4">
  <!-- ==================== CIUDADES ==================== -->
  <div class="col-md-4">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-geo-alt"></i> Ciudades</div>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/admin/catalogo_controlador.jsp" id="formCiudad">
          <input type="hidden" name="accion" value="agregar_ciudad">
          <div class="input-group input-group-sm mb-2">
            <select class="form-select" name="nombre" id="selectCiudad" required
                    onchange="document.getElementById('otroCiudad').classList.toggle('d-none', this.value !== '__otro__')">
              <option value="" selected disabled>Seleccione una ciudad...</option>
<%
    java.util.List<String> ciudadesSugeridas = new java.util.ArrayList<String>(java.util.Arrays.asList(
        "Bucaramanga", "Floridablanca", "Giron", "Piedecuesta", "San Gil", "Barrancabermeja",
        "Barichara", "Zapatoca", "Socorro", "Malaga", "Velez", "Lebrija", "Cucuta",
        "Bogota", "Medellin", "Cali", "Cartagena", "Barranquilla", "Pereira", "Manizales",
        "Ibague", "Villavicencio", "Santa Marta", "Monteria", "Neiva", "Armenia",
        "Popayan", "Pasto", "Tunja", "Valledupar"
    ));
    try {
        Statement stCiuExist = con.createStatement();
        ResultSet rsCiuExist = stCiuExist.executeQuery("SELECT nombre FROM ciudad");
        while (rsCiuExist.next()) ciudadesSugeridas.remove(rsCiuExist.getString("nombre"));
        cerrar(rsCiuExist, stCiuExist);
    } catch (SQLException ex) { /* si falla, se muestran todas las sugeridas */ }
    for (String c : ciudadesSugeridas) {
%>
              <option value="<%= c %>"><%= c %></option>
<%  } %>
              <option value="__otro__">Otro (escribir)...</option>
            </select>
          </div>
          <div class="input-group input-group-sm mb-2 d-none" id="otroCiudad">
            <input type="text" class="form-control" name="nombre_otro" placeholder="Escriba la ciudad nueva">
          </div>
          <div class="input-group input-group-sm mb-2">
            <select class="form-select" name="departamento" required>
              <option value="" selected disabled>Seleccione el departamento...</option>
<%
    String[] departamentosColombia = {
        "Amazonas","Antioquia","Arauca","Atlantico","Bogota D.C.","Bolivar","Boyaca",
        "Caldas","Caqueta","Casanare","Cauca","Cesar","Choco","Cordoba","Cundinamarca",
        "Guainia","Guaviare","Huila","La Guajira","Magdalena","Meta","Narino",
        "Norte de Santander","Putumayo","Quindio","Risaralda","San Andres y Providencia",
        "Santander","Sucre","Tolima","Valle del Cauca","Vaupes","Vichada"
    };
    for (String dep : departamentosColombia) {
%>
              <option value="<%= dep %>"><%= dep %></option>
<%  } %>
            </select>
          </div>
          <button class="btn btn-sm btn-primary w-100">Agregar ciudad</button>
        </form>
        <hr>
        <p class="small fw-bold text-muted mb-1">
            <i class="bi bi-list-ul"></i> Ciudades ya registradas</p>
        <div class="list-group list-group-flush small" style="max-height:220px; overflow-y:auto;">
<%
    try {
        Statement stCiuLista = con.createStatement();
        ResultSet rsCiuLista = stCiuLista.executeQuery(
            "SELECT c.nombre, COUNT(p.id_propiedad) AS usos "
            + "FROM ciudad c LEFT JOIN propiedad p ON p.id_ciudad = c.id_ciudad "
            + "GROUP BY c.id_ciudad, c.nombre ORDER BY c.nombre");
        int totalCiu = 0;
        while (rsCiuLista.next()) {
            totalCiu++;
%>
          <div class="list-group-item d-flex justify-content-between align-items-center px-0 py-1 border-0">
            <span><%= esc(rsCiuLista.getString("nombre")) %></span>
            <span class="badge text-bg-light text-muted"><%= rsCiuLista.getInt("usos") %> propiedad(es)</span>
          </div>
<%      }
        cerrar(rsCiuLista, stCiuLista);
        if (totalCiu == 0) { %>
          <p class="text-muted mb-0">Todavia no hay ciudades registradas.</p>
<%      }
    } catch (SQLException ex) { %>
          <p class="text-danger mb-0">Error al listar: <%= esc(ex.getMessage()) %></p>
<%  } %>
        </div>
      </div>
    </div>
  </div>

  <!-- ==================== TIPOS DE PROPIEDAD ==================== -->
  <div class="col-md-4">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-house"></i> Tipos de propiedad</div>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/admin/catalogo_controlador.jsp" id="formTipo">
          <input type="hidden" name="accion" value="agregar_tipo">
          <div class="input-group input-group-sm mb-2">
            <select class="form-select" name="nombre" id="selectTipo" required
                    onchange="document.getElementById('otroTipo').classList.toggle('d-none', this.value !== '__otro__')">
              <option value="" selected disabled>Seleccione un tipo...</option>
<%
    java.util.List<String> tiposSugeridos = new java.util.ArrayList<String>(java.util.Arrays.asList(
        "Casa", "Apartamento", "Apartaestudio", "Casa campestre", "Finca", "Lote",
        "Local comercial", "Oficina", "Bodega", "Terreno", "Cabana", "Penthouse", "Duplex"
    ));
    try {
        Statement stTipoExist = con.createStatement();
        ResultSet rsTipoExist = stTipoExist.executeQuery("SELECT nombre FROM tipo_propiedad");
        while (rsTipoExist.next()) tiposSugeridos.remove(rsTipoExist.getString("nombre"));
        cerrar(rsTipoExist, stTipoExist);
    } catch (SQLException ex) { /* si falla, se muestran todas las sugeridas */ }
    for (String t : tiposSugeridos) {
%>
              <option value="<%= t %>"><%= t %></option>
<%  } %>
              <option value="__otro__">Otro (escribir)...</option>
            </select>
          </div>
          <div class="input-group input-group-sm mb-2 d-none" id="otroTipo">
            <input type="text" class="form-control" name="nombre_otro" placeholder="Escriba el tipo nuevo">
          </div>
          <button class="btn btn-sm btn-primary w-100">Agregar tipo</button>
        </form>
        <hr>
        <p class="small fw-bold text-muted mb-1">
            <i class="bi bi-list-ul"></i> Tipos ya registrados</p>
        <div class="list-group list-group-flush small" style="max-height:220px; overflow-y:auto;">
<%
    try {
        Statement stTipoLista = con.createStatement();
        ResultSet rsTipoLista = stTipoLista.executeQuery(
            "SELECT t.nombre, COUNT(p.id_propiedad) AS usos "
            + "FROM tipo_propiedad t LEFT JOIN propiedad p ON p.id_tipo = t.id_tipo "
            + "GROUP BY t.id_tipo, t.nombre ORDER BY t.nombre");
        int totalTipoLista = 0;
        while (rsTipoLista.next()) {
            totalTipoLista++;
%>
          <div class="list-group-item d-flex justify-content-between align-items-center px-0 py-1 border-0">
            <span><i class="bi <%= iconoTipo(rsTipoLista.getString("nombre")) %> text-muted me-1"></i>
                <%= esc(rsTipoLista.getString("nombre")) %></span>
            <span class="badge text-bg-light text-muted"><%= rsTipoLista.getInt("usos") %> propiedad(es)</span>
          </div>
<%      }
        cerrar(rsTipoLista, stTipoLista);
        if (totalTipoLista == 0) { %>
          <p class="text-muted mb-0">Todavia no hay tipos registrados.</p>
<%      }
    } catch (SQLException ex) { %>
          <p class="text-danger mb-0">Error al listar: <%= esc(ex.getMessage()) %></p>
<%  } %>
        </div>
      </div>
    </div>
  </div>

  <!-- ==================== CARACTERISTICAS ==================== -->
  <div class="col-md-4">
    <div class="card shadow-sm h-100">
      <div class="card-header bg-white fw-bold"><i class="bi bi-list-check"></i> Caracteristicas</div>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/admin/catalogo_controlador.jsp" id="formCaracteristica">
          <input type="hidden" name="accion" value="agregar_caracteristica">
          <div class="input-group input-group-sm mb-2">
            <select class="form-select" name="nombre" id="selectCaracteristica" required
                    onchange="document.getElementById('otroCaracteristica').classList.toggle('d-none', this.value !== '__otro__')">
              <option value="" selected disabled>Seleccione una caracteristica...</option>
<%
    java.util.List<String> caracSugeridas = new java.util.ArrayList<String>(java.util.Arrays.asList(
        "Piscina", "Parqueadero", "Ascensor", "Gimnasio", "Balcon", "Zona BBQ",
        "Vigilancia 24 horas", "Jardin", "Terraza", "Amoblado", "Chimenea", "Jacuzzi",
        "Aire acondicionado", "Calefaccion", "Deposito", "Zona de lavanderia",
        "Cuarto de servicio", "Cocina integral", "Closet", "Estudio"
    ));
    try {
        Statement stCarExist = con.createStatement();
        ResultSet rsCarExist = stCarExist.executeQuery("SELECT nombre FROM caracteristica");
        while (rsCarExist.next()) caracSugeridas.remove(rsCarExist.getString("nombre"));
        cerrar(rsCarExist, stCarExist);
    } catch (SQLException ex) { /* si falla, se muestran todas las sugeridas */ }
    for (String c : caracSugeridas) {
%>
              <option value="<%= c %>"><%= c %></option>
<%  } %>
              <option value="__otro__">Otro (escribir)...</option>
            </select>
          </div>
          <div class="input-group input-group-sm mb-2 d-none" id="otroCaracteristica">
            <input type="text" class="form-control" name="nombre_otro" placeholder="Escriba la caracteristica nueva">
          </div>
          <button class="btn btn-sm btn-primary w-100">Agregar caracteristica</button>
        </form>
        <hr>
        <p class="small fw-bold text-muted mb-1">
            <i class="bi bi-list-ul"></i> Caracteristicas ya registradas</p>
        <div class="list-group list-group-flush small" style="max-height:220px; overflow-y:auto;">
<%
    try {
        Statement stCarLista = con.createStatement();
        ResultSet rsCarLista = stCarLista.executeQuery(
            "SELECT car.nombre, COUNT(pc.id_propiedad) AS usos "
            + "FROM caracteristica car "
            + "  LEFT JOIN propiedad_caracteristica pc ON pc.id_caracteristica = car.id_caracteristica "
            + "GROUP BY car.id_caracteristica, car.nombre ORDER BY car.nombre");
        int totalCarLista = 0;
        while (rsCarLista.next()) {
            totalCarLista++;
%>
          <div class="list-group-item d-flex justify-content-between align-items-center px-0 py-1 border-0">
            <span><%= esc(rsCarLista.getString("nombre")) %></span>
            <span class="badge text-bg-light text-muted"><%= rsCarLista.getInt("usos") %> propiedad(es)</span>
          </div>
<%      }
        cerrar(rsCarLista, stCarLista);
        if (totalCarLista == 0) { %>
          <p class="text-muted mb-0">Todavia no hay caracteristicas registradas.</p>
<%      }
    } catch (SQLException ex) { %>
          <p class="text-danger mb-0">Error al listar: <%= esc(ex.getMessage()) %></p>
<%  } %>
        </div>
      </div>
    </div>
  </div>
</div>
<% cerrar(con); %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
