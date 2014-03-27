<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.net.URL"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../jspClasses/jsonServer.jsp" %>

<%
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);

    URL geolocator;
    String rip, geoInfo, selectSQL, insertSQL, val, updateSQL;
    BufferedReader in;
    String[] geoInfoArr;
    int hit = 0, miss = 0, indx = 1;
    ResultSet rs;
    java.sql.Timestamp sqlDate;
    
    /*
    updateSQL = "UPDATE downloads SET productcode=15 WHERE productcode=10 AND downloadtimestamp>#7/26/2011 8:0:0 PM#";
    obj.executeQuery(updateSQL);
    updateSQL = "UPDATE downloads SET productcode=16 WHERE productcode=11 AND downloadtimestamp>#7/26/2011 8:0:0 PM#";
    obj.executeQuery(updateSQL);
    */

    out.print("<h1>Inserting missing records into \"all_downloads_table\" from \"downloads\".</h1>");
    insertSQL = "insert into All_Downloads_Table([IP Address], count,\"date\",[Country Code],[Region Code],city,[ZIP Code],Latitude,Longitude";
    insertSQL += ",[Metro Code],[Area Code],ISP,Organization) ";
    insertSQL += "values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
    PreparedStatement ps = obj.getPreparedStmt(insertSQL);

    selectSQL = "SELECT d.ipaddress,downloadtimestamp FROM downloads d LEFT OUTER JOIN all_downloads_table t ON (d.ipaddress=t.[ip address] AND d.downloadtimestamp=t.date)WHERE t.[ip address] IS NULL";
    rs = obj.executeQuery(selectSQL);

    while (rs.next()) {
        
        rip = rs.getString(1);
        sqlDate = (java.sql.Timestamp) rs.getTimestamp("downloadtimestamp");

        if (rip != null && rip.length() >= 7) {
            in = null;
            try {
                geolocator = new URL("http://geoip3.maxmind.com/f?l=uHb8LATVUFub&i=" + rip);
                in = new BufferedReader(new InputStreamReader(geolocator.openStream()));
                geoInfo = in.readLine();

                if (geoInfo != null) {
                    geoInfoArr = geoInfo.split(",");
                    if (geoInfoArr[8].startsWith("\"")) {
                        geoInfoArr[8] = geoInfoArr[8].substring(1, geoInfoArr[8].length() - 1);
                    }
                    if (geoInfoArr[9].startsWith("\"")) {
                        geoInfoArr[9] = geoInfoArr[9].substring(1, geoInfoArr[9].length() - 1);
                    }
                    indx = 0;
                    ps.setString(++indx, rip);
                    ps.setString(++indx, "1");

                    ps.setTimestamp(++indx, sqlDate);
                    ps.setString(++indx, geoInfoArr[0]);
                    ps.setString(++indx, geoInfoArr[1]);
                    ps.setString(++indx, geoInfoArr[2]);
                    ps.setString(++indx, geoInfoArr[3]);
                    ps.setString(++indx, geoInfoArr[4]);
                    ps.setString(++indx, geoInfoArr[5]);
                    ps.setString(++indx, geoInfoArr[6]);
                    ps.setString(++indx, geoInfoArr[7]);
                    ps.setString(++indx, geoInfoArr[8]);
                    ps.setString(++indx, geoInfoArr[9]);
                    
                    try {
                        if (ps.executeUpdate() == 1) {
                            hit++;
                        } else {
                            miss++;
                            out.println("Error! Could not insert record.<br>");
                        };
                    } catch (Exception e) {
                        miss++;
                        out.println("Error: " + e.toString() + "<br>");
                    }

                }


            } catch (Exception e) {
                out.println("Error: " + e);
            } finally {
                if (in != null) {
                    in.close();
                }
            }
        }

    }

    out.print("<h1>" + hit + " records inserted. " + miss + " insert statements had issues.</h1>");
%>
