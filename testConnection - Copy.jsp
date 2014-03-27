<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%
    String filename = "D:/Public/Server/tomcat7042/webapps/EME/WEB-INF/EME_files/EME-Downloads.mdb";
            String database = "JDBC:ODBC:Driver=Microsoft Access Driver (*.mdb, *.accdb); DBQ=";
            database += filename.trim() + ";DriverID=22;READONLY=true}"; // add on to the end 
            try {
                Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
                Connection con = DriverManager.getConnection(database, "", "");
            } catch (ClassNotFoundException ex) {
                out.print("class error"+ex.toString());
            } catch (SQLException ex) {
                out.print("SQL"+ex.toString());
            }
%>