<%@page import="java.util.Calendar"%>
<%@page import="java.util.Enumeration"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../jspClasses/login.jsp" %>
<%

    /* Enumeration headerNames = request.getHeaderNames();
    while (headerNames.hasMoreElements()) {
    String headerName = (String) headerNames.nextElement();
    out.println("<div>" + headerName + " : " + request.getHeader(headerName));
    }*/

    //verify valid user

/*
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    login loginObj = new login(hardWiredFilePath);
    String ret = loginObj.verify(request);
    if (!(ret.equals("true"))) {
        out.println(ret);
        out.close();
    }
    */


    login loginObj = new login(getServletContext());
    String[] ret = loginObj.verify(request);
    if (!(ret[0].equals("true"))) {
        out.println(loginObj.getNoAccessPage(ret));
        out.close();
	return;
    }

    String fromDate, toDate, jsonUrl, sumbit, headerMessage = null, todayDate;
    sumbit = (request.getParameter("form_post") != null) ? request.getParameter("form_post") : "false";

    Calendar today = Calendar.getInstance();
    long now = today.getTimeInMillis();
    todayDate = (today.get(Calendar.MONTH) + 1) + "/" + today.get(Calendar.DATE) + "/" + today.get(Calendar.YEAR);


    if (sumbit.equals("false")) {
        toDate = todayDate;
        today.add(Calendar.DATE, -30);
        fromDate = (today.get(Calendar.MONTH) + 1) + "/" + today.get(Calendar.DATE) + "/" + today.get(Calendar.YEAR);
    } else {
        fromDate = (request.getParameter("fromDate") != null) ? request.getParameter("fromDate") : (session.getAttribute("fromDate") != null ? ((String) session.getAttribute("fromDate")) : "");
        toDate = (request.getParameter("toDate") != null) ? request.getParameter("toDate") : (session.getAttribute("toDate") != null ? ((String) session.getAttribute("toDate")) : "");
    }
    jsonUrl = "../json/jsonDownloadDetails.json?cacheClr=" + now;
    if (fromDate != "" && toDate != "") {
        jsonUrl = jsonUrl + "&fromDate=" + fromDate + "&toDate=" + toDate;
        headerMessage = "Current report restricted to downloads from \"" + fromDate + "\" to \"" + toDate + "\".";
    } else if (fromDate != "") {
        jsonUrl = jsonUrl + "&fromDate=" + fromDate;
        headerMessage = "Current report restricted to downloads from \"" + fromDate + "\" to \"11/1/2008\".";
    } else if (toDate != "") {
        jsonUrl = jsonUrl + "&toDate=" + toDate;
        headerMessage = "Current report restricted to downloads from \"" + todayDate + "\" to \"" + toDate + "\".";
    }
%><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <!-- TemplateBeginEditable name="doctitle" -->
        <title>EPA Metadata Editor (EME)</title>
        <link href="../main.css" rel="stylesheet" type="text/css" /> 

        <style type="text/css">
            body {
                background-repeat: no-repeat;
                background-color: #4A5B63;
            }
        </style>
        <link href="<% out.print(jsonUrl);%>" type="application/json" rel="exhibit/data" />

        <script src="/simile_new/exhibit/api/exhibit-api.js?bundle=false" type="text/javascript"></script>
        <link href='../javaScripts/jquery-ui/development-bundle/themes/base/jquery.ui.all.css' rel='stylesheet' type='text/css' />
        <link href='/OpenLayers/theme/default/style.css' rel='stylesheet' type='text/css' />

        <style> 
            body {
                margin:             0px;
                padding:            0px;
                background-color:   #fff;
                color:              #222;
                font-family: "Lucida Grande",Geneva,Verdana,Arial,Helvetica,sans-serif;
                font-size:          12px;
            }

            div{
                font-size: 12px;
            }

            legend{
                font-weight: bold;
                padding:0px 10px;
                font-size: 20px;
                color: #369;
            }

            #view{
                width:840px;
                float:left;
            }

            #facet{
                padding-top : 70px;
                width:360px; 
                float:left;

            }



            #view .box{
                -moz-border-radius: 5px;
                -webkit-border-radius: 5px;
                border-radius: 5px;
                border: 2px solid #CCC;
                margin-bottom: 10px;
                padding : 8px; 
                width:760px;
                overflow:hidden;
            }

            fieldset{
                border-color: #E3E6EC;
                -moz-border-radius: 5px;
                -webkit-border-radius: 5px;
                border-width: 2px;
                width: inherit;
            }

            fieldset div{
                line-height: 15px;
                font-size: 12px;
            }

            .map_desc{
                float:left; 
                width: 380px;
            }

            .smallmap{
                float:right;
                width:340px;
                height: 335px; 
                vertical-align: middle;


                border-left: 1px solid #cccccc;
                border-right: 1px solid #cccccc;
                border-bottom: 1px solid #cccccc;
                background-color: #FFFFFF;
                -moz-box-shadow: 3px 3px 4px #000;
                -webkit-box-shadow: 3px 3px 4px #000;
                box-shadow: 3px 3px 4px #000;
                /* For IE 8 */
                -ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#000000')";
                /* For IE 5.5 - 7 */
                filter: progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#000000');

            }

            .label{
                font-weight:bold;
            }

            .container{
                width:1240px; 
                float: left; 
                border-right: thick solid #4A5B63;
                border-bottom: 25px solid #4A5B63; 
                border-left: thick solid #4A5B63;

            }


        </style> 
    </head>

    <body >

        <div style="width:1250px; margin:0px auto;">
            <div class="header">
                <div class="HeaderMenu"><img src="../images/EME_Banner1.jpg" align="middle" /></div>

            </div>

            <div class="container">
                <div style="padding-left:4px;">
                    <br /><br />
                    <h1>EME Downloads</h1>
                    <% if (headerMessage != null) {
                            out.print("<h3>" + headerMessage + "</h3>");
                        }%>


                    <div ex:role="view" id="view" ex:orders=".down_date" ex:directions="descending" ex:paginate = "true"
                         ex:pageSize = "15"
                         ex:page = "0"
                         ex:pageWindow = "10"
                         ex:alwaysShowPagingControls="true"
                         ex:pagingControlLocations="bottom">
                        <!-- VIEW -->
                        <div ex:role="exhibit-lens"> 
                            <div class="box">
                                <div class="map_desc">

                                    <fieldset>
                                        <legend>User supplied information</legend>
                                        <div><span class="label">Organization : </span><span ex:content=".down_organization"></span></div>
                                        <div><span class="label">Name : </span><span ex:content=".firstname"></span>&nbsp;<span ex:content=".lastname"></span></div>
                                        <div><span class="label">Email : </span><span ex:content=".email"></span></div> 
                                        <div><span class="label">Location : </span><span ex:content=".locationcode"></span>&nbsp;<span ex:content=".locationother"></span></div>
                                        <div><span class="label">Heard from : </span><span ex:content=".howdidyouhear"></span></div>
                                        <div><span class="label">Product : </span><span ex:content=".productfullname"></span></div>
                                        <div><span class="label">Product content : </span><span ex:content=".productcontent"></span></div>
                                        <div><span class="label">Do not contact : </span><span ex:content=".donotcontact"></span></div>
                                    </fieldset>
                                    <fieldset>
                                        <legend>Geo-coded service information</legend>
                                        <div><span class="label">Organization : </span><span ex:content=".organization"></span></div>
                                        <div><span class="label">City : </span><span ex:content=".city"></span></div> 
                                        <div><span class="label">State/Region : </span><span ex:content=".region"></span>&nbsp;&nbsp;<span class="label">Zip Code : </span>&nbsp;<span ex:content=".zip_code"></span></div> 
                                        <div><span class="label">Country : </span><span ex:content=".country_code"></span></div>                                
                                        <div><span class="label">IP Address : </span><span ex:content=".ip_address"></span></div> 
                                        <div><span class="label">No of Downloads : </span><span ex:content=".count"></span>&nbsp;&nbsp;&nbsp;<span class="label">Downloaded Date : </span><span ex:content=".down_date"></span></div> 
                                        <div><span class="label">Longitude, Latitude : </span><span ex:content=".longitude"></span>,&nbsp;<span ex:content=".latitude"></span></div> 
                                        <div><span class="label">Area Code : </span><span ex:content=".area_code"></span>&nbsp;<span class="label">Metro Code : </span><span ex:content=".metro_code"></span></div>
                                        <div><span class="label">ISP : </span><span ex:content=".isp"></span></div>
                                        <div><span class="label">Domain Name : </span><span ex:content=".domain_name"></span></div>
                                    </fieldset>

                                </div>
                                <div ex:id-subcontent="map_{{.label}}" ex:longitude-content=".longitude" ex:latitude-content=".latitude" class="smallmap"></div>
                                <div style="clear:both;"></div>
                            </div>
                        </div> 
                    </div>
                    <div id="facet">
                        <!-- FACET -->
                        <div>
                            <form method="post" target="_blank" action="../json/downloadCSV.jsp" name="csvForm">
                                <textarea name="csv" id="csv" style="display:none;"  ></textarea>
                                <a href="javascript:void(0)" onClick="submitFrom();"><img src="../images/document_excel_csv.png" border="0" /> [ Generate CSV ] </a>
                            </form>
                        </div>
                        <fieldset>
                            <legend>Filters (user supplied)</legend>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".full_name" ex:facetLabel="Text based search on &quot;Downloaded By&quot;"> </div>
                            <div ex:role="facet" ex:expression=".full_name" ex:facetLabel="Downloaded By"></div>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".down_organization" ex:facetLabel="Text based search on &quot;Organization&quot;"> </div>
                            <div ex:role="facet" ex:expression=".down_organization" ex:facetLabel="Organization"></div>
                            <div ex:role="facet" ex:expression=".donotcontact" ex:facetLabel="Do not contact" ex:height="50px"></div>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".howdidyouhear" ex:facetLabel="Text based search on &quot;Heard From&quot;"> </div>
                            <div ex:role="facet" ex:expression=".howdidyouhear" ex:facetLabel="Heard From"></div>
                            <div ex:role="facet" ex:expression=".productfullname" ex:facetLabel="Product"></div>
                            <div ex:role="facet" ex:expression=".productcontent" ex:facetLabel="Product Content" ex:height="50px"></div>
                            <div>

                                <form name="dateFilter" method="post" action="">
                                    <input type="hidden" name="form_post" id="form_post" value="false" />
                                    <div><span class="exhibit-facet-header-title">Dates</span></div>
                                    <div class="exhibit-facet-body-frame">
                                        <div style=" display: block;" class="exhibit-facet-body">
                                            <div title="Source" class="exhibit-facet-value">

                                                <div class="exhibit-facet-value-inner" style="padding:4px;">
                                                    <div> 
                                                        <span>From date : </span><span><input type="text" name="fromDate" id="fromDate" style="width:80px;"></span>
                                                        &nbsp;&nbsp;<span>To date : </span><span><input type="text" name="toDate" id="toDate" style="width:80px;"></span>
                                                        &nbsp;&nbsp;<span><a href="javascript:void(0);" onclick="submitForm();">[Submit]</a></span>
                                                        &nbsp;&nbsp;<span><a href="javascript:void(0);" onclick="submitForm(-1);">[Clear]</a></span>
                                                    </div>
                                                </div>
                                                <div class="exhibit-facet-value-inner" style="padding:4px; "><a href="javascript:void(0);" onclick="submitForm(7);" style="text-decoration: none;">7 days activity report</a></div>
                                                <div class="exhibit-facet-value-inner" style="padding:4px; "><a href="javascript:void(0);" onclick="submitForm(30);" style="text-decoration: none;">30 days activity report</a></div>
                                                <div class="exhibit-facet-value-inner" style="padding:4px; "><a href="javascript:void(0);" onclick="submitForm(365);" style="text-decoration: none;">1 year activity report</a></div>
                                            </div>
                                        </div>
                                    </div>
                                </form>    
                            </div>  

                        </fieldset>
                        <fieldset>
                            <legend>Filters (Geo-coded info.)</legend>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".organization" ex:facetLabel="Text based search on &quot;Organization&quot;"> </div>
                            <div ex:role="facet" ex:expression=".organization" ex:facetLabel="Organization"></div>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".country_name" ex:facetLabel="Text based search on &quot;Country&quot;"> </div>
                            <div ex:role="facet" ex:expression=".country_name" ex:facetLabel="Country"></div>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".region" ex:facetLabel="Text based search on &quot;State/Region&quot;"> </div>
                            <div ex:role="facet" ex:expression=".region" ex:facetLabel="State/Region"></div>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".city" ex:facetLabel="Text based search on &quot;City&quot;"> </div>
                            <div ex:role="facet" ex:expression=".city" ex:facetLabel="City"></div>
                            <div ex:role="facet" ex:facetClass="TextSearch" ex:expressions=".ip_address" ex:facetLabel="Text based search on &quot;IP Address&quot;"> </div>
                            <div ex:role="facet" ex:expression=".ip_address" ex:facetLabel="IP Address"></div>
                        </fieldset>

                    </div>

                </div>
                <div style="clear:both; background-color: #4A5B63; line-height: 40px; height: 40px;"> </div>
                <div class="footer">
                    <div style="width:1245px; text-align: center; color: #FFF;  background-color: #4A5B63;">
                        <span>The EME is an FGDC Metadata Editor compatible with ArcGIS 10. Please read EPA's <a href="http://www.epa.gov/epahome/usenotice2.htm" style="color: #FFFFFF;">Privacy and Security Notice</a>.</span>
                        <span><img src="../images/seal-bottom.png" align="center" alt="" width="82" height="82" border="0" /></span>
                    </div>
                </div>
            </div>

            <!-- end .container --></div>

    </body>
    <script src="../javaScripts/jquery-ui/development-bundle/jquery-1.5.1.js"></script>
    <script src="../javaScripts/jquery-ui/development-bundle/ui/jquery.ui.core.js"></script>
    <script src="../javaScripts/jquery-ui/development-bundle/ui/jquery.ui.widget.js"></script>
    <script src="../javaScripts/jquery-ui/development-bundle/ui/jquery.ui.datepicker.js"></script>
    <script src="/OpenLayers/lib/OpenLayers.js"></script>
    <script src="../javaScripts/bing-tiles.js"></script>
    <script type="text/javascript">
        
        $(function() {
            $( "#fromDate" ).datepicker();
            $( "#toDate" ).datepicker();
            $( "#format" ).change(function() {
                $( "#fromDate" ).datepicker( "option", "dateFormat", "dd/mm/yy" );
                $( "#toDate" ).datepicker( "option", "dateFormat", "dd/mm/yy" );
            });

            $( "#fromDate" ).val('<% out.print(fromDate);%>');
            $( "#toDate" ).val('<% out.print(toDate);%>');
        });
    
        function submitForm(filterBy){
            url="?report_type=";
            fromDate    = new Date();
            toDate      = new Date();
            document.forms['dateFilter'].form_post.value="true";
            
            if(filterBy){
                $( "#fromDate" ).val(null);
                $( "#toDate" ).val(null);

                $( "#toDate" ).val((toDate.getMonth()+1)+'/'+toDate.getDate()+'/'+toDate.getFullYear());

                switch(filterBy){
                    case -1:
                        $( "#fromDate" ).val(null);
                        $( "#toDate" ).val(null);
                        break;
                    case 7:
                        fromDate.setDate(fromDate.getDate()-7);
                        $( "#fromDate" ).val((fromDate.getMonth()+1)+'/'+fromDate.getDate()+'/'+fromDate.getFullYear());
                        break;
                    case 30:
                        fromDate.setDate(fromDate.getDate()-30);
                        $( "#fromDate" ).val((fromDate.getMonth()+1)+'/'+fromDate.getDate()+'/'+fromDate.getFullYear());
                        break;
                    case 365:
                        fromDate.setFullYear(fromDate.getFullYear()-1,fromDate.getMonth(),fromDate.getDate()); 
                        $( "#fromDate" ).val((fromDate.getMonth()+1)+'/'+fromDate.getDate()+'/'+fromDate.getFullYear());
                        break;
                }
                document.forms["dateFilter"].submit();
            }else{
                if( $("#fromDate" ).val() || $("#toDate" ).val()){
                    document.forms["dateFilter"].submit();
                }

            }
            document.forms["dateFilter"].submit();
        }



        function submitFrom(obj){
            var set = exhibit.getDefaultCollection().getRestrictedItems();
            var db = exhibit._uiContext.getDatabase();

            obj = document.forms["csvForm"];
            obj["csv"].value = Exhibit.CSVExporter.exportMany(set,db);
            obj.submit();
        }
        
        
    </script>
</html>
