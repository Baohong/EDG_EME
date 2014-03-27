<%@page import="java.util.Iterator, java.util.Set, java.util.regex.Matcher, java.util.regex.Pattern, java.util.HashMap, java.util.Enumeration, java.io.*"%>
<%@ include file="../jspClasses/precisionHandler.jsp" %><%@ include file="../jspClasses/multipartParser.jsp" %><%
    String contentType = request.getContentType();
    if ((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0)) {

        DataInputStream in = new DataInputStream(request.getInputStream());
        //we are taking the length of Content type data
        int formDataLength = request.getContentLength();
        byte dataBytes[] = new byte[formDataLength];
        int byteRead = 0;
        int totalBytesRead = 0;
        //this loop converting the uploaded file into byte code
        while (totalBytesRead < formDataLength) {
            byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
            totalBytesRead += byteRead;
        }
        String file = new String(dataBytes);
         
        //break the contents and get the post values
        String key;
        HashMap postContents = new HashMap();
        HashMap fileContents = new HashMap();
        multipartParser multipartParserObj = new multipartParser(file);
        postContents = multipartParserObj.getPostValues();
        fileContents = multipartParserObj.parseFileContent(postContents.get("coordFile").toString());
        
        Set s = postContents.keySet();
        Iterator i = s.iterator();
        while (i.hasNext()) {
            key = i.next().toString();
            //out.println(key+"="+postContents.get(key).toString());
            postContents.put(key, multipartParserObj.getContent(postContents.get(key).toString()));
        }
        
        Float precision = new Float(postContents.get("precision").toString());
        precisionHandler obj = new precisionHandler();
        obj.setFileContent(fileContents.get("content").toString());
        
        obj.setPrecision(precision);
        obj.doReplacements();
        String fileContent = obj.returnContent();
        
        String saveFile = fileContents.get("filename").toString();
        response.addHeader("Content-Disposition", "attachment; filename=" + saveFile);
        response.setContentType(fileContents.get("content-type").toString());
        out.write(fileContent);
    }
%>