/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for lightning compoment c:BulkUpdateDeskCommentaryProhibited
**/ 
public class FileParserUtil {
    public static Map<String, sObject> parseFile(Blob fileData, String objectApiName, 
    		Map<String, String>FieldApiByFieldLabelMap, String rowDel, String columnDel) {
    	System.debug('#### FileParserUtil::parseFile');
		Map<String, sObject> RowDataSObjByIdenrMap = new Map<String, sObject>(); 
    	String error='';
    	try {
    		if(fileData==null) {
				error='File is Empty';	
    		} if(String.isBlank(objectApiName)) {
    			error='Please provide the valid ObjectAPI name';
    		} else {
    			rowDel = String.isBlank(rowDel) ? '\n' : rowDel;
    			columnDel = String.isBlank(columnDel) ? ',' : columnDel; 
	    		String contentTxt = fileData.toString();
	    		List<String> lines = new List<String>();
	    		lines = contentTxt.split(rowDel);
	    		if(lines.size()<2) {
	    			error = 'There should be ataleast Header and one Row to upload';
	    		} else {
	    			// parse the Header 
	    			Map<Integer, String> FieldApiByHeaderIndxMap = parseHeaderLine(lines[0], FieldApiByFieldLabelMap, columnDel);
	    			System.debug('HEADER MAP : '+FieldApiByHeaderIndxMap);
	    			// parse each row
	    			for(Integer rowIndx=1; rowIndx<lines.size(); ++rowIndx) {
	    				Map<String, sObject> ParsedSObjRowByIdentMap = parseRowLineWithValidation(lines.get(rowIndx), rowIndx, 
	    					objectApiName, FieldApiByHeaderIndxMap, columnDel);
	    				for(String identifier : ParsedSObjRowByIdentMap.keySet()) {
	    					if(RowDataSObjByIdenrMap.containsKey(identifier)) {
	    						error='Duplicate record entries found with record identifier : '+identifier;
	    						break;
	    					}
	    				}
	    				RowDataSObjByIdenrMap.putAll(ParsedSObjRowByIdentMap);
	    			}
	    		}
    		}
    		
    	} catch (Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		error = ex.getMessage();
    	}
    	
    	if(String.isNotBlank(error)) {
			throw new FileParserException(error);
		}
		
		return RowDataSObjByIdenrMap;
    }
    
    
    public static Map<Integer, String> parseHeader(Blob fileData, Map<String, String>FieldApiByFieldLabelMap, 
    		String rowDel, String columnDel) {
    	System.debug('#### FileParserUtil::parseHeader');
		Map<Integer, String> FieldApiByHeaderIndxMap = new Map<Integer, String>(); 
    	String error='';
    	try {
    		if(fileData==null) {
				error='File is Empty';	
    		} else {
    			rowDel = String.isBlank(rowDel) ? '\n' : rowDel;
    			columnDel = String.isBlank(columnDel) ? ',' : columnDel; 
	    		String contentTxt = fileData.toString();
	    		List<String> lines = new List<String>();
	    		lines = contentTxt.split(rowDel, 3);
	    		if(lines.size()<2 || String.isBlank(lines[1])) {
	    			error = 'There should be ataleast Header and one Row to upload';
	    		} else {
	    			FieldApiByHeaderIndxMap = parseHeaderLine(lines[0], FieldApiByFieldLabelMap, columnDel);
	    			System.debug('HEADER MAP : '+FieldApiByHeaderIndxMap);
	    		}
    		}
    	} catch (Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		error = ex.getMessage();
    	}
    	
    	if(String.isNotBlank(error)) {
			throw new FileParserException(error);
		}
		
		return FieldApiByHeaderIndxMap;
	}
    
    private static Map<Integer, String> parseHeaderLine(String headerLine, 
    		Map<String,String>FieldApiByFieldLabelMap, String columnDel) {
    	System.debug('#### FileParserUtil::parseHeaderLine');
    	System.debug('FieldApiByFieldLabelMap : '+FieldApiByFieldLabelMap);
    	String error='';
    	Map<Integer, String> FieldApiByHeaderIndxMap = new Map<Integer, String>(); 
    	try {
	    	List<String> headerFields = headerLine.split(columnDel);
	    	// atleast 2 colums should be specified
	    	if(headerFields.size()<2 || String.isBlank(headerFields.get(0).trim()) || 
	    			!FieldApiByFieldLabelMap.containsKey(headerFields.get(0).trim())) {
	    		error='File should contain atleast 2 coulmns and first column should be Identifier field Or the Identifier field not mapped correctly';
	    	} else { 
		    	// always assume that first column is Identifier, and we don't need API name for it as this field is not updated
		    	FieldApiByHeaderIndxMap.put(0, headerFields.get(0).trim());
				for(Integer indx = 1; indx<headerFields.size(); ++indx) {
					String fieldLbl=headerFields.get(indx).trim();
					System.debug('fieldLbl : '+fieldLbl);
					if(String.isNotBlank(fieldLbl)) {
						// to do - establish the mapping here
						System.debug('1 '+FieldApiByFieldLabelMap.containsKey(fieldLbl));
						if(FieldApiByFieldLabelMap.containsKey(fieldLbl)) {
							String fieldApi=FieldApiByFieldLabelMap.get(fieldLbl).trim();
							System.debug('2 '+FieldApiByFieldLabelMap.containsKey(fieldLbl));
							if(String.isBlank(fieldApi)) {
								error='Invalid Field Label to Feild API Mapping for file header column : '+fieldLbl;
								break;	
							} else {
								FieldApiByHeaderIndxMap.put(indx, fieldApi);
							}
						}
					}
					else {
						//throw error
						error='File cannot be uploaded with empty header, found an empty header field at position : '+indx;
						break;
					}
				}
				
				System.debug('Error so far : '+error);
				System.debug('FieldApiByHeaderIndxMap : '+FieldApiByHeaderIndxMap);
				// is there is no error so far, check the number of valid columns found
				if(String.isBlank(error) && FieldApiByHeaderIndxMap.size()<2) {
					error='There should be atlease two valid colums of data, and first column should be Identifier column and others should be fields to be updated';
				}
				// Remove the following temporary code
				//FieldApiByHeaderIndxMap.put(0,'Identifier');
				//FieldApiByHeaderIndxMap.put(1,'DeskCommentaryProhibited__c');
	    	}
    	} catch(Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		error = ex.getMessage();
    	}
		
		if(String.isNotBlank(error)) {
			throw new FileParserException('Error in parsing the file Header : '+error);
		}
		
		return FieldApiByHeaderIndxMap;
    }
    

	public class FileReaderInfo {
		public Integer filePointer;
		public Boolean isEOF;
		public Map<String, sObject> RowDataSObjByIdenrMap;
		public Map<Integer, String> ErrorByLineNoMap;
	}

	public static FileReaderInfo parseNRows(Blob fileData, Map<Integer, String> FieldApiByHeaderIndxMap,
			Integer filePointer, Integer bufferSize, String objectApiName, String rowDel, String columnDel) {
		System.debug('#### FileParserUtil::parseNRows');
		System.debug('fileData '+fileData);
		Integer initialFilePointer = filePointer; 
		FileReaderInfo fileReadInfo = new FileReaderInfo();
		//Map<String, sObject> RowDataSObjByIdenrMap = new Map<String, sObject>();
		// Boolean isEOF = false;
		try {
			fileReadInfo.RowDataSObjByIdenrMap = new Map<String, sObject> ();
			fileReadInfo.ErrorByLineNoMap = new Map<Integer, String>();
			fileReadInfo.filePointer = filePointer;
			fileReadInfo.isEOF = false;
			if(String.isBlank(columnDel)) {
				columnDel=',';
			}
			if(String.isBlank(rowDel)) {
				rowDel='\n';
			}
			String fileDataTxt = fileData.toString();
			List<String> lines = fileDataTxt.split(rowDel);
			Integer totalNoOfLines = lines.size();
			System.debug('totalNoOfLines : '+totalNoOfLines);
			//Integer currRowNo = filePointer;
			if(fileReadInfo.filePointer >= totalNoOfLines) {
				fileReadInfo.isEOF = true;
			} 
			else {
				Integer noOfRowsParsed=0;
				Map<String, sObject> ParsedSObjRowByIdentMap = new Map<String, sObject>();
				Set<String>UniqueIdentSet = new Set<String>();
				String error;
				for(; fileReadInfo.filePointer < totalNoOfLines && noOfRowsParsed < bufferSize; ) {
					error='';
					ParsedSObjRowByIdentMap.clear(); 
					error = parseRowLineWithOutValidation(lines.get(fileReadInfo.filePointer), 
							fileReadInfo.filePointer, FieldApiByHeaderIndxMap, objectApiName, columnDel, ParsedSObjRowByIdentMap);
					if(String.isNotBlank(error)) {
						// error in parsing
						fileReadInfo.ErrorByLineNoMap.put(fileReadInfo.filePointer, error);
					} else if(!ParsedSObjRowByIdentMap.isEmpty()){
						String key = (new List<String>(ParsedSObjRowByIdentMap.keySet())).get(0).toUpperCase();
						if(UniqueIdentSet.add(key)) {
							fileReadInfo.RowDataSObjByIdenrMap.putAll(ParsedSObjRowByIdentMap);
							//System.debug('fileReadInfo.RowDataSObjByIdenrMap : '+fileReadInfo.RowDataSObjByIdenrMap);
						} else {
							// duplicate found
							fileReadInfo.ErrorByLineNoMap.put(fileReadInfo.filePointer, 'Duplicate entry found for : '+ParsedSObjRowByIdentMap.keySet()+' : at row number : '+(fileReadInfo.filePointer+1));
						}
					} else {
						// we should receive parsed row
						fileReadInfo.ErrorByLineNoMap.put(fileReadInfo.filePointer, '');
					}
					// increment counters;
					++fileReadInfo.filePointer;
					++noOfRowsParsed;
				}
				
				// update the filePointer to the new position Number
				if(fileReadInfo.filePointer >= totalNoOfLines) {
					fileReadInfo.isEOF=true;
				}
			}
		} catch(Exception ex) {
			// ToDo decide wat to do about exception
			// whether to fail all parsed records or absorb the exception and return the results we have so far
			System.debug('Error : '+ex.getMessage());
    		System.debug('Error Stack : '+ex.getStackTraceString());
			throw new FileParserException('Error in parsing the file block of size '+bufferSize+' starting at row : '+(filePointer+1)+ ' : '+ex.getMessage());
		}
		
		return fileReadInfo;
	}
	
	private static String parseRowLineWithOutValidation(String rowLine, Integer rowIndx,  
    		Map<Integer, String> FieldApiByHeaderIndxMap, String objectApiName, String columnDel,
    		Map<String, sObject> ParsedSObjByIndentifier) {
    	System.debug('#### FileParserUtil::parseRowLineWithOutValidation');
    	//Map<String, sObject> ParsedSObjByIndentifier = new Map<String, sObject>();
    	String error=''; 
    	try{
    		if(String.isNotBlank(rowLine)) {
    			List<String> rowFields = rowLine.split(columnDel);
    			if(!rowFields.isEmpty()) {
    				String key;
					sObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject() ;
					for(Integer indx : FieldApiByHeaderIndxMap.keySet()) {
						// first column is always assumed to be Row identifier and should be non-null
						if(indx==0) {
							// Identifier
							String identifierVal = rowFields.get(indx).trim(); 
							if(String.isBlank(identifierVal)) {
								error='Error : Found empty Identifier key at row number - '+(rowIndx+1);
								break;
							} else {
								key = identifierVal;
							}
						} else {
							// non-indentifier field
							String val;
							if(indx < rowFields.size()) {
								val = rowFields.get(indx).trim();
								if(String.isBlank(val)) {
									val = null;
								}
							}
							//System.debug('val : '+val);
							sObj.put(FieldApiByHeaderIndxMap.get(indx), val);
						}
                    }
                    if(String.isNotBlank(key)) {
						ParsedSObjByIndentifier.put(key, sObj);
                    }
    			} 
    		}
    	} catch(Exception ex) {
    		// as no validations are performed, absorb the exception and an empty structure will be returned 
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error Stack : '+ex.getStackTraceString());
			throw new FileParserException('Error in parsing the file row, row number : '+(rowIndx+1)+' Error: '+ex.getMessage());
    	}
    	return error;
	}

    private static Map<String, sObject> parseRowLineWithValidation(String rowLine, Integer rowIndx, String objectApiName, 
    		Map<Integer, String> FieldApiByHeaderIndxMap, String columnDel) {
    	System.debug('#### FileParserUtil::parseRowLineWithValidation');
    	Map<String, sObject> ParsedSObjByIndentifier = new Map<String, sObject>(); 
    	String error='';
    	try {
    		if(String.isBlank(rowLine)) {
    			error='File cannot be uploaded with Null row';
    		} else {
				List<String> rowFields = rowLine.split(columnDel);
				System.debug('rowFields : '+rowFields);
				if(rowFields.isEmpty()) {
					error='File cannot be uploaded with empty row, atleast Indentifier field should be populated, row number : '+(rowIndx+1);				
				} else {
					String key;
					sObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject() ;
					for(Integer indx : FieldApiByHeaderIndxMap.keySet()) {
						// first column is always assumed to be Row identifier and should be non-null
						if(indx==0) {
							// Identifier
							String identifierVal = rowFields.get(indx).trim(); 
							if(String.isBlank(identifierVal)) {
								error='Identifier field cannot be null, found null Identifier field at row number : '+(rowIndx+1);
								break;
							} else {
								key = identifierVal.toUpperCase();
							}
							System.debug('key : '+key);
						} else {
							// non-indentifier field
							String val;
							if(indx < rowFields.size()) {
								val = rowFields.get(indx).trim();
								if(String.isBlank(val)) {
									val = null;
								}
							}
							//String val = (indx < rowFields.size() && String.isNotBlank(rowFields.get(indx))) ?
							//	rowFields[indx] : null;
							System.debug('val : '+val);
							sObj.put(FieldApiByHeaderIndxMap.get(indx), val);
							//System.debug('sObj : '+sObj);
						}
                    }
					
					if(String.isBlank(error)) {
						ParsedSObjByIndentifier.put(key, sObj);
						System.debug('ParsedSObjByIndentifier : '+ParsedSObjByIndentifier);
					} 
				}
    		}
    	} catch(Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		error = ex.getMessage();
    	}
    	
    	if(String.isNotBlank(error)) {
    		throw new FileParserException('Error in parsing the file row, row number : '+(rowIndx+1)+' Error: '+error);
    	}
    	
    	return ParsedSObjByIndentifier;
    }
    
    public class FileParserException extends Exception{
	    // Add members and methods here to communicate data
	    // relating to exceptions
	}
}