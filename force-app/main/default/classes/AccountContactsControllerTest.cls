@isTest
public class AccountContactsControllerTest 
{
    /* SHIELD - START : 
    @testSetup 
    private static void setupTestData()
    {
		List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);

        insert testAccounts;

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c1);
      
        insert contacts;     
    }
        
    
	@isTest
	static void verifiyAccountContactsController(){
    	Test.startTest(); 
        
			AccountContactsController testCont = new AccountContactsController(
            	new ApexPages.StandardController
                ([
                	SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c 
                    FROM 
                    Account 
                    WHERE NAme = 'S Test Account'
                ])
            );
        
        	//system.assertEquals(2, testCont.getContacts().size());

        Test.stopTest();
    }
    SHIELD - END : 	*/
 
}