/**
 * @Description: Business Logic/Util class for the Event Trigger
 *
 * Change Log
 *
 * Date         Author          Change Description
 * ---------------------------------------------------------------------------------------------------------------------------------
 * 05/05/2017   T.Sotiraki      Bulkified updates to EventRelations in validateNomuraWhoId method for Too Many DML Exception Error
 */
public class EventTriggerBL {
    private static final String NOMURA_RDM_ORG_ID = 'CPG12345';
    private static final String SOURCE_INSTINET_FEED = 'Instinet Feed';
    private static final String SOURCE_INSTINET = 'Instinet';

    public static User userObj {
        public get {
            if(userObj==null) {
                userObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];   
            }
            return userObj;
        }
        private set;
    }

    public static void validateNoInActiveContact(Map<Id,Event> triggerOldMap, List<Event> triggerNew , boolean isInsert, boolean isUpdate){                        
        if(!'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            system.debug('<><><><> trigger for event start' );
            //event to contactId Map    
            Map<Id, Id> eventToContactIDMap = new Map<Id,Id>();    
            //ContactId to error Message Map
            Map<Id, String> errorMap = new Map<Id,String>();        
            
            for(Event  t : triggerNew){
                if(t.whoid <> null){
                    eventToContactIDMap.put(t.Id,t.whoid);
                }
            }
            List<Contact> cList = new List<Contact>();
            
            
            cList= [SELECT Id ,Active__c , Name 
                                FROM Contact 
                                where Contact.Id IN :eventToContactIDMap.values() 
                                and Contact.Active__c =false] ;
            
            for(Contact c : cList){
                errorMap.put(c.Id, System.Label.ContactInactiveErrorForEvent.Replace('%ContactName%', c.Name)) ;
                //errorMap.put(c.Id, 'Contact:' + c.Name + ' is inactive .  You cannot add an inactive contact to the Event.') ;                       
            }
            System.debug('errorMap=' + errorMap);
            for(Event  t : triggerNew){
                if(t.whoid <> null){
                    if(isInsert  && errorMap.get(t.whoId) <> null ){
                        system.debug('Error eventid=' + t.id + ' subject='+ t.subject + ' error=' + errorMap.get(t.whoId) );
                        t.addError(errorMap.get(t.whoId));
                    }else if(isUpdate){
                        Event oldEvent = (Event)triggerOldMap.get(t.Id) ;    
                        if(  (t.whoId <> oldEvent.whoId) && (errorMap.get(t.whoId) <> null)  ){
                            system.debug('Error eventid=' + t.id + ' subject='+ t.subject + ' error=' + errorMap.get(t.whoId) );
                            t.addError(errorMap.get(t.whoId));
                        }
                    }
                }//t.whoId <> null
            }//for Event t
        }
    }

    public static void validateOutlook(List<Event> triggerNew ){
        if(!'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            System.debug('inside trigger validateOutlook......');
            for (Event t : triggerNew){
				if(t.Source__c != 'Outlook Plugin'){
					//t.isOutlook__c=false;
					if(null==t.whatID && null == t.whoId ){
						System.debug('whatID and whoId is null');
						//t.isOutlook__c=true;
						t.Source__c='Outlook';
					}else{
						t.Source__c='Desktop';
					}
				}
            }
        }        
    }

    /* Changing the source during Insert for Instient Feed */
    public static void changeSource(List<Event> triggerNew){
        if('Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            for(Event t: triggerNew){
                if(SOURCE_INSTINET_FEED.equalsIgnoreCase(t.Source__c))
                    t.Source__c = 'Instinet';
            }
        }
    }

    public static void validateWhatId(List<Event> triggerNew ){
        System.debug('inside trigger validateWhatId......');
        Map<String,String> whoIdMap = new Map<String,String>();
        List<ID> tList = new List<ID>();
        List<ID> whatIdList = new List<ID>();
        for (Event t : triggerNew){
			if(t.Source__c != 'Outlook Plugin'){
				if(null==t.whatID){
					System.debug('whatID is null');
					if(null!=t.whoId){
						whoIdMap.put(t.id,t.WhoId);
						System.debug('whoId is not null: '+t.WhoId);
					}else{
						System.debug('whoId is null: '+t.WhoId);
						tList.add(t.id);
					}
				}else{
					System.debug('whatId is not null ');
					System.debug('whatID type '+ t.whatID.getSObjectType());
					if(t.whatID.getSObjectType() == Account.sObjectType && t.RecordTypeId == CommonTools.getRecordTypeIdUsingDeveloperName('Event', 'Standard_Event')){
						whatIdList.add(t.whatId);
					}
					
					if(null!=t.whoId){
						System.debug('whoID is not null');
						whoIdMap.put(t.id,t.WhoId);
					}            
				}
			}	
        }

        if(whoIdMap.size() > 0){
            updateWhatId(whoIdMap,triggerNew);
        }

        if(tList.size() > 0){
            if(!System.isFuture()){
                System.debug('Async call');
                AsyncValidateWhatId(tList);
            }else{
                System.debug('Sync call');
                syncValidateWhatId(tList);
            }
        }
        
        if(whatIdList.size() > 0){
            Map<Id, Account> parentIds = new Map<Id, Account>(); 
            //System.debug('***parentIdList Before:'+parentIdList);
            for(Account parentacc : [SELECT Id,ParentId FROM Account Where ParentId IN :whatIdList]){                
                    parentIds.put(parentacc.ParentId, parentacc);
                	//System.debug('***parentacc.ParentId:'+parentacc.ParentId);            
            }
            //System.debug('***parentIdList:'+parentIdList);
            for(Event t:triggerNew){
                System.debug('***t.whatId:'+t.whatId);
                System.debug('***parentIds.get(t.whatId):'+parentIds.get(t.whatId));
                if(parentIds.get(t.whatId) == null){
                    t.addError(System.Label.Event_NOT_to_Hanging_RG);
                }
            }
        }
    }
       
    public static void syncValidateWhatId(List<Id> tid){
        
        System.debug('synch inside trigger validateWhatId......');
        if(null!=tid&&tid.size()>0){
            System.debug('synch execute query on event');
            List<Event> eventsList = new List<Event>([SELECT Id, WhatId, WhoId from Event where Id IN:tid]);
            System.debug('outside events.size() :: ' + eventsList.size());
            System.debug('Sync event :: ' + eventsList);

            if(eventsList.size() >0){
                Map<String,String> whoIdMap = new Map<String,String>();
                for(Event event : eventsList){
                    if(null!=event.whoId && null==event.whatID){
                        whoIdMap.put(event.id,event.WhoId);
                    }
                }

                if(whoIdMap.size() > 0){
                    updateWhatId(WhoIdMap,eventsList);
                }
            }
        }
    }
    
    @future
    public static void validateNomuraWhoId(List<Id> eventIdList){
        if(!'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            System.debug('inside trigger validateNomuraWhoId......');
            List<id> nomRelIds = new List<id>();
            
            eventRelation  [] eventNomRel = [select RelationId, AccountId from eventRelation where eventId IN:eventIdList and isWhat = false];
            System.debug('size of whos is :: ' + eventNomRel.size());
            if(eventNomRel.size()>0){
                List<id> relationIdevent = new List<id>();
                for(eventRelation tr:eventNomRel){
                    relationIdevent.add(tr.RelationId);
                }
                Contact [] contactsNom = [select id, Account.Parent.RDM_Org_Id__c from Contact where id IN  : relationIdevent ];
                
                System.debug('size of contacts nomura  is :: ' + contactsNom.size());
                if(contactsNom.size()>0){
                    for(integer i=0; i<contactsNom.size(); i++){
                        String accNam = string.valueOf(contactsNom[i].Account.Parent.RDM_Org_Id__c); 
                        
                        if(string.isNotBlank(accNam)){
                            if(accNam.contains(NOMURA_RDM_ORG_ID)){                            
                                System.debug('adding to delete list');                          
                                nomRelIds.add(contactsNom[i].id);                           
                            } 
                        }
                    }
                }
            }
            
            System.debug('inside trigger DeleventRelId......');        
            eventRelation [] trdel = [select RelationId, Relation.Name  from eventRelation where RelationId in : nomRelIds];
            System.debug('relations to be deleted count :: ' + trdel.size());
            if(trdel.size()>0){
                List<EventRelation> eventRelationsToUpdate = new List<EventRelation>();
                try{ 
                    System.debug('Inside try');
                    for(EventRelation ert:trdel){
                        ert.isInvitee = true;
                        ert.isParent = false;
                        eventRelationsToUpdate.add(ert);
                    
                        //System.debug('updated '+ ert.relation.name);
                    }
                    
                    if(eventRelationsToUpdate.size() > 0){
                        update eventRelationsToUpdate;
                    }
                }catch (Exception e){
                    System.debug('exception :: ' + e.getMessage());
                }
            }
            //eventRelation [] trdel2 = [select RelationId, Relation.Name  from eventRelation where RelationId in : nomRelIds];
            //System.debug('After deletion relations to be deleted count :: ' + trdel2.size());
        }
    }
    
    @future
    public static void AsyncValidateWhatId(List<Id> tid){
        
        System.debug('Asynch inside trigger validateWhatId......');
        if(null!=tid&&tid.size()>0){     
            System.debug('Asynch execute query on event');
            List<Event> eventsList = new List<Event>([SELECT Id, WhatId, WhoId from Event where Id IN:tid]);
            
            System.debug('outside events.size() :: ' + eventsList.size());
            System.debug('Async event :: ' + eventsList);
            
            if(eventsList.size() >0){
                Map<String,String> whoIdMap = new Map<String,String>();
                for(Event event : eventsList){
                    if(null!=event.whoId && null==event.whatID){
                        whoIdMap.put(event.id,event.WhoId);
                    }
                }
                
                if(whoIdMap.size() > 0){
                    updateWhatId(WhoIdMap,eventsList);
                }
            }
        }
    }
    
    public static void validateOtherFields(List<Event> triggerNew){
        if(!'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            System.debug('inside trigger EventErrorOutTrigger');
            Set<String> whatIDs = new Set<String>();
            
            for (Event t : triggerNew) {
                t.IsRepeat__c = t.IsRecurrence2;
                if(t.WhatId != null){
                    whatIDs.add(t.whatID);
                }                
            }
            List<Account> accts = new List<Account>();
            
            
            accts = [SELECT Id, RG_Account__c, RM_Account__c ,Name, Parent.RDM_Org_Id__c   
                                FROM Account 
                                WHERE Id =: whatIDs];
            
            
            System.debug('accts:' + accts);

            if(accts.size() > 0){
                for (Event t : triggerNew){
                    System.debug('Event:' + t);
					if(t.Source__c != 'Outlook Plugin'){
						if(accts[0].parent.RDM_Org_Id__c == NOMURA_RDM_ORG_ID ){
							//t.addError('Events cannot be Related To this Account.');
							t.addError(System.Label.Event_NOT_to_Nomura_Employee_Account);
						}else if(accts[0].RG_Account__c){
							if(String.isBlank(t.WhoId) && !t.IsRecurrence2 ){
								System.debug('who id is blank');
								t.addError(System.Label.Account_Error );//'You are adding this Activity, please select a RG Account for Related To field or a Contact in the Name field or both.'
							} 
						}else {if(accts[0].RM_Account__c){
							t.addError(System.Label.RG_Only_Error);//'Please add this activity at the RM level.'
						}else{//not rm , not rg , should not happen
							t.addError(System.Label.RG_Only_Error);//'Please add this activity at the RM level.'
						}
							}
					}
				} //end for Task in Trigger.New loop
            }
        }
    }
    
    public static void updateServiceStats(Map<Id,Event> triggerOldMap, List<Event> triggerNew){
        system.debug('In stats');
        for(Event e: triggerNew)
        {
            Event oldEvent = triggerOldMap.get(e.Id);
            if(oldEvent.SR_AS_Cnt__c == e.SR_AS_Cnt__c && oldEvent.SR_EM_Cnt__c == e.SR_EM_Cnt__c && oldEvent.SR_JP_Cnt__c == e.SR_JP_Cnt__c && oldEvent.SR_US_Cnt__c == e.SR_US_Cnt__c && oldEvent.SR_AS_Con_Cnt__c == e.SR_AS_Con_Cnt__c && oldEvent.SR_EM_Con_Cnt__c == e.SR_EM_Con_Cnt__c && oldEvent.SR_JP_Con_Cnt__c == e.SR_JP_Con_Cnt__c && oldEvent.SR_US_Con_Cnt__c == e.SR_US_Con_Cnt__c)
            {
                e.IsServiceStatsSummarized__c = false;
            }
        }
    }
    
    public static void updateWhatId(Map<String,String> whoIdMap,List<Event> events){
        System.debug('Inside updateWhatId');
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,Account.ParentId,Account.Parent.RDM_Org_Id__c FROM Contact WHERE Id IN:whoIdMap.values()]);
        System.debug('Contact Map Size:'+contactMap.size());
        List<String> blankWhatIdList = new List<String>();
        for (Event t : events){
            if(contactMap.get(t.whoId) != null && NOMURA_RDM_ORG_ID.equals(contactMap.get(t.whoId).Account.Parent.RDM_Org_Id__c)){
                System.debug('Nomura add error');
                t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
            }
            else if(null != contactMap.get(t.whoId) && null == t.WhatId){
                blankWhatIdList.add(t.id);
            }
        }
        
        if(blankWhatIdList.size() > 0){
            System.debug('Inside inner if blankWhatIdMap');
            Map<Id, Event> updateEvent = new Map<Id, Event>([SELECT Id, WhatId FROM Event WHERE Id IN: blankWhatIdList]);
            System.debug('updateEvent Size: '+updateEvent.size());
            for(Event t: events){
                if(null != updateEvent.get(t.Id)){
                    if(null != contactMap.get(t.whoId).Account.ParentId){
                        updateEvent.get(t.Id).whatId = contactMap.get(t.whoId).Account.ParentId;                                    
                    }
                }
            }
            update updateEvent.values();
        }
    }

    /* Storing owner of Event as a contact relation for Instinet Feed */
    public static void makeOwnerAsInvitee(List<Event> triggerNew){
        if('Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            List<String> loginIds = new List<String>();
            for (Event t : triggerNew){
                if(t.Event_Name__c != null && (SOURCE_INSTINET.equalsIgnoreCase(t.Source__c) || SOURCE_INSTINET_FEED.equalsIgnoreCase(t.Source__c))){
                    loginIds.add(t.Event_Name__c);
                }
            }
            
            System.debug('loginIds Size: '+loginIds.size());
            if(loginIds.size() > 0){                
                Map<String,String> contactIdMap = new Map<String,String>();
                List<EventRelation> eventRelationList = new List<EventRelation>();

                List<Contact> contactList = [SELECT Id,Login_Id__c FROM Contact WHERE Login_Id__c IN:loginIds AND Account.RDM_Org_Id__c = 'IN12345' 
                                            AND Active__c = true];
                
                for(Contact con : contactList){
                    if(con.Login_Id__c !=null){
                        contactIdMap.put(con.Login_Id__c.toUpperCase(), con.Id);
                    }
                }                                

                for (Event t : triggerNew){
                    if(t.Event_Name__c !=null && contactIdMap.get(t.Event_Name__c.toUpperCase()) != null){
                        EventRelation eventRelationObj = new EventRelation(EventId = t.Id, RelationId = contactIdMap.get(t.Event_Name__c.toUpperCase()), isParent = false, isInvitee = true);
                        eventRelationList.add(eventRelationObj);
                    }
                }

                List<Database.SaveResult> resultList = Database.insert(eventRelationList, false);
                System.debug('resultList: '+resultList.size());
                for(Integer i=0; i<resultList.size(); i++){
                    Database.SaveResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage()))
                            System.debug('Error on Insert. Error Message: '+errorObj.getMessage());
                        }
                    }
                }
            }
        }
    }

    /* Delete EventRelation records when Event update is performed */
    public static void deleteEventRelation(List<Event> triggerNew){
        if('Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            Map<Id,Id> eventWhoIdMap = new Map<Id,Id>();
            Map<Integer,Map<Id,Id>> eventWhoIdRecordMap = new Map<Integer,Map<Id,Id>>();
            Integer count = 0;
            for(Event newEvent : triggerNew){
                if(SOURCE_INSTINET_FEED.equalsIgnoreCase(newEvent.Source__c)){
                    eventWhoIdMap.put(newEvent.Id, newEvent.whoId);
                    eventWhoIdRecordMap.put(count++,eventWhoIdMap);
                }
            }
            if(eventWhoIdRecordMap !=null && eventWhoIdRecordMap.size() > 0){
                Integer batchSize = 200;
                Map<Integer,Map<Id,Id>> whoIdEventMap = getSubsetLists(eventWhoIdRecordMap, batchSize);                
                List<EventRelation> eventRelationList ;
                String selectQuery = 'SELECT Id FROM EventRelation WHERE Relation.Type IN (\'Contact\',\'User\') AND (';            
                String whereQuery='';

                for(Integer i: whoIdEventMap.keySet()){
                    Map<Id,Id> whoIdsMap = whoIdEventMap.get(i);
                    for(Id Id:whoIdsMap.keySet()){
                        whereQuery = whereQuery + '(RelationId NOT IN (\''+whoIdsMap.get(Id)+'\') AND EventId IN (\''+Id+'\')) OR ';
                    }
                }

                whereQuery = whereQuery.substring(0, whereQuery.length()-4) + ')';
                String sqlQuery = selectQuery + whereQuery;
                System.debug('Sql query: '+sqlQuery);
                
                eventRelationList = Database.query(sqlQuery) ;
                                                            
                if(eventRelationList != null && eventRelationList.size() > 0){
                    List<Database.DeleteResult> resultList = Database.delete(eventRelationList,false) ;
                    System.debug('resultList: '+resultList.size());
                    for(Integer i=0; i<resultList.size(); i++){            
                        Database.DeleteResult resultObj = resultList.get(i);
                        if(!resultObj.isSuccess()){ 
                            for(Database.Error errorObj : resultObj.getErrors()){
                                if(String.isNotEmpty(errorObj.getMessage())){
                                    System.debug('Error on Delete. Error Message: '+errorObj.getMessage());
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static Map<Integer,Map<Id,Id>> getSubsetLists(Map<Integer,Map<Id,Id>> recordDataInputMap, Integer batchSize){        
        Map<Integer,Map<Id,Id>> recordDataMap = new Map<Integer,Map<Id,Id>>();        
        if(recordDataInputMap != null && recordDataInputMap.size() > 0){
            Integer size = (batchSize == 1) ? recordDataInputMap.size() : ((recordDataInputMap.size()/batchSize) + 1);
            for(Integer outerLoop = 0; outerLoop < size; outerLoop++){
                Map<Id,Id> recordDataList = new Map<Id,Id>();                
                for(Integer innerLoop = (outerLoop*batchSize); innerLoop < (outerLoop*batchSize)+batchSize && innerLoop < recordDataInputMap.size() ; innerLoop++){
                    recordDataList.putAll(recordDataInputMap.get(innerLoop));
                }                
                recordDataMap.put(outerLoop,recordDataList);                
            }
        }        
        return recordDataMap;
    }

    public static void populateDurationAndL0Type(List<Event> triggerNew){
        if('Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)){
            Map<String,L1_Event_Type_Setting__mdt> metaDataMap = new Map<String,L1_Event_Type_Setting__mdt>();
            List<L1_Event_Type_Setting__mdt> metaDataList = [SELECT Id,Label,L0_Type__c,Default_Duration__c FROM L1_Event_Type_Setting__mdt];
                       
            for(L1_Event_Type_Setting__mdt metaDataRecord : metaDataList){
                metaDataMap.put(metaDataRecord.Label,metaDataRecord);
            }
             
            for(Event newEvent: triggerNew){
                if(SOURCE_INSTINET.equalsIgnoreCase(newEvent.Source__c) || SOURCE_INSTINET_FEED.equalsIgnoreCase(newEvent.Source__c)){
                    L1_Event_Type_Setting__mdt eventRecord = metaDataMap.get(newEvent.Type);
					Integer duration = eventRecord.Default_Duration__c.intValue();
                    newEvent.DurationInMinutes = duration;
                    System.debug('Duration: '+duration);
                    newEvent.L0_Type__c = eventRecord.L0_Type__c;
                }
            }
        }
    }
}