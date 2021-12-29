@isTest(SeeAllData=true)
public class AutoCmpgnMembrStatusTrgBL_Test {
    
    static testMethod  void testCampaignInsert(){
        
        RecordType cmpgnRecordType = [SELECT Id from RecordType WHERE Name = 'Mass Email'];
        Campaign cmpgn = new Campaign();
        cmpgn.IsActive = true;
        cmpgn.RecordTypeId = cmpgnRecordType.Id;
        cmpgn.Name = 'test Campaign';
        cmpgn.ActualCost = 1000;       
        //cmpgn.Email_HTMLBody__c = 'This is a test email';
        EmailPreviewController.setBody(cmpgn, 'This is a test email');
        cmpgn.Email_IsCompleted__c = true;
        cmpgn.Email_IsInitialized__c = true;
        cmpgn.Email_Salutation__c = '';        
        
        
        insert cmpgn;
        System.debug('Campaign Id :'+ cmpgn.Id );
    }
}