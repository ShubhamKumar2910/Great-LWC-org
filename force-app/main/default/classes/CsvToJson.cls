public class CsvToJson {
    public static String csvToJSON(String dataKeyName, String contents, Integer headerLineNum, Boolean hasDataTypeRow, Integer headerTypeLineNum, Integer[] skipTopLines, Integer[] skipFields) {    
       
         String[] headerFields = new String[]{};
         String[] headerFieldTypes = new String[]{};
         String jsonString = '';
         // replace instances where a double quote begins a field containing a comma  
         // in this case you get a double quote followed by a doubled double quote    
         // do this for beginning and end of a field    
     
         contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');    
      
         // now replace all remaining double quotes - we do this so that we can reconstruct 
         // fields with commas inside assuming they begin and end with a double quote     
      
         contents = contents.replaceAll('""','DBLQT');    
     
         // we are not attempting to handle fields with a newline inside of them  
         // so, split on newline to get the spreadsheet rows     
      
         List<String> lines = new List<String>();      
      
         try {
             lines = contents.split('\n');
         }  catch (System.ListException e) {
             System.debug('Limits exceeded?' + e.getMessage());
         }     
      
              
      	 Integer lineNum = 0;
         Integer[] skippedFieldsIndex = new Integer[]{};
         for(String line : lines) {
             if(!skipTopLines.contains(lineNum)) {
                 // check for blank CSV lines (only commas)
                 if (line.replaceAll(',','').trim().length() == 0) break;               
          
                 List<String> fields = line.split(',');          
                 List<String> cleanFields = new List<String>();    
                 String compositeField;  
                 Boolean makeCompositeField = false; 
                 
                 for ( String field : fields ) {
                     if (field.startsWith('"') && field.endsWith('"')) {
                         cleanFields.add(field.replaceAll('DBLQT','"').replaceAll('"',''));
                     } else if (field.startsWith('"')) {
                         makeCompositeField = true;  
                         compositeField = field;
                     } else if (field.endsWith('"')) {
                         compositeField += ',' + field;    
                         cleanFields.add(compositeField.replaceAll('DBLQT','"').replaceAll('"',''));    
                         makeCompositeField = false;
                     } else if (makeCompositeField) {
                         compositeField +=  ',' + field;   
                     } else {
                         cleanFields.add(field.replaceAll('DBLQT','"').replaceAll('"',''));
                     }
                 }
                 
                 if(lineNum != headerLineNum && lineNum != headerTypeLineNum){
                       jsonString += '{';                    
                 }               
				
                 Integer fieldNum = 0;
                 Integer ultimateFieldNumber = 0;
                 for(String s : cleanFields){                     
                     try{
                         if(lineNum == headerLineNum && !skipFields.contains(fieldNum)){
                            headerFields.add(s); 
                         } else if(hasDataTypeRow && lineNum == headerTypeLineNum && !skipFields.contains(fieldNum)){
                            headerFieldTypes.add(s);                    
                         } else if(!skipFields.contains(fieldNum)){
                             if(ultimateFieldNumber > 0){
                                 jsonString += ', ';
                             }
                             if((hasDataTypeRow && headerFieldTypes[ultimateFieldNumber] == 'String') || !hasDataTypeRow){
                                 jsonString += '"' + headerFields[ultimateFieldNumber] + '" : "' + s + '"';
                             } else {
                                 jsonString += '"' + headerFields[ultimateFieldNumber] + '" : ' + s;        
                             }
                             ultimateFieldNumber++;
                         }                            
                         fieldNum++;
                     }
                     catch(Exception e) {
                         system.debug(e.getMessage());
                     }
                 }
                 
                 if(lineNum != headerLineNum && lineNum != headerTypeLineNum){
                       jsonString += '},';                   
                 }                 
             } 
                 
             lineNum++;
         }
         
         String finalJsonString = '{"' + dataKeyName + '" : [' + jsonString.removeEnd(',') + ']}';
      	 
         return finalJsonString;          
      
    }   
}