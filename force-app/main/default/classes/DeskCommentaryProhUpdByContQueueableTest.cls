/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - DeskCommentaryProhUpdByContQueueable
 *
 */
 
@isTest
private class DeskCommentaryProhUpdByContQueueableTest {

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
      			Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(bodyBlob,  
					FieldApiByFieldLabelMap, '\n', ',');
      			DeskCommentaryProhUpdByContQueueable loadJob = new DeskCommentaryProhUpdByContQueueable(
      				(String)bulkUpdDskCommInit.campaignId, FieldApiByHeaderIndxMap, bodyBlob, 1, 200);
				jobId = System.enqueueJob(loadJob);
				System.debug('jobId '+jobId);
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
}