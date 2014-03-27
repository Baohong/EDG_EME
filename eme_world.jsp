<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<%@page buffer="2000kb" autoFlush="False"%> 
<html>
    <head>
		<meta http-equiv="X-UA-Compatible" content="IE=8" />
        <title>EME Downloads</title>
        <link href="schema.js" rel="exhibit/data" type="application/json" />
        <link href="ByCountry.jsp" rel="exhibit/data" type="application/json" />
        <link href="ByDate.js" rel="exhibit/data" type="application/json" />

        <script src="/simile_new/exhibit/api/exhibit-api.js?bundle=false" type="text/javascript"></script>
        <script src="/simile_new/exhibit/api/extensions/map/map-extension.js?bundle=false&service=openlayers" type="text/javascript"></script>
        <script src="/simile_new/exhibit/api/extensions/chart/chart-extension.js?bundle=false" type="text/javascript"></script>
        <script type="text/javascript" src="javaScripts/jquery-ui/js/jquery-1.5.1.min.js"></script>
        <script type="text/javascript" src="javaScripts/mapLegend.js"></script>
        <script type="text/javascript">
            
            function hideIFrame(countryCode){
                $("#loading_"+countryCode).fadeOut("slow", function(){$("#iframe_"+countryCode).fadeIn("slow")});
            }
            
            $(document).ready(function() {
                obj = new mapLegend({
                    "idOfCoder":"download-ratio-colors"
                    ,"dataURL":"ByCountry.jsp"
                    ,"renderInDiv":"mapLegend"
                    ,"mapDivID":"innoExhibitMap"
                });

            });
        </script>

        <link href='common.css' rel='stylesheet' type='text/css' />
        <link href='styles.css' rel='stylesheet' type='text/css' />
        <link href='table.css' rel='stylesheet' type='text/css' />
        <style>
            .setWH .loading{
                /*margin:0px auto;*/
                margin-left:100px;
            }

            .loading {
                width: 200px;
                height: 100px;
                line-height: 100px;
                background-color: #CCC;
                text-align: center;  
                vertical-align: center;
                -webkit-border-radius: 10px; /* Safari prototype */
                -moz-border-radius: 10px; /* Gecko browsers */
                border-radius: 10px; /* Everything else - limited support at the moment */
                margin-left:40px;

            }

            .loadingReset{
                width: 0px;
                height: 0px;
                display: none;
                visibility: hidden;
            }

            .hidden{
                display:none;
            }

            .noBorder{
                border: 0px;
            }

            .setWH{
                width: 400px; 
                height:320px;
                overflow: hidden;
            }
        </style>
    </head>
    <%@ include file="jspClasses/jsonServer.jsp" %><%
        Double maxCount = 0.0, minCount = 0.0;
        String sql;
        String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
        jsonServer obj = new jsonServer(hardWiredFilePath);

        sql = "SELECT MAX([%$##@_Alias].DownloadCount) as max_count, MIN([%$##@_Alias].DownloadCount) as min_count "+
                "FROM (SELECT [Country Code], SUM(Count) AS DownloadCount, FORMAT(MAX(date),'yyyy-mm-dd hh:mm:ss AMPM') AS latestDownDate FROM All_Downloads GROUP BY [Country Code])  AS [%$##@_Alias]";

        ResultSet rs = obj.executeQuery(sql);
        while (rs.next()) {
            maxCount = Double.parseDouble(rs.getString("max_count"));
            minCount = Double.parseDouble(rs.getString("min_count"));
        }
    %>
    <body style="margin:0pt;">
        <br/><br/>	
        <div ex:role="coder" ex:coderClass="ColorGradient" id="download-ratio-colors" ex:gradientPoints="0, #000000; 10,#0000AA;<% out.print(maxCount/2);%>, #00f0ff; <% out.print(maxCount);%>, #00ffff" ></div>
        <!--<div ex:role="coder" ex:coderClass="ColorGradient" id="download-ratio-colors" ex:gradientPoints="0.0, #0000ff; 1.0, #000fff; 310.0, #00f0ff; 3888.0, #00ffff" ></div>-->
        <div name="ByCountry" id="ByCountry" ex:itemtypes="ByCountry" ex:role="collection"> </div>
        <div id="ByDate" ex:itemtypes="ByDate" ex:role="collection"> </div>

        <div ex:role="viewPanel">
            <!--
            -->
            <div ex:collectionid="ByCountry" ex:expression=".label" ex:facetlabel="Countries" ex:height="20em" ex:role="facet"> </div>
            <div ex:collectionid="ByCountry" ex:expression=".downloadcount" ex:facetlabel="Downloads" ex:height="20em" ex:role="facet" ex:sortdirection="reverse"> </div>

            <div 
                ex:collectionid="ByCountry"
                ex:role="view" 
                ex:label="Map"
                ex:viewClass="OLMap"
                ex:type="vmap"
                ex:scaleControl="false"
                ex:scrollWheelZoom="false"
                ex:numZoomLevels="4"
                ex:polygon=".polygon"
                ex:latlngOrder="lnglat"
                ex:latlngPairSeparator="|"
                ex:colorKey=".downloadcount"
                ex:colorCoder="download-ratio-colors"
                ex:zoom="2"
                ex:mapHeight="600"
                ex:opacity="0.3"
                ex:borderWidth="0"
                id="innoExhibitMap"
                >
                <div ex:itemtypes="ByCountry" ex:role="lens" style="display: none;">
                    <div class="setWH">
                        <div class="setWH" ex:id-subcontent="loading_{{.countrycode}}" >
                            <br /><br />
                            <br /><br />
                            <br /><br />
                            <div class="loading">Loading. Please wait...</div>
                        </div>
                        <div class="hidden"  ex:id-subcontent="iframe_{{.countrycode}}" >
                            <iframe width="400px" height="320px;" scrolling="no" frameBorder="0" ex:src-subcontent="countryWisePlot.jsp?cc={{.countrycode}}&country={{.label}}" ></iframe>
                        </div>
                    </div>
                </div>
            </div>
            <div 
                ex:collectionid="ByCountry" 
                ex:label="Table" 
                ex:columnlabels="Country, Download Count, Latest Download Date" 
                ex:columns=".label, .downloadcount, .latestdowndate" 
                ex:label="Table" 
                ex:role="view" 
                ex:sortascending="false" 
                ex:sortcolumn="1" 
                ex:viewclass="TabularView"> </div>
            <div ex:role="view"
                 ex:viewClass="ScatterPlotView"
                 ex:collectionid="ByDate"
                 ex:label="Chart"
                 ex:x=".dayno"
                 ex:xLabel="Date"
                 ex:y=".downloadcount"
                 ex:yLabel="<BR/>Download Count"
                 ex:scroll="true"
                 ex:plotHeight="600"
                 ex:plotWidth="800"
                 ex:bubbleWidth="200"
                 ex:bubbleHeight="25"
                 ex:color="#608CB9"
                 >
                <div ex:itemtypes="ByDate" ex:role="lens" style="display: none">
                    <span ex:content=".downloadcount"></span> download(s) on <span ex:content=".label"></span>.
                </div>
            </div>
        </div>
        <div id="mapLegend" style="width: 500px; margin: 0px auto;">
            <div style="text-align: center; font-weight: bold; font-size: 15px; padding-bottom: 10px;">Legend (number of downloads)</div>
        </div>
       
       
    </body>
</html>