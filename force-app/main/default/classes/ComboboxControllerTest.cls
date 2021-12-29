@isTest
private class ComboboxControllerTest {
	
    @testSetup
    static void testDataSetup(){
        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;

        Account rg1rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg1.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert rg1rm2;

        Account pod = UtilityTesting.createPODAccount(
                'POD Test Account 1', rg1.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert pod;

        List <Contact> contactList = new List<Contact>();
        Contact contact1 = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId=rg1rm1.id);
        contactList.add(contact1);
        insert contactList;
    }
    
    
    
	@isTest static void performQueryDefaultTest() {
		
        Test.startTest();

        List<Account> accountObj = [Select Id, Name FROM Account WHERE Name = 'G Test Account' LIMIT 1];
        String accId = '';

        List<Account> podAccountObj = [Select Id, Name FROM Account WHERE Name = 'POD Test Account 1' LIMIT 1];
        String podId = '';

        for(Account accOb : accountObj)
            accId = accOb.Id;
        
        for(Account podAccOb : podAccountObj)
            podId = podAccOb.Id;
        
        List<ComboboxListItemWrapper> results = ComboboxController.performQuery('', 'Account', accId, false);
        List<ComboboxListItemWrapper> resultsSearch = ComboboxController.search('G Test', 'Account', accId);
        System.assertEquals(results.size(), 2);

        List<ComboboxListItemWrapper> results1 = ComboboxController.performQuery('', 'Account', accId, false, true);
        List<ComboboxListItemWrapper> resultsSearch1 = ComboboxController.search('POD', 'Account', podId);
        System.assertEquals(results1.size(), 1);
        
        List<ComboboxListItemWrapper> contactSearch = ComboboxController.search('aTestFirstName', 'Contact', '');
         System.debug('---contactSearch--' + contactSearch);
        
        List<ComboboxListItemWrapper> resultsSearchText = ComboboxController.search_text('', 'Account', accId, '', false);
        System.debug('---resultsSearchText--' + resultsSearchText);
        System.assert(resultsSearchText.size() > 0);

        List<ComboboxListItemWrapper> resultsSearchText1 = ComboboxController.search_text('', 'Account', accId, '', true);
        System.debug('---resultsSearchText1--' + resultsSearchText1);
        System.assert(resultsSearchText1.size() > 0);
        
        List<ComboboxListItemWrapper> resultsSearchPreSelected = ComboboxController.preSelectedLookup('', accId, 'Account');
        System.debug('---resultsSearchPreSelected--' + resultsSearchPreSelected);
        System.assert(resultsSearchPreSelected.size() > 0);

        List<ComboboxListItemWrapper> resultsSearchPreSelected1 = ComboboxController.preSelectedLookup('', podId, 'Account', true);
        System.debug('---resultsSearchPreSelected1--' + resultsSearchPreSelected1);
        System.assert(resultsSearchPreSelected1.size() > 0);
        
        Test.stopTest();
	}
	
	
}