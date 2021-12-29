@isTest(SeeAllData=true)
public class ResearchDetailsControllerTest {

    static testmethod void testResearchDetailsController(){
         Test.startTest();
         
         Integer numTestUsers = 1;  
    	 List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
         
         RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
         
         /* Insert Account */
         Account accountObj = new Account();
         accountObj.Name = 'cP Test Account';
         accountObj.RDM_Org_Id__c = 'CPXXXXX';
         accountObj.RecordTypeId = RMRecordType.Id;
         accountObj.Active__c = TRUE;   
         accountObj.BillingStreet = '**Not Entered**' ;
         accountObj.BillingCity = '**Not Entered**';
         accountObj.BillingCountry = 'United States';
         
         insert accountObj;
         
         /* Insert Contact */
         Contact contactObj = new Contact();
         
         contactObj.AccountId = accountObj.id;
         contactObj.FirstName = 'contact1FirstName'; 
         contactObj.LastName = 'contact1LastName';    
         contactObj.Active__c = TRUE;
         contactObj.Email = 'contact1FirstName.contact1LastName@dummy.com';
         contactObj.Research_Email__c = 'contact1FirstName.contact1LastName@dummy.com';
         contactObj.Phone = '+0 (000) 000-0000'; 
         contactObj.Salutation = 'M.';    
         contactObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
         contactObj.Affiliation_Id__c = '0000';
         contactObj.Contact_ID__c = '1111';
         
         insert contactObj;
         
         ResearchDetailsController controllerObj = new ResearchDetailsController();
         
         Map<String, Map<String, String>> labelMap = ResearchDetailsController.initializeLabels();
         System.assertEquals(1, labelMap.size());
        
         ResearchDetails researchDetailsObj = ResearchDetailsController.getResearchDetails(contactObj.Id);
         System.assertEquals(FALSE,researchDetailsObj.contact.GRP_Access__c);
         
         Test.stopTest();
     }   
}