<%@page contentType="text/html" pageEncoding="UTF-8"%><%@include file="../jspClasses/login.jsp" %><%
    login loginObj = new login(getServletContext());
    String ret[] = loginObj.verify(request);
    out.print(ret[0]);
%>
