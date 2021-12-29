/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 30/11/2018
	Description : Test class for the ETradingAssignContactController 
				  controller class.
	
*/  
@isTest
public with sharing class ETradingAssignContactControllerTest 
{
    static testMethod void getETradingEnablementDataTest()
    {
        String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
                
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
		    PermissionSet eTradingEnablementPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ETrading_Enablement_Admin'];
        
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = testUser.Id;
        permissionSetAssignment.PermissionSetId = eTradingEnablementPermissionSet.Id;
        insert permissionSetAssignment;

        System.runAs(testUser) 
        {
          // Insert RS Account
          Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
          Account rsAccount = AccountTestData.getAccount();
          rsAccount.RecordTypeId = rsAccountRecordTypeId;
          rsAccount.RDM_Org_ID__c = 'RS Account';
          rsAccount.Active__c = true; 
          insert rsAccount;
            
          // Insert RG Account
          Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
          Account rgAccount = AccountTestData.getAccount();
          rgAccount.RecordTypeId = rgAccountRecordTypeId;
          rgAccount.RDM_Org_ID__c = 'RG Account';
          rgAccount.ParentId = rsAccount.Id;
          rgAccount.Active__c = true;
          insert rgAccount;
          
          // Insert RM Account
          Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
          Account account = AccountTestData.getAccount();
          account.RecordTypeId = rmAccountRecordTypeId;
          account.RDM_Org_ID__c = 'RM Account';
          account.ParentId = rgAccount.Id;
          account.Active__c = true; 
          insert account;

          Contact contact = ContactTestData.getContact(account.Id);
          contact.RG_Account__c = rgAccount.Id;
          contact.Developer_Reference__c = 'Unassigned eTrading';
          insert contact;

          Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
          
          List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

          // The three groups of ETradingEnablements will be aggregated down to one when read 
          // from ETradingAssignContactController 
          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          insert eTradingEnablements;

          Test.startTest();

          ETradingAssignContactController.ETrading eTrading = new ETradingAssignContactController.ETrading();

          String eTradingJSON = ETradingAssignContactController.getETradingData();
          eTrading = (ETradingAssignContactController.ETrading)JSON.deserialize(eTradingJSON, ETradingAssignContactController.ETrading.class);

          if (eTrading.error)
          {
              System.debug('ETradingAssignContactControllerTest : getETradingEnablementDataTest : eTrading.errorMessage : ' + eTrading.errorMessage);
          }

          System.assertEquals(eTrading.error, false);
          System.assertEquals(eTrading.errorMessage, '');
          System.assertEquals(eTrading.eTradingData.size(), 10);
        
          Test.stopTest();
        }
      
    }

    static testMethod void checkFieldLevelSecurityTest()
    {
        String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
                
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
        System.runAs(testUser) 
        {
          // Insert RS Account
          Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
          Account rsAccount = AccountTestData.getAccount();
          rsAccount.RecordTypeId = rsAccountRecordTypeId;
          rsAccount.RDM_Org_ID__c = 'RS Account';
          rsAccount.Active__c = true; 
          insert rsAccount;
            
          // Insert RG Account
          Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
          Account rgAccount = AccountTestData.getAccount();
          rgAccount.RecordTypeId = rgAccountRecordTypeId;
          rgAccount.RDM_Org_ID__c = 'RG Account';
          rgAccount.ParentId = rsAccount.Id;
          rgAccount.Active__c = true;
          insert rgAccount;
          
          // Insert RM Account
          Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
          Account account = AccountTestData.getAccount();
          account.RecordTypeId = rmAccountRecordTypeId;
          account.RDM_Org_ID__c = 'RM Account';
          account.ParentId = rgAccount.Id;
          account.Active__c = true; 
          insert account;

          Contact contact = ContactTestData.getContact(account.Id);
          contact.RG_Account__c = rgAccount.Id;
          contact.Developer_Reference__c = 'Unassigned eTrading';
          insert contact;

          Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
          
          List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          insert eTradingEnablements;

          Test.startTest();

          ETradingAssignContactController.ETrading eTrading = new ETradingAssignContactController.ETrading();

          String eTradingJSON = ETradingAssignContactController.getETradingData();
          eTrading = (ETradingAssignContactController.ETrading)JSON.deserialize(eTradingJSON, ETradingAssignContactController.ETrading.class);

          System.assertEquals(eTrading.error, true);
          System.assertEquals(eTrading.errorMessage, 'Field Level Security Error : User does not have permission to view the data');
        
          Test.stopTest();
        }
    }

    static testMethod void saveETradingPlatformContactDataTest()
    {
        String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
                
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
		PermissionSet eTradingEnablementPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ETrading_Enablement_Admin'];
        
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = testUser.Id;
        permissionSetAssignment.PermissionSetId = eTradingEnablementPermissionSet.Id;
        insert permissionSetAssignment;

        System.runAs(testUser) 
        {
          // Insert RS Account
          Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
          Account rsAccount = AccountTestData.getAccount();
          rsAccount.RecordTypeId = rsAccountRecordTypeId;
          rsAccount.RDM_Org_ID__c = 'RS Account';
          rsAccount.Active__c = true; 
          insert rsAccount;
            
          // Insert RG Account
          Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
          Account rgAccount = AccountTestData.getAccount();
          rgAccount.RecordTypeId = rgAccountRecordTypeId;
          rgAccount.RDM_Org_ID__c = 'RG Account';
          rgAccount.ParentId = rsAccount.Id;
          rgAccount.Active__c = true;
          insert rgAccount;
          
          // Insert RM Account
          Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
          Account account = AccountTestData.getAccount();
          account.RecordTypeId = rmAccountRecordTypeId;
          account.RDM_Org_ID__c = 'RM Account';
          account.ParentId = rgAccount.Id;
          account.Active__c = true; 
          insert account;

          Contact contact = ContactTestData.getContact(account.Id);
          contact.RG_Account__c = rgAccount.Id;
          contact.Developer_Reference__c = 'Unassigned eTrading';
          insert contact;

          Contact newContact = ContactTestData.getContact(account.Id);
          newContact.RG_Account__c = rgAccount.Id;
          newContact.Email = 'etradingassigncontacttest@nomura.com';
          insert newContact;

          Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
          
          List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

          // The three groups of ETradingEnablements will be aggregated down to one when read 
          // from ETradingAssignContactController 
          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          insert eTradingEnablements;

          Test.startTest();

          ETradingAssignContactController.ETrading eTrading = new ETradingAssignContactController.ETrading();

          String eTradingJSON = ETradingAssignContactController.getETradingData();
          eTrading = (ETradingAssignContactController.ETrading)JSON.deserialize(eTradingJSON, ETradingAssignContactController.ETrading.class);

          String eTradingPlatformIdContactId = '{"eTradingPlatformIdContactIds":[';

          for (ETradingAssignContactController.ETradingData eTradingDataItem : eTrading.eTradingData)
          {
              eTradingPlatformIdContactId += '{"platformId":"' + eTradingDataItem.platformId + '","contactId":"' + newContact.Id +'"},';
          }

          eTradingPlatformIdContactId = eTradingPlatformIdContactId.removeEnd(',');
          eTradingPlatformIdContactId += ']}';   

          ETradingAssignContactController.ETradingAssignContact eTradingAssignContact = new ETradingAssignContactController.ETradingAssignContact();
          
          String eTradingAssignContactJSON = ETradingAssignContactController.saveETradingPlatformContactData(eTradingPlatformIdContactId);
          eTradingAssignContact = (ETradingAssignContactController.ETradingAssignContact)JSON.deserialize(eTradingAssignContactJSON, ETradingAssignContactController.ETradingAssignContact.class);

          System.assertEquals(eTradingAssignContact.error, false);
          System.assertEquals(eTradingAssignContact.errorMessage, '');

          Set<Id> eTradingEnablementsIds = new Set<Id>();

          for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
          {
              eTradingEnablementsIds.add(eTradingEnablement.Id);
          }

          eTradingEnablements = [SELECT Id, 
                                 Contact__c, 
                                 Contact__r.Developer_Reference__c, 
                                 Status__c, 
                                 RecordTypeId, 
                                 Platform_Id__c 
                                 FROM ETradingEnablement__c 
                                 WHERE Id IN :eTradingEnablementsIds];

          for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
          {
            System.assertEquals(eTradingEnablement.Contact__c, newContact.Id);
            System.assertEquals(eTradingEnablement.Status__c, 'Pending Approval');
          }

          Test.stopTest();
        }
    }

    static testMethod void saveETradingPlatformContactDataErrorTest()
    {
        String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
                
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
		PermissionSet eTradingEnablementPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ETrading_Enablement_Admin'];
        
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = testUser.Id;
        permissionSetAssignment.PermissionSetId = eTradingEnablementPermissionSet.Id;
        insert permissionSetAssignment;

        System.runAs(testUser) 
        {
          // Insert RS Account
          Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
          Account rsAccount = AccountTestData.getAccount();
          rsAccount.RecordTypeId = rsAccountRecordTypeId;
          rsAccount.RDM_Org_ID__c = 'RS Account';
          rsAccount.Active__c = true; 
          insert rsAccount;
            
          // Insert RG Account
          Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
          Account rgAccount = AccountTestData.getAccount();
          rgAccount.RecordTypeId = rgAccountRecordTypeId;
          rgAccount.RDM_Org_ID__c = 'RG Account';
          rgAccount.ParentId = rsAccount.Id;
          rgAccount.Active__c = true;
          insert rgAccount;
          
          // Insert RM Account
          Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
          Account account = AccountTestData.getAccount();
          account.RecordTypeId = rmAccountRecordTypeId;
          account.RDM_Org_ID__c = 'RM Account';
          account.ParentId = rgAccount.Id;
          account.Active__c = true; 
          insert account;

          Contact contact = ContactTestData.getContact(account.Id);
          contact.RG_Account__c = rgAccount.Id;
          contact.Developer_Reference__c = 'Unassigned eTrading';
          insert contact;

          Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
          
          List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

          // The three groups of ETradingEnablements will be aggregated down to one when read 
          // from ETradingAssignContactController 
          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          for (Integer intLoop = 0; intLoop <= 9; intLoop++)
          {
              ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
              eTradingEnablement.Status__c = 'On Hold';
              eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
              eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
              eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
              eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
              eTradingEnablement.Contact__c = contact.Id;
              eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

              eTradingEnablements.add(eTradingEnablement);
          }

          insert eTradingEnablements;

          Test.startTest();

          ETradingAssignContactController.ETrading eTrading = new ETradingAssignContactController.ETrading();

          String eTradingJSON = ETradingAssignContactController.getETradingData();
          eTrading = (ETradingAssignContactController.ETrading)JSON.deserialize(eTradingJSON, ETradingAssignContactController.ETrading.class);

          String eTradingPlatformIdContactId = '{"eTradingPlatformIdContactIds":[';

          for (ETradingAssignContactController.ETradingData eTradingDataItem : eTrading.eTradingData)
          {
              eTradingPlatformIdContactId += '{"platformId":"' + eTradingDataItem.platformId + '","contactId":"INCORRECT-Id"},';
          }

          eTradingPlatformIdContactId = eTradingPlatformIdContactId.removeEnd(',');
          eTradingPlatformIdContactId += ']}';   

          ETradingAssignContactController.ETradingAssignContact eTradingAssignContact = new ETradingAssignContactController.ETradingAssignContact();
          
          String eTradingAssignContactJSON = ETradingAssignContactController.saveETradingPlatformContactData(eTradingPlatformIdContactId);
          eTradingAssignContact = (ETradingAssignContactController.ETradingAssignContact)JSON.deserialize(eTradingAssignContactJSON, ETradingAssignContactController.ETradingAssignContact.class);

          System.assertEquals(eTradingAssignContact.error, true);
          System.assertEquals(eTradingAssignContact.errorMessage, 'Invalid id: INCORRECT-Id');

          Test.stopTest();
        }
    }   
}