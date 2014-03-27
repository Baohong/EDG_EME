<%@include file="../jspClasses/login.jsp" %><%
   
    login loginObj = new login(getServletContext());
    out.print(loginObj.getUserIdFromHeader(request));
%>