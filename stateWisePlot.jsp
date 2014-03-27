<%@page import="java.util.Map"%>
<%@page import="java.util.Set"%><%@ include file="jspClasses/jsonServer.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>

    </head>
    <body>
        <%
            String state, regionCode, maxDate, hardWiredFilePath;
            int totalDownloads = 0;
            int downloads = 0;
            ResultSet rs;

            maxDate = null;
            state = request.getParameter("state");
            regionCode = request.getParameter("rc");

            hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
            jsonServer obj = new jsonServer(hardWiredFilePath);

            ArrayList list = new ArrayList();
            ArrayList listVal = new ArrayList();
            ArrayList params = new ArrayList();
            params.add(state);
            
            String sql = "SELECT SWITCH(city IS NULL,'Unknown',true,city) as [city_name],sum(count) as [downloads] FROM all_download_details WHERE region_name=? GROUP BY SWITCH(city IS NULL,'Unknown',true,city) HAVING sum(count)>0 ORDER BY sum(count) DESC";
            
            rs = obj.executeQuery(sql,params);
            while (rs.next()) {
                listVal = new ArrayList();

                downloads = rs.getInt("downloads");
                totalDownloads += downloads;

                listVal.add(rs.getString("city_name"));
                listVal.add(downloads);

                list.add(listVal);
            }
            
            sql = "SELECT Format(MAX(date),'mm/dd/yyyy hh:mm AMPM')  FROM all_download_details WHERE region_name=?";
            rs = obj.executeQuery(sql,params);
            while (rs.next()) {
                maxDate = rs.getString(1);
            }


        %>
        <div id="content">
            <div style="width: 400px; height: 300px; " >
                <div style="text-align: center; font-family: Arial; font-weight: bold; font-size: x-small;"><% out.print(totalDownloads + " download(s) in " + state + ". ");%></div>
                <div style="text-align: center; font-family: Arial; font-weight: bold; font-size: x-small;"><% out.print(" Last download on " + maxDate + ". ");%></div>
                <div id="chart_div"></div>
            </div>
        </div>
    </body>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
        google.load("visualization", "1", {packages:["corechart"]});
        google.setOnLoadCallback(drawChart);
        function drawChart() {
            
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'City');
            data.addColumn('number', 'Download(s)');
            data.addRows(<% out.print(list.size());%>);
            <%
            String key;
            int count = 0;
            Iterator iterator = list.iterator();
            while (iterator.hasNext()) {
                listVal = (ArrayList) iterator.next();
                key = listVal.get(0).toString();
                out.println("data.setValue(" + count + ", 0, '" + key + "');");
                out.println("data.setValue(" + count + ", 1, " + listVal.get(1) + ");");
                count++;

            }
            %>
                
                var chart = new google.visualization.PieChart(document.getElementById("chart_div"));
                chart.draw(data, {width: 400, height: 300, title: '',pieSliceText:"none"});
                window.parent.hideIFrame('<% out.print(regionCode);%>');
            }
    </script>
</html>