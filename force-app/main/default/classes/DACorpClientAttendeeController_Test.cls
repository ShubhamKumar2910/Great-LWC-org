@isTest
public class DACorpClientAttendeeController_Test {
	
    static testMethod void testDACorpClientAttendeeController(){
        Test.startTest();
        
        // Record Types
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account', 'RG Account', 'DealAxis Event Integration')];
        Id recordTypeIdForRM = null;
        Id recordTypeIdForRG = null;
        Id recordTypeIdForDAEventIntegration = null;
        
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForRM = recordTypeObj.Id; 
                }
                else if('RG Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForRG = recordTypeObj.Id; 
                }
                else if('DealAxis Event Integration'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForDAEventIntegration = recordTypeObj.Id; 
                }
            }
        }
        
        
        //Inserting Accounts
        List<Account> accountList = new List<Account>();
        Account accountRG  = new Account(); 
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
        accountRG.RecordTypeId = recordTypeIdForRG;
        accountRG.Active__c = TRUE;  
        
        accountList.add(accountRG);
        
        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy';
        accountRM.RDM_Org_ID__c = 'RMXXXXXX';            
        accountRM.RecordTypeId = recordTypeIdForRM;
        accountRM.BillingStreet = '52nd Street' ;
        accountRM.BillingCity = 'Los Angeles';
        accountRM.BillingPostalCode = '90001';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        
        accountList.add(accountRM);
        
         insert accountList;
        
        /* Insert Contact */
        List<Contact> contactList = new List<Contact>();
        
        Contact contactObj1 = new Contact();
        contactObj1.AccountId = accountRM.Id;
        contactObj1.FirstName = 'TestFN'; 
        contactObj1.LastName = 'TestLN';    
        contactObj1.Active__c = TRUE;
        contactObj1.Email = 'TestFN_TestLN@test.com';
        contactObj1.Phone = '+0000000000'; 
        contactObj1.Salutation = 'M.';    
        contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
        
        contactList.add(contactObj1);
        
        insert contactList;
        
        /* Insert Event */
        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);
        
        Event eventObj = new Event();
        eventObj.WhatId = accountRG.Id;
        eventObj.WhoId = contactObj1.Id;
        eventObj.Subject = 'Test DA Event';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = recordTypeIdForDAEventIntegration;
        eventObj.DA_Event_Meeting_Id__c = 14;
        eventObj.DA_Event_ID__c = 20658;
        eventObj.Location = 'Martin Currie Investment Management UK Saltire Court 20 Castle Terrace Edinburgh, EH1 2ES';
        eventObj.CP_Id__c = '20658#14#RGXXXXXX#Deal';
        
        insert eventObj;
        System.debug('Event Id:'+eventObj.Id);
        
        /* Insert DA_CorpClient_Attendee*/
        List<DA_CorpClient_Attendee__c> corpClientAttendeeList = new List<DA_CorpClient_Attendee__c>();
        
        DA_CorpClient_Attendee__c corpClientAttendee1 = new DA_CorpClient_Attendee__c();
        corpClientAttendee1.Name = 'WI';
        corpClientAttendee1.Corporate_Client_Name__c = 'Wirecard';
        corpClientAttendee1.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee1.Corporate_Client_Contact_Name__c = 'Burkhard Ley';
        corpClientAttendee1.Corporate_Client_Contact_Title__c = 'CFO';
        corpClientAttendee1.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee1.Event_Meeting_ID__c = '20658#14#RGXXXXXX#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee1);
        
        DA_CorpClient_Attendee__c corpClientAttendee2 = new DA_CorpClient_Attendee__c();
        corpClientAttendee2.Name = 'WI';
        corpClientAttendee2.Corporate_Client_Name__c = 'Wirecard';
        corpClientAttendee2.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee2.Corporate_Client_Contact_Name__c = 'Iris Stoeckl';
        corpClientAttendee2.Corporate_Client_Contact_Title__c = 'Head of IR';
        corpClientAttendee2.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee2.Event_Meeting_ID__c = '20658#14#RGXXXXXX#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee2);
        
        
        DA_CorpClient_Attendee__c corpClientAttendee3 = new DA_CorpClient_Attendee__c();
        corpClientAttendee3.Name = 'CPN_US';
        corpClientAttendee3.Corporate_Client_Name__c = 'Calpine Corporation';
        corpClientAttendee3.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee3.Corporate_Client_Contact_Name__c = 'Bryan Kimzey';
        corpClientAttendee3.Corporate_Client_Contact_Title__c = 'VP, IR';
        corpClientAttendee3.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee3.Event_Meeting_ID__c = '20658#14#RGXXXXXX#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee3);
        
        DA_CorpClient_Attendee__c corpClientAttendee4 = new DA_CorpClient_Attendee__c();
        corpClientAttendee4.Name = 'CPN_US';
        corpClientAttendee4.Corporate_Client_Name__c = 'Calpine Corporation';
        corpClientAttendee4.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee4.Corporate_Client_Contact_Name__c = 'Christine Parker';
        corpClientAttendee4.Corporate_Client_Contact_Title__c = 'Director, IR';
        corpClientAttendee4.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee4.Event_Meeting_ID__c = '20658#14#RGXXXXXX#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee4);
        
        DA_CorpClient_Attendee__c corpClientAttendee5 = new DA_CorpClient_Attendee__c();
        corpClientAttendee5.Name = 'CPN_US';
        corpClientAttendee5.Corporate_Client_Name__c = 'Calpine Corporation';
        corpClientAttendee5.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee5.Corporate_Client_Contact_Name__c = 'Dan Olenium';
        corpClientAttendee5.Corporate_Client_Contact_Title__c = 'Manager, IR';
        corpClientAttendee5.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee5.Event_Meeting_ID__c = '20658#14#RGXXXXXX#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee5);
        
        
        DA_CorpClient_Attendee__c corpClientAttendee6 = new DA_CorpClient_Attendee__c();
        corpClientAttendee6.Name = 'DGE_LN';
        corpClientAttendee6.Corporate_Client_Name__c = 'Diageo plc';
        corpClientAttendee6.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee6.Corporate_Client_Contact_Name__c = 'Catherine James';
        corpClientAttendee6.Corporate_Client_Contact_Title__c = 'Head of IR';
        corpClientAttendee6.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee6.Event_Meeting_ID__c = '20658#14#RGXXXXXX#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee6);
        
        insert corpClientAttendeeList;
        
        Test.setCurrentPageReference(new PageReference('Page.DACorpClientAttendeeData')); 
    	System.currentPageReference().getParameters().put('id', eventObj.id);
        
		DACorpClientAttendeeController corpClientAttendeeController = new DACorpClientAttendeeController(new ApexPages.StandardController(eventObj));
        corpClientAttendeeController.getDACorpClientAttendees();
        Test.stopTest();
    }
}