<%@page contentType="application/json" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.util.*" %>
<%@include file="../jspClasses/login.jsp" %>
<%@ include file="../jspClasses/jsonServer.jsp" %>
<%!    public Date getDate(String dateStr) {
        String[] parts = dateStr.split("/");
        Integer year, month, day;

        year = Integer.parseInt(parts[2]);
        month = Integer.parseInt(parts[0])-1;
        day = Integer.parseInt(parts[1]);
        Calendar calendar = new GregorianCalendar(year, month, day);
        Date date = new java.sql.Date(calendar.getTimeInMillis());
        return date;
    }
%>
<%

    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);
    ArrayList params = new ArrayList();

    login loginObj = new login(getServletContext());
    String ret = loginObj.verify(request)[0];
    if (!(ret.equals("true"))) {
        out.close();
    }
    PreparedStatement ps = null;

    StringBuilder sql = new StringBuilder();
    sql.append("SELECT ip_address,count,date as [down_date],organization,country_code,country_name,region_name,region_code,region,city,zip_code,latitude,longitude,metro_code,area_code,isp,domain_name,lookup_error,email,full_name,firstname,lastname,locationcode,locationother,down_organization,howdidyouhear,productcode,downloadtimestamp,productfullname,productversion,productname,containsbinary,containssource,donotcontact,productcontent FROM all_download_details WHERE 1=1 ");
    if ((request.getParameter("fromDate") != null && request.getParameter("fromDate") != "")
            && (request.getParameter("toDate") != null && request.getParameter("toDate") != "")) {
        
        sql.append(" AND DateValue(date)>= ");
        sql.append("?");
        sql.append(" AND DateValue(date) <= ");
        sql.append("?");
        
        ps = obj.getPreparedStmt(sql.toString());
        ps.setDate(1, getDate(request.getParameter("fromDate")));
        ps.setDate(2, getDate(request.getParameter("toDate")));
        
        
    } else if (request.getParameter("fromDate") != null && request.getParameter("fromDate") != "") {
        params.add(request.getParameter("fromDate"));
        sql.append(" AND DateValue(date) >= ");
        sql.append("?");

        ps = obj.getPreparedStmt(sql.toString());
        ps.setDate(1, getDate(request.getParameter("fromDate")));
    } else if (request.getParameter("toDate") != null && request.getParameter("toDate") != "") {
        params.add(request.getParameter("toDate"));

        sql.append(" AND DateValue(date) <= ");
        sql.append("?");
        ps = obj.getPreparedStmt(sql.toString());
        ps.setDate(1, getDate(request.getParameter("toDate")));
    }

    //out.print(sql.toString());
    //ResultSet rs = obj.executeQuery(sql.toString(), params);
    
    HashMap hint = new HashMap();
    hint.put("zip_code", "STRING");
    obj.setHint(hint);
    
    ResultSet rs = ps.executeQuery();
    out.write(obj.getJson(rs, true));
%>
