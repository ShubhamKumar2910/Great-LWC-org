@isTest
public class PopulateServiceCountBatch_Test {

    @testSetup 
    private static void setupData(){

        List<User> users = UtilityTesting.createUsersWithProfile(1, 'Nomura - Integration');
        
        setupEventData(users[0]);
        //setupCampaignEventData(users[0]);
    }
    
    private static void setupCampaignEventData(User testUser){
        String recordTypeIdForRGAccount = null;
        String recordTypeIdForCPEventIntegration = null;
        String recordTypeIdForDealAxisEventIntegration = null;
            
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
            
           
            /* Record Type */
            List<RecordType> recordTypeList = [Select Id, Name FROM RecordType 
                                               WHERE Name IN ('RG Account', 'CP Event Integration','DealAxis Event Integration')  ];
            if(recordTypeList != null && recordTypeList.size() > 0){
                for(RecordType recordType : recordTypeList){
                    if('RG Account'.equalsIgnoreCase(recordType.Name)){
                        recordTypeIdForRGAccount = recordType.Id;
                    }
                    else if('CP Event Integration'.equalsIgnoreCase(recordType.Name)){
                        recordTypeIdForCPEventIntegration = recordType.Id;
                    }
                    else if('DealAxis Event Integration'.equalsIgnoreCase(recordType.Name)){
                        recordTypeIdForDealAxisEventIntegration = recordType.Id;
                    }                    
                }
            }
            
            /* Account Insertion */
            Account testAccount = new Account(Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                              RecordTypeId = recordTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
            insert testAccount;
            
             Account testAccountRM= new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                              RecordTypeId = RMRecordType.id,ParentId =testAccount.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
            
            
            insert testAccountRM;            
	    
            Account testAccount2 = new Account(Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                              RecordTypeId = recordTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
            insert testAccount2;
            
             Account testAccountRM2= new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                              RecordTypeId = RMRecordType.id,ParentId =testAccount2.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
            
            
            insert testAccountRM2; 	    
            
            


            
            /* Contact Insertion */
            Contact contactObj1 = new Contact(FirstName='contact1FirstName', LastName='contact1LastName', Salutation='Mr', Email='contact1FirstName.contact1LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = testAccountRM.id );
            insert contactObj1;
	    
            Contact contactObj2 = new Contact(FirstName='contact2FirstName', LastName='contact2LastName', Salutation='Mr', Email='contact2FirstName.contact1LastName@dummy.com',Phone='+0 (000) 100-0000',Active__c=true,AccountId = testAccountRM2.id );
            insert contactObj2;	    
            
            /* Campaign */
            Campaign camp = new Campaign(Name='Sam Test Campaign1', Type='Phone Book',Status='Planned',isactive=true,ownerid=testUser.id );
            insert camp;    
	    
            Campaign camp2 = new Campaign(Name='Sam Test Campaign2', Type='Phone Book',Status='Planned',isactive=true,ownerid=testUser.id );
            insert camp2;	    

           List<CampaignMember> campaignMemberList = new List<CampaignMember>();              
            campaignMemberList.add(new CampaignMember(ContactId = contactObj1.Id,CampaignId = camp.id));   
	    campaignMemberList.add(new CampaignMember(ContactId = contactObj1.Id,CampaignId = camp2.id)); 
            campaignMemberList.add(new CampaignMember(ContactId = contactObj2.Id,CampaignId = camp.id));   
	    campaignMemberList.add(new CampaignMember(ContactId = contactObj2.Id,CampaignId = camp2.id));	    
            insert campaignMemberList;          
            
            /* Event Insertion */
            Datetime startDateTime = Datetime.now();
            Datetime endDateTime = startDateTime.addHours(1);
            System.runas(testUser){
                Event eventObj = new Event();
                eventObj.WhatId = camp.Id;
                eventObj.WhoId = contactObj1.Id;
                eventObj.OwnerId = testUser.Id;
                eventObj.Subject = 'Test Event';
                eventObj.StartDateTime = startDateTime;
                eventObj.EndDateTime = endDateTime;
                eventObj.RecordTypeId = recordTypeIdForCPEventIntegration;
                eventObj.SR_JP_Cnt__c = 1;
                eventObj.SR_AS_Cnt__c = 1;
                eventObj.SR_US_Cnt__c = 0;
                eventObj.SR_EM_Cnt__c = 1;
                eventObj.SR_GBL_Cnt__c = 1;
                eventObj.SR_JP_Con_Cnt__c = 1;
                eventObj.SR_AS_Con_Cnt__c = 1;
                eventObj.SR_US_Con_Cnt__c = 0;
                eventObj.SR_EM_Con_Cnt__c = 1;
                eventObj.SR_GBL_Con_Cnt__c = 0;
                eventObj.Type = 'Dialer';
                insert eventObj;
                
                system.debug('eventObj :' +eventObj.id);
                
                Event eventObj1 = new Event(); 
                eventObj1.WhatId = camp.Id;
                eventObj1.WhoId = contactObj1.Id;
                eventObj1.OwnerId = testUser.Id;
                eventObj1.Subject = 'Test Event1';
                eventObj1.StartDateTime = startDateTime;
                eventObj1.EndDateTime = endDateTime;
                eventObj1.RecordTypeId = recordTypeIdForCPEventIntegration;
                eventObj1.SR_JP_Cnt__c = 1;
                eventObj1.SR_AS_Cnt__c = 1;
                eventObj1.SR_US_Cnt__c = 0;
                eventObj1.SR_EM_Cnt__c = 1;
                eventObj1.SR_GBL_Cnt__c = 1;
                eventObj1.SR_JP_Con_Cnt__c = 1;
                eventObj1.SR_AS_Con_Cnt__c = 1;
                eventObj1.SR_US_Con_Cnt__c = 0;
                eventObj1.SR_EM_Con_Cnt__c = 1;
                eventObj1.SR_GBL_Con_Cnt__c = 0;
                eventObj1.Type = 'Voicemail';
                insert eventObj1; 
                
                 Event eventObj4 = new Event(); 
                eventObj4.WhatId = camp2.Id;
                eventObj4.WhoId = contactObj1.id;
                eventObj4.OwnerId = testUser.Id;
                eventObj4.Subject = 'Test Event4';
                eventObj4.StartDateTime = startDateTime;
                eventObj4.EndDateTime = endDateTime;
                eventObj4.RecordTypeId = recordTypeIdForCPEventIntegration;
                eventObj4.SR_JP_Cnt__c = 1;
                eventObj4.SR_AS_Cnt__c = 1;
                eventObj4.SR_US_Cnt__c = 0;
                eventObj4.SR_EM_Cnt__c = 1;
                eventObj4.SR_GBL_Cnt__c = 1;
                eventObj4.SR_JP_Con_Cnt__c = 1;
                eventObj4.SR_AS_Con_Cnt__c = 1;
                eventObj4.SR_US_Con_Cnt__c = 0;
                eventObj4.SR_EM_Con_Cnt__c = 1;
                eventObj4.SR_GBL_Con_Cnt__c = 0;
                eventObj4.Type = 'Voicemail';         
                insert eventObj4;		
                
 		
            }   
    }   

    private static void setupEventData(User testUser){
        String recordTypeIdForRGAccount = null;
        String recordTypeIdForCPEventIntegration = null;
        String recordTypeIdForDealAxisEventIntegration = null;
            
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
            
           
            /* Record Type */
            List<RecordType> recordTypeList = [Select Id, Name FROM RecordType 
                                               WHERE Name IN ('RG Account', 'CP Event Integration','DealAxis Event Integration')  ];
            if(recordTypeList != null && recordTypeList.size() > 0){
                for(RecordType recordType : recordTypeList){
                    if('RG Account'.equalsIgnoreCase(recordType.Name)){
                        recordTypeIdForRGAccount = recordType.Id;
                    }
                    else if('CP Event Integration'.equalsIgnoreCase(recordType.Name)){
                        recordTypeIdForCPEventIntegration = recordType.Id;
                    }
                    else if('DealAxis Event Integration'.equalsIgnoreCase(recordType.Name)){
                        recordTypeIdForDealAxisEventIntegration = recordType.Id;
                    }                       
                }
            }
            
            /* Account Insertion */
            Account testAccount = new Account(Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                              RecordTypeId = recordTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
            insert testAccount;
            
             Account testAccountRM= new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                              RecordTypeId = RMRecordType.id,ParentId =testAccount.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
            
            
            insert testAccountRM;            
            
            

            /* Contact Insertion */
            Contact contactObj1 = new Contact(FirstName='contact1FirstName1', LastName='contact1LastName', Salutation='Mr', Email='contact1FirstName1.contact1LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = testAccountRM.id );
            insert contactObj1;
            
            /* Event Insertion */
            Datetime startDateTime = Datetime.now();
            Datetime endDateTime = startDateTime.addHours(1);
            
            System.runas(testUser){
                Event eventObj = new Event();
                eventObj.WhatId = testAccount.Id;
                eventObj.WhoId = contactObj1.Id;
                eventObj.OwnerId = testUser.Id;
                eventObj.Subject = 'Test Event';
                eventObj.StartDateTime = startDateTime;
                eventObj.EndDateTime = endDateTime;
                eventObj.RecordTypeId = recordTypeIdForCPEventIntegration;
                eventObj.SR_JP_Cnt__c = 1;
                eventObj.SR_AS_Cnt__c = 1;
                eventObj.SR_US_Cnt__c = 0;
                eventObj.SR_EM_Cnt__c = 1;
                eventObj.SR_GBL_Cnt__c = 1;
                eventObj.SR_JP_Con_Cnt__c = 1;
                eventObj.SR_AS_Con_Cnt__c = 1;
                eventObj.SR_US_Con_Cnt__c = 0;
                eventObj.SR_EM_Con_Cnt__c = 1;
                eventObj.SR_GBL_Con_Cnt__c = 0;
                eventObj.Type = 'Dialer';
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
                eventObj1.SR_JP_Cnt__c = 1;
                eventObj1.SR_AS_Cnt__c = 1;
                eventObj1.SR_US_Cnt__c = 0;
                eventObj1.SR_EM_Cnt__c = 1;
                eventObj1.SR_GBL_Cnt__c = 1;
                eventObj1.SR_JP_Con_Cnt__c = 1;
                eventObj1.SR_AS_Con_Cnt__c = 1;
                eventObj1.SR_US_Con_Cnt__c = 0;
                eventObj1.SR_EM_Con_Cnt__c = 1;
                eventObj1.SR_GBL_Con_Cnt__c = 0;
                eventObj1.Type = 'Voicemail';
                insert eventObj1; 
                
                 Event eventObj2 = new Event(); 
                //eventObj2.WhatId = null;
                eventObj2.WhoId = contactObj1.id;
                eventObj2.OwnerId = testUser.Id;
                eventObj2.Subject = 'Test Event1';
                eventObj2.StartDateTime = startDateTime;
                eventObj2.EndDateTime = endDateTime;
                eventObj2.RecordTypeId = recordTypeIdForDealAxisEventIntegration;
                eventObj2.SR_JP_Cnt__c = 1;
                eventObj2.SR_AS_Cnt__c = 1;
                eventObj2.SR_US_Cnt__c = 0;
                eventObj2.SR_EM_Cnt__c = 1;
                eventObj2.SR_GBL_Cnt__c = 1;
                eventObj2.SR_JP_Con_Cnt__c = 1;
                eventObj2.SR_AS_Con_Cnt__c = 1;
                eventObj2.SR_US_Con_Cnt__c = 0;
                eventObj2.SR_EM_Con_Cnt__c = 1;
                eventObj2.SR_GBL_Con_Cnt__c = 0;
                eventObj2.Event_Type__c = 'Corporate Management';
                eventObj2.type = 'Small Group';         
                insert eventObj2; 
            }   
    }  
    
    private static void setupModelDataForCP(){
        RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
        
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : calls';
        equityCoreserviceModel2.Order__c = 3;
        equityCoreserviceModel2.stable_version__c=1;        
        equityCoreserviceModel2.inprogress_version__c=2;
        equityCoreserviceModel2.CALL_REPORT_TYPE__C='Dialer;Voicemail';
        equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;     
    }   

    private static void setupModelDataForDA(){
        RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
        
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'YES';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : small group meeting';
        equityCoreserviceModel2.Order__c = 5;
        equityCoreserviceModel2.inprogress_version__c=2;
        equityCoreserviceModel2.stable_version__c=1;
        //equityCoreserviceModel2.DEALAXIS_EVENT_TYPE__C='Corporate Management';
        //equityCoreserviceModel2.dealaxis_event_meeting_type__c='Small Group';   
        equityCoreserviceModel2.DealAxis_Type__c = 'Corporate Management~Small Group';	
		    
        equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;     
    }   
    
    static testMethod void testPopulateServiceCountForCPAccountEvent() {
        setupModelDataForCP();
        Test.startTest(); 
        
        Database.executeBatch(new PopulateServiceCountBatch(), 1);
        Test.stopTest();  
    }
    
    static testMethod void testPopulateServiceCountForCPCampaignEvent() {
        Test.startTest(); 
        setupModelDataForCP();
        Database.executeBatch(new PopulateServiceCountBatch(), 1);
        Test.stopTest();  
    }

    
    static testMethod void testPopulateServiceCountForDXEvent() {
        Test.startTest(); 
        setupModelDataForDA();
        Database.executeBatch(new PopulateServiceCountBatch(), 1);
        Test.stopTest();  
    }   
    static testMethod void testServiceROIUtility() {
        Test.startTest(); 
        DateTime cdate = DateTime.now();
        system.debug(ServiceROIUtility.getQuaterPeriods(DateTime.newInstanceGMT(cdate.yearGmt(), 3, cdate.dayGmt(), 23,59, 59)).size());
        system.debug(ServiceROIUtility.getQuaterPeriods(DateTime.newInstanceGMT(cdate.yearGmt(), 12, cdate.dayGmt(), 23,59, 59)).size());
        system.debug(ServiceROIUtility.getQuaterPeriods().size());
        ServiceROIUtility.updateModelImpacted([select id, SR_GBL_Cnt__c, type, event_type__c from Event]);
        setupModelDataForCP();
        ServiceROIUtility.updateModelsImpacted([select id, name, recordtype.name, inprogress_version__c, stable_version__c, CALL_REPORT_TYPE__C, External_Id__c from Account_Service_Model__c]);
        Test.stopTest();  
    }   
    static testMethod void testServiceROIUtility_monthly() {
        Test.startTest(); 
        DateTime cdate = DateTime.now();
        system.debug(ServiceROIUtility.getMonthPeriods(DateTime.newInstanceGMT(cdate.yearGmt(), 3, cdate.dayGmt(), 23,59, 59)).size());
        system.debug(ServiceROIUtility.getMonthPeriods(DateTime.newInstanceGMT(cdate.yearGmt(), 12, cdate.dayGmt(), 23,59, 59)).size());
        system.debug(ServiceROIUtility.getMonthPeriods().size());
        ServiceROIUtility.updateModelImpacted([select id, SR_GBL_Cnt__c, type, event_type__c from Event]);
        setupModelDataForCP();
        ServiceROIUtility.updateModelsImpacted([select id, name, recordtype.name, inprogress_version__c, stable_version__c, CALL_REPORT_TYPE__C, External_Id__c from Account_Service_Model__c]);
        Test.stopTest();  
    }  

   static testMethod void test_mergeRanks() {
        Test.startTest(); 
	Account_Service_Rank__c emptyRank = new Account_Service_Rank__c();
	Account_Service_Rank__c fullyPopulatedRank = new Account_Service_Rank__c();
	populateRank(fullyPopulatedRank);
	PopulateServiceCountBatch batch = new PopulateServiceCountBatch();
	batch.mergeRanks(emptyRank, emptyRank);
	batch.mergeRanks(fullyPopulatedRank, fullyPopulatedRank);
	batch.mergeRanks(emptyRank, fullyPopulatedRank);
	batch.mergeRanks(fullyPopulatedRank, emptyRank);
        Test.stopTest();  
    }
    
    private static void populateRank(Account_Service_Rank__c rank) {
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 

        for (String fieldName : mapFields.keyset()) 
        { 
            if (fieldName.toUpperCase().contains('_COUNT__C') || fieldName.toUpperCase().contains('_POINTS__C')) {
                    rank.put(fieldName , 3);
            }
        }     
    }
}