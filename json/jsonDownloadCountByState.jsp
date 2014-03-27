<%@page contentType="application/json" pageEncoding="ISO-8859-1"%>
<%@ include file="../jspClasses/jsonServer.jsp" %>
<%
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);
    
    String sql = "SELECT total_download_count, region_name , region_name as [id] FROM download_count_by_state";
    out.write(obj.getJson(sql));
%>