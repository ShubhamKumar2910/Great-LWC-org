@isTest
public class CustomExternalContacts_Test {
	/* SHIELD - START :     
    static testmethod void CustomExternalContactsTestMethod(){  
    
    Test.startTest();
      
     String recordTypeIdForRGAccount = null;
     String recordTypeIdForCPEventIntegration = null;
        
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
       
        // Record Type 
        List<RecordType> recordTypeList = [Select Id, Name FROM RecordType 
                                           WHERE Name IN ('RG Account', 'CP Event Integration')  ];
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordType : recordTypeList){
                if('RG Account'.equalsIgnoreCase(recordType.Name)){
                    recordTypeIdForRGAccount = recordType.Id;
                }
                else if('CP Event Integration'.equalsIgnoreCase(recordType.Name)){
                    recordTypeIdForCPEventIntegration = recordType.Id;
                }
            }
        }
        
        // Account Insertion 
        Account testAccount = new Account(Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = recordTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert testAccount;
        
        
         Account acNomEmp = new Account(Name='NOMURA EMPLOYEES',BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
       
        insert acNomEmp;
        
         Account testAccountRM= new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = RMRecordType.id,ParentId =testAccount.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        
        
        insert testAccountRM;
         //User Insertion 
          /PREVIOUS_COMMENT*  string iNo= '1';
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        User u    = new User( Alias = 'newUser'+iNo,
                             Email ='newuser'+iNo+'@testorg.com',
                             EmailEncodingKey = 'UTF-8',
                             LastName = 'Testing'+iNo,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', 
                             UserName='event1newuser'+iNo+UtilityTesting.userDomain,
                             ProfileId=p.Id,
                             TimeZoneSidKey = 'America/Los_Angeles'
                            );
        
        insert u;*PREVIOUS_COMMENT/
        
        User testUser = null;
        List<User> testUserList = UtilityTesting.CreateUsers(1);
        if(testUserList != null && testUserList.size() > 0){
            testUser = testUserList[0];
        }
        
        // Contact Insertion 
         Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId = testAccountRM.id);
        insert act;
        
        Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__c=false,AccountId = testAccountRM.id );
        insert ict;
        
		Contact contactObj1 = new Contact(FirstName='contact1FirstName', LastName='contact1LastName', Salutation='Mr', Email='contact1FirstName.contact1LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = testAccountRM.id );
        insert contactObj1;
        
        Contact contactObj2 = new Contact(FirstName='contact2FirstName', LastName='contact2LastName', Salutation='Mr', Email='contact2FirstName.contact2LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true, AccountId =  testAccountRM.id);
        insert contactObj2;
        
        Contact contactObj3 = new Contact(FirstName='contact3FirstName', LastName='contact3LastName', Salutation='Mr', Email='contact3FirstName.contact3LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true, AccountId =  testAccountRM.id);
        insert contactObj3;
        
        string  cids = contactObj1.Id + ',' + contactObj2.Id + ',' + contactObj3.id;
        
        List<String> contacts = new List<String>();       
       
            contacts.add( contactObj1.Id);
        contacts.add( contactObj2.Id);
        contacts.add( contactObj3.Id);
        
        // Event Insertion 
        Datetime startDateTime = Datetime.now();
		Datetime endDateTime = startDateTime.addHours(1);
        
        Event eventObj = new Event();
        eventObj.WhatId = testAccount.Id;
        eventObj.WhoId = contactObj1.Id;
        eventObj.OwnerId = testUser.Id;
        eventObj.Subject = 'Test Event';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = recordTypeIdForCPEventIntegration;
        
        insert eventObj;
        
        system.debug('eventObj :' +eventObj.id);
        
        Event eventObj1 = new Event(); 
        eventObj1.WhatId = null;
        eventObj1.WhoId = contactObj1.Id;
        eventObj1.OwnerId = testUser.Id;
        eventObj1.Subject = 'Test Event1';
        eventObj1.StartDateTime = startDateTime;
        eventObj1.EndDateTime = endDateTime;
        eventObj1.RecordTypeId = recordTypeIdForCPEventIntegration;
       
        insert eventObj1;
        
        PageReference myVfPage = Page.CustomExternalContactLookup;
       Test.setCurrentPage(myVfPage);

// Put Id into the current page Parameters
    ApexPages.currentPage().getParameters().put('cids',cids);

    CustomExternalContactsLookupController controller = new CustomExternalContactsLookupController();
     controller.WhereClause = 'Vipin'; 
     controller.selectedUserIds = contacts;
        controller.removedUserIds = contacts;
           controller.selectedUsersMap.put(contacts[0],contacts[0]);
        controller.isErrored = false;
        controller.MessageText='Testing.....Testing';
     controller.filterAvailableOptions();
        controller.getAvailableUsers();
        controller.getSelectedUsers();
        controller.MakePrimary();
        controller.add();
        controller.remove();
  
    Test.stopTest();  
 
    }
    
    SHIELD - END : */
    
    
     }