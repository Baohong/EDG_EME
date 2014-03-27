<%@page import="java.io.PrintWriter,java.sql.ResultSet,java.sql.ResultSetMetaData,java.sql.SQLException"%><%@page import="java.util.ArrayList,java.util.HashMap,java.util.Iterator,java.util.logging.Level"%><%@page import="java.util.logging.Logger,java.sql.*,java.util.Collection,java.util.HashMap"%><%@page import="java.util.regex.Matcher,java.util.regex.Pattern"%><%!
    /**
     *
     * @author Deewen
     */
    public class jsonServer {

        private Connection con = null;
        private Statement stmt = null;
        private HashMap hint;
        private Float floatValue;
        private Integer intValue;

        /*
         * Class constructor
         * @param : hardWiredFilePath   String  Path to the "WEB-INF\EME_files folder"/path where the mdb file is stored
         */
        public jsonServer(String hardWiredFilePath) {
            this.setConnection(hardWiredFilePath);
            hint = new HashMap();
        }

        /*
         * does the connection to the EME-Downloads.mdb
         * @param : hardWiredFilePath   String  Path to the "WEB-INF\EME_files folder"/path where the mdb file is stored
         */
        public final void setConnection(String hardWiredFilePath) {
            String filename = hardWiredFilePath + "EME-Downloads.mdb";
//            String database = "jdbc:odbc:Driver={Microsoft Access Driver (*.mdb)};DBQ=";
            String database = "JDBC:ODBC:Driver=Microsoft Access Driver (*.mdb); DBQ=";
            database += filename.trim() + ";DriverID=22;READONLY=true}"; // add on to the end 
            try {
                Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
                this.con = DriverManager.getConnection(database, "", "");
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(jsonServer.class.getName()).log(Level.SEVERE, null, ex);
            } catch (SQLException ex) {
                Logger.getLogger(jsonServer.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

        public Connection getConnection() {
            return this.con;
        }

        /*
         * Replaces some special characters to their encoded form
         * @param  : str   String  String in which the special charaters have to be replaced with encoded equivalent
         * @return : String   Escaped string
         */
        public String escapeSpecialChars(String str) {

            if (str != null) {
                str = str.replace("\"", "&quot;");
                str = str.replace("<", "&lt;");
                str = str.replace(">", "&gt;");
            }

            return str;
        }

        /*
         * Execute an sql query
         * @param  : sql   String  SQL to process 
         * @return : VOID
         */
        public ResultSet executeQuery(String sql) {
            try {
                this.stmt = (Statement) this.con.createStatement();
                ResultSet resultSetObj = stmt.executeQuery(sql);
                return resultSetObj;

            } catch (SQLException ex) {
                Logger.getLogger(jsonServer.class.getName()).log(Level.SEVERE, null, ex);
                return null;
            }
        }

        /*
         * Execute an sql query
         * @param  : sql   String  SQL to process 
         * @return : VOID
         */
        public ResultSet executeQuery(String sql, ArrayList params) {

            PreparedStatement ps = null;
            int indx = 1;
            try {
                ps = this.con.prepareStatement(sql);
                Iterator it = params.iterator();

                while (it.hasNext()) {
                    ps.setString(indx, it.next().toString());
                    indx++;
                }

                ResultSet resultSetObj = ps.executeQuery();
                return resultSetObj;

            } catch (SQLException ex) {
                System.out.println(ex.toString());
                return null;
            }

        }
        
        /*
         * Returns a prepared statement resource
         * @param  : sql   String  SQL to process 
         * @return : PreparedStatement
         */
        public PreparedStatement getPreparedStmt(String sql) {
            try {
                return this.con.prepareStatement(sql);
            }catch(SQLException ex){
                return null;
            }
        }
        

        /*
         * Creates json string from the sql provided
         * @param  : sql   String  SQL to process and generate json from 
         * @return : String   json equivalent of the result from the sql
         */
        public String getJson(String sql) {
            return this.getJson(sql, false);
        }

        public void getJsonWithHeader(HttpServletResponse response, String json) throws Exception {
            response.setContentType("application/json;charset=ISO-8859-1");
            PrintWriter out = response.getWriter();
            out.print(json);
        }

        /*
         * Creates json string from the sql provided
         * @param  : sql             String  SQL to process and generate json from 
         *           autoAddLabel    Boolean if true add an item called label which is auto incremented value
         * @return : String   json equivalent of the result from the sql
         */
        public String getJson(String sql, Boolean autoAddLabel) {
            try {
                this.stmt = (Statement) this.con.createStatement();
                ResultSet resultSetObj = stmt.executeQuery(sql);

                return this.getJson(resultSetObj, autoAddLabel);
            } catch (SQLException ex) {
                System.out.println(ex.toString());
                return null;
            }
        }

        /*
         * Creates json string from the ResultSet object
         * @param  : resultSetObj   ResultSet  ResultSet to process and generate json from 
         * @return : String   json equivalent of the result from the sql
         */
        public String getJson(ResultSet resultSetObj) {
            return this.getJson(resultSetObj, false);
        }

        /*
         * Creates json string from the ResultSet object
         * @param  : resultSetObj   ResultSet    ResultSet to process and generate json from 
        autoAddLabel   Boolean      if true add an item called label which is auto incremented value
         * @return : String   json equivalent of the result from the sql
         */
        public String getJson(ResultSet resultSetObj, Boolean autoAddLabel) {
            StringBuilder returnStr = new StringBuilder();
            HashMap columnAttributes;
            ArrayList tableColumns = new ArrayList();
            boolean first = true;
            boolean labelExists = false;
            Boolean isNumber = false;
            int count = 0;
            int recCount = 1;
            String fieldValue, tmpFieldValue, fieldName;

            try {
                ResultSetMetaData metaData = resultSetObj.getMetaData();
                int noOfColumns = metaData.getColumnCount();
                for (int i = 1; i <= noOfColumns; i++) {
                    columnAttributes = new HashMap();
                    columnAttributes.put("COLUMN_NAME", metaData.getColumnName(i).toLowerCase());
                    columnAttributes.put("COLUMN_TYPE", metaData.getColumnTypeName(i).toLowerCase());

                    tableColumns.add(columnAttributes);
                    if (metaData.getColumnName(i).equalsIgnoreCase("label")) {
                        labelExists = true;
                        //label exists
                    }
                }
                if (!labelExists && autoAddLabel) {
                    //THERE IS NO LABEL
                    columnAttributes = new HashMap();
                    columnAttributes.put("COLUMN_NAME", "label");
                    columnAttributes.put("COLUMN_TYPE", "INTEGER");

                    tableColumns.add(columnAttributes);
                }

//                returnStr.append("{\n\titems:[\n");
                 returnStr.append("{items:[");

                while (resultSetObj.next()) {
                    count = 0;
                    if (!first) {
                        returnStr.append(",");
                    } else {
                        first = false;
                    }

//                    returnStr.append("\n\t{");
                    returnStr.append("{");
                    Iterator it = tableColumns.iterator();
                    while (it.hasNext()) {
                        count++;
                        columnAttributes = (HashMap) it.next();
                        fieldName = columnAttributes.get("COLUMN_NAME").toString().toLowerCase();

//                        returnStr.append("\n\t\t");
                       

                        returnStr.append("\"");
                        returnStr.append(fieldName);
                        returnStr.append("\"");
                        returnStr.append(":");

                        if (!labelExists && autoAddLabel && "label".equalsIgnoreCase(fieldName)) {
                            returnStr.append(this.returnFieldValue(fieldName, Integer.toString(recCount)));

                        } else {
                            fieldValue = resultSetObj.getString((String) columnAttributes.get("COLUMN_NAME"));
                            returnStr.append(this.returnFieldValue(fieldName, fieldValue));
                        }

                        if (count != tableColumns.size()) {
                            returnStr.append(", ");
                        }
                    }
                    returnStr.append("}");
                    recCount++;
                }

//                returnStr.append("\n]\n}");
                returnStr.append("]}");
                return returnStr.toString();
            } catch (SQLException ex) {
                Logger.getLogger(jsonServer.class.getName()).log(Level.SEVERE, null, ex);
                return null;
            }


        }

        /*
         * this function retuns proper string value after analyzing/processing the hints
         * @param  : fieldName   String    the name of the column of the table 
        fieldValue  String    the value corresponding to the column
         * @return : String   processed value of fieldValue
         */
        public String returnFieldValue(String fieldName, String fieldValue) {
            //CHECK HINT
            StringBuffer returnStr = new StringBuffer();
            boolean appendQuote = true;

            fieldName = fieldName.toLowerCase();

            String tmpFieldValue = null;

            if (!(fieldValue == null || fieldValue.isEmpty())) {
                tmpFieldValue = fieldValue.replaceAll("[^a-zA-Z0-9]+", "");
                if (tmpFieldValue == null || (tmpFieldValue.trim()).length() == 0 || tmpFieldValue.equalsIgnoreCase("null")) {
                    fieldValue = "";
                }
            } else {
                fieldValue = "";
            }
            if (fieldValue == "") {
                returnStr.append("\"");
                returnStr.append("\"");
                return returnStr.toString();
            }

            if (this.hint.containsKey(fieldName)) {

                if (this.hint.get(fieldName).toString().indexOf("ARRAY") != -1) {
                    appendQuote = false;
                } else if (this.hint.get(fieldName).toString().indexOf("STRING") != -1) {
                    appendQuote = true;
                    fieldValue = this.escapeSpecialChars(fieldValue);
                } else if (this.hint.get(fieldName).toString().indexOf("INTEGER") != -1) {
                    appendQuote = false;
                    this.floatValue = Float.parseFloat(fieldValue);
                    this.intValue = floatValue.intValue();
                    fieldValue = intValue.toString();
                } else if (this.hint.get(fieldName).toString().indexOf("FLOAT") != -1) {
                    appendQuote = false;
                }
            } else {
                if (this.isNumber(fieldValue)) {
                    appendQuote = false;
                    fieldValue = this.removeUnwantedDecimals(fieldValue);
                } else {
                    fieldValue = this.escapeSpecialChars(fieldValue);
                }
            }

            if (appendQuote) {
                returnStr.append("\"");
            }
            returnStr.append(fieldValue);
            if (appendQuote) {
                returnStr.append("\"");
            }

            return returnStr.toString();
        }

        /*
         * this function checks if the given value is numeric or not
         * priority is given to hint, if the value is not numeric but the hint says that it is numeric
         * then this function will return true   
         * @param  : str         String    some string value corresponding to the value in the column "columnName"
        columnName  String    the column name of table 
         * @return : Boolean   true if the given str is numeric(or the hint says its numeric)
         *                     false otherwise     
         */
        public Boolean isNumber(String str, String columnName) {
            if (this.hint.containsKey(columnName) && this.hint.get(columnName) == "NUMERIC") {
                return true;
            }
            try {
                Double d = Double.parseDouble(str);
                return true;
            } catch (Exception e) {
                return false;
            }
        }

        /*
         * this function checks if the given value is numeric or not
         * @param  : str         String    some string value
         * @return : Boolean   true if the given str is numeric
         *                     false otherwise     
         */
        public Boolean isNumber(String str) {
            try {
                Double d = Double.parseDouble(str);
                return true;
            } catch (Exception e) {
                return false;
            }
        }

        /*
         * this function removes unwanted decimal values, such as frmo 2.0 to 2
         * @param  : number    String    number in string format
         * @return : String    number in string format with un-necessary decimal removed
         */
        public String removeUnwantedDecimals(String number) {
            if (this.isNumber(number)) {
                Float f = Float.parseFloat(number);
                if (f == f.intValue()) {
                    Integer i = f.intValue();
                    return i.toString();
                }
            }
            return number;

        }

        /*
         * this function sets the hint
         * @param  : hint    HashMap    HashMap with key representing table column name
         * @return : VOID
         */
        public void setHint(HashMap hint) {
            this.hint = hint;
        }
    }
%>