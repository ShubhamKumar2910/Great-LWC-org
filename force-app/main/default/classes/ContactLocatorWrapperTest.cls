@isTest
private class ContactLocatorWrapperTest {
	
	@isTest static void ContactLocatorWrapperTest() {
		// Initialise Data
		Account sLevel = UtilityTesting.createRSAccount('S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
		insert sLevel;
		Account gLevel = UtilityTesting.createRGAccount('G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
		insert gLevel;
		Account rmLevel = UtilityTesting.createRMAccount('RM Test Account', gLevel.Id, 'Test3', '52nd Street', 'California', 'United States', true);
		insert rmLevel;
		Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rmLevel.Id, true);
		insert c;

		Test.StartTest();
		ContactLocatorWrapper clw = new ContactLocatorWrapper(c, gLevel, rmLevel, true);
		Test.StopTest();
		System.assertNotEquals(clw, null);
	}
}