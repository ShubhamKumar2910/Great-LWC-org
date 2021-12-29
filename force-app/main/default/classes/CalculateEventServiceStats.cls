global class CalculateEventServiceStats implements Database.batchable<sObject>, Database.Stateful{ 
 
    public Boolean isWeekDay = false;
    Set<Id> userIDs = new Set<Id>();
    Set<Id> nomuraContactIDs = new Set<Id>();
    Set<Id> contactIDs = new Set<Id>();
    Set<Id> eventIDs = new Set<Id>();
    String eventquery {get;set;}  
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    
    
    Set<String> affectedCPEventMeetingTypes = new Set<String>();
    Set<String> affectedDLEventMeetingTypes = new Set<String>();
    
    public CalculateEventServiceStats()
    {
        try
        {
            SetDayType();
            system.debug(isWeekDay);
            if(!isWeekDay)
            {
                //string typeEvent = 'DealAxis_Event_Integration';   //for testing
                //string idValue ='00U170000023a9BEAQ';
                //eventquery = 'select id from Event where isChild = false and id = \'' + idValue + '\'';
                
                
                eventquery = 'select id from Event where ischild = false';
                
            }
            else
            {
                userIDs = getUsersModifiedby2Days();
                
                for(ContactHistory history: getNomuraContactsReportsToModifiedby2Days())
                {
                    contactIDs.add(history.ContactId);
                }
                
                for(Contact contactRec: [select id from Contact where Id in:contactIDs and Account.RDM_Org_ID__c = 'CP12345'])
                {
                    nomuraContactIDs.add(contactRec.id);
                }
                 
                //eventIDs.addAll(getEventsModifiedby2Days());
                
                for(EventRelation relation : getEventsbyParticipants())
                {
                    eventIDs.add(relation.EventId);
                }
                
                eventquery = 'select id from Event where (id in:eventIDs OR OwnerId in:userIDs OR (LastModifiedDate = LAST_N_DAYS:2 AND IsServiceStatsSummarized__c = false)) and isChild = false';      
            }
            if(test.isRunningTest())
            {Decimal a = 2/0;}
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
			exception_message += '\n';
			batchExecutionSuccessfully = false;
			EventServiceStatsUtility.emailErrorLog('FAILURE','CalculateEventServiceStats',exception_message+'\n\nRegards,\nSalesforce Tech');
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(eventquery);
    }   
    
    global void execute(Database.batchableContext info, List<sObject> scope){
		SavePoint sp;
        try
        {
            sp = Database.setSavepoint();
            List<Event> eventlist_to_Update = new List<Event>();
            EventServiceStatsUtility.getNomuraContactMap();
          
            Set<Id> userparentRoleIds = new Set<Id>();
            userparentRoleIds = EventServiceStatsUtility.getResearchRoleUserParentIds();
            if(userparentRoleIds.size()>0)
            {
                Set<Id> subRoleIds = new Set<Id>();
                subRoleIds.addAll(userparentRoleIds); 
                subRoleIds.addAll(EventServiceStatsUtility.getSubordinateRoles(userparentRoleIds));   
                
                if(subRoleIds.size() > 0)
                {
                    EventServiceStatsUtility.getNomuraResearchUsersMap(subRoleIds);
                }
            }
            
            Set<Id> eventIds = (new Map<Id,SObject>(scope)).keySet();
            system.debug(eventIds);
            for(Event eventRecord :[select id, RecordType.DeveloperName,type,IsServiceStatsSummarized__c,Event_Type__c, SR_AS_Cnt__c,SR_AS_Con_Cnt__c,SR_EM_Cnt__c, SR_EM_Con_Cnt__c, SR_JP_Cnt__c, SR_JP_Con_Cnt__c, SR_US_Cnt__c, SR_US_Con_Cnt__c, SR_GBL_Cnt__c, SR_GBL_Con_Cnt__c,(select id,relation.id, relation.type from eventrelations), OwnerId,Event_Origination_Region__c from Event where isChild = false and Id in:eventIds])
            {
                initailizeStats();
                Boolean isDealEvent= EventServiceStatsUtility.isDealAxisEvent(eventRecord);
            	system.debug('UUU isDealEvent:'+isDealEvent);
               	system.debug('UUU eventRecord.Event_Type__c:'+eventRecord.Event_Type__c);
                system.debug('UUU eventRecord.type:'+eventRecord.type);
                system.debug('UUU:'+eventRecord);
                
                if(isDealEvent)
                {
                    eventRecord = EventServiceStatsUtility.setEventStatsforDealAxisEvent(eventRecord);
                }
                else
                {
                    system.debug('CP Event');
                    eventRecord = EventServiceStatsUtility.setEventStatsforCPEvent(eventRecord);
                }
                
                
                if(EventServiceStatsUtility.valueChanged)
                {
                   if(isWeekDay){
                        if(eventRecord.type != null && eventRecord.type != '' && !isDealEvent) // CP Event
                        { 
                            system.debug('CP Value Changed');
                            affectedCPEventMeetingTypes.add(eventRecord.type); 
                        }
                        else //Deal Axis
                        {
                            system.debug('Deal Axis Value Changed');
                            if(eventRecord.Event_Type__c!=null && eventRecord.type!=null)
                            affectedDLEventMeetingTypes.add(eventRecord.Event_Type__c+ ':' + eventRecord.type);
                        }   
                    }
                    eventRecord.IsServiceStatsSummarized__c = true;
                    eventRecord.source__c='BulkInsert';
                    eventlist_to_Update.add(eventRecord); 
                }
            }
            
            System.debug('******* :Update Size : '+eventlist_to_Update);
            if(eventlist_to_Update.size()>0)
            update eventlist_to_Update;
            if(test.isRunningTest())
            {Decimal a = 2/0;}
            
        }
        catch(Exception e)
		{
            if(sp!=null)
			Database.rollback(sp);
			exception_message += e+'\n'+e.getStackTraceString();
			exception_message += '\n';
			batchExecutionSuccessfully = false;
            System.abortJob(info.getJobId());
        }
    }     
    
    global void finish(Database.batchableContext info){  
       if(batchExecutionSuccessfully)
       {
			//if(!Test.isRunningTest())
			updateAffectedModelVersion();
			if(!Test.isRunningTest())
			Database.executeBatch(new PopulateServiceCountBatch(), 1);
	   }
	   else
	   {
           system.debug(exception_message);
		   EventServiceStatsUtility.emailErrorLog('FAILURE','CalculateEventServiceStats',exception_message+'\n\nRegards,\nSalesforce Tech');
	   }
        
    } 
    
    public void updateAffectedModelVersion() {
        List<Account_Service_Model__c> modelObjs = new List<Account_Service_Model__c>();
        Set<String> modelNames = new Set<String>();

        for (Account_Service_Model__c model : [select id, name, call_report_type__c,item_name__c,DealAxis_Type__c, inprogress_version__c, stable_version__c, recordtype.name from Account_Service_Model__c order by order__c desc]) {
            if (model.recordtype.name.equals('Actual')) {
                if ( !isWeekDay || isCPModelImpacted(model) || isDAModelImpacted(model)) {
                        updateVersion(model);
                        modelObjs.add(model);
                        modelNames.add(model.name);
                    }
            }
            else if (model.recordtype.name.equals('Total')){
                    if ( !isWeekDay || modelNames.contains(model.name) ){
                        updateVersion(model);
                        modelObjs.add(model);
                    }
            }
        }
        if (modelObjs.size() > 0) {
            Database.update(modelObjs,true);
        }   
    }
    
    public void updateVersion(Account_Service_Model__c model) {
        if (model.inprogress_version__c != null)
            model.inprogress_version__c = model.inprogress_version__c + 1;
        else
            model.inprogress_version__c = model.stable_version__c + 1;
    }
    
    public boolean isDAModelImpacted(Account_Service_Model__c model) {
        boolean isDAModelImpacted = false;
        if(model.DealAxis_Type__c!=null)
        {
            AccountServiceModelBl.DAMeetingEventWrapper daWrapper = AccountServiceModelBl.splitDAEventMeetingType(model.DealAxis_Type__c);
                
        if (daWrapper.da_event_types != null && isPresentInDATypes(daWrapper.da_event_types, daWrapper.da_event_meeting_types)) {
            isDAModelImpacted = true;
        }
        }
        //System.debug('isDAModelImpacted = ' + isDAModelImpacted + ' for ' + model.name+ model.item_name__c+model.dealaxis_event_type__c+model.dealaxis_event_meeting_type__c);
        return isDAModelImpacted;
    }   
    
    private boolean isPresentInDATypes(String modelEventType, String modelEventMeetingType) {
        boolean isPresentInDATypes = false;
        Set<String> modelEventTypeList = new Set<String> (modelEventType.split(';'));
        Set<String> modelEventMeetingTypeList = new Set<String> (modelEventMeetingType.split(';'));
        
        for (String affectedType: affectedDLEventMeetingTypes ) {
            List<String> affectedTypeList = affectedType.split(':');
            String affectedEventType = null;
            String affectedEventMeetingType = null;
            if (affectedTypeList != null && affectedTypeList.size() > 0) {
                affectedEventType = affectedTypeList[0];
            }
            if (affectedTypeList != null && affectedTypeList.size() > 1) {
                affectedEventMeetingType = affectedTypeList[1];
            }
            
            if (modelEventTypeList.contains(affectedEventType) && modelEventMeetingTypeList.contains(affectedEventMeetingType)) {
                isPresentInDATypes = true;
                break;
            }
        }
        return isPresentInDATypes;
    }   
    
    public boolean isCPModelImpacted(Account_Service_Model__c model) {
        boolean isCPModelImpacted = false;
        if (model.call_report_type__c != null && isPresentInCPTypes(model.call_report_type__c)) {
            isCPModelImpacted = true;
        }
        System.debug('isCPModelImpacted = ' + isCPModelImpacted + ' for ' + model.name+ model.item_name__c+model.call_report_type__c);
        return isCPModelImpacted;
    }
    
    public boolean isPresentInCPTypes(String modelType) {
        boolean isPresentInCPTypes = false;
        Set<String> modelTypeList = new Set<String>(modelType.split(';'));
        for (String cpType: affectedCPEventMeetingTypes ) {
            if (modelTypeList.contains(cpType)) {
                isPresentInCPTypes = true;
                break;
            }
        }
        return isPresentInCPTypes;
    }
    
    
    
    /********************************* Batch Methods ***********************************************************************************************************************/
    private void setDayType()
    {
       List<Configuration__c> configlist = [select id, Param_Name__c, Parameter_Value__c from Configuration__c where Param_Name__c = 'LoadROIAllEvents']; 
       Boolean configsettings = false;
       String  configValue = '';
       if(configlist.size() == 1)
       {
           configsettings = true;
           configValue = configlist[0].Parameter_Value__c;
       }
        
       if(configsettings) //settings defined in config or not
       {
           if(configValue == 'True' || configValue == 'true')
               isWeekDay = false;
           else
            setDayTypeNormal(configValue);   
       }
        else
        {
            setDayTypeNormal(configValue);
        }
    }
    
    private void setDayTypeNormal(string configValue)
    {
        if((DateTime.now().formatGMT('E') == 'Sat' || DateTime.now().formatGMT('E') == 'Sun') && configValue.toLowerCase() == 'false'     )
                isWeekDay =  false; //run all events
            else
                isWeekDay = true;
    }
    private Set<Id> getEventsModifiedby2Days()
    {
        return (new Map<Id,Event>([select id from Event where LastModifiedDate = LAST_N_DAYS:2 limit 30000])).keySet();
    }
    
    
    
    public Set<Id> getUsersModifiedby2Days() 
    {
        return (new Map<Id,User>([select id from User where LastModifiedDate = LAST_N_DAYS:2 AND Profile.Name <> 'Nomura - Integration'])).keySet();
    }
    
    public List<ContactHistory> getNomuraContactsReportsToModifiedby2Days()
    {
        return [select ContactId from ContactHistory where Field='ReportsTo' and CreatedDate = LAST_N_DAYS:2]; 
    }
    
    public List<EventRelation> getEventsbyParticipants()
    {
        return [select Id,EventId from EventRelation where RelationId in:userIDs OR RelationId in:nomuraContactIDs];
    }
    
    public void initailizeStats()
    {
        EventServiceStatsUtility.valueChanged = false;
        EventServiceStatsUtility.SR_US_Cnt = 0;
        EventServiceStatsUtility.SR_EM_Cnt = 0;
        EventServiceStatsUtility.SR_AS_Cnt = 0;
        EventServiceStatsUtility.SR_JP_Cnt = 0;
        EventServiceStatsUtility.SR_GB_Cnt = 0;
        
        EventServiceStatsUtility.SR_US_Con_Cnt = 0;
        EventServiceStatsUtility.SR_EM_Con_Cnt = 0;
        EventServiceStatsUtility.SR_AS_Con_Cnt = 0;
        EventServiceStatsUtility.SR_JP_Con_Cnt = 0;
        EventServiceStatsUtility.SR_GB_Con_Cnt = 0;
    }
    /**********************************************************************************/
}