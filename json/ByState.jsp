<%@ include file="../jspClasses/jsonServer.jsp" %><%
    String sql;
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);

    HashMap hint = new HashMap();
    hint.put("polygon", "ARRAY");
    hint.put("downloadcount", "INTEGER");

    String browserType = request.getHeader("User-Agent");
    if (browserType.indexOf("MSIE") != -1) {
        sql = "SELECT states.regionCode, states.polygon_ie as [polygon], sub.*";
        sql += " FROM (SELECT 'ByState' AS type, all_download_details.region_name AS label, sum(all_download_details.count) AS downloadCount, FORMAT(MAX(date),'yyyy-mm-dd hh:mm:ss AMPM') AS latestDownDate ";
        sql += "FROM all_download_details WHERE all_download_details.country_code='US' And all_download_details.region_name Is Not Null GROUP BY all_download_details.region_name)  AS sub LEFT JOIN states ON sub.label=states.regionName";
    } else {
        sql = "SELECT states.regionCode, states.polygon, sub.*";
        sql += " FROM (SELECT 'ByState' AS type, all_download_details.region_name AS label, sum(all_download_details.count) AS downloadCount, FORMAT(MAX(date),'yyyy-mm-dd hh:mm:ss AMPM') AS latestDownDate ";
        sql += "FROM all_download_details WHERE all_download_details.country_code='US' And all_download_details.region_name Is Not Null GROUP BY all_download_details.region_name)  AS sub LEFT JOIN states ON sub.label=states.regionName";
    }


    obj.setHint(hint);
    //out.write(obj.getJson(sql));
    obj.getJsonWithHeader(response, obj.getJson(sql));
%>