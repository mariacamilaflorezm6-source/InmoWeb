<%-- logout.jsp - Cierra la sesion y regresa a la landing page. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    session.invalidate();
    response.sendRedirect("index.jsp");
%>
