// This class clones an event and all related objects
public class EventCloneController {
 
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    
     // add the instance for the variables being passed by id on the url
    private Event event {get;set;}
 
    // initialize the controller
    public EventCloneController(ApexPages.StandardController controller) { 
        this.controller = controller;
        event = (Event)controller.getRecord();    
        system.debug('in lone constructor');
    }
 
    // method called from the VF's action attribute to clone the partners    
    public PageReference doClone() { 
         // setup the save point for rollback
        system.debug('enter doClone');
        Savepoint sp = Database.setSavepoint();
		Event newEvent;
        try {                      
			//event =[select e.RECORDTYPEID, e.WHOID, e.WHATID,e.SUBJECT, e.LOCATION, e.ISALLDAYEVENT, e.ACTIVITYDATETIME, e.ACTIVITYDATE, e.STARTDATETIME, e.ENDDATETIME, e.DESCRIPTION, e.ACCOUNTID, e.TYPE,  e.EVENTSUBTYPE  from Event e where e.Id = :event.id];
			event =[select e.RECORDTYPEID, e.WHOID, e.WHATID,e.SUBJECT, e.LOCATION, e.ISALLDAYEVENT,  e.STARTDATETIME, e.ENDDATETIME, e.DESCRIPTION, e.ACCOUNTID, e.TYPE,  e.EVENTSUBTYPE  from Event e where e.Id = :event.id];
            newEvent = event.clone(false);
            Datetime now = system.now();
			now = DateTime.valueOf(now.year() + '-' + now.month() + '-' + now.day() + ' ' + now.hour() + ':' + now.minute() + ':00');
			newEvent.StartDateTime = now;        
            newEvent.EndDateTime = now.addHours(1) ;
            newEvent.subject = 'Follow Up Event: ' + event.subject ;
            insert newEvent;
			system.debug('old eventid=' + event.id + ' new eventid='  + newEvent.id);
            List<EventRelation> existingRelations=  [SELECT Id,RelationId,isParent,isWhat,isInvitee from EventRelation WHERE EventId=:event.Id and isWhat=false ] ;
            List<EventRelation> eventRelationsToBeSkip=  [SELECT Id,RelationId,isParent,isWhat,isInvitee from EventRelation WHERE EventId=:newEvent.Id ] ;
            Set<String> idSet = new Set<String>();
            for(EventRelation e: eventRelationsToBeSkip){
                idSet.add(e.RelationId);
            }
            List<EventRelation> eventRelationsTobeAdded = new List<EventRelation>();
            for(EventRelation oldRelation : existingRelations){
                if(!idSet.contains(oldRelation.RelationId)){
                    EventRelation newRelation = new EventRelation();
                    newRelation.eventId = newEvent.Id;
                    newRelation.RelationId = oldRelation.RelationId ;
                    newRelation.IsWhat =oldRelation.IsWhat;
                    newRelation.IsParent = oldRelation.IsParent;
                    newRelation.IsInvitee = oldRelation.IsInvitee;
                    eventRelationsTobeAdded.add(newRelation);                
                }
            }
        	system.debug('insert eventrleation=' + eventRelationstoBeAdded);        
        	if(eventRelationsTobeAdded.size() > 0){
            	insert eventRelationsTobeAdded;
        	}            
            
            PageReference page = new PageReference('/'+newEvent.id+'/e?retURL=%2F'+newEvent.id);
            page.getParameters().put('isFromClone','1');
            page.getParameters().put('fromEventId',event.id);
            system.debug('fw to page=' + page);
            return page;
            //return new ApexPages.StandardController(newEvent).edit();
         } catch (Exception e){
             // roll everything back in case of errors
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
    }
}