/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 12/09/2018
	Description : Test class for the ETradingEnablementContactController  
				  class.
	
*/
@isTest
private class ETradingEnablementContactControllerTest 
{
    static testMethod void getSalutationsTest()
    {
    	Test.startTest();
        	
    	String eTradingEnablementDataJSON = ETradingEnablementContactController.initialise();
    	ETradingEnablementContactController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementContactController.ETradingEnablementData();
    	eTradingEnablementData = (ETradingEnablementContactController.ETradingEnablementData)JSON.deserialize(eTradingEnablementDataJSON, ETradingEnablementContactController.ETradingEnablementData.class);

		System.assertNotEquals(eTradingEnablementData.salutations.size(), 0);
		System.assertEquals(eTradingEnablementData.error, false);
		System.assertEquals(eTradingEnablementData.errorMessage, '');
	
		Test.stopTest();
    }
    
    static testMethod void initialiseTest()
    {
		Test.startTest();
		
        
        
        Test.stopTest();
    }
    
    static testMethod void getAccountAddressesTest() 
    {
 		Account parentAccount = AccountTestData.getAccount();
 		insert parentAccount;
 		
 		List<Account> accounts = AccountTestData.getAccounts(10);
 		for (Account account : accounts)
 		{
 			account.ParentId = parentAccount.Id;
 		}
 		
 		insert accounts;
 		
 		Test.startTest();
 		
		List<Account> testAccounts = ETradingEnablementContactController.getAccountAddresses(parentAccount.Id); 		
 		
 		System.assertEquals(testAccounts.size(), 10);
 		
 		Test.stopTest();       
    }
    
    static testMethod void checkFieldLevelSecurityTest()
	{
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Chatter Free User'];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
        System.runAs(testUser) 
        {
        	Test.startTest();
        	
        	String eTradingEnablementContactDataJSON = ETradingEnablementContactController.initialise();
        	ETradingEnablementContactController.ETradingEnablementContactData eTradingEnablementContactData = new ETradingEnablementContactController.ETradingEnablementContactData();
        	eTradingEnablementContactData = (ETradingEnablementContactController.ETradingEnablementContactData)JSON.deserialize(eTradingEnablementContactDataJSON, ETradingEnablementContactController.ETradingEnablementContactData.class);
			
			System.assertEquals(eTradingEnablementContactData.error, true);
			System.assertNotEquals(eTradingEnablementContactData.errorMessage, '');
		
			Test.stopTest();
        }
	}
	
	static testMethod void saveContactTest()
	{
		Account account = AccountTestData.getAccount();
		insert account;

		Contact contact = ContactTestData.getContact(account.Id);
		
		Test.startTest();
		
		String eTradingEnablementDataJSON = ETradingEnablementContactController.saveContact(contact, account.Id);
    	ETradingEnablementContactController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementContactController.ETradingEnablementData();
    	eTradingEnablementData = (ETradingEnablementContactController.ETradingEnablementData)JSON.deserialize(eTradingEnablementDataJSON, ETradingEnablementContactController.ETradingEnablementData.class);

		System.assertEquals(eTradingEnablementData.error, false);
		System.assertEquals(eTradingEnablementData.errorMessage, '');
	
		Test.stopTest();
	}
	
	static testMethod void saveContactErrorTest()
	{
		Account account = AccountTestData.getAccount();
		insert account;

		Contact contact = ContactTestData.getContact(account.Id);
		contact.Email = null;
		
		Test.startTest();
		
		String eTradingEnablementDataJSON = ETradingEnablementContactController.saveContact(contact, account.Id);
    	ETradingEnablementContactController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementContactController.ETradingEnablementData();
    	eTradingEnablementData = (ETradingEnablementContactController.ETradingEnablementData)JSON.deserialize(eTradingEnablementDataJSON, ETradingEnablementContactController.ETradingEnablementData.class);

		System.assertEquals(eTradingEnablementData.error, true);
		System.assertNotEquals(eTradingEnablementData.errorMessage, '');
	
		Test.stopTest();
	}
}