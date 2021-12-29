@isTest
public class TopicAssignmentTriggerBL_Test {
	
    @testSetUp
    public static void testSetupForTopicAssignment(){        
        
        Id recordTypeIdForRG = CommonTools.getRecordTypeId('Account','RG Account');
		Id recordTypeIdForRM = CommonTools.getRecordTypeId('Account','RM Account');
        
        Account account = new Account(); 
        account.Name = 'RG_Account_Dummy';
        account.RDM_Org_ID__c = 'RGXXXXXX';            
        account.RecordTypeId = recordTypeIdForRG;
        account.Active__c = TRUE;         
        insert account;
        
        //Creating Opportunity Data
        List<Opportunity> opptyList = new List<Opportunity>();
        Opportunity opptyObj1 = new Opportunity();
        opptyObj1.Name='TestOppo1';
        opptyObj1.Account__c=account.Id;
        opptyObj1.CloseDate=DATE.today();
        opptyObj1.StageName='Closed Won';
        opptyList.add(opptyObj1);
        
        Opportunity opptyObj2 = new Opportunity();
        opptyObj2.Name='TestOppo2';
        opptyObj2.Account__c=account.Id;
        opptyObj2.CloseDate=DATE.today();
        opptyObj2.StageName='Closed Won';
        opptyList.add(opptyObj2);
        
        insert opptyList;

        //Creating Legal Agreement Data
        List<Legal_Agreement__c> dlList = new List<Legal_Agreement__c>();
        Legal_Agreement__c dlObj1 = new Legal_Agreement__c();
        dlObj1.Agreement_Type__c = 'test';
        dlList.add(dlObj1);

        Legal_Agreement__c dlObj2 = new Legal_Agreement__c();
        dlObj2.Agreement_Type__c = 'test1';
        dlList.add(dlObj2);

        insert dlList;
               
        //Creating Topic Data       
        List<Topic> topicList = new List<Topic>();
        Topic topicObj1 = new Topic();
        topicObj1.Name='TestXX_TopicXX_1';
        topicList.add(topicObj1);
        
        Topic topicObj2 = new Topic();
        topicObj2.Name='TestXX_TopicXX_2';
        topicList.add(topicObj2);
        
        Topic topicObj3 = new Topic();
        topicObj3.Name='TestXX_TopicXX_3';
        topicList.add(topicObj3);
        
        insert topicList;
        
        Topic[] topicIdArray = [SELECT Id FROM Topic WHERE Name LIKE '%TestXX_TopicXX%'];
        Opportunity[] OpportunityIdArray = [SELECT Id FROM Opportunity WHERE Name LIKE '%TestOppo%'];
        Legal_Agreement__c[] LegalAgreementIdArray = [SELECT Id FROM Legal_Agreement__c WHERE Agreement_Type__c LIKE '%test%'];

        //Creating TopicAssignment Data
        List<TopicAssignment> topicAssignmentList = new List<TopicAssignment>();
        TopicAssignment topicAssgObj0 = new TopicAssignment();
        topicAssgObj0.TopicId = topicIdArray[1].Id;
        topicAssgObj0.EntityId = LegalAgreementIdArray[0].Id;
        topicAssignmentList.add(topicAssgObj0);

        TopicAssignment topicAssgObj1 = new TopicAssignment();
        topicAssgObj1.TopicId=topicIdArray[0].Id;
        topicAssgObj1.EntityId=OpportunityIdArray[0].Id;        
        topicAssignmentList.add(topicAssgObj1);
                
        TopicAssignment topicAssgObj2 = new TopicAssignment();
        topicAssgObj2.TopicId=topicIdArray[1].Id;
        topicAssgObj2.EntityId=OpportunityIdArray[0].Id;        
        topicAssignmentList.add(topicAssgObj2);
        
        TopicAssignment topicAssgObj3 = new TopicAssignment();
        topicAssgObj3.TopicId=topicIdArray[1].Id;
        topicAssgObj3.EntityId=OpportunityIdArray[1].Id;        
        topicAssignmentList.add(topicAssgObj3);
        
        TopicAssignment topicAssgObj4 = new TopicAssignment();
        topicAssgObj4.TopicId=topicIdArray[2].Id;
        topicAssgObj4.EntityId=OpportunityIdArray[1].Id;        
        topicAssignmentList.add(topicAssgObj4);

        TopicAssignment topicAssgObj5 = new TopicAssignment();
        topicAssgObj5.TopicId = topicIdArray[0].Id;
        topicAssgObj5.EntityId = account.Id;
        topicAssignmentList.add(topicAssgObj5);

        TopicAssignment topicAssgObj6 = new TopicAssignment();
        topicAssgObj6.TopicId = topicIdArray[1].Id;
        topicAssgObj6.EntityId = account.Id;
        topicAssignmentList.add(topicAssgObj6);

        insert topicAssignmentList;
    }
    
    // Test for removeOpportunitytopics
    static testMethod void removeOpportunityTopics(){
       	Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([SELECT Id, Name, Topics__c FROM Opportunity 
                                                                WHERE Account__r.RDM_Org_Id__c = 'RGXXXXXX']);
        
        Map<Id,Topic> topicMap = new Map<Id,Topic>([SELECT Id, Name FROM Topic WHERE Name LIKE 'TestXX_TopicXX%']);
        
        if(opptyMap != null && !opptyMap.isEmpty() && topicMap != null && !topicMap.isEmpty()){
        
            List<TopicAssignment> topicAssignmentList = [SELECT Id, TopicId, EntityId, EntityKeyPrefix, EntityType, CreatedDate, 
                                               CreatedById, IsDeleted, SystemModstamp FROM TopicAssignment 
                                               WHERE TopicId IN :topicMap.keySet() AND 
                                               EntityId IN :opptyMap.keySet() AND
                                               EntityType = 'Opportunity'];
            
            if(topicAssignmentList != null && !topicAssignmentList.isEmpty()){
            	delete topicAssignmentList;
                
                Map<Id,Opportunity> opptyMapAfterDelete = new Map<Id,Opportunity>(
                    [SELECT Id, Name, Topics__c FROM Opportunity 
                     WHERE Account__r.RDM_Org_Id__c = 'RGXXXXXX']);
                
                if(opptyMapAfterDelete != null && !opptyMapAfterDelete.isEmpty()){
                    for(Id opptyId : opptyMapAfterDelete.keySet()){
                        Opportunity opptyObj = opptyMapAfterDelete.get(opptyId);
                        if(opptyObj != null){
                            System.assert(opptyObj.Topics__c == null || opptyObj.Topics__c == '');
                        }
                    }                    
                }
            }
        }
    }  
    
    static testMethod void addOpportunityTopics(){
        List<TopicAssignment> topicAssignmentList = [SELECT Id,Topic.Name FROM TopicAssignment 
                                                   WHERE Entity.Name = 'TestOppo2' AND EntityType = 'Opportunity'];
        
        String topicNames;
        for(TopicAssignment topicAssign : topicAssignmentList){
            topicNames = topicNames == null ? 
                				topicAssign.Topic.Name : topicNames + ';' + topicAssign.Topic.Name;
        }
        
        List<Opportunity> opportunityList = [SELECT Topics__c FROM Opportunity WHERE Name = 'TestOppo2'];
        String opptyTopicName = opportunityList[0].Topics__c;
        
        System.assertEquals(topicNames, opptyTopicName);        
    }

    static testMethod void addAccountTopics(){
        List<TopicAssignment> topicAssignmentList = [SELECT    Id,Topic.Name FROM TopicAssignment
                                                     WHERE     Entity.Name = 'RG_Account_Dummy' AND EntityType = 'Account'];

        String topicNames;

        for(TopicAssignment topicAssign : topicAssignmentList){
            topicNames = topicNames == null ?
                    topicAssign.Topic.Name : topicNames + ';' + topicAssign.Topic.Name;
        }

        List<Account> accountList = [SELECT Topics__c FROM Account WHERE Name = 'RG_Account_Dummy'];

        System.assertEquals(topicNames, accountList[0].Topics__c, 'Topics values on topic assignment and account object do not match');
    }

    static testMethod void removeAccountTopics(){
        List<Account> accountListWithTopics = [SELECT Topics__c FROM Account WHERE Name = 'RG_Account_Dummy'];

        System.assert(accountListWithTopics[0].Topics__c != null, 'Existing topics__c field value on account cannot be empty');

        List<TopicAssignment> topicAssignmentList = [SELECT Id FROM TopicAssignment
                                                     WHERE  EntityType = 'Account'];

        delete topicAssignmentList;

        accountListWithTopics = [SELECT Topics__c FROM Account WHERE Name = 'RG_Account_Dummy'];

        System.assert(accountListWithTopics[0].Topics__c == null, 'Account topics__c field value should be empty following deletion of all topic assignments');
    }

    static testMethod void validateLegalAgreementTopicAssignment()
    {
        List<TopicAssignment> topicAssignmentList = [SELECT Id,EntityId,TopicId,EntityType FROM TopicAssignment
                                                     WHERE  EntityType = 'Legal_Agreement'];
        TopicAssignmentTriggerBL.validateTopicAssignment(topicAssignmentList);

        /* Testing with other user */
        User otherUser = [SELECT Id FROM User WHERE Login_Id__c = 'sfadmin' Limit 1];
        System.runAs(otherUser) {
            TopicAssignmentTriggerBL.validateTopicAssignment(topicAssignmentList);
        }
    }

    static testMethod void validateLegalAgreementTopicAssignmentDeletion()
    {
        List<TopicAssignment> topicAssignmentList = [SELECT Id,EntityId,TopicId,EntityType FROM TopicAssignment
                                                     WHERE  EntityType = 'Legal_Agreement'];
        TopicAssignmentTriggerBL.validateTopicAssignmentDeletion(topicAssignmentList);
        
        /* Testing with other user */
        User otherUser = [SELECT Id FROM User WHERE Login_Id__c = 'sfadmin' Limit 1];
        System.runAs(otherUser) {
            TopicAssignmentTriggerBL.validateTopicAssignmentDeletion(topicAssignmentList);
        }
    }
}