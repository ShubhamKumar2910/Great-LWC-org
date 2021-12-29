@isTest
private class ContactLocatorControllerTest {
	
	@isTest static void ControllerTest() {
		ContactLocatorController controller = new ContactLocatorController();

		Contact c = ContactLocatorController.contact;
		String url = ContactLocatorController.baseURL;

		System.assertEquals(url, '');
		System.assertEquals(c.Description, '');
	}

	@isTest static void getBaseURLTest() {
		Test.startTest();
		String baseURL = ContactLocatorController.getBaseURL();
		Test.stopTest();
		System.assertNotEquals(baseURL, null);
	}

	@isTest static void initialiseColumnsTest() {
		Map<String, Map<String, String>> columnHeaders = new Map<String, Map<String, String>>();

		ContactLocatorController controller = new ContactLocatorController();
		Test.startTest();
		columnHeaders = ContactLocatorController.initialiseColumns();
		Test.stopTest();
		System.assertNotEquals(columnHeaders, null);
	}
	
	@isTest static void checkCoverageStatusColumnViewTest() {
		// Initialise Data
		User researchUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Research')[0];
		Boolean result;

		System.runAs(researchUser){
			ContactLocatorController controller = new ContactLocatorController();
			Test.startTest();
			result = ContactLocatorController.checkCoverageStatusColumnView();
			Test.stopTest();
			System.assertEquals(result, false);
		}
	}

	@isTest static void getContacts2Test() {
		// Initialise Data
		Account sLevel = UtilityTesting.createRSAccount('S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
		insert sLevel;
		Account gLevel = UtilityTesting.createRGAccount('G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
		insert gLevel;
		Account rmLevel = UtilityTesting.createRMAccount('RM Test Account', gLevel.Id, 'Test3', '52nd Street', 'California', 'United States', true);
		insert rmLevel;
		Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rmLevel.Id, true);
		insert c;
		
		Id [] fixedSearchResults= new Id[1];
    	fixedSearchResults[0] = c.Id;
       	Test.setFixedSearchResults(fixedSearchResults);

		List<ContactLocatorWrapper> results = new List<ContactLocatorWrapper>();
		ContactLocatorController controller = new ContactLocatorController();
		Test.startTest();
		
		///Test for name
		String inputSearchString = 'John';
		Contact con = new Contact();
		con.Description = inputSearchString;
		results = ContactLocatorController.getContacts2(inputSearchString, con);

		System.assertEquals(results.size(), 1);
       
		///Test for email
		String inputSearchString2 = 'johnnysmith@test.com';
		Contact con2 = new Contact();
		con2.Description = inputSearchString2;
		
		results = ContactLocatorController.getContacts2(inputSearchString2, con2);
		
		Test.stopTest();
	}
	
}