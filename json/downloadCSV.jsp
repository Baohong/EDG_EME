<%
String filename = "EMEDownloadDetails.csv";
String csv;

csv = request.getParameter("csv");

//set response headers
response.setContentType("text/csv");
response.addHeader("Content-Disposition", "attachment; filename=" + filename);
response.setContentLength((int) csv.length());
out.write(csv);
%>