@isTest
public class AttachmentReparentingCRTest {
	 static testMethod void testChampionUpdatesForClientRemediation() {
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
       
        system.runas(users[0]){
       
            //Insert Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RG1';
            oldAccountObj.RecordTypeId = recordTypeRG.Id;
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RG2';
            newAccountObj.RecordTypeId = recordTypeRG.Id;
            newAccountObj.Active__c = TRUE;   
            
            insert newAccountObj;
            
            //Insert Attachments
            List<Attachment> attachmentList = new List<Attachment>();
            
            Attachment attachmentForOldAccountObj = new Attachment();
            attachmentForOldAccountObj.Name = 'Attachment With Old Account';
            Blob bodyBlobForOldAccount = Blob.valueOf('Unit Test Attachment with Old Account Body');
            attachmentForOldAccountObj.Body = bodyBlobForOldAccount;
            attachmentForOldAccountObj.ParentId = oldAccountObj.Id;
            
            attachmentList.add(attachmentForOldAccountObj);
            
            Attachment attachmentForNewAccountObj = new Attachment();
            attachmentForNewAccountObj.Name = 'Attachment With New Account';
            Blob bodyBlobForNewAccount = Blob.valueOf('Unit Test Attachment with New Account Body');
            attachmentForNewAccountObj.Body = bodyBlobForNewAccount;
            attachmentForNewAccountObj.ParentId = newAccountObj.Id;
            
            attachmentList.add(attachmentForNewAccountObj);
            
            insert attachmentList;
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RG__c = 'RG1';
            crObj.NEW_RG__c = 'RG2';
            crObj.RG_ACTION__c = 'MERGE';
            crObj.OLD_RG_Account__c = oldAccountObj.Id;
            crObj.NEW_RG_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new AttachmentReparentingBatch(), 1);
           
            Test.stopTest();  
            
            //Test Results
            List<Attachment> attachmentListResults = [SELECT Id, Name, parentId FROM Attachment
                                                      WHERE ParentId = :newAccountObj.Id];
            System.assertEquals(2, attachmentListResults.size());
            
                     
        }
            
	}
}