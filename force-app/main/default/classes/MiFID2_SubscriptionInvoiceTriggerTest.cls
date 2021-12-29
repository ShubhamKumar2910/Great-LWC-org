@isTest
private class MiFID2_SubscriptionInvoiceTriggerTest 
{
    @isTest static void verifiyTrigger() 
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
        
        MiFID2_SubscriptionInvoice__c subInvoice1 = new MiFID2_SubscriptionInvoice__c ();
        subInvoice1.Contact__c = c.id;
        subInvoice1.Account__c = rg1rm1.id;
        subInvoice1.Start_Date_of_Service__c = system.today();
        subInvoice1.Contract_End_Date__c = system.today();
        subInvoice1.Currency__c = 'GBP';
        subInvoice1.Amount__c = 1000;
        subInvoice1.Package_Type__c = 'FIGL';
        subInvoice1.Service_Type__c = 'Full Service';
        subInvoice1.Approx_GRP_Entitled_Users__c = '10';
        insert subInvoice1;

 
        Test.startTest();

            subInvoice1= [Select RG_Account__c From MiFID2_SubscriptionInvoice__c Where id =: subInvoice1.id];
            System.assertEquals(subInvoice1.RG_Account__c , rg1.id);

        Test.stopTest();
    }
}