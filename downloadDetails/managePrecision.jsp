<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <form method="post" enctype='multipart/form-data' action="downloadManagedPrecision.jsp">
            <table border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td>File :</td>
                    <td><input type="file" name="coordFile"/></td>
                </tr>
                <tr>
                    <td>Precision :</td>
                    <td><input type="text" name="precision" value="0.001"/></td>
                </tr>
                <tr>
                    <td></td>
                    <td><input type="submit" value="Press"> </td>
                </tr>
            </table>
        </form>
    </body>
</html>
