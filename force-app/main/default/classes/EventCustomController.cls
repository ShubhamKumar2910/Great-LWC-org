public class EventCustomController {

    public string Title {get;set;}
    private ApexPages.StandardController controller {get; set;}
    public Task_LTA__C tLTA {get;set;}
    public  Event thisEvent {get; set; } 
    public string hiddenExternalContactsId {get;set;}
    public string hiddenNomuraIds{get;set;}
    public string externalContactsName {get; set; }
    public string internalContactsName {get; set; }
    public static DateTime checkdate {get;set;}
    
    public boolean isFromClone {get;set;}
    public string  fromEventId {get;set;}    
    
    public EventCustomController(ApexPages.StandardController controller){
        this.controller = controller;
        String isFromCloneStr = ApexPages.currentPage().getParameters().get('isFromClone');      
        fromEventId=ApexPages.currentPage().getParameters().get('fromEventId');  
        system.debug('isFromClone=' + isFromCloneStr + ' fromEventId=' + fromEventId);
        isFromClone=('1'== isFromCloneStr)?true:false;
        
        //eventStartDate = today();
        //eventEndDate = today().addHours(1);
        thisEvent = (Event)controller.getRecord();
        if(thisEvent == null){           
            thisEvent = new Event();
        }
        
        if(thisEvent.id == null){
            Title = Label.Event_Custom_New_Event;
        }
        else{
            Title = thisEvent.Subject;
            
        }
        
        system.debug('EventId=' + thisEvent.Id);
        tLTA = new Task_LTA__c();
        if(thisEvent.Id == null){
            //this is a new Event
            thisEvent.OwnerId = Userinfo.getUserId();
            if (thisEvent.WhoId != null){ // this will only happen when a new event is created through a Contact
                hiddenExternalContactsId=thisEvent.WhoId;
                List<Contact> tempWho = [select Name from Contact where Id=:thisEvent.WhoId];
                system.debug('query whoid =' + tempWho);
                if(tempWho.size() >0){
                    externalContactsName= tempWho[0].name ;
                }
            }            
        }else{ // this is from Edit event
            //t = [SELECT Subject, OwnerID FROM Event WHERE Id = :thisEvent.Id];
            List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :thisEvent.Id];
            System.debug('<><><><><><><><><>tLTAList=' + tLTAList + ' size()=' + tLTAList.size());
            if(tLTAList.size() == 0){
                tLTA = new Task_LTA__c();
                System.debug('Event has no EventExtension; creating tLTA');
                tLTA.Parent_Task__c = thisEvent.Id;
            }else{
                tLTA= tLTAList[0];   
            }
            
            hiddenExternalContactsId='';
            externalContactsName='';

            hiddenNomuraIds='';
            internalContactsName='';

            List<EventRelation> erList = [SELECT RelationId, Relation.Name, IsParent FROM EventRelation WHERE EventId = :thisEvent.Id and IsWhat=false order by ID];
            for(EventRelation er : erList){
                if(er.isParent){ // external client contact
                    hiddenExternalContactsId += (er.RelationId + ',');
                    externalContactsName += (er.Relation.Name + ',') ;
                    
                }else{ // Nomura Contact
                    hiddenNomuraIds += (er.RelationId + ',');
                    internalContactsName +=(er.Relation.Name + ',') ;
                }
            }
            system.debug('externalContactsName=' + externalContactsName);
            if(externalContactsName.length()>0){
                externalContactsName=externalContactsName.removeEnd(',');
            }
            if(internalContactsName.length()>0){
                internalContactsName=internalContactsName.removeEnd(',');
            }
            if(hiddenExternalContactsId.length()>0){
                hiddenExternalContactsId=hiddenExternalContactsId.removeEnd(',');
            }
            if(hiddenNomuraIds.length()>0){
                hiddenNomuraIds=hiddenNomuraIds.removeEnd(',');
            }
        }
    }
   
    public PageReference doCancel()
    {
        if(isFromClone){
            system.debug('this is from clone , delete the event when cancel is click');
            delete thisEvent;            
            PageReference page = new PageReference('/'+fromEventId);
            return page;
        }else{
            return this.controller.cancel();    
        }
    }
    
    
    public PageReference save(){
     
        system.debug('In Save() hiddenExternalContactsId :' + hiddenExternalContactsId);
        string [] externalContacts = new string[]{};
        thisEvent.WhoId=null;
        //this will make sure the user has select at lease one contact
        if(string.isNotBlank(hiddenExternalContactsId)){
             externalContacts = hiddenExternalContactsId.split(',');
             system.debug(externalContacts);
            if(externalcontacts.size()>0){
               thisEvent.WhoId = externalContacts[0];   
            }
        }
        if(thisEvent.WhoId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Event_Custom_Contact_Error));
            return null;
        }
        string [] internalContacts = new string[]{};
        if(string.isNotBlank(hiddenNomuraIds)){
            internalContacts =  hiddenNomuraIds.split(','); 
            system.debug(internalContacts);            
        }
        
        try{
            if(thisEvent.Id == null){
                insert thisEvent;
            }else{
                update thisEvent;
            }
            updateEventRelationsForExternalContacts(externalContacts);
            updateEventRelationsforInternalContacts(internalContacts);
            updateLTA();
            return new PageReference('/' + thisEvent.Id);            
        }catch(System.DMLException ex){
            ApexPages.addMessages(ex);
        }
        return null;
       
    }
    
    public static void setDate(DateTime startDate,DateTime endDate){
        system.debug('startDate in setDate :'+ startDate);
        system.debug('endDate in setDate:'+ endDate);
        
        checkDate = startDate;

    }
    
    public void updateLTA(){
        if(tLTA.Id == null){
            tLTA.Parent_Task__c = thisEvent.Id;
            insert tLTA;
        }
        else{
            update tLTA;
        }
    }

    //save the client contacts
    private void updateEventRelationsForExternalContacts(string[] externalContacts)
    {
        Set<String> externalContactsSet = new Set<String>(externalContacts);
        //all existing client contacts
        List<EventRelation> existingERForContacts=  [SELECT Id,RelationId from EventRelation WHERE EventId=:thisEvent.Id ANd isParent=true AND isWhat=false ] ;
        delete existingERForContacts;
        
        List<EventRelation> eventRelationsTobeAdded = new List<EventRelation>();
        system.debug('input external client contact array=' + externalContacts);
        for(integer i = 0; i < externalContacts.size(); i++){
            String currentId= externalContacts[i];
            EventRelation  eventRelationInsert= new EventRelation();
            eventRelationInsert.RelationId = currentId ;
            eventRelationInsert.eventId = thisEVent.Id;
            eventRelationInsert.IsWhat =false;
            eventRelationInsert.IsParent = true;
            eventRelationInsert.IsInvitee = false;
            eventRelationsTobeAdded.add(eventRelationInsert);
        }
        system.debug('insert eventrleation=' + eventRelationstoBeAdded);        
        if(eventRelationsTobeAdded.size() > 0){
            insert eventRelationsTobeAdded;
        }        
    }
    
    private void updateEventRelationsforInternalContacts(string[] internalContacts)
    {
        system.debug('internalContacts' + internalContacts + ' eventid=' + thisEvent.Id);

        Set<String> internalContactsSet = new Set<String>(internalContacts);
        List<Contact> nomuraEmployeeIds =  [SELECT Id FROM Contact WHERE 
                                            Id IN (SELECT RelationId from EventRelation WHERE EventId=:thisEvent.Id)  
                                            and Account.Name = 'NOMURA EMPLOYEES'];       
        List<User> userIds = [SELECT Id FROM User WHERE Id IN (SELECT RelationId from EventRelation WHERE EventId=:thisEvent.Id) ];
        List<EventRelation> existingEventRelations = [SELECT Id , RelationId from EventRelation WHERE EventId=:thisEvent.Id                                                        
                                                      AND (RelationId IN : nomuraEmployeeIds OR RelationId IN : userIds) ];
        if(existingEventRelations.size() > 0){
            delete existingEventRelations;    
        }
        List<EventRelation> eventRelationsTobeAdded = new List<EventRelation>();
        system.debug('array' + internalContacts);
        for(integer i = 0; i < internalContacts.size(); i++){
            String currentId= internalContacts[i];
            if( thisEvent.OwnerId != currentId ){
                EventRelation  eventRelationInsert= new EventRelation();
                eventRelationInsert.RelationId = currentId ;
                eventRelationInsert.eventId = thisEVent.Id;
                eventRelationInsert.IsWhat =false;
                eventRelationInsert.IsParent = false;
                eventRelationInsert.IsInvitee = true;
                eventRelationsTobeAdded.add(eventRelationInsert);
            }
        }
        system.debug('insert eventrleation=' + eventRelationstoBeAdded);        
        if(eventRelationsTobeAdded.size() > 0){
            insert eventRelationsTobeAdded;
        }
    }
      
 
}