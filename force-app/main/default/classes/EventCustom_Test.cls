@isTest
public class EventCustom_Test {
 	static testmethod void EventCustomTest(){  
    
        String recTypeIdForRGAccount = null;
        String recTypeIdForRMAccount = null; 
        String recTypeIdForCPEventIntegration = null;
        String recTypeIdForNomuraEmployee = null;
         
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType 
                                     WHERE Name IN ('RS Account','RG Account','RM Account','NOMURA EMPLOYEES','CP Event Integration')] ;
         
        if(recordTypeList != null && recordTypeList.size() > 0){
             for(RecordType recordType : recordTypeList){
                 if('RG Account'.equalsIgnoreCase(recordType.Name)){
                     recTypeIdForRGAccount = recordType.Id;
                 }
                 else if('RM Account'.equalsIgnoreCase(recordType.Name)){
                     recTypeIdForRMAccount = recordType.Id;
                 }
                 else if('CP Event Integration'.equalsIgnoreCase(recordType.Name)){
                     recTypeIdForCPEventIntegration = recordType.Id;
                 }
                 else if('NOMURA EMPLOYEES'.equalsIgnoreCase(recordType.Name)){
                     recTypeIdForNomuraEmployee = recordType.Id;
                 }
             }
         }
     
         Test.startTest();
          
         /* Account Insertion */
         /*Account rmAccount= new Account(RDM_Org_Id__c = 'RMYYYYYY', Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                        RecordTypeId = recTypeIdForRMAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
         
         Account parentAccount = new Account(RDM_Org_Id__c = 'RGXXXXXX');
         rmAccount.Parent = parentAccount;
         
         Account rgAccount = new Account(RDM_Org_Id__c = 'RGXXXXXX', Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                         RecordTypeId = recTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
         Account acNomEmp = new Account(RDM_Org_Id__c = 'CP12345', Name='NOMURA EMPLOYEES',BillingCity = 'California',RecordTypeId = recTypeIdForNomuraEmployee,BillingCountry = 'United States',BillingStreet = '52nd Street',Active__c = true);
         
         Database.SaveResult[] accountResults = Database.insert(new SObject[] {rgAccount, rmAccount, acNomEmp});*/
         
         Account rgAccount = new Account(RDM_Org_Id__c = 'RGXXXXXX', Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                         RecordTypeId = recTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
         insert rgAccount;
         
         Account rmAccount= new Account(RDM_Org_Id__c = 'RMYYYYYY', Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                        RecordTypeId = recTypeIdForRMAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street',
                                        ParentId = rgAccount.Id);
         Account acNomEmp = new Account(RDM_Org_Id__c = 'CP12345', Name='NOMURA EMPLOYEES',BillingCity = 'California',RecordTypeId = recTypeIdForNomuraEmployee,BillingCountry = 'United States',BillingStreet = '52nd Street',Active__c = true);
         
         Database.SaveResult[] accountResults = Database.insert(new SObject[] {rmAccount, acNomEmp});
         
         
         /* Users */
         User testUser = null;
         User inviteeUser =null;
         List<User> testUserList = UtilityTesting.CreateUsers(2);
         if(testUserList != null && testUserList.size() > 0){
             testUser = testUserList[0];
             inviteeUser = testUserList[1];
         }
            
    
         /* Contact Insertion */
         List<Contact> contacts = new List<Contact>();
         
         Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId = rmAccount.Id );
         Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__c=false,AccountId = rmAccount.Id );
         Contact c1 = new Contact(FirstName='contact1FirstName', LastName='contact1LastName', Salutation='Mr', Email='contact1FirstName.contact1LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = rmAccount.Id );
         Contact c2 = new Contact(FirstName='contact2FirstName', LastName='contact2LastName', Salutation='Mr', Email='contact2FirstName.contact2LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = rmAccount.Id );
         Contact c3 = new Contact(FirstName='contact3FirstName', LastName='contact3LastName', Salutation='Mr', Email='contact3FirstName.contact3LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = rmAccount.Id );
         Contact c4 = new Contact(FirstName='contact4FirstName', LastName='contact4LastName', Salutation='Mr', Email='contact4FirstName.contact3LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true, AccountId =  acNomEmp.id);
         
         contacts.add(act);
         contacts.add(ict);
         contacts.add(c1);
         contacts.add(c2);
         contacts.add(c3);
         contacts.add(c4);
         
         insert contacts;
         
         
         string  cids = c1.Id + ',' + c2.Id + ',' + c3.id;
         string  cidsInternal = c4.Id + ',' + testUser.id;
            
         /* Event Insertion */
         Datetime startDateTime = Datetime.now();
         Datetime endDateTime = startDateTime.addHours(1);
         
         Event eventObj = new Event();
         eventObj.Subject = 'Test cP Event';
         eventObj.WhatId = rgAccount.Id;
         eventObj.WhoId = c1.Id;
         eventObj.StartDateTime = startDateTime;
         eventObj.EndDateTime = endDateTime;
         eventObj.RecordTypeId = recTypeIdForCPEventIntegration;
         
         insert eventObj;
         
         EventRelation eventRelation1 = new EventRelation();
         eventRelation1.RelationId = inviteeUser.id;
         eventRelation1.EventId = eventObj.id;
         eventRelation1.IsWhat =false;
         eventRelation1.IsParent = false;
         eventRelation1.IsInvitee = true;
         insert eventRelation1;
         
         Task_LTA__c testDesc = new Task_LTA__c();
         testDesc.Parent_Task__c = eventObj.Id;
         testDesc.LTA_1__c = 'This is a test Custom description';
         insert testDesc;
         
         PageReference myVfPage = Page.EventCustom;
         Test.setCurrentPage(myVfPage);
         
         EventCustomController controller = new EventCustomController( new ApexPages.StandardController([SELECT Id,Subject,WhoId,WhatId FROM Event WHERE ID=:eventObj.Id]));
         controller.hiddenExternalContactsId = cids;
         controller.hiddenNomuraIds = cidsInternal;
         controller.save();
         controller.doCancel();
         controller.updateLTA();
         
         Test.stopTest();  
 
    }
}