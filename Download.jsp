<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="jspClasses/jsonServer.jsp" %>
<%
    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);

    int loopCnt = 0, chked = 0;
    String prevProductVersion = null, curProductVersion = null, checked = null, containsSource = null;
    String content = "<table width=\"100%\">";
    ResultSet rs = obj.executeQuery("SELECT productCode,containsBinary,productVersion,containsSource,fileName,displayName FROM products WHERE downloadable='Y' ORDER BY versionOrder DESC,containsSource DESC");
    ArrayList versions = new ArrayList();
    ArrayList source = new ArrayList();
    ArrayList installer = new ArrayList();
    ResultSetMetaData md;
    int columns;
    HashMap row;

    while (rs.next()) {
//        containsSource = rs.getString("containsSource");

        md = rs.getMetaData();
        columns = md.getColumnCount();

        containsSource = rs.getString("containsSource");
        
        row = new HashMap(columns);
        for (int i = 1; i <= columns; i++) {
           
            try {
                row.put(md.getColumnName(i), rs.getObject(i));
            } catch (Exception e) {
                row.put(md.getColumnName(i), "");
            }
        }

        if ((containsSource).equalsIgnoreCase("1")) {
            source.add(row);
        } else {
            installer.add(row);
        }
    }

    int size = Math.max(source.size(), installer.size());

    for (int i = 0; i < size; i++) {
        if(i==0){
            checked = "checked=\"checked\"";
        }else{
            checked = "";
        }
        content += ("<tr>");
        try {
            row = (HashMap) installer.get(i);
            content += ("<td><input type=\"radio\" name=\"product\" value=\"" + row.get("productCode") + "\" " + checked + " >" + row.get("displayName") + "</td>");
            checked = "";
        } catch (Exception e) {
            content += ("<td></td>");
        }
        try {
            row = (HashMap) source.get(i);
            content += ("<td><input type=\"radio\" name=\"product\" value=\"" + row.get("productCode") + "\" " + checked + " >" + row.get("displayName") + "</td>");
        } catch (Exception e) {
            content += ("<td></td>");
        }
        content += ("</tr>");
    }
    
    content += "</table>";
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>EPA Metadata Editor (EME)</title>
        <link href="main.css" rel="stylesheet" type="text/css" />
        <style type="text/css">
            body {
                background-color: #FFF;
            }
            td{
                font-size: 12px;
                line-height: 14px;
            }
        </style>
        <script type="text/javascript">
            function isValidEmail(string) {
                //return (string.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1);
                return (string.search(/^[a-zA-Z]+([_\.-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9]+([\.-]?[a-zA-Z0-9]+)*(\.[a-zA-Z]{2,4})+$/) != -1);
            }
            function validate() {
                if(!isValidEmail(document.forms["frmInfo"]["txtEmail"].value))
                {
                    alert("Please provide a valid email address.");
                    return false;
                }

                if(!document.forms["frmInfo"]["chkEME"].checked && !document.forms["frmInfo"]["chkEMESrc"].checked)
                {
                    alert("Please indicate what you would like to download.");
                    return false;
                }

                return true;
            }
        </script>
    </head>
    <body>

        <form method="post" action="/EME/DoDownload.jsp" name="frmInfo" target="" id="frmInfo" onsubmit="return validate();">
            <h1>EPA Metadata Editor and Source Code Download Form</h1>Thank you for choosing to download the EME.  Please take the steps listed below to complete the download process. We've begun collecting basic information about users to help track EME use and improve our product.  The data may be used to email users with information on EME updates or announcements.  If you do not wish to receive this information, please check the 'Do not contact me' checkbox.  We do not sell or give out information to any third party. Please view our privacy policy for more information. <br><br><p></p>
                    <!-- Ayhan to edit/update here -->


                    <h3>Step 1 - Enter Your Information <font size="2">(Fields with asterisks [*] are required)</font></h3>

                    <table border="0">
                        <tbody>
                            <tr>
                                <td width="80">First Name: </td>
                                <td width="150"><input type="text" size="20" name="first"></td>
                                <td width="60">Location: </td>
                                <td >
                                    <select name="selLoc">
                                        <option value="">-- Please Select --</option>
                                        <option>AL</option>
                                        <option>AR</option>
                                        <option>AS</option>
                                        <option>AZ</option>
                                        <option>CA</option>
                                        <option>CO</option>
                                        <option>CT</option>
                                        <option>DC</option>
                                        <option>DE</option>
                                        <option>FL</option>
                                        <option>GA</option>
                                        <option>GU</option>
                                        <option>HI</option>
                                        <option>IA</option>
                                        <option>ID</option>
                                        <option>IL</option>
                                        <option>IN</option>
                                        <option>KS</option>
                                        <option>KY</option>
                                        <option>LA</option>
                                        <option>MA</option>
                                        <option>MD</option>
                                        <option>ME</option>
                                        <option>MI</option>
                                        <option>MN</option>
                                        <option>MP</option>
                                        <option>MO</option>
                                        <option>MS</option>
                                        <option>MT</option>
                                        <option>NC</option>
                                        <option>ND</option>
                                        <option>NE</option>
                                        <option>NH</option>
                                        <option>NJ</option>
                                        <option>NM</option>
                                        <option>NV</option>
                                        <option>NY</option>
                                        <option>OH</option>
                                        <option>OK</option>
                                        <option>OR</option>
                                        <option>PA</option>
                                        <option>PR</option>
                                        <option>RI</option>
                                        <option>SC</option>
                                        <option>SD</option>
                                        <option>TN</option>
                                        <option>TX</option>
                                        <option>UT</option>
                                        <option>VA</option>
                                        <option>VI</option>
                                        <option>VT</option>
                                        <option>WA</option>
                                        <option>WI</option>
                                        <option>WV</option>
                                        <option>WY</option>
                                        <option value="Other">Other - please specify</option>
                                    </select>
                                    <input type="text" size="50" name="txtOtherLoc"></td>
                            </tr>
                            <tr>
                                <td>Last Name: </td>
                                <td><input type="text" size="20" name="last"></td>
                                <td>Organization: </td>
                                <td><select name="selOrg">
                                        <option value="">-- Please Select --</option>
                                        <option value="U.S. Environmental Protection Agency">U.S. Environmental Protection Agency</option>
                                        <option value="Federal Government">Federal Government (not EPA)</option>
                                        <option value="State Government">State Government</option>
                                        <option value="Local Government">Local Government</option>
                                        <option value="Tribal">Tribal</option>
                                        <option value="University">University</option>
                                        <option value="Non-Profit">Non-Profit</option>
                                        <option value="Commercial">Commercial</option>
                                        <option value="Other">Other - please specify</option>
                                    </select>
                                    <input type="text" size="34" name="txtOtherOrg"></td>
                            </tr>
                            <tr>
                                <td>Email*: </td>
                                <td><input type="text" size="20" name="txtEmail"></td>
                                <td colspan="2">How did you hear about EME?
                                    <input type="text" size="59" name="source"></td>
                            </tr>
                            <tr>
                                <td colspan="4"><input type="checkbox" name="chkAnnounce"><i>Do not contact me with updates on EME announcements or releases</i><br><br></td>
                                                </tr>
                                                </tbody>
                                                </table>
                                                <h3>Step 2 - Choose Product(s) to Download </h3>
                                                <div ><% out.print(content);%></div>
                                                <h3>Step 3 - Read and Agree to License Agreement</h3>
                                                <p>To download this item and install on your desktop, you must agree to the liability statement shown below by clicking on the 'I Agree' button located at the bottom of this page.<br>
                                                        <br><b>Liability Statement:</b> The software you are about to install, although reviewed for quality assurance, should be installed and used with the understanding that all possible variations in the conditions of hardware and software configurations, as well as the data entered, cannot always be anticipated and may consequently have an effect on the software used and the computer hardware. To the maximum extent permitted by applicable law, the U.S. Environmental Protection Agency makes no warranty, express or implied, and accepts no liability for any damages, consequential or other (such as, damages for personal injury, loss of business profits, business interruption, loss of business information) concerning the use, attempted use, or application of this software. <br>
                                                                <br>Finally, reference to any specific commercial product, process, or service by trade name, trademark, manufacturer, or otherwise, does not necessarily constitute or imply its endorsement, recommendation, or favoring by the United States Government and shall not be used for advertising or product endorsement purposes.<br><br></p>
                                                                            <input type="submit" name="I Agree" value="I Agree">&nbsp;&nbsp;<input type="button" name="I Do Not Agree" value="I Do Not Agree">
                                                                                    </form>
                                                                                    </body>
                                                                                    </html>
