<%@page import="java.io.File"%><%@page import="java.io.FileInputStream"%><%@page import="java.util.regex.*"%><%!
/**
 *
 * @author Deewen
 */
public class precisionHandler {

    private String filePath;
    private String wholeFile;
    private StringBuffer myStringBuffer;
    private Float precision;

    public precisionHandler() {
        this.myStringBuffer = new StringBuffer();
        //this("E:\\Apache Software Foundation\\webapps\\EME\\WEB-INF\\EME_files\\world.json", (float) 0.1);
    }

    public void setFile(String filePath) {
        this.filePath = filePath;
        this.bufferWholeFile();
    }

    public void setFileContent(String wholeFile) {
        this.wholeFile = wholeFile;

    }

    public void setPrecision(Float precision) {
        this.precision = precision;
    }

    /* READ WHOLE FILE AND STORE IT IN STRING wholeFile*/
    public void bufferWholeFile() {
        try {
            int len = (int) (new File(this.filePath).length());
            byte[] buf = new byte[len];

            FileInputStream fis = new FileInputStream(this.filePath);
            fis.read(buf);
            fis.close();
            this.wholeFile = new String(buf);

        } catch (Exception e) {
            System.err.println(e);
        }
    }

    public void doReplacements() {
        String longitude,latitude,end;
        String regex = "(([-+]?[0-9]*\\.?[0-9]+)\\,([-+]?[0-9]*\\.?[0-9]+)((\\;|\")))";
        Pattern pattern = Pattern.compile(regex);
        final Matcher matcher = pattern.matcher(this.wholeFile);
        while (matcher.find()) {
            //System.out.println(this.returnCorrectedString(matcher.group()));
            longitude = matcher.group(2).toString();
            latitude = matcher.group(3).toString();
            end = matcher.group(4).toString();
            
            matcher.appendReplacement(this.myStringBuffer, this.returnCorrectedString(longitude,latitude,end));
            // System.out.println(matcher.group());

        }
        matcher.appendTail(this.myStringBuffer);
        //System.out.println(this.myStringBuffer.toString());
    }
    
     public void doReplacements_() {
        String regex = "(([-+]?[0-9]*\\.?[0-9]+)(\\,)([-+]?[0-9]*\\.?[0-9]+)(\\;|\"))";
        Pattern pattern = Pattern.compile(regex);
        final Matcher matcher = pattern.matcher(this.wholeFile);
        while (matcher.find()) {
            System.out.println(matcher.group());
            System.out.println(matcher.group(1));
            System.out.println(matcher.group(2));
            //matcher.appendReplacement(this.myStringBuffer, this.returnCorrectedString(matcher.group()));
            // System.out.println(matcher.group());

        }
        //matcher.appendTail(this.myStringBuffer);
        //System.out.println(this.myStringBuffer.toString());
    }
     
    public String returnCorrectedString(String str) {
        String longitude, latitude, last;
        last = str.substring(str.length() - 1);
        str = str.substring(0, str.length() - 1);
        longitude = str.substring(0, str.lastIndexOf(","));
        latitude = str.substring(str.lastIndexOf(",") + 1);

        longitude = this.returnPrecisionBasedCoordinate(Float.parseFloat(longitude));
        latitude = this.returnPrecisionBasedCoordinate(Float.parseFloat(latitude));

        return longitude + "," + latitude + last;
    }
    
    public String returnCorrectedString(String longitude,String latitude,String last) {
        longitude = this.returnPrecisionBasedCoordinate(Float.parseFloat(longitude));
        latitude = this.returnPrecisionBasedCoordinate(Float.parseFloat(latitude));

        return longitude + "," + latitude + last;
    }

    public String returnPrecisionBasedCoordinate(Float floatValue) {

        int position = 0;
        String decimal;
        String floatString = Float.toString(floatValue);
        Float modPrecision;

        if (floatValue.intValue() == floatValue) {
            return Integer.toString(floatValue.intValue());
        } else {
            decimal = this.getDecimalString(floatValue);
            position = decimal.length();
            modPrecision = this.retPrecisionValue(decimal, position);

            while (modPrecision < this.precision && position > 1) {
                position--;
                modPrecision = this.retPrecisionValue(decimal, position);

            }
            if (position == 0) {
                floatString = Integer.toString(floatValue.intValue());
            } else {
                floatString = floatValue.intValue() + "." + decimal.substring(0, position);
            }
            return floatString;
        }
    }

    public Float retPrecisionValue(String decimal, int position) {
        
        position--;
        String ret = "0.";
        for (int i = 0; i < position; i++) {
            ret += "0";
        }
        ret += decimal.substring(position);
        return Float.parseFloat(ret);
        
    }
    
    public Float retPrecisionValue_(String decimal, int position){
        Double d = Math.pow(10.0,(-1*(decimal.length())))*Double.parseDouble(decimal.substring(position));
        return d.floatValue();
    }
    
    public String getDecimalString(Float floatValue) {
        String floatString = Float.toString(floatValue);
        int position = floatString.lastIndexOf(".");
        return (floatString.substring(position + 1));
    }

    public String returnContent() {
        return this.myStringBuffer.toString().trim();
    }
}
%>