<%@page contentType="application/json" pageEncoding="ISO-8859-1"%><%@ include file="jspClasses/jsonServer.jsp" %>
<%
    String sql;
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);

    HashMap hint = new HashMap();
    hint.put("polygon", "ARRAY");
    hint.put("downloadcount", "INTEGER");

    String browserType = request.getHeader("User-Agent");
    if (browserType.indexOf("MSIE") != -1) {
        sql = "SELECT 'ByCountry' AS type,[%$##@_Alias].[Country Code], [%$##@_Alias].[latestDownDate], c.CNTRY_NAME AS [label], c.Lat&','&c.Lon as LatLon, c.Polygon_ie as [polygon], [%$##@_Alias].DownloadCount ";
        sql += " FROM (SELECT [Country Code], SUM(Count) AS DownloadCount, FORMAT(MAX(date),'yyyy-mm-dd hh:mm:ss AMPM') AS latestDownDate FROM All_Downloads GROUP BY [Country Code])  AS [%$##@_Alias], Countries AS c";
        sql += " WHERE ((([%$##@_Alias].[Country Code])=[CNTRY_CODE])) ORDER BY c.CNTRY_NAME";

    } else {
        sql = "SELECT 'ByCountry' AS type,[%$##@_Alias].[Country Code], [%$##@_Alias].[latestDownDate], c.CNTRY_NAME AS [label], c.Lat&','&c.Lon as LatLon, c.Polygon, [%$##@_Alias].DownloadCount ";
        sql += " FROM (SELECT [Country Code], SUM(Count) AS DownloadCount, FORMAT(MAX(date),'yyyy-mm-dd hh:mm:ss AMPM') AS latestDownDate FROM All_Downloads GROUP BY [Country Code])  AS [%$##@_Alias], Countries AS c";
        sql += " WHERE ((([%$##@_Alias].[Country Code])=[CNTRY_CODE])) ORDER BY c.CNTRY_NAME";

    }

    obj.setHint(hint);
    out.write(obj.getJson(sql));
%>