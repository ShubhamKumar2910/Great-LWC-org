@isTest
private class EventTriggerBL_Test {
 
    @testSetUp
    public static void insertEventAndEventRelations() {
        String recordTypeIdForRGAccount = null;
        String recordTypeIdForCPEventIntegration = null;
        
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
       
        /* Record Type */
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
        
        List<Account> accounts = new List<Account>();
        
        /* Account Insertion */
        Account rgAccount = new Account(Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = recordTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        
        
        Account acNomEmpRG = new Account(Name='NOMURA EMPLOYEES (G)', Active__c = true, RDM_Org_Id__c = 'CPG12345',
                                        RecordTypeId = RGRecordType.id, BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
       
        accounts.add(rgAccount);
        accounts.add(acNomEmpRG);
        insert accounts;

        List<Account> accountRMList = new List<Account>();
        
        Account rmAccount = new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = RMRecordType.id,ParentId = rgAccount.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        
        Account acNomEmpRM = new Account(Name='NOMURA EMPLOYEES', Active__c = true, RDM_Org_Id__c = 'CP12345',
                                          RecordTypeId = RMRecordType.id,ParentId = acNomEmpRG.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');

        Account acInstinetEmpRM = new Account(Name='INSTINET EMPLOYEES', Active__c = true, RDM_Org_Id__c = 'IN12345',
                                          RecordTypeId = RMRecordType.id,ParentId = acNomEmpRG.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        
        accountRMList.add(rmAccount);
        accountRMList.add(acNomEmpRM);
        accountRMList.add(acInstinetEmpRM);
        insert accountRMList;        
        
        User testUser = null;
        List<User> testUserList = UtilityTesting.CreateUsers(1);
        if(testUserList != null && testUserList.size() > 0){
            testUser = testUserList[0];
        }
        
        /* Contact Insertion */
        List<Contact> contacts = new List<Contact>();

        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId = rmAccount.Id );
        Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__c=false,AccountId = rmAccount.Id );
        Contact c1 = new Contact(FirstName='contact1FirstName', LastName='contact1LastName', Salutation='Mr', Email='test1@test1.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = rmAccount.Id );
        Contact c2 = new Contact(FirstName='contact2FirstName', LastName='contact2LastName', Salutation='Mr', Email='contact2FirstName.contact2LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = rmAccount.Id );
        Contact c3 = new Contact(FirstName='contact3FirstName', LastName='contact3LastName', Salutation='Mr', Email='contact3FirstName.contact3LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = rmAccount.Id );
        Contact c4 = new Contact(FirstName='contact4FirstName', LastName='contact4LastName', Salutation='Mr', Email='contact4FirstName.contact4LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = acInstinetEmpRM.Id,Login_Id__c = '123789' );        
        contacts.add(act);
        contacts.add(ict);
        contacts.add(c1);
        contacts.add(c2);
        contacts.add(c3);
        contacts.add(c4);

        insert contacts;
        
        List<Event> events = new List<Event>();

        Event cpEvent = UtilityTesting.createEvent('CP_Event_Integration', c1.Id, '1on1');
        Event cpEvent2 = UtilityTesting.createEvent('CP_Event_Integration', c1.Id, '1on1');
        cpEvent.WhatId = rgAccount.Id;
        cpEvent.OwnerId = testUser.Id;
        cpEvent.Subject = 'Test Event';
        cpEvent.Source__c = 'Instinet Feed';
        cpEvent2.OwnerId = testUser.Id;
        cpEvent2.WhatId = null;
        cpEvent2.Subject = 'Test Event1';
        cpEvent2.Event_Name__c = c4.Login_Id__c;
        cpEvent2.Source__c = 'Instinet';
        events.add(cpEvent2);
        events.add(cpEvent);

        insert events;       
        
        List<EventRelation> eventRelations = new List<EventRelation>();
        
        EventRelation er1 = UtilityTesting.createEventRelation(cpEvent.Id, c2.Id, true, true);
        EventRelation er2 = UtilityTesting.createEventRelation(cpEvent.Id, c3.Id, true, true);
        EventRelation er3 = UtilityTesting.createEventRelation(cpEvent.Id, c4.Id, true, true);
        eventRelations.add(er1);
        eventRelations.add(er2);
        eventRelations.add(er3);

        insert eventRelations;        
    }
    
    private static testmethod void syncValidateWhatId(){        
        List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId FROM Event WHERE Subject ='Test Event1' ];
        ID []  tid = new ID[]{};
        if(events.size() > 0){
            tid.add(events[0].id);
        }
        EventTriggerBL.syncValidateWhatId(tid);
    }
    
    private static testmethod void AsyncValidateWhatId(){       
        List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId FROM Event WHERE Subject ='Test Event1' ];  
        ID []  tid = new ID[]{};
        if(events.size() > 0){
            tid.add(events[0].id);
        }
        system.debug('whatId in test :'+ events[0].whatId);
        system.debug('whoId in test:'+ events[0].whoId);
        EventTriggerBL.AsyncValidateWhatId(tid);
    }
    
    private static testmethod void validateNoInActiveContact(){
        User nonIntegrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE UserName = 'event1newuser1230@nomtestorg.com' LIMIT 1];
        System.runAs(nonIntegrationUserObj){
            List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId FROM Event WHERE Subject ='Test Event1' ];
            EventTriggerBL.validateNoInActiveContact(null, events, true, false);
        }
    }

	private static testmethod void validateOutlook(){
        User nonIntegrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE UserName = 'event1newuser1230@nomtestorg.com' LIMIT 1];
        System.runAs(nonIntegrationUserObj){        
            List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId,Source__c FROM Event WHERE Subject ='Test Event1' ];
            EventTriggerBL.validateOutlook(events);
            for(Event event: events){
                if(null==event.whatID && null == event.whoId ){
                    System.assertEquals('Outlook', event.Source__c);
                }else{
                    System.assertEquals('Desktop', event.Source__c);
                }
            }
        }
    }    
    
	private static testmethod void validateWhatId(){
        List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId,Source__c FROM Event WHERE Subject ='Test Event1' ];
        EventTriggerBL.validateWhatId(events);
        Account account = [SELECT Id FROM Account WHERE Name = 'Test_Account_For_Event_And_EventRelations' LIMIT 1];
        List<Event> updatedEvents = [SELECT Id,WhatId,WhoId,RecordTypeId,Source__c FROM Event WHERE Subject ='Test Event1' ];
        for(Event event: updatedEvents){
            System.assertEquals(account.Id, event.WhatId);
        }

        List<Event> event2 = [SELECT Id,WhatId,WhoId,RecordTypeId,Source__c FROM Event WHERE Subject ='Test Event' ];
        EventTriggerBL.validateWhatId(event2);        
    }    

	private static testmethod void validateNomuraWhoId(){
        Test.startTest();
        User nonIntegrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId, Profile.Name
                        		   FROM User WHERE UserName = 'event1newuser1230@nomtestorg.com' LIMIT 1];
        System.runAs(nonIntegrationUserObj){
            System.debug('Inside ValidateNomuraWhoId: Profile: '+nonIntegrationUserObj.Profile.Name);             
            List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId FROM Event WHERE Subject ='Test Event' ];
            ID []  tid = new ID[]{};
            if(events.size() > 0){
                tid.add(events[0].id);
            }
            EventTriggerBL.validateNomuraWhoId(tid);
            Contact nomCon = [SELECT Id FROM Contact WHERE login_Id__c = '123789'];
            EventRelation eventRelation = [SELECT isParent,isInvitee FROM EventRelation WHERE RelationId =: nomCon.Id and Event.Subject = 'Test Event'];
            //System.assertEquals(false, eventRelation.isParent);
            System.assertEquals(true, eventRelation.isInvitee);
        }
        Test.stopTest();
    }    
	
    private static testmethod void validateOtherFields(){
        User nonIntegrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE UserName = 'event1newuser1230@nomtestorg.com' LIMIT 1];
        System.runAs(nonIntegrationUserObj){
            List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId,IsRecurrence2,Source__c FROM Event WHERE Subject ='Test Event' ];
            EventTriggerBL.validateOtherFields(events);
        }
    }
    
    private static testmethod void makeOwnerAsInvitee(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId,Event_Name__c,Source__c FROM Event WHERE Subject ='Test Event1' ];
            EventTriggerBL.makeOwnerAsInvitee(events);
            Contact con = [SELECT Id FROM Contact WHERE Login_Id__c = '123789'];
            List<EventRelation> eventRelation = [SELECT Id FROM EventRelation WHERE RelationId =: con.Id];
            System.assert(eventRelation.size() > 0);
        }
    }
    
    private static testmethod void changeSource(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            Contact c1 = [SELECT Id FROM Contact WHERE email = 'test1@test1.com'];
            Event cpEvent = UtilityTesting.createEvent('CP_Event_Integration', c1.Id, '1on1');
            cpEvent.Subject = 'InstinetTest123';
            cpEvent.Source__c = 'Instinet Feed';
            
            insert cpEvent;
            
            List<Event> events = [SELECT Id,Source__c FROM Event WHERE Subject ='InstinetTest123' ];
            EventTriggerBL.changeSource(events);
            System.assertEquals('Instinet', events[0].Source__c);
            
        }
    }
    
    private static testmethod void deleteEventRelation(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            List<Event> events = [SELECT Id,WhatId,WhoId,RecordTypeId,Event_Name__c,Source__c FROM Event WHERE Subject ='Test Event' ];
            EventTriggerBL.deleteEventRelation(events);
            List<EventRelation> eventRelList = [SELECT Id FROM EventRelation WHERE Relation.Type IN ('Contact','User') AND
                                     (RelationId <>: events[0].WhoId AND EventId =: events[0].Id)];
            System.assert(eventRelList.size() == 0);
        }
    }
    
    private static testmethod void populateDurationAndL0Type(){
        Test.startTest();
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            L1_Event_Type_Setting__mdt metaData = [SELECT Id,Label,L0_Type__c,Default_Duration__c FROM L1_Event_Type_Setting__mdt WHERE Label = 'Other'];
			Integer duration = metaData.Default_Duration__c.intValue();
            
            Contact c1 = [SELECT Id FROM Contact WHERE email = 'test1@test1.com'];
            Event cpEvent = UtilityTesting.createEvent('CP_Event_Integration', c1.Id, '1on1');
            cpEvent.Subject = 'InstinetTest123';
            cpEvent.Source__c = 'Instinet';
            cpEvent.StartDateTime = Datetime.now();
            cpEvent.Type = 'Other';
            
            insert cpEvent;
            
            List<Event> events = [SELECT Id,Source__c,StartDateTime,EndDateTime,Type,L0_Type__c FROM Event WHERE Subject ='InstinetTest123' ];
            EventTriggerBL.populateDurationAndL0Type(events);
            System.assertEquals(metaData.L0_Type__c, events[0].L0_Type__c);

        }
        Test.stopTest();
    }
}