<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../jspClasses/jsonServer.jsp" %>
<%
    out.print("<h1>Inserting missing information into downloads table.</h1>");

    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);

    Connection con = null;
    Statement s = null;
    Statement s1 = null;
    Statement s2 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    int hit = 0, miss = 0;

    try {
        String filename = hardWiredFilePath + "EME-Downloads.mdb";
        String database = "jdbc:odbc:Driver={Microsoft Access Driver (*.mdb)};DBQ=";
        database += filename.trim() + ";DriverID=22;READONLY=true}"; // add on to the end 
        StringBuilder query = new StringBuilder();
        String select, insert, date;
        String ip_address, productcode, locationcode, locationother, organization;
        ip_address = productcode = locationcode = locationother = organization = null;

        Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
        // now we can get the connection from the DriverManager
        con = DriverManager.getConnection(database, "", "");
        s = con.createStatement();
        s1 = con.createStatement();
        s2 = con.createStatement();

        //query.append("SELECT DISTINCT ip_address,date FROM all_download_details dtl");
        //query.append(" LEFT OUTER JOIN downloads d ON dtl.ip_address=d.ipaddress AND dtl.date=d.downloadtimestamp");
        //query.append(" WHERE d.email IS NULL");

        query.append("SELECT dtl.[ip address] as ip_address,dtl.date,dtl.[region code] as region_code,dtl.city,dtl.organization FROM all_downloads_table dtl");
        query.append(" LEFT OUTER JOIN downloads d ON dtl.[ip address]=d.ipaddress AND dtl.date=d.downloadtimestamp");
        query.append(" WHERE d.ipaddress IS NULL");

        rs = s.executeQuery(query.toString());

        int t = 0;
        boolean first = true;
        while (rs.next()) {

            date = rs.getString("date");
            select = new String();
            select = "SELECT productcode FROM products WHERE #" + date + "# >= startdate";
            select += " AND #" + date + "# < SWITCH(IsNull(enddate),DATE(),True,enddate)";

            rs1 = s1.executeQuery(select);


            if (rs1.next()) {

                ip_address = rs.getString("ip_address");
                productcode = rs1.getString("productcode");

                locationcode = rs.getString(3);
                locationcode = locationcode != null ? locationcode.replace("'", "''") : "";

                locationother = rs.getString(4);
                locationother = locationother != null ? locationother.replace("'", "''") : "";

                organization = rs.getString(5);
                organization = organization != null ? organization.replace("'", "''") : "";

                insert = new String();
                insert = "INSERT INTO downloads (ipaddress,productcode,downloadtimestamp,locationcode,locationother,organization) VALUES (";
                insert += "'" + ip_address + "'";
                insert += ",'" + productcode + "'";
                insert += ",#" + date + "#";
                insert += ",'" + locationcode + "'";
                insert += ",'" + locationother + "'";
                insert += ",'" + organization + "'";
                insert += ")";

                try {

                    if (s2.executeUpdate(insert) != 1) {
                        out.print("Error when executing query : <br>");
                        out.print(insert);
                        out.print("<hr>");
                        miss++;
                    } else {
                        hit++;
                    }

                } catch (SQLException e) {
                    out.print("Error when executing query : <br>");
                    out.print(insert);
                    out.print("<br>"+e.toString());
                    out.print("<hr>");
                }
            }


        }



    } catch (Exception e) {
        out.write("Error: " + e);
    } finally {

        if (rs != null) {
            rs.close();
        }
        if (rs1 != null) {
            rs1.close();
        }
        if (s != null) {
            s.close();
        }
        if (s1 != null) {
            s.close();
        }
        if (con != null) {
            con.close();
        }

    }
    out.print("<h1>" + hit + " records inserted. " + miss + " insert statements had issues.</h1>");
%>