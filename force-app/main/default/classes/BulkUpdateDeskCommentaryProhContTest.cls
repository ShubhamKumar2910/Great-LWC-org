/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - BulkUpdateDeskCommentaryProhController
 *
 */
 
 @isTest
private class BulkUpdateDeskCommentaryProhContTest {

    static testMethod void testInitialize() {
        // TO DO: implement unit test
        BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        System.assertNotEquals(bulkUpdDskCommInit, null);
        System.assertNotEquals(bulkUpdDskCommInit.campaignId, null);
    }
    
    static testMethod void testDeleteOldEmptyCampaigns() {
        // TO DO: implement unit test
        BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit1 = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        
        // set the old date on just created campaign
        Test.setCreatedDate(bulkUpdDskCommInit1.campaignId, DateTime.newInstance(2015,12,12));
        
        BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit2;
        Test.startTest();
        	bulkUpdDskCommInit2 = BulkUpdateDeskCommentaryProhController.initialize();
        Test.stopTest();
        
        System.assertNotEquals(bulkUpdDskCommInit1.campaignId, bulkUpdDskCommInit2.campaignId);
        List<Campaign> CampList = [SELECT Id FROM Campaign WHERE Id=:bulkUpdDskCommInit1.campaignId];
        System.assertEquals(CampList.size(), 0);
    }
    
    static testMethod void testDownloadFileTempl() {
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
         String rgTmpId = BulkUpdateDeskCommentaryProhController.downloadFileTempl(bulkUpdDskCommInit.campaignId, true, false, 
			false);
		String rmTmpId = BulkUpdateDeskCommentaryProhController.downloadFileTempl(bulkUpdDskCommInit.campaignId, false, true, 
			false);
		String contTmpId = BulkUpdateDeskCommentaryProhController.downloadFileTempl(bulkUpdDskCommInit.campaignId, false, false, 
			true);
		
		System.assertNotEquals(rgTmpId, null);
		System.assertNotEquals(rmTmpId, null);
		System.assertNotEquals(contTmpId, null);
    }
    
    static testMethod void testVerifyUploadedFileErr() {
    	// first create a campaign
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg1rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm2);

        insert testAccounts;

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c1);
        insert contacts; 
        
        // create a temporary file
        String fileBodyTxt = 'RecordIdentifier,DeskCommentaryProhibited\n';
        fileBodyTxt += 'RGXXXXXX,US;EMEA;AEJ\nRG_ACC_NAME,EMEA;US\n';
        
        Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
		ContentVersion oContVer = new ContentVersion(
			Title='RG_ACC_UPLOAD', 
			PathOnClient ='/'+'RG_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String contDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		ContentDocumentLink oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = contDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink; 
      
      	// now verify the file just created here
      	Boolean isErr=false;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskValidateFile fileValidattionInfo;
      	Test.startTest();
      		try {
      			fileValidattionInfo=BulkUpdateDeskCommentaryProhController.verifyUploadedFile(contDocId, true, false, false);
  			} catch(Exception ex) {
  				isErr=true;
  			}
      	Test.stopTest();
      	System.assertEquals(isErr, false);
      	System.assertNotEquals(fileValidattionInfo.errors, null);
    }
    
    static testMethod void testVerifyUploadedFileSucc() {
    	// first create a campaign
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg1rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg1.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm2);

        insert testAccounts;

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c1);
        insert contacts; 
        
        // create a RG temporary file
        String fileHeader = '';
        Map<String, String> FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('RG');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        String fileBodyTxt = fileHeader;
        fileBodyTxt += 'G1 Test Account,US;EMEA;AEJ\nRGTest2,EMEA;US\n';
        
        Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
		ContentVersion oContVer = new ContentVersion(
			Title='RG_ACC_UPLOAD', 
			PathOnClient ='/'+'RG_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String rgContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		ContentDocumentLink oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = rgContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink; 
      
      
      	// create a RM temporary file
        fileHeader = '';
        FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('RM');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        fileBodyTxt = fileHeader;
        fileBodyTxt += 'RM Test Account 1,US;EMEA;AEJ\nRMTest4,EMEA;US\n';
        
        bodyBlob=Blob.valueOf(fileBodyTxt); 
		oContVer = new ContentVersion(
			Title='RM_ACC_UPLOAD', 
			PathOnClient ='/'+'RM_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String rmContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = rmContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink;
        
        
        // create a CONT temporary file
        fileHeader = '';
        FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('CONT');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        fileBodyTxt = fileHeader;
        fileBodyTxt += 'johnnysmith@test.com,US;EMEA;AEJ\njamessmith@test.com,EMEA;US\n';
        
        bodyBlob=Blob.valueOf(fileBodyTxt); 
		oContVer = new ContentVersion(
			Title='CONT_ACC_UPLOAD', 
			PathOnClient ='/'+'CONT_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String contactContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = contactContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink;
      
      
      	// now verify the file just created here
      	Boolean isRGErr=false;
      	Boolean isRMErr=false;
      	Boolean isContErr=false;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskValidateFile rgFileValidattionInfo;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskValidateFile rmFileValidattionInfo;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskValidateFile contFileValidattionInfo;
      	Test.startTest();
      		try {
      			rgFileValidattionInfo = BulkUpdateDeskCommentaryProhController.verifyUploadedFile(rgContDocId, true, false, false);
      			System.debug('rgFileValidattionInfo : '+rgFileValidattionInfo);
  			} catch(Exception ex) {
  				isRGErr=true;
  				System.debug('Error : '+ex.getMessage());
    			System.debug('Error stack: '+ex.getStackTraceString());
  			}
  			
  			try {
      			rmFileValidattionInfo = BulkUpdateDeskCommentaryProhController.verifyUploadedFile(rmContDocId, false, true, false);
      			System.debug('rmFileValidattionInfo : '+rmFileValidattionInfo);
  			} catch(Exception ex) {
  				isRMErr=true;
  				System.debug('Error : '+ex.getMessage());
    			System.debug('Error stack: '+ex.getStackTraceString());
  			}
  			
  			try {
      			contFileValidattionInfo = BulkUpdateDeskCommentaryProhController.verifyUploadedFile(contactContDocId, false, false, true);
      			System.debug('contFileValidattionInfo : '+contFileValidattionInfo);
  			} catch(Exception ex) {
  				isContErr=true;
  				System.debug('Error : '+ex.getMessage());
    			System.debug('Error stack: '+ex.getStackTraceString());
  			}
      	Test.stopTest();
      	
      	System.assertEquals(isRGErr, false);
      	System.assertEquals(String.isBlank(rgFileValidattionInfo.errors), true);
      	
      	System.assertEquals(isRMErr, false);
      	System.assertEquals(String.isBlank(rmFileValidattionInfo.errors), true);
      	
      	System.assertEquals(isContErr, false);
      	System.assertEquals(String.isBlank(contFileValidattionInfo.errors), true);
    }
    
    static testMethod void testStartBulkUpload_ByRGAcc() {
    	// first create a campaign
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		

        insert testAccounts;
        
        System.debug('ACCOUNTS : '+[SELECT Id,RDM_Org_ID__c FROM Account]);

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        c.RG_Account__c=rg1.Id;
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 222-4567', 'Dear [FirstName]', rg2rm2.Id, true);
        c1.RG_Account__c=rg2.Id;
        contacts.add(c1);
        
        Contact c2 = UtilityTesting.createContact('Jamy', 'Smithy', 'jamessmithy@test.com', '(212) 522-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c2.RG_Account__c=rg3.Id;
        contacts.add(c2);
        
        Contact c3 = UtilityTesting.createContact('Jamesx', 'Smithx', 'jamessmithx@test.com', '(212) 228-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c3.RG_Account__c=rg3.Id;
        contacts.add(c3);
        
        insert contacts;
        
        List<Contact> ContList = [SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email 
        FROM Contact WHERE (RG_Account__c = :rg1.Id OR RG_Account__c = :rg2.Id )  AND Active__c=true]; 
        System.debug('IN TEST CONT : '+ContList);
        
        System.debug('LIST OF CONTACTS :'+[SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email FROM Contact]);  
        
        // create a RG temporary file
        String fileHeader = '';
        Map<String, String> FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('RG');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        String fileBodyTxt = fileHeader;
        fileBodyTxt += 'G1 Test Account,US;EMEA;AEJ\nRGTest2,EMEA;US\n';
        
        Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
		ContentVersion oContVer = new ContentVersion(
			Title='RG_ACC_UPLOAD', 
			PathOnClient ='/'+'RG_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String rgContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		ContentDocumentLink oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = rgContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink; 
      
      	// now verify the file just created here
      	Boolean isRGErr=false;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdRslt;
      	Test.startTest();
      		try {
      			bulkUpdRslt = BulkUpdateDeskCommentaryProhController.startBulkUpload(
      				bulkUpdDskCommInit.campaignId, fileBodyTxt, true, false, false);
  			} catch(Exception ex) {
  				isRGErr=true;
  				System.debug('Error : '+ex.getMessage());
    			System.debug('Error stack: '+ex.getStackTraceString());
  			}
      	Test.stopTest();
      	
      	System.assertEquals(isRGErr, false);
      	System.assertNotEquals(bulkUpdRslt.runningJobId, null);
      	// now query the related contacts and confirm that updated correctly
      	System.debug('AFTER TEST : '+[SELECT Id, DeskCommentaryProhibited__c FROM Contact]);
      	Integer noOfContsUpd = [SELECT count() FROM Contact WHERE DeskCommentaryProhibited__c!=null];
      	System.assertEquals(noOfContsUpd, 2);
    } 
    
    static testMethod void testStartBulkUpload_ByRMAcc() {
    	// first create a campaign
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		

        insert testAccounts;
        
        System.debug('ACCOUNTS : '+[SELECT Id,RDM_Org_ID__c FROM Account]);

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        c.RG_Account__c=rg1.Id;
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 222-4567', 'Dear [FirstName]', rg2rm2.Id, true);
        c1.RG_Account__c=rg2.Id;
        contacts.add(c1);
        
        Contact c2 = UtilityTesting.createContact('Jamy', 'Smithy', 'jamessmithy@test.com', '(212) 522-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c2.RG_Account__c=rg3.Id;
        contacts.add(c2);
        
        Contact c3 = UtilityTesting.createContact('Jamesx', 'Smithx', 'jamessmithx@test.com', '(212) 228-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c3.RG_Account__c=rg3.Id;
        contacts.add(c3);
        
        insert contacts;
        
        List<Contact> ContList = [SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email 
        FROM Contact WHERE (RG_Account__c = :rg1.Id OR RG_Account__c = :rg2.Id )  AND Active__c=true]; 
        System.debug('IN TEST CONT : '+ContList);
        
        System.debug('LIST OF CONTACTS :'+[SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email FROM Contact]);  
        
        // create a RG temporary file
              	// create a RM temporary file
        String fileHeader = '';
        Map<String,String> FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('RM');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        String fileBodyTxt = fileHeader;
        fileBodyTxt += 'RMTest3,US;EMEA;AEJ\nRM Test Account 3,EMEA;US\n';
        
        Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
		ContentVersion oContVer = new ContentVersion(
			Title='RM_ACC_UPLOAD', 
			PathOnClient ='/'+'RM_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String rmContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		ContentDocumentLink oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = rmContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink;
        
      	// now verify the file just created here
      	Boolean isRGErr=false;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdRslt;
      	Test.startTest();
      		try {
      			bulkUpdRslt = BulkUpdateDeskCommentaryProhController.startBulkUpload(
      				bulkUpdDskCommInit.campaignId, fileBodyTxt, false, true, false);
  			} catch(Exception ex) {
  				isRGErr=true;
  				System.debug('Error : '+ex.getMessage());
    			System.debug('Error stack: '+ex.getStackTraceString());
  			}
      	Test.stopTest();
      	
      	System.assertEquals(isRGErr, false);
      	System.assertNotEquals(bulkUpdRslt.runningJobId, null);
      	// now query the related contacts and confirm that updated correctly
      	System.debug('AFTER TEST : '+[SELECT Id, DeskCommentaryProhibited__c FROM Contact]);
      	Integer noOfContsUpd = [SELECT count() FROM Contact WHERE DeskCommentaryProhibited__c!=null];
      	System.assertEquals(noOfContsUpd, 3);
    }
    
    static testMethod void testStartBulkUpload_ByCont() {
    	// first create a campaign
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		

        insert testAccounts;
        
        System.debug('ACCOUNTS : '+[SELECT Id,RDM_Org_ID__c FROM Account]);

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        c.RG_Account__c=rg1.Id;
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 222-4567', 'Dear [FirstName]', rg2rm2.Id, true);
        c1.RG_Account__c=rg2.Id;
        contacts.add(c1);
        
        Contact c2 = UtilityTesting.createContact('Jamy', 'Smithy', 'jamessmithy@test.com', '(212) 522-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c2.RG_Account__c=rg3.Id;
        contacts.add(c2);
        
        Contact c3 = UtilityTesting.createContact('Jamesx', 'Smithx', 'jamessmithx@test.com', '(212) 228-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c3.RG_Account__c=rg3.Id;
        contacts.add(c3);
        
        insert contacts;
        
        List<Contact> ContList = [SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email 
        FROM Contact WHERE (RG_Account__c = :rg1.Id OR RG_Account__c = :rg2.Id )  AND Active__c=true]; 
        System.debug('IN TEST CONT : '+ContList);
        
        System.debug('LIST OF CONTACTS :'+[SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email FROM Contact]);  
        
        // create a RG temporary file
              	// create a RM temporary file
        String fileHeader = '';
        Map<String,String> FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('CONT');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        String fileBodyTxt = fileHeader;
        fileBodyTxt += 'johnnysmith@test.com,US;EMEA;AEJ\njamessmith@test.com,EMEA;US\n';
        
        Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
		ContentVersion oContVer = new ContentVersion(
			Title='RM_ACC_UPLOAD', 
			PathOnClient ='/'+'RM_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String rmContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		ContentDocumentLink oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = rmContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink;
        
      	// now verify the file just created here
      	Boolean isRGErr=false;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdRslt;
      	String jobId;
      	try {
      		Test.startTest();
      			bulkUpdRslt = BulkUpdateDeskCommentaryProhController.startBulkUpload(
      				bulkUpdDskCommInit.campaignId, fileBodyTxt, false, false, true);
      		Test.stopTest();
      	} catch(Exception ex) {
      		isRGErr=true;
  			System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
      	}
      	
      	System.assertEquals(isRGErr, false);
      	//System.assertNotEquals(jobId, null);
      	// now query the related contacts and confirm that updated correctly
      	System.debug('AFTER TEST : '+[SELECT Id, DeskCommentaryProhibited__c FROM Contact]);
      	Integer noOfContsUpd = [SELECT count() FROM Contact WHERE DeskCommentaryProhibited__c!=null];
      	System.assertEquals(noOfContsUpd, 2);
    }
    
    static testMethod void testGetJobStatus() {
    	// first create a campaign
    	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdDskCommInit = 
        	BulkUpdateDeskCommentaryProhController.initialize();
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		

        insert testAccounts;
        
        System.debug('ACCOUNTS : '+[SELECT Id,RDM_Org_ID__c FROM Account]);

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        c.RG_Account__c=rg1.Id;
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 222-4567', 'Dear [FirstName]', rg2rm2.Id, true);
        c1.RG_Account__c=rg2.Id;
        contacts.add(c1);
        
        Contact c2 = UtilityTesting.createContact('Jamy', 'Smithy', 'jamessmithy@test.com', '(212) 522-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c2.RG_Account__c=rg3.Id;
        contacts.add(c2);
        
        Contact c3 = UtilityTesting.createContact('Jamesx', 'Smithx', 'jamessmithx@test.com', '(212) 228-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c3.RG_Account__c=rg3.Id;
        contacts.add(c3);
        
        insert contacts;
        
        List<Contact> ContList = [SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email 
        FROM Contact WHERE (RG_Account__c = :rg1.Id OR RG_Account__c = :rg2.Id )  AND Active__c=true]; 
        System.debug('IN TEST CONT : '+ContList);
        
        System.debug('LIST OF CONTACTS :'+[SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email FROM Contact]);  
        
        // create a RG temporary file
              	// create a RM temporary file
        String fileHeader = '';
        Map<String,String> FieldApiByFieldLabelMap = BulkUpdateDeskCommentaryProhController.FieldApiByFieldLabelMapByLoadTypeMap.get('CONT');
        for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
			fileHeader+=colHeader+',';
		}
		fileHeader.removeEnd(',');
		fileHeader+='\n';
        String fileBodyTxt = fileHeader;
        fileBodyTxt += 'johnnysmith@test.com,US;EMEA;AEJ\njamessmith@test.com,EMEA;US\n';
        
        Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
		ContentVersion oContVer = new ContentVersion(
			Title='RM_ACC_UPLOAD', 
			PathOnClient ='/'+'RM_ACC_UPLOAD'+'.csv',
			VersionData = bodyBlob, 
			origin = 'H'
		);
		insert oContVer;
		String rmContDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
		
		ContentDocumentLink oContentlink = new ContentDocumentLink();
        oContentlink.LinkedEntityId = bulkUpdDskCommInit.campaignId;
        oContentlink.contentdocumentid = rmContDocId;
        oContentlink.ShareType = 'V';
        insert oContentlink;
        
      	// now verify the file just created here
      	Boolean isRGErr=false;
      	BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommInitInfo bulkUpdRslt;
      	String jobId;
      	try {
      		Test.startTest();
      			bulkUpdRslt = BulkUpdateDeskCommentaryProhController.getJobStatus(bulkUpdDskCommInit.campaignId);
      		Test.stopTest();
      	} catch(Exception ex) {
      		isRGErr=true;
  			System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
      	}
      	
      	System.assertEquals(isRGErr, false);
    }
}