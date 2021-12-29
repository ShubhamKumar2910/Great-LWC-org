@isTest
public class DAUpdatesCRTest {
    
    static testMethod void testDAUpdatesForClientRemediation(){
        
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
        
        
        //Insert RG Accounts
        Account oldRGAccountObj = new Account();
        oldRGAccountObj.Name = 'Old_Account_RG';
        oldRGAccountObj.RDM_Org_Id__c = 'RG1';
        oldRGAccountObj.RecordTypeId = recordTypeIdForRG;
        oldRGAccountObj.Active__c = TRUE;   
        
        insert oldRGAccountObj;
            
        Account newRGAccountObj = new Account();
        newRGAccountObj.Name = 'New_Account_RG';
        newRGAccountObj.RDM_Org_Id__c = 'RG2';
        newRGAccountObj.RecordTypeId = recordTypeIdForRG;
        newRGAccountObj.Active__c = TRUE;   
        
        insert newRGAccountObj;
       
        //Insert RM Accounts
        Account oldAccountObj = new Account();
        oldAccountObj.Name = 'Old_Account';
        oldAccountObj.RDM_Org_Id__c = 'RM1';
        oldAccountObj.RecordTypeId = recordTypeIdForRM;
        oldAccountObj.ParentId = oldRGAccountObj.Id;
        oldAccountObj.BillingCity = 'California';
        oldAccountObj.BillingCountry = 'United States';
        oldAccountObj.BillingStreet = '52nd Street';
        oldAccountObj.Active__c = TRUE;   
        
        insert oldAccountObj;
        
        Account newAccountObj = new Account();
        newAccountObj.Name = 'New_Account';
        newAccountObj.RDM_Org_Id__c = 'RM2';
        newAccountObj.RecordTypeId = recordTypeIdForRM;
        newAccountObj.ParentId = newRGAccountObj.Id;
        newAccountObj.BillingCity = 'California';
        newAccountObj.BillingCountry = 'United States';
        newAccountObj.BillingStreet = '52nd Street';
        newAccountObj.Active__c = TRUE;   
        
        insert newAccountObj;
        
        //Insert Contacts
        Contact contactForOldAccountObj = new Contact();
        contactForOldAccountObj.Salutation = 'M.';
        contactForOldAccountObj.FirstName = 'FN_Old';
        contactForOldAccountObj.LastName = 'LN_Old';
        contactForOldAccountObj.Email = 'FN_Old.LN_Old@test.com';
        contactForOldAccountObj.Research_Email__c = 'FN_Old.LN_Old@test.com';
        contactForOldAccountObj.Phone = '+0000000000';
        contactForOldAccountObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
        contactForOldAccountObj.Active__c = true;
        contactForOldAccountObj.AccountId = oldAccountObj.Id;
        
        insert contactForOldAccountObj;
        
        Contact contactForNewAccountObj = new Contact();
        contactForNewAccountObj.Salutation = 'M.';
        contactForNewAccountObj.FirstName = 'FN_New';
        contactForNewAccountObj.LastName = 'LN_New';
        contactForNewAccountObj.Email = 'FN_New.LN_New@test.com';
        contactForNewAccountObj.Research_Email__c = 'FN_New.LN_New@test.com';
        contactForNewAccountObj.Phone = '+0000000000';
        contactForNewAccountObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
        contactForNewAccountObj.Active__c = true;
        contactForNewAccountObj.AccountId = newAccountObj.Id;
        
        insert contactForNewAccountObj;
        
        /* Insert Event */
        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);
        
        Event eventObj = new Event();
        eventObj.WhatId = oldRGAccountObj.Id;
        eventObj.WhoId = contactForOldAccountObj.Id;
        eventObj.Subject = 'Test DA Event';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = recordTypeIdForDAEventIntegration;
        eventObj.DA_Event_Meeting_Id__c = 14;
        eventObj.DA_Event_ID__c = 20658;
        eventObj.Location = 'Martin Currie Investment Management UK Saltire Court 20 Castle Terrace Edinburgh, EH1 2ES';
        eventObj.CP_Id__c = '20658#14#RG1#Deal';
        
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
        corpClientAttendee1.Event_Meeting_ID__c = '20658#14#RG1#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee1);
        
        DA_CorpClient_Attendee__c corpClientAttendee2 = new DA_CorpClient_Attendee__c();
        corpClientAttendee2.Name = 'WI';
        corpClientAttendee2.Corporate_Client_Name__c = 'Wirecard';
        corpClientAttendee2.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee2.Corporate_Client_Contact_Name__c = 'Iris Stoeckl';
        corpClientAttendee2.Corporate_Client_Contact_Title__c = 'Head of IR';
        corpClientAttendee2.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee2.Event_Meeting_ID__c = '20658#14#RG1#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee2);
        
        
        DA_CorpClient_Attendee__c corpClientAttendee3 = new DA_CorpClient_Attendee__c();
        corpClientAttendee3.Name = 'CPN_US';
        corpClientAttendee3.Corporate_Client_Name__c = 'Calpine Corporation';
        corpClientAttendee3.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee3.Corporate_Client_Contact_Name__c = 'Bryan Kimzey';
        corpClientAttendee3.Corporate_Client_Contact_Title__c = 'VP, IR';
        corpClientAttendee3.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee3.Event_Meeting_ID__c = '20658#14#RG1#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee3);
        
        DA_CorpClient_Attendee__c corpClientAttendee4 = new DA_CorpClient_Attendee__c();
        corpClientAttendee4.Name = 'CPN_US';
        corpClientAttendee4.Corporate_Client_Name__c = 'Calpine Corporation';
        corpClientAttendee4.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee4.Corporate_Client_Contact_Name__c = 'Christine Parker';
        corpClientAttendee4.Corporate_Client_Contact_Title__c = 'Director, IR';
        corpClientAttendee4.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee4.Event_Meeting_ID__c = '20658#14#RG1#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee4);
        
        DA_CorpClient_Attendee__c corpClientAttendee5 = new DA_CorpClient_Attendee__c();
        corpClientAttendee5.Name = 'CPN_US';
        corpClientAttendee5.Corporate_Client_Name__c = 'Calpine Corporation';
        corpClientAttendee5.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee5.Corporate_Client_Contact_Name__c = 'Dan Olenium';
        corpClientAttendee5.Corporate_Client_Contact_Title__c = 'Manager, IR';
        corpClientAttendee5.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee5.Event_Meeting_ID__c = '20658#14#RG1#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee5);
        
        
        DA_CorpClient_Attendee__c corpClientAttendee6 = new DA_CorpClient_Attendee__c();
        corpClientAttendee6.Name = 'DGE_LN';
        corpClientAttendee6.Corporate_Client_Name__c = 'Diageo plc';
        corpClientAttendee6.Corporate_Client_Contact_ID__c = '';
        corpClientAttendee6.Corporate_Client_Contact_Name__c = 'Catherine James';
        corpClientAttendee6.Corporate_Client_Contact_Title__c = 'Head of IR';
        corpClientAttendee6.Corporate_Client_Contact_Status__c = 'Confirmed';
        corpClientAttendee6.Event_Meeting_ID__c = '20658#14#RG1#Deal';
        
        corpClientAttendeeList.add(corpClientAttendee6);
        
        insert corpClientAttendeeList;
        
        //Insert entry in Client_Remediation__c Obect
        Client_Remediation__c crObj = new Client_Remediation__c();
        
        crObj.OLD_RG__c = 'RG1';
        crObj.NEW_RG__c = 'RG2';
        crObj.RG_ACTION__c = 'MERGE';
        crObj.OLD_RG_Account__c = oldRGAccountObj.Id;
        crObj.NEW_RG_Account__c = newRGAccountObj.Id;
        
        insert crObj;
        
        DACorpClientWrapper corpClientWrapper =  new DACorpClientWrapper(eventObj.Id, '20658#14#RG1#Deal', '20658#14#RG2#Deal');

		//Execute the Job
        Test.startTest();
        List<String> oldNewCPIdList = new List<String>();
        oldNewCPIdList.add('20658#14#RG1#Deal~20658#14#RG2#Deal');
        
        Database.executeBatch(new DAUpdatesForClientRemediationBatch(oldNewCPIdList), 1);
        
        Test.stopTest(); 
	        
        List<DA_CorpClient_Attendee__c> corpClientsForOld = [SELECT Id, Name FROM DA_CorpClient_Attendee__c
                                                             WHERE Event_Meeting_ID__c LIKE '%#RG1%'];
        
        System.assertEquals(0, corpClientsForOld.size());
                            
        List<DA_CorpClient_Attendee__c> corpClientsForNew = [SELECT Id, Name FROM DA_CorpClient_Attendee__c
                                                             WHERE Event_Meeting_ID__c LIKE '%#RG2%'];
        
        System.assertEquals(6, corpClientsForNew.size());
        
      
        
    }

}