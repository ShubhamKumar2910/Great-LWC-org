/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - FileParserUtil
 *
 */
@isTest
private class FileParserUtilTest {

    static testMethod void testParseFile() {
        // TO DO: implement unit test
        Map<String, String> FieldApiByFieldLabelMap = new Map<String, String>(); 
		FieldApiByFieldLabelMap.put('RecordIdentifier', 'Identifier');
		FieldApiByFieldLabelMap.put('DeskCommentaryProhibited', 'DeskCommentaryProhibited__c');
        
        // error - Identifier Missing
        String fileBodyTxt = ',DeskCommentaryProhibited\n';
        Blob bodyBlob=Blob.valueOf(fileBodyTxt);
        Boolean isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - null fule
        fileBodyTxt = ',DeskCommentaryProhibited\n';
        bodyBlob=null;
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - no data rows
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - empty file
        fileBodyTxt = '';
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true); 
        
        // error - no object api name
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, null, 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - duoplicate entries
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident2,EMEA\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident1,EMEA\n'; 
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - empty row
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += '\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n'; 
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - empty identifier
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += ',US\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n'; 
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - empty header field
        fileBodyTxt = 'RecordIdentifier,\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n'; 
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - invalid header column
        fileBodyTxt = 'RecordIdentifier,TEMP\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n'; 
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - valid filr
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident2,US\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n'; 
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	Map<String, sObject> ParsedData = FileParserUtil.parseFile(bodyBlob, 'Contact', 
        		FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
        	isErr=true;
        }
        System.assertEquals(isErr, false);
    }
    
    
    static testMethod void testParseHeader() {
        // TO DO: implement unit test
        Map<String, String> FieldApiByFieldLabelMap = new Map<String, String>(); 
		FieldApiByFieldLabelMap.put('RecordIdentifier', 'Identifier');
		FieldApiByFieldLabelMap.put('DeskCommentaryProhibited', 'DeskCommentaryProhibited__c');
        
        // error - null file
        String fileBodyTxt = ',DeskCommentaryProhibited\n';
        Blob bodyBlob=null;
        Boolean isErr=false;
        try {
        	 	Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(bodyBlob, 
        	 			FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - less than 2 lines
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	 	Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(bodyBlob, 
        	 			FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, true);
        
        // error - valid file
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident2,US\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n';
        bodyBlob=Blob.valueOf(fileBodyTxt);
        isErr=false;
        try {
        	 	Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(bodyBlob, 
        	 			FieldApiByFieldLabelMap, '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, false);
    }
    
    static testMethod void testParseNRows() {
        // TO DO: implement unit test
        Map<String, String> FieldApiByFieldLabelMap = new Map<String, String>(); 
		FieldApiByFieldLabelMap.put('RecordIdentifier', 'Identifier');
		FieldApiByFieldLabelMap.put('DeskCommentaryProhibited', 'DeskCommentaryProhibited__c');
        
        String fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident100,EMEA\n';
        Blob fileBody=Blob.valueOf(fileBodyTxt);
        Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(fileBody,FieldApiByFieldLabelMap, '\n', ',');
										
        // success
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident2,US\n';
        fileBodyTxt += 'ident3,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n';
        fileBodyTxt += 'ident5,EMEA\n';
        fileBodyTxt += 'ident6,EMEA\n';
        fileBodyTxt += 'ident7,EMEA\n';
        fileBodyTxt += 'ident8,EMEA\n';
        fileBody=Blob.valueOf(fileBodyTxt);
        FileParserUtil.FileReaderInfo fileReadInfo;
        Boolean isErr=false;
        try {
        	 	fileReadInfo = FileParserUtil.parseNRows(fileBody, FieldApiByHeaderIndxMap, 
    					1, 3, 'Contact', '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, false);
        System.assertEquals(fileReadInfo.isEOF, false);
        
        isErr=false;
        try {
        	 	fileReadInfo = FileParserUtil.parseNRows(fileBody, FieldApiByHeaderIndxMap, 
    					fileReadInfo.filePointer, 3, 'Contact', '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, false);
        System.assertEquals(fileReadInfo.isEOF, false);
        
        isErr=false;
        try {
        	 	fileReadInfo = FileParserUtil.parseNRows(fileBody, FieldApiByHeaderIndxMap, 
    					fileReadInfo.filePointer, 3, 'Contact', '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, false);
        System.assertEquals(fileReadInfo.isEOF, true);
        
        // error - duplicate
        fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'ident1,EMEA\n';
        fileBodyTxt += 'ident2,US\n';
        fileBodyTxt += 'ident2,EMEA\n';
        fileBodyTxt += 'ident4,EMEA\n';
        fileBodyTxt += 'ident5,EMEA\n';
        fileBodyTxt += 'ident6,EMEA\n';
        fileBodyTxt += 'ident7,EMEA\n';
        fileBodyTxt += 'ident8,EMEA\n';
        fileBody=Blob.valueOf(fileBodyTxt);
        fileReadInfo=null;
        isErr=false;
        try {
        	 	fileReadInfo = FileParserUtil.parseNRows(fileBody, FieldApiByHeaderIndxMap, 
    					1, 4, 'Contact', '\n', ',');
        } catch(Exception ex) {
        	isErr=true;
        }
        System.assertEquals(isErr, false);
        System.assertEquals(fileReadInfo.isEOF, false);
        System.debug('fileReadInfo : '+fileReadInfo);
        System.assertEquals(fileReadInfo.ErrorByLineNoMap.isEmpty(), false);
    }
}