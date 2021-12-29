@isTest
private class ContactChangeValidationTest 
{

    @isTest static void testValidateAccountChange()   
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
        Account rg1rm2 = UtilityTesting.createRMAccount(
            'RM Test Account 2', rg1.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert rg1rm2;
        Account rg2 = UtilityTesting.createRGAccount(
            'G Test Account', sLevel.Id, 'Test5', '52nd Street', 'California', 'United States', true);
        insert rg2;
        Account rg2rm1 = UtilityTesting.createRMAccount(
            'RM Test Account 3', rg2.Id, 'Test6', '52nd Street', 'California', 'United States', true);
        insert rg2rm1;

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        insert c;

        Test.startTest();
            // verify valide contact RM change (change RM account links to same RG as before change)
            c.AccountId = rg1rm2.id;
            update c;
            c = [Select AccountId From Contact Where id =: c.id];
            system.assertEquals(c.AccountId, rg1rm2.id);

            // verfiy error on invalid contact RM account change (change RM account links to differnt RG)
            try
            {
                c.AccountId = rg2rm1.id;    
                update rg2rm1;
            }
            catch(Exception  e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Contact_Change_Account_Validation) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);     
            }
        Test.stopTest();
    }
    
    @isTest static void testRetainContactOwner(){
        
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
       
        Test.startTest();
        
        //Test User
        User otherUserObj = null;
        List<User> testUserList = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales');
        if(testUserList != null && testUserList.size() > 0){
            otherUserObj = testUserList.get(0);
        }
        
        /* Insert Account */
        Account accountObj = new Account(Name = 'Test Account', RDM_Org_Id__c = 'RMXXXXXX', 
                                         RecordTypeId = RMRecordType.Id, Active__c = TRUE, 
                                         BillingStreet = '**Not Entered**', BillingCity = '**Not Entered**', BillingCountry = 'United States');
        insert accountObj;
        
        /* Insert Contact */
        Contact contactObj = new Contact(AccountId = accountObj.id,
                                         Salutation = 'M.',
                                         FirstName = 'contactFirstName',
                                         LastName = 'contactLastName',
                                         Active__c = TRUE,
                                         Email = 'contact1FirstName.contact1LastName@dummy.com',
                                         Phone = '+0 (000) 000-0000',
                                         Mailing_Address_Same_As_Account_Address__c = TRUE,
                                         OwnerId = otherUserObj.Id);
        
        insert contactObj;
        
        //Update the inserted contact using sfadmin User
        User userObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runas(userObj){
            contactObj.LastName = 'contactLastNameCHG';
            
            update contactObj;
            
            Contact updatedContactObj = [SELECT Id, Name, OwnerId FROM Contact WHERE Id =: contactObj.Id];
            
            if(updatedContactObj != null){
                System.assertEquals(otherUserObj.Id, updatedContactObj.OwnerId);
            }
        }
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testVlidateMiFIDIIEntitlementChange() {
    	System.debug('#### ContactChangeValidationTest::testVlidateMiFIDIIEntitlementChange()');
        	
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
        rg1rm1.Override_Contacts_MiFID_II_Entitlement__c = true;
        rg1rm1.MiFID_II_Research_In_Scope__c = true;
        rg1rm1.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		

        insert testAccounts;
        
        System.debug('ACCOUNTS : '+[SELECT Id,RDM_Org_ID__c FROM Account]);

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        c.RG_Account__c=rg1.Id;
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 222-4567', 'Dear [FirstName]', rg2rm2.Id, true);
        c1.RG_Account__c=rg2.Id;
        contacts.add(c1);
        
        Contact c2 = UtilityTesting.createContact('Jamy', 'Smithy', 'jamessmithy@test.com', '(212) 522-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c2.RG_Account__c=rg3.Id;
        contacts.add(c2);
        
        Contact c3 = UtilityTesting.createContact('Jamesx', 'Smithx', 'jamessmithx@test.com', '(212) 228-4567', 'Dear [FirstName]', rg3rm3.Id, true);
        c3.RG_Account__c=rg3.Id;
        contacts.add(c3);
        
        insert contacts;
        
        List<Contact> ContList = [SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email 
        FROM Contact WHERE (RG_Account__c = :rg1.Id OR RG_Account__c = :rg2.Id )  AND Active__c=true]; 
        System.debug('IN TEST CONT : '+ContList);
        
        System.debug('LIST OF CONTACTS :'+[SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.RDM_Org_ID__c,Email FROM Contact]);  
        
        // now verify the file just created here
      	Boolean isRGErr=false;
      	Contact oContWithErr;
      	Contact oContNoErr;
      	Database.SaveResult[] srList;
      	try {
      		Test.startTest();
      			List<Contact> UpdContList = new List<Contact>();
				oContWithErr = [SELECT Id, MiFIDII_In_Scope__c, MiFIDII_Sales_Commentary_Allowed__c FROM Contact WHERE Id = :c.Id];
				System.debug('oContWithErr : '+oContWithErr);
				System.assertEquals(oContWithErr.MiFIDII_In_Scope__c, true);
				oContWithErr.MiFIDII_In_Scope__c=false;
				oContWithErr.MiFIDII_Sales_Commentary_Allowed__c='';
				UpdContList.add(oContWithErr);
				
				oContNoErr = [SELECT Id, MiFIDII_In_Scope__c, MiFIDII_Sales_Commentary_Allowed__c FROM Contact WHERE Id = :c1.Id];
				System.debug('oContNoErr : '+oContNoErr);
				oContNoErr.MiFIDII_In_Scope__c=true;
				oContNoErr.MiFIDII_Sales_Commentary_Allowed__c='Allowed';
				UpdContList.add(oContNoErr);
				
				srList = Database.update(UpdContList, false);
				System.debug('srList : '+srList.size());
				System.debug('srList : '+srList);
			Test.stopTest();
      	} catch(Exception ex) {
      		
      	}

		for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
            	System.debug('Success : '+sr.getId());
                System.assertEquals(sr.getId(), oContNoErr.Id);
            }
            else {
            	System.debug('Failed to Updated ET Rec : ' + sr.getId());
            	String error='';
                for(Database.Error err : sr.getErrors()) {
                    error+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    //System.debug('Account fields that affected this error: ' + err.getFields());
                }
            	
            	System.assertEquals(error.contains(System.Label.MiFIDII_Entitlement_Derived_From_Account_Level), true);
        	}
		}
    }
}