<%@ page import="java.io.*" %><%@ page import="java.net.*" %><%@ page import="java.sql.*" %><%@ include file="jspClasses/jsonServer.jsp" %><%

    String hardWiredFilePath = getServletContext().getInitParameter("EmeFilesPath");
    jsonServer obj = new jsonServer(hardWiredFilePath);

    boolean goodToGo = true;
    String downloadFile = "";
    String product = request.getParameter("product");
    int productCode = 0;

    if (product != null) {
        PreparedStatement ps = obj.getPreparedStmt("SELECT fileName,displayName FROM products WHERE downloadable='Y' AND productCode=?");
        ps.setString(1, product);
        ResultSet rs = ps.executeQuery();
        rs.next();

        downloadFile = rs.getString("fileName");
        productCode = Integer.parseInt(product);
    }

    if (downloadFile.equals("")) {
        goodToGo = false;
    }

    String email = request.getParameter("txtEmail");
    if (email == null || email.trim().equals("")) {
        goodToGo = false;
    }

    if (!goodToGo) {
        response.sendRedirect("Download.htm");
    }

    String firstName = request.getParameter("first");
    if (firstName != null && firstName.length() > 255) {
        firstName = firstName.substring(0, 254);
    }
    String lastName = request.getParameter("last");
    if (lastName != null && lastName.length() > 255) {
        lastName = lastName.substring(0, 254);
    }
    String locationCode = request.getParameter("selLoc");
    if (locationCode != null && locationCode.length() > 2) {
        locationCode = null;
    }
    String locationOther = request.getParameter("txtOtherLoc");
    if (locationOther != null && locationOther.length() > 255) {
        locationOther = locationOther.substring(0, 254);
    }
    String org = request.getParameter("selOrg");
    if (org != null && org.indexOf("Other") > -1) {
        org = request.getParameter("txtOtherOrg");
    }
    if (org != null && org.length() > 255) {
        org = org.substring(0, 254);
    }
    String source = request.getParameter("source");
    String doNotContact = request.getParameter("chkAnnounce");
    if (doNotContact == null) {
        doNotContact = "";
    }

    String rip = "";
    if (request.getHeader("x-forwarded-for") != null) {
        rip = request.getHeader("x-forwarded-for");
    } else {
        rip = request.getRemoteAddr();
    }


    String geoInfo = null;
    if (rip != null && rip.length() >= 7) {
        BufferedReader in = null;
        try {
            URL geolocator = new URL("http://geoip3.maxmind.com/f?l=uHb8LATVUFub&i=" + rip);
            in = new BufferedReader(new InputStreamReader(geolocator.openStream()));
            geoInfo = in.readLine();
        } catch (Exception e) {
            System.out.println("Error: " + e);
        } finally {
            if (in != null) {
                in.close();
            }
        }
    }

    Connection con = null;
    PreparedStatement s = null;

    try {
        String filename = hardWiredFilePath + "EME-Downloads.mdb";
        String database = "jdbc:odbc:Driver={Microsoft Access Driver (*.mdb)};DBQ=";
        database += filename.trim() + ";DriverID=22;READONLY=true}";

        Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
        con = DriverManager.getConnection(database, "", "");
        s = con.prepareStatement("insert into Downloads(IPAddress,Email,DoNotContact,FirstName,LastName,LocationCode,LocationOther,Organization,HowDidYouHear,ProductCode) values(?,?,?,?,?,?,?,?,?,?)");
        s.setString(1, rip);
        s.setString(2, email);
        s.setBoolean(3, doNotContact.compareTo("on") == 0);
        s.setString(4, firstName);
        s.setString(5, lastName);
        s.setString(6, locationCode);
        s.setString(7, locationOther);
        s.setString(8, org);
        s.setString(9, source);
        s.setInt(10, productCode);

        s.execute();
        s.close();


        if (geoInfo != null) {
            String[] geoInfoArr = geoInfo.split(",");
            if (geoInfoArr[8].startsWith("\"")) {
                geoInfoArr[8] = geoInfoArr[8].substring(1, geoInfoArr[8].length() - 1);
            }
            if (geoInfoArr[9].startsWith("\"")) {
                geoInfoArr[9] = geoInfoArr[9].substring(1, geoInfoArr[9].length() - 1);
            }

// [US, MA, Norwell, 02061, 42.150799, -70.822800, 506, 781, "Verizon Internet Services", "Verizon Internet Services"]

            s = con.prepareStatement("insert into All_Downloads_Table([IP Address], [Country Code], [Region Code], City, [ZIP Code], Latitude, Longitude, [Metro Code], [Area Code], ISP, Organization) values(?,?,?,?,?,?,?,?,?,?,?)");
            s.setString(1, rip);
            s.setString(2, geoInfoArr[0]);
            s.setString(3, geoInfoArr[1]);
            s.setString(4, geoInfoArr[2]);
            s.setString(5, geoInfoArr[3]);
            s.setString(6, geoInfoArr[4]);
            s.setString(7, geoInfoArr[5]);
            s.setString(8, geoInfoArr[6]);
            s.setString(9, geoInfoArr[7]);
            s.setString(10, geoInfoArr[8]);
            s.setString(11, geoInfoArr[9]);

            s.execute();
        }
    } catch (Exception e) {
        System.out.println("Error: " + e);
    } finally {
        if (s != null) {
            s.close();
        }
        if (con != null) {
            con.close();
        }
    }



    response.setContentType("application/zip");
    response.setHeader("Content-Disposition", "Attachment; Filename=\"" + downloadFile + "\"");

    downloadFile = hardWiredFilePath + downloadFile;
    OutputStream o = null;
    try {
        o = response.getOutputStream();
        //downloadFile += "EME_installer.zip";
        FileInputStream is =
                new FileInputStream(downloadFile);

        byte[] buf = new byte[32 * 1024]; // 32k buffer
        int nRead = 0;
        boolean done = false;
        while (!done) {
            nRead = is.read(buf);
            if (nRead > 0) {
                o.write(buf, 0, nRead);
            } else {
                done = true;
            }
        }
    } finally {
        if (o != null) {
            o.flush();
            o.close();// *important* to ensure no more jsp output
            return;
        }
    }
%>

