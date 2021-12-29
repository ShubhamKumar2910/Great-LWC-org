global class CrossSellReferralOpptyUpdatesForCRBatch implements Database.Batchable<sObject>,Database.Stateful {
    //Important Execute this batch taking Batch size as 1
    
    global List<Opportunity> errorUpdateList;
    global String clientType;
    
    class OpportunityWrapper implements Comparable {
        public Opportunity oppty;
        
        public OpportunityWrapper(Opportunity opptyObj){
            oppty = opptyObj;
        }
        
        public Integer compareTo(Object compareTo){
            OpportunityWrapper compareToOppty = (OpportunityWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (oppty.CloseDate > compareToOppty.oppty.CloseDate) {
                returnValue = 1;
            } else if (oppty.CloseDate < compareToOppty.oppty.CloseDate) {
                returnValue = -1;
            }
            return returnValue;      
        }
    }
    
    global CrossSellReferralOpptyUpdatesForCRBatch(String strClientType){
    	errorUpdateList = new List<Opportunity>();
        clientType = strClientType;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String clientTypeCondition = '';
        String orderByCondition = '';
        
        if('RM'.equalsIgnoreCase(clientType)){
            clientTypeCondition = ' RM_ACTION__c IN (\'MERGE\',\'MOVE\',\'MERGE AND MOVE\') ';
            orderByCondition = ' ORDER BY NEW_RM__c ';
        }
        else if('RG'.equalsIgnoreCase(clientType)){
            clientTypeCondition = ' RG_ACTION__c IN (\'MERGE\',\'MOVE\') ';
            orderByCondition = ' ORDER BY NEW_RG__c ';
        }
        
        String query = 'SELECT RG_ACTION__c, RM_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE ' + clientTypeCondition + orderByCondition;
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
       List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        
       if('RG'.equalsIgnoreCase(clientType)){
            handleForRG(clientRemediationList);
       }
       
        
    }
    
    global void handleForRG(List<Client_Remediation__c> clientRemediationList){
         Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        
         if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && 
                   crObj.NEW_RG_Account__c != null &&
                  !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                   oldNewIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG_Account__c);    
                }
            }
            
            if(oldNewIdMap.size() > 0){
                //Cross Sell Opportunities
                processCrossSellReferralOpportunities(oldNewIdMap);
            }
        }
    }
    
    global void processCrossSellReferralOpportunities(Map<Id,Id> oldNewIdMap){
        List<Id> newRGAccountIdList = new List<Id>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();
        List<Opportunity> opportunityListForOld = new List<Opportunity>();
        List<Opportunity> opportunityListForNew = new List<Opportunity>();
        Map<String,List<Opportunity>> oldRGOpptyMap = new Map<String,List<Opportunity>>();
        Map<String,List<Opportunity>> newRGOpptyMap = new Map<String,List<Opportunity>>();
        
        //Fetch Cross Sell Referral opportunities associated with old RG
        opportunityListForOld = [SELECT Id, Name, AccountId, Account.RDM_Org_Id__c, 
                                 Account__c, Account__r.RDM_Org_Id__c, ProductVal__c, Referral_Sales_Code__c,
                                 Active__c, No_Trade_in_six_months__c, CloseDate
                                 FROM Opportunity 
                                 WHERE AccountId IN :oldNewIdMap.keySet() AND
                                 SystemAuto_Type__c = null AND
                                 RecordType.DeveloperName = 'Cross_Sell_Referral' AND
                                 IsWon = TRUE AND IsClosed = TRUE];
        
        if(opportunityListForOld.size() > 0 && oldNewIdMap != null){
            
            for(Id oldRGId : oldNewIdMap.keySet()){
                if(oldNewIdMap.get(oldRGId) != null){
                    newRGAccountIdList.add(oldNewIdMap.get(oldRGId));
                }
            }
            
            //Fetch Cross Sell Referral opportunities associated with new RG
            if(newRGAccountIdList.size() > 0){
                opportunityListForNew = 
                    [SELECT Id, Name, AccountId, Account.RDM_Org_Id__c, 
                     Account__c, Account__r.RDM_Org_Id__c, ProductVal__c, Referral_Sales_Code__c,
                     Active__c, No_Trade_in_six_months__c, CloseDate
                     FROM Opportunity 
                     WHERE AccountId IN :newRGAccountIdList AND
                     SystemAuto_Type__c = null AND
                     RecordType.DeveloperName = 'Cross_Sell_Referral' AND 
                     IsWon = TRUE AND IsClosed = TRUE];
            }
            
            //Form Data for Opportunities corresponding to Old RG
            for(Integer i = 0; i<opportunityListForOld.size(); i++){
               Opportunity opptyObj = opportunityListForOld.get(i);
               String opptyKey =  opptyObj.ProductVal__c + '#' + opptyObj.Referral_Sales_Code__c;
               List<Opportunity> opptyList = oldRGOpptyMap.containsKey(opptyKey) ? oldRGOpptyMap.get(opptyKey) : new List<Opportunity>() ;
               opptyList.add(opptyObj);
               oldRGOpptyMap.put(opptyKey, opptyList);
            }
            
            //Form Data for Opportunities corresponding to New RG
            for(Integer i = 0; i<opportunityListForNew.size(); i++){
               Opportunity opptyObj = opportunityListForNew.get(i);
               String opptyKey =  opptyObj.ProductVal__c + '#' + opptyObj.Referral_Sales_Code__c;
               List<Opportunity> opptyList = newRGOpptyMap.containsKey(opptyKey) ? newRGOpptyMap.get(opptyKey) : new List<Opportunity>() ;
               opptyList.add(opptyObj);
               newRGOpptyMap.put(opptyKey, opptyList);
            }
            
            //For each opportunity associated with old RG, check whether opportunity exists with new RG
            if(oldRGOpptyMap.size() > 0){
                for(String opptyKey : oldRGOpptyMap.keySet()){
                    if(newRGOpptyMap.containsKey(opptyKey)){
                        List<Opportunity> oldRGOpptyList = new List<Opportunity>();
                        List<Opportunity> newRGOpptyList = newRGOpptyMap.get(opptyKey);
                        List<Opportunity> combinedOpptyList = new List<Opportunity>();
                        List<OpportunityWrapper> opptyWrapperList = new List<OpportunityWrapper>();
                        Set<Opportunity> tempUpdateOpptyList = new Set<Opportunity>();
                        
                        //Modify the old list for Account Id
                        for(Opportunity opptyObj : oldRGOpptyMap.get(opptyKey)){
                            Id recordId = oldNewIdMap.get(opptyObj.AccountId);
                        
                        	opptyObj.AccountId = recordId;
                        	opptyObj.Account__c = recordId;
                        	oldRGOpptyList.add(opptyObj);
                        }
                        
                        //Combine both lists
                        combinedOpptyList.addAll(oldRGOpptyList);
                        combinedOpptyList.addAll(newRGOpptyList);
                        
                        for(Opportunity opptyObj : combinedOpptyList){
                            opptyWrapperList.add(new OpportunityWrapper(opptyObj));
                        }
                        
                        //Sort the opptyWrapperList (based on CloseDate)
                        opptyWrapperList.sort();
                        
                        Opportunity baseOppty = null;
                        
                        //Take first opportunity as base opportunity
                        if(opptyWrapperList != null && opptyWrapperList.size() > 0){
                            baseOppty = opptyWrapperList.get(0).oppty;
                        }
                        
                        for(Integer i = 1; i<opptyWrapperList.size(); i++){
                            Opportunity oppty = opptyWrapperList.get(i).oppty;
                            
                            Date baseOpptyCloseDate = baseOppty.CloseDate;
                            Date baseOpptyEndDate = (baseOpptyCloseDate.addYears(1)).addDays(-1);
                            
                            if(oppty.CloseDate < baseOpptyEndDate){
                                oppty.StageName = 'Invalidated';
                                tempUpdateOpptyList.add(oppty);
                            }
                            else if(oppty.CloseDate > baseOpptyEndDate){
                                if(oldRGOpptyList.contains(baseOppty)){
                                	tempUpdateOpptyList.add(baseOppty);
                                }
                                baseOppty = oppty;
                            }
                            //Keep it as it is
                            else { //Only Change the Account Id with new RG Id if it is from Old RG Id
                                if(oldRGOpptyList.contains(oppty)){
                                    tempUpdateOpptyList.add(oppty);
                                }
                            }
                        }
                        
                        if(baseOppty != null){
                            if(oldRGOpptyList.contains(baseOppty)){
                            	tempUpdateOpptyList.add(baseOppty);
                            }
                        }
                        
                        //Adding set to List
                        updateOpptyList.addAll(tempUpdateOpptyList);
                    }
                    else {
                        List<Opportunity> opptyList = oldRGOpptyMap.get(opptyKey);
                        for(Opportunity opptyObj : opptyList){
                            Id recordId = oldNewIdMap.get(opptyObj.AccountId);
                        
                        	opptyObj.AccountId = recordId;
                        	opptyObj.Account__c = recordId;
                        	updateOpptyList.add(opptyObj);
                        }
                    }
                }
            }
            
            //Update Opportunities
            if(updateOpptyList.size() > 0){
                updateOpportunities(updateOpptyList);
            }
            
        }
                
        
    }
    
    global void finish(Database.BatchableContext bc){
    	String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorUpdateList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Cross Sell Referral Opportunity Updates For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateOpportunities(List<Opportunity> opportunityList){
        if(opportunityList != null && opportunityList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(opportunityList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Opportunity Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(opportunityList.get(i));
                }
            }
        }
    }
    
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Opportunity Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Opportunity records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Opportunity Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Opportunity opptyObj : errorUpdateList){
                String opptyDetails = 'Id : ' + opptyObj.Id + ' Name : ' + opptyObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + opptyDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
       
        return emailBody;
    }

}