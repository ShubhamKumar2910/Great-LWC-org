global class CallReportNotifyToSymphonyBatch implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts{

    global String currentTimeStamp = '';
    global String lastExtractTimeStamp = '';
    global final String CONFIG_NAME = 'Call_Report_Notification_To_Symphony';
    global final String PARAM_NAME = 'LastUpdatedTimeStamp';
    global final String SOURCE_NAME = 'SymphonyBatch';
    global String toEmailAddress = '';
    global Boolean isSandbox = true;
    
    public CallReportNotifyToSymphonyBatch (){        
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> typeSet = new Set<String>();
        lastExtractTimeStamp = CommonTools.getParameterValueFromConfiguration(CONFIG_NAME,PARAM_NAME,true);

        currentTimeStamp = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        
        isSandbox = CommonTools.runningInASandbox();
        
        String symphonyEmailQuery = 'SELECT Sandbox_Email_Address__c,Production_Email_Address__c FROM CallReport_Notification_Settings__mdt'+
        ' WHERE DeveloperName = \'Symphony_Email\' AND Type__c = \'Send Notification to Symphony\'';
        CallReport_Notification_Settings__mdt emailAdd = Database.query(symphonyEmailQuery);

        if(isSandbox){
           toEmailAddress =  emailAdd.Sandbox_Email_Address__c;
        }else{
            toEmailAddress =  emailAdd.Production_Email_Address__c;
        }
        
        //Fetch Types to be considered
        List<L1_Event_Type_Setting__mdt> typeL1List = [SELECT Label FROM L1_Event_Type_Setting__mdt 
                                                       WHERE Available_for_Symphony_BOT_Notification__c = true AND Active__c = true];
        if(typeL1List != null && typeL1List.size() > 0){
            for(L1_Event_Type_Setting__mdt eventType : typeL1List){
                typeSet.add(eventType.Label);
            }
        }
        
		String query = 'SELECT Id,What.Name FROM Event WHERE createdDate >= '+ lastExtractTimeStamp +' AND createdDate < '+ currentTimeStamp +
        ' AND IsChild = false AND Type IN :typeSet '+
        ' AND RecordType.DeveloperName IN (\'Standard_Event\',\'CP_Event_Integration\') AND What.Type = \'Account\''+
        ' AND WhatId IN (SELECT Id FROM Account WHERE RecordType.DeveloperName = \'RG_Account\''+ 
        ' AND (Symphony_Room_Id__c <> null or Symphony_Room_Id__c <> \'\')) ORDER BY CreatedDate ASC';
        System.debug('Query: '+query);
        return Database.getQueryLocator(query);
    }   

    global void execute(Database.BatchableContext bc, List<Event> eventList){
        for(Event event : eventList){
            List<UserDetails> usrdtlList = new List<UserDetails>();
            UserDetails usrdtl = new UserDetails();
            usrdtl.Name = event.What.Name;
            usrdtl.Id = event.Id;
            usrdtl.Email = toEmailAddress;
            usrdtl.UserType = 'Invitee';
            usrdtl.Source = SOURCE_NAME;
            usrdtlList.add(usrdtl);
            System.debug('User Detail: '+usrdtl);
            String sJSONOutput = JSON.serialize(usrdtlList);          
            SendEventController.sendEmailCmp(event.Id, sJSONOutput);
        }
    }

    global void finish(Database.BatchableContext bc){
        String batchName = null;
        String emailBody = null;
        String subject = '';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];

        if(apexJob != null && apexJob.NumberOfErrors > 0 ){
            /* If Apex Batch fails then email will be sent out */
            subject = 'SF - Call Report Notification to Symphony Batch - Failed';
            emailBody = getEmailBody(apexJob);
            batchName = 'CallReportNotifyToSymphonyBatch';
            CommonTools.emailLog(subject, batchName, emailBody, null, null);
        }
        else{
            CommonTools.updateParameterValueInConfiguration(CONFIG_NAME,PARAM_NAME,currentTimeStamp);            
        }
    }

    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = 'The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s).';
                
        return emailBody;
    }
}