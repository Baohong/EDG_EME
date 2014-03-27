<%@page contentType="application/json" pageEncoding="ISO-8859-1"%><%@ include file="../jspClasses/jsonServer.jsp" %><%
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);
    
    String sql = "SELECT label, type,  DayNo, DownloadCount FROM ByDateState";
    // String sql = "SELECT count(*)as netty FROM ByDateState";
    out.write(obj.getJson(sql,true));
%>