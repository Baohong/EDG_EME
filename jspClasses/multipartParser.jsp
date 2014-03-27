<%@page import="java.util.HashMap"%><%@page import="java.util.regex.Matcher"%><%@page import="java.util.regex.Pattern"%><%!

/**
 *
 * @author Deewen
 */
public class multipartParser {

    private String allContent;

    public multipartParser(String allContent) {
        this.allContent = allContent;
    }

    public HashMap getPostValues() {
        int nameIndex, nameBeginIndex=0, nameEndIndex=0, start = 0, end = 0;
        HashMap postContent = new HashMap();
        int count=0;
        
        String regex = "------";
        Pattern pattern = Pattern.compile(regex);
        final Matcher matcher = pattern.matcher(this.allContent);
        while (matcher.find()) {
            count++;
            end = matcher.start();
            
            if(end!=0){
                postContent.put(this.allContent.substring(nameBeginIndex,nameEndIndex), this.allContent.substring(start,end));
            }
            
            nameIndex = this.allContent.indexOf("name=", end);
            nameBeginIndex = this.allContent.indexOf("\"", nameIndex)+1;
            nameEndIndex = this.allContent.indexOf("\"", nameBeginIndex);
            
            start = end;
        }
        if(count==1){
            postContent.put(this.allContent.substring(nameBeginIndex,nameEndIndex).trim(), this.allContent);
        }
       
        return postContent;
    }
    
    public String getContent(String multipartData){
        int pos = multipartData.indexOf("name=\"");
        pos = multipartData.indexOf("\n", pos) + 1;
        pos = multipartData.indexOf("\n", pos) + 1;
        
        int startPos = ((multipartData.substring(0, pos)).getBytes()).length;
        int endPos = multipartData.length();
        
        return multipartData.substring(startPos, endPos).trim();
    }
    
    public HashMap parseFileContent(String multipartData){
        HashMap fileContent = new HashMap();
        int start,end;
        
        start = multipartData.indexOf("name=");
        start = multipartData.indexOf("\"",start)+1;
        end = multipartData.indexOf("\"", start);
        fileContent.put("name", multipartData.substring(start,end).trim());
        
        start = multipartData.indexOf("filename=");
        start = multipartData.indexOf("\"",start)+1;
        end = multipartData.indexOf("\"", start);
        fileContent.put("filename", multipartData.substring(start,end).trim());
        
        start = multipartData.indexOf("Content-Type");
        start = multipartData.indexOf(":",start)+1;
        end = multipartData.indexOf("\n", start) + 1;
        fileContent.put("content-type", multipartData.substring(start,end).trim());
        
        fileContent.put("content", this.getContent(multipartData));
        return fileContent;
    }
}
%>