<%@page contentType="application/json" pageEncoding="ISO-8859-1"%><%@ include file="jspClasses/jsonServer.jsp" %>
<%
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);
    
    String sql = "SELECT type, label, DayNo, DownloadCount FROM ByDate";
    out.write(obj.getJson(sql));
%>