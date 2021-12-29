@isTest
public class SchToolEditHome_Test {

    @testSetup
    public static void setupTestData(){
        //Nomura_Trigger_Activation__c
        Nomura_Trigger_Activation__c externalCodeMappingActivation = new Nomura_Trigger_Activation__c();
        externalCodeMappingActivation.Name = 'ExternalCodeMappingTrigger';
        externalCodeMappingActivation.Object__c = 'External_Code_Mapping__c';
        //externalCodeMappingActivation.Active__c = TRUE;
        externalCodeMappingActivation.Active__c = FALSE;
        insert externalCodeMappingActivation;

        //Nomura_Trigger_Activation__c
        Nomura_Trigger_Activation__c topicAssignmentTriggerActivation = new Nomura_Trigger_Activation__c();
        topicAssignmentTriggerActivation.Name = 'TopicAssignmentSchTrigger';
        topicAssignmentTriggerActivation.Object__c = 'TopicAssignment';
        //topicAssignmentTriggerActivation.Active__c = TRUE;
        topicAssignmentTriggerActivation.Active__c = FALSE;
        insert topicAssignmentTriggerActivation;
        
        Account rsAccount = UtilityTesting.createRSAccount(
                'RS Test Account', 'RSTest1', '52nd Street', 'California', 'United States', true);
        insert rsAccount;
        
        Account rgAccount = UtilityTesting.createRGAccount('RG Test Account', rsAccount.Id, 'RGTest1', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rgAccount2 = UtilityTesting.createRGAccount('Gold Tier Account 1', rsAccount.Id, 'RGTest2', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount2;
        
        Account rgAccount3 = UtilityTesting.createRGAccount('Aej Account 1', rsAccount.Id, 'RGTest3', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount3;
        
        Account rgAccount4 = UtilityTesting.createRGAccount('Diamond Account 1', rsAccount.Id, 'RGTest4', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount4;
        
        Account rmAccount = UtilityTesting.createRMAccount(
                'RM Test Account', rgAccount.Id, 'RMTest1', '52nd Street', 'California', 'United States', true);
        rmAccount.Client_Type__c = 'Bank';
        insert rmAccount;
        
        List<Topic> topicList = new List<Topic>();
        
        Topic t1 = new Topic(Name = '$PS Americas Diamond Tier Test');
        topicList.add(t1);        
        Topic t2 = new Topic(Name = '$EQR Japan Gold Tier Test');
        topicList.add(t2);
        Topic t3 = new Topic(Name = '@AEJ Agnostic Test');
        topicList.add(t3);  
        Topic t4 = new Topic(Name = '@AsiaEX Agnostic Test');
        topicList.add(t4);
        Topic t5 = new Topic(Name = '$EQR Japan Platinum Tier Test');
        topicList.add(t5);
        insert topicList;
        System.debug('--topicList--' + topicList);

        External_Code_Mapping__c extMapping = new External_Code_Mapping__c(External_Mapping_Id__c = '9999', 
                                                                           External_Mapping_Type__c='SMS',
                                                                          RM_Account__c = rmAccount.Id);
        insert extMapping;
        
        List<TopicAssignment> topicAssignmentList = new List<TopicAssignment>();
        TopicAssignment ta1 = new TopicAssignment(TopicId = topicList[0].Id, EntityId =rgAccount4.Id);
        topicAssignmentList.add(ta1);
        TopicAssignment ta2 = new TopicAssignment(TopicId = topicList[1].Id, EntityId = rgAccount2.Id);
        topicAssignmentList.add(ta2);
       TopicAssignment ta3 = new TopicAssignment(TopicId = topicList[3].Id, EntityId = rgAccount3.Id);
        topicAssignmentList.add(ta3);
        insert topicAssignmentList;
        System.debug('--topicAssignmentList--' + topicAssignmentList);
       
		SCH_Request__c oSchReq;        
        oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                rgAccount.Id, 'RG1 Test Account', 
                rsAccount.Id, 'RS1 Test Account', 'US',
                true);
            
		//External code mapping
		
         
    }
   
    
    static testMethod void testAllMethods(){
        Id [] fixedSearchResultsAcc = new Id[4];
        String rsName, rsId = '';
        String rgName, rgId = '';
        String rmName, rmId = '';
        
        Id rsModificationRecordTypeId = Schema.SObjectType.Sch_Request__c.getRecordTypeInfosByDeveloperName().get('RS_Account_Attribute_Modification').getRecordTypeId();
        
        List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c FROM Account WHERE Name LIKE '%Test Account%'];

        SCH_Request__c reqObj = [SELECT Id, Name, RM_Account_Name__c FROM SCH_Request__c WHERE RM_Account_Name__c = 'Test RM Acc Name'];
        
        List<Topic> topicList = [SELECT Id, Name FROM Topic];
        System.debug('--topicList--' + topicList);
        Topic updateTopic = topicList[3];
        updateTopic.Name = '@AsiaEx Agnostic Test';
        update updateTopic;
        
        
        List<TopicAssignment> topicAssignmentList = [SELECT Id, EntityId, Entity.Name, TopicId, Topic.Name FROM TopicAssignment];
        System.debug('--topicAssignmentList--' + topicAssignmentList);
        
        External_Code_Mapping__c ext = [SELECT Id, External_Mapping_Id__c, External_Mapping_Type__c FROM External_Code_Mapping__c WHERE External_Mapping_Id__c = '9999'AND External_Mapping_Type__c='SMS'];
        
        if(accountList != null && accountList.size() > 0){
            for(Account acc : accountList){
                if(acc.RDM_Org_Id__c == 'RSTest1'){
                    fixedSearchResultsAcc[0] = acc.Id;
                    rsName = acc.Name;
                    rsId = acc.Id;
                }
                else if(acc.RDM_Org_Id__c == 'RGTest1'){
                    fixedSearchResultsAcc[1] = acc.Id;
                    rgId = acc.Id;
                	rgName = acc.Name;
            	}
                else if(acc.RDM_Org_Id__c == 'RMTest1'){
                    fixedSearchResultsAcc[2] = acc.Id;
                    rmName = acc.Name;
					rmId = acc.Id;             
            	}
            }
            fixedSearchResultsAcc[3] = reqObj.Id;
            
            
            Test.setFixedSearchResults(fixedSearchResultsAcc);
            
            Test.startTest();
            
            String rsResult = SchToolEditHome.getAccountHierarchy(rsName);
            System.assert(rsResult != null);
            
            String rgResult = SchToolEditHome.getAccountHierarchy(rgName);
            System.assert(rgResult != null);
            
            String rmResult = SchToolEditHome.getAccountHierarchy(rmName);
            System.assert(rmResult != null);
            
            Boolean checkAccName = SchToolEditHome.checkNameChange('Gold Tier Account 1', rgId, '');        
            System.debug('--checkAccName--' + checkAccName);
            System.assert(checkAccName);
            
            Boolean checkSchRMName = SchToolEditHome.checkNameChange('Test RM Acc Name', rmId, 'RMAccount');        
            System.debug('--checkSchRMName--' + checkSchRMName);
            System.assert(checkSchRMName);
            
            Boolean checkSchRGName = SchToolEditHome.checkNameChange('RG1 Test Account', rgId, 'RGAccount');        
            System.debug('--checkSchRGName--' + checkSchRGName);
            System.assert(checkSchRGName == false);
            
            Boolean checkSchRSName = SchToolEditHome.checkNameChange('RS1 Test Account', rsId, 'RSAccount');        
            System.debug('--checkSchRSName--' + checkSchRSName);
            System.assert(checkSchRSName == false);
            
            Boolean checkChildActive = SchToolEditHome.checkChildActiveRecords(rsId);        
            System.debug('--checkChildActive--' + checkChildActive);
            System.assert(checkChildActive == true);
            
            List<Priority_List__mdt> getPriorityList = SchToolEditHome.getPriorityListMetadata();
            System.debug('--getPriorityList--' + getPriorityList);
            System.assert(rmResult != null);
            
            List<LookupSearchResult> searchResult1 = SchToolEditHome.getPriorityListOptions('Global_Tiering', 'Tier');
            List<LookupSearchResult> searchResult2 = SchToolEditHome.getPriorityListOptions('Product_Focus_List', 'Agnostic');
            System.debug('--searchResul1t--' + searchResult1);
            System.assert(searchResult1 != null);
            System.assert(searchResult2 != null);
            
            Id topicId = topicList[0].Id;
            List<SchToolEditHome.AccountTopicDetails> accountPriorityList = SchToolEditHome.getAccountsWithPriorityListSelected(topicId);
            System.assert(accountPriorityList != null);
            
            List<Id> accountIds = new List<Id>{rgId, topicAssignmentList[0].EntityId};
            List<SchToolEditHome.AccountTopicDetails> priorityAccountList = SchToolEditHome.getPriorityListsWithAccountsSelected(accountIds, 'Global_Tiering');
            
            SchToolEditHome.AccountTopicDetails addAccTopic = new SchToolEditHome.AccountTopicDetails();
            SchToolEditHome.AccountTopicDetails addAccTopic2 = new SchToolEditHome.AccountTopicDetails();
            SchToolEditHome.AccountTopicDetails delAccTopic = new SchToolEditHome.AccountTopicDetails();
            SchToolEditHome.AccountTopicDetails delAccTopic2 = new SchToolEditHome.AccountTopicDetails();
            List<SchToolEditHome.AccountTopicDetails> addAccTopicList = new List<SchToolEditHome.AccountTopicDetails>();
            List<SchToolEditHome.AccountTopicDetails> addAccTopicList2 = new List<SchToolEditHome.AccountTopicDetails>();
            List<SchToolEditHome.AccountTopicDetails> delAccTopicList = new List<SchToolEditHome.AccountTopicDetails>();
            List<SchToolEditHome.AccountTopicDetails> delAccTopicList2 = new List<SchToolEditHome.AccountTopicDetails>();
            
            addAccTopic.EntityId = topicAssignmentList[1].Id;
            addAccTopic.TopicName = topicList[4].Name;
            addAccTopic.TopicId = topicList[4].Id;
            addAccTopicList.add(addAccTopic);
            
            delAccTopic.TopicAssignmentId = topicAssignmentList[0].Id;
            delAccTopicList.add(delAccTopic);
            
            String manageTopicAssignment = SchToolEditHome.manageTopicAssignment(addAccTopicList, delAccTopicList, 'Global_Tiering');
            System.assert(manageTopicAssignment == 'Success');                       
            
            addAccTopic2.EntityId = rgId;
            addAccTopic2.TopicName = topicList[3].Name;
            addAccTopic2.TopicId = topicList[3].Id;
            addAccTopicList2.add(addAccTopic2);
            
            delAccTopic2.TopicAssignmentId = topicAssignmentList[2].Id;
            delAccTopicList2.add(delAccTopic2);
            
            String manageTopicAssignment2 = SchToolEditHome.manageTopicAssignment(addAccTopicList2, delAccTopicList2, 'Product_Focus_List');
            System.assert(manageTopicAssignment2 == 'Success');        
            
            String topicCreation = SchToolEditHome.createNewTopic('$EQR Americas Gold Tier Test');
            System.assert(topicCreation == 'Success');
            
            Topic delTopic = [SELECT Id FROM Topic WHERE Name = '$EQR Americas Gold Tier Test' LIMIT 1];
            String topicDeletion = SchToolEditHome.deleteTopic(delTopic.Id);
            System.assert(topicDeletion == 'Success');
            
            SchToolEditHome.ExternalCodeAccountDetails addExtDetails = new SchToolEditHome.ExternalCodeAccountDetails();
            SchToolEditHome.ExternalCodeAccountDetails delExtDetails = new SchToolEditHome.ExternalCodeAccountDetails();
            List<SchToolEditHome.ExternalCodeAccountDetails> addExtList = new List<SchToolEditHome.ExternalCodeAccountDetails>();
            List<SchToolEditHome.ExternalCodeAccountDetails> delExtList = new List<SchToolEditHome.ExternalCodeAccountDetails>();
            
            addExtDetails.ExternalCodeMappingId = '1234';
            addExtDetails.MappingType = 'CCP';
            addExtDetails.AccountId = rmId;            
            addExtList.add(addExtDetails);
            
            delExtDetails.ExternalCodeId= ext.Id;
            delExtList.add(delExtDetails);
            
            String extCodeMapping = SchToolEditHome.manageExternalCodeMapping(addExtList, delExtList);
            //System.assert(extCodeMapping == 'Success');
            
            String rmMappingIds = SchToolEditHome.getRMExternalMappingCodes(rmId);
            //System.assert(rmMappingIds != null);
            
            String mappingIdType = SchToolEditHome.checkAccountMappingData(ext.External_Mapping_Type__c, ext.External_Mapping_Id__c);
            //System.assert(mappingIdType != null);
            
            List<SCH_Request__c> addSchRequestList = new List<SCH_Request__c>();            
            SCH_Request__c schRequest = new SCH_Request__c(RS_Account__c = rsId, New_RS_Account_Name__c = rsName + ' NameChange', RecordTypeId = rsModificationRecordTypeId);
            addSchRequestList.add(schRequest);
            String saveSch = SchToolEditHome.saveSCHRequest(addSchRequestList);
			//System.assert(saveSch == 'Success');
            
            
            
            
            Test.stopTest();
        }
    
    }
}