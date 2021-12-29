/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - AccountService 
 *
 */

@isTest
public class AccountServiceTest {
	static testMethod void testUpdateMiFIDIIInScopeAtRMandRGAcountLevel() {
		System.debug('#### AccountServiceTest::testUpdateMiFIDIIInScopeAtRMandRGAcountLevel()');
		
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rg1rm1.Default_New_Contact_MiFID_II_Entitlement__c = true;
        //rg1rm1.MiFID_II_Research_In_Scope__c = false;
        //rg1rm1.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        //rg2rm2.Default_New_Contact_MiFID_II_Entitlement__c = true;
        //rg2rm2.MiFID_II_Research_In_Scope__c = true;
        //rg2rm2.MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed';
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		
        insert testAccounts;
        
        List<Contact> ContactList = new List<Contact>();
        for(Integer i=0; i<100; ++i) {
        	if(i<10) {
	        	Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-456'+i, 'Dear [FirstName]', rg1rm1.Id, true);
	        	oCOnt.RG_Account__c=rg1.Id;
	        	ContactList.add(oCOnt);
        	} else if(i<30) {
	        	Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg1rm1.Id, true);
	        	oCOnt.RG_Account__c=rg1.Id;
	        	ContactList.add(oCOnt);
        	} else if(i < 70) {
        		Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg2rm2.Id, true);
	        	oCOnt.RG_Account__c=rg2.Id;
	        	ContactList.add(oCOnt);
        	} else {
        		Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg3rm3.Id, true);
	        	oCOnt.RG_Account__c=rg3.Id;
	        	ContactList.add(oCOnt);
        	} 
        }
        
        insert ContactList;
        List<Id> AccIdList = new List<Id>{rg1rm1.Id, rg2rm2.Id, rg3rm3.Id};
		Map<Id, Account> RMAccMap = new Map<Id, Account>([SELECT Id,MiFIDII_In_Scope__c FROM Account WHERE Id IN :AccIdList]);
		System.assertEquals(RMAccMap.get(rg1rm1.Id).MiFIDII_In_Scope__c, false);
		System.assertEquals(RMAccMap.get(rg2rm2.Id).MiFIDII_In_Scope__c, false);
		System.assertEquals(RMAccMap.get(rg3rm3.Id).MiFIDII_In_Scope__c, false);
		
        
      	Boolean isErr=false;
      	List<Contact> UpdContList = new List<Contact>();
      	Test.startTest();
      	try {
      		UpdContList.add(new Contact(Id=ContactList[0].Id, MiFIDII_In_Scope__c=true, MiFIDII_Sales_Commentary_Allowed__c='Allowed'));
      		UpdContList.add(new Contact(Id=ContactList[95].Id, MiFIDII_In_Scope__c=true, MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed'));
      		update UpdContList;
      		RMAccMap = new Map<Id, Account>([SELECT Id,MiFIDII_In_Scope__c FROM Account WHERE Id IN :AccIdList]);
			System.assertEquals(RMAccMap.get(rg1rm1.Id).MiFIDII_In_Scope__c, true);
			System.assertEquals(RMAccMap.get(rg2rm2.Id).MiFIDII_In_Scope__c, false);
			System.assertEquals(RMAccMap.get(rg3rm3.Id).MiFIDII_In_Scope__c, true);
			
			UpdContList.clear();
			UpdContList.add(new Contact(Id=ContactList[0].Id, Active__c=false, Inactive_Reason__c='No Longer a Client of Nomura'));
			// for following contact MiFIDII in scope is set to true but at the same time it is de-activated so it should not
			// change the flag on RM Account 
      		UpdContList.add(new Contact(Id=ContactList[65].Id, MiFIDII_In_Scope__c=true, MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed',
      				Active__c=false, Inactive_Reason__c='No Longer a Client of Nomura'));
      		update UpdContList;
      		RMAccMap = new Map<Id, Account>([SELECT Id,MiFIDII_In_Scope__c FROM Account WHERE Id IN :AccIdList]);
			System.assertEquals(RMAccMap.get(rg1rm1.Id).MiFIDII_In_Scope__c, false);
			System.assertEquals(RMAccMap.get(rg2rm2.Id).MiFIDII_In_Scope__c, false);
			System.assertEquals(RMAccMap.get(rg3rm3.Id).MiFIDII_In_Scope__c, true);
      		
      		UpdContList.clear();
      		UpdContList.add(new Contact(Id=ContactList[0].Id, Active__c=true));
			// for following contact MiFIDII in scope is set to true but at the same time it is de-activated so it should not
			// change the flag on RM Account 
      		UpdContList.add(new Contact(Id=ContactList[65].Id, Active__c=true));
      		update UpdContList;
      		RMAccMap = new Map<Id, Account>([SELECT Id,MiFIDII_In_Scope__c FROM Account WHERE Id IN :AccIdList]);
			System.assertEquals(RMAccMap.get(rg1rm1.Id).MiFIDII_In_Scope__c, true);
			System.assertEquals(RMAccMap.get(rg2rm2.Id).MiFIDII_In_Scope__c, true);
			System.assertEquals(RMAccMap.get(rg3rm3.Id).MiFIDII_In_Scope__c, true);
			
      		
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		System.debug('Error stack: '+ex.getStackTraceString());
      		isErr = true;
      	}
      	Test.stopTest();

		System.assertEquals(isErr, false);
	}
}