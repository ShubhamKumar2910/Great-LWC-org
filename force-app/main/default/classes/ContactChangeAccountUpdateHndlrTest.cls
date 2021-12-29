@isTest
private class ContactChangeAccountUpdateHndlrTest 
{
   /* @isTest static void testSetAccountsAsMiFIDII_InScope() 
    {
        // Initialise Data
        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
        Account rg1 = UtilityTesting.createRGAccount(
            'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
        Account rg1rm1 = UtilityTesting.createRMAccount(
            'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;
        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        insert c;

        Test.startTest();
            c.MiFIDII_in_Scope__c = true;
            update c;

            rg1 = [Select MiFIDII_in_Scope__c From Account Where id =: rg1.id];
            System.assertEquals(rg1.MiFIDII_in_Scope__c, true);
            rg1rm1  = [Select MiFIDII_in_Scope__c From Account Where id =: rg1rm1.id];
            System.assertEquals(rg1rm1.MiFIDII_in_Scope__c, true);

        Test.stopTest();
    }*/
}