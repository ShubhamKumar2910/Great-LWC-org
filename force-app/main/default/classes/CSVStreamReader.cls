public class CSVStreamReader {
    
    /**
    * Returns a List containing Lists of Strings that represents
    * the values contained in an IETF RFC 4180-compliant CSV file.
    *
    * Each element in the outer list represents a row in the CSV file.
    * Each element in the inner list is the value in the field specified
    * by the row-column combination.
    *
    * @param  file the CSV file to read
    * @return      the List<List<String>> containing values read from the
    *              CSV file
    */
    /*public static List<List<String>> readIETFRFC4180CSVFile(Blob file) {
        String fileString = file.toString();
        
        if (!fileString.endsWith(CSVStreamParser.CRLF)) {
            fileString = fileString + CSVStreamParser.CRLF;
        }
        
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();
        
        Boolean eod = false;  // Whether end of CSV data is reached
        while (!eod) {
            
            csvValue = readIETFRFC4180CSVValue(fileString);
            
            rowValues.add(csvValue.value);
            
            if (csvValue.delimiter == CSVStreamParser.CRLF) {
                fileValues.add(rowValues);
                
                
                if (fileValues.size() > 0) {
                    System.assertEquals(fileValues.get(0).size(),
                                        rowValues.size());
                }
                
                rowValues = new List<String>();
            }
            
            if (csvValue.biteSize() == fileString.length()) {
                eod = true;
            }
            else {
                fileString = fileString.substring(csvValue.biteSize());
            }
        }
        
        return fileValues;
    }
    */
    /**
    * Returns the first String value read from a String representation of
    * data contained in an IETF RFC 4180-compliant CSV file.
    *
    * The data is assumed to be terminated with a CRLF.
    *
    * @param  data the textual CSV data in one long string
    * @return      the first CSV value read from <code>data</code>.
    *              null is returned if no value is discerned.
    */
    public static CSVValue readIETFRFC4180CSVValue(String data) {
        System.assert(data.endsWith(CSVStreamParser.CRLF));
        
        CSVValue csvValue = new CSVValue();
        
        if (data.startsWith(CSVStreamParser.DQUOTE)) {
            csvValue.enclosed = true;
            
            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE
            
            Boolean closerFound = false;
            
            while (!closerFound) {
                dquoteIndex = data.indexOf(CSVStreamParser.DQUOTE, searchIndex);
                
                dquotesIndex = data.indexOf(CSVStreamParser.DQUOTEDQUOTE,
                                            searchIndex);
                
                System.assert(dquoteIndex != -1);
                
                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex
                        + CSVStreamParser.DQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }
            
            csvValue.value = data.substring(
                CSVStreamParser.DQUOTE.length(), dquoteIndex)
                .replaceAll(CSVStreamParser.DQUOTEDQUOTE, CSVStreamParser.DQUOTE);
            
            Integer commaIndex = data.indexOf(CSVStreamParser.COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(CSVStreamParser.CRLF, dquoteIndex);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = CSVStreamParser.COMMA;
            }
            else {
                csvValue.delimiter = CSVStreamParser.CRLF;
            }
        }
        else {
            csvValue.enclosed = false;
            
            Integer commaIndex = data.indexOf(CSVStreamParser.COMMA);
            Integer crlfIndex = data.indexOf(CSVStreamParser.CRLF);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = CSVStreamParser.COMMA;
            }
            else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = CSVStreamParser.CRLF;
            }
        }
        
        
        return csvValue;
    }
    
    /**
    * CSVValue is a class structure containing information about a CSV
    * value that was read from a CSV file, including such information as
    * whether the value was encapsulated in double-quotes.
    */
    public class CSVValue {
        /**
        * The field value that was read from the CSV file.
        */
        public String value;
        
        /**
        * Whether the value was surrounded by double-quotes.
        */
        public Boolean enclosed;
        
        /**
        * The comma or CRLF delimiter that identified the end of the CSV value.
        */
        public String delimiter;
        
        /**
        * Default constructor, setting all members to null.
        */
        public CSVValue() {
            this(null, null, null);
        }
        
        /**
        * Constructor.
        *
        * @param value     the field value
        * @param enclosed  whether the value was surrounded by double-quotes
        * @param delimiter the delimiter that identified the end
        *                  of the CSV value
        */
        public CSVValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }
        
        /**
        * Returns the number of characters to remove from the data
        * String which produced the CSVValue in order to reach the next
        * value in the data String.
        */
        public Integer biteSize() {
            Integer biteSize = value
                .replaceAll(CSVStreamParser.DQUOTE, CSVStreamParser.DQUOTEDQUOTE).length()
                + delimiter.length();
            
            if (enclosed) {
                biteSize += CSVStreamParser.DQUOTE.length() * 2;
            }
            
            
            return biteSize;
        }
        public CSVValue(CSVStreamParser pars)
        {
            
        }
        
        /**
        * Returns whether a CSVValue has the same <code>value</code> and
        * <code>enclosed</code> as another CSVValue.
        */
        /*public Boolean equals(CSVValue compCSVValue) {
            return this.value.equals(compCSVValue.value)
                && this.enclosed == compCSVValue.enclosed
                && this.delimiter == compCSVValue.delimiter;
        }*/
        
        /**
        * Asserts that two <code>CSVValue</code> instances have the same
        * <code>value</code> and <code>enclosed</code>.
        */
        /*public void assertEquals(CSVValue compCSVValue) {
            System.assertEquals(value, compCSVValue.value);
            System.assertEquals(enclosed, compCSVValue.enclosed);
            System.assertEquals(delimiter, compCSVValue.delimiter);
        }*/
    }
    
    public static List<List<String>> readCSVFile(String file, CSVStreamParser pars)
    {
        //Remove trailing empty lines
        String fileString = file.replaceAll('\\s*\\z', '');
        if(!fileString.endsWith(CSVStreamParser.crlf))
            fileString = fileString + CSVStreamParser.crlf;
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValues = new CSVValue(pars);
        Boolean eod = false; //Whether end of CSV data is reached
        while(!eod)
        {
            csvValues = CSVStreamReader.readIETFRFC4180CSVValue(fileString);
            rowValues.add(csvValues.value);
            if(csvValues.delimiter == CSVStreamParser.crlf)
            {
                fileValues.add(rowValues);
                if(fileValues.size() > 0)
                {
                    if(fileValues.get(0).size() != rowValues.size())
                    {}     //Throw an exception
                }
                rowValues = new List<String>();
            }
            if(csvValues.biteSize() == fileString.length())
                eod = true;
            else
                fileString = fileString.subString(csvValues.biteSize());
        }
        return fileValues;
    }
    
}