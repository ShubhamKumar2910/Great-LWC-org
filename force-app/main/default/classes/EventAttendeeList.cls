public without sharing class EventAttendeeList {
    //Changes for JIRA 3624
    //changed the return type from Event Relation to Wrapper values
    @AuraEnabled 
    public static List<EventDataWrapper> getAttendees(string recordId) {
		List<EventRelation> lstEventRelation = new List<EventRelation>();
        List<EventDataWrapper> finalwrapper = new List<EventDataWrapper>();
        Map<Id,EventRelation> mapEventRelation = new Map<Id, EventRelation>();
        Map<Id,Contact> maContactRelation = new Map<Id, Contact>();
        Map<Id,User> mapUserRelation = new Map<Id, User>();
        for(EventRelation eventRel: [SELECT Id, Relation.Id, Relation.Name , Relation.Type , isParent FROM 
    		EventRelation WHERE EventId =: recordId AND isWhat=false]){
            mapEventRelation.put(eventRel.Relation.Id,eventRel);   
        }
        //get all contacts 
        for(Contact conObj:[SELECT Id, Name, RG_Account__r.name, RG_Account__c,PositionPicklist__c,Title, Phone FROM Contact WHERE Id IN: mapEventRelation.keySet()]){
            maContactRelation.put(conObj.Id,conObj);   
        }
        //get all users 
        for(User userObj:[SELECT Id, Name, Title, Phone FROM User WHERE Id IN: mapEventRelation.keySet()]){
            mapUserRelation.put(userObj.Id,userObj);   
        }
        //prepare the wrapper
        for(EventRelation eventRel: mapEventRelation.values()){
            EventDataWrapper eventwrap = new EventDataWrapper();
            eventwrap.IsParent = eventRel.isParent;
            eventwrap.RecordId = eventRel.Relation.Id;
            eventwrap.RecordName = eventRel.Relation.Name;
            
            //set the contact record fields
            if(maContactRelation.containsKey(eventRel.Relation.Id)){
                Contact conObj = maContactRelation.get(eventRel.Relation.Id);
                eventwrap.AccountId = conObj.RG_Account__c;
                eventwrap.AccountName = conObj.RG_Account__r.name;
                eventwrap.Phone = conObj.Phone;
                if(conObj.PositionPicklist__c != null && conObj.PositionPicklist__c != '')
                    eventwrap.Position = conObj.PositionPicklist__c;
                else {
                    eventwrap.Position = '';
                }
                if(conObj.Title != null && conObj.Title != '')
                    eventwrap.Title = conObj.Title;
                else {
                    eventwrap.Title = '';
                }
            }
            else{
                eventwrap.AccountId = '';
                eventwrap.AccountName = '';
                eventwrap.Position = '';
                eventwrap.Title = '';
                eventwrap.Phone = '';
            }  
            //set the user record title
            if(mapUserRelation.containsKey(eventRel.Relation.Id)){
                User userObj = mapUserRelation.get(eventRel.Relation.Id);
                eventwrap.Phone = userObj.Phone;
                if(userObj.Title != null && userObj.Title != '')
                    eventwrap.Title = userObj.Title;
                else {
                    eventwrap.Title = '';
                }                              
            }
            finalwrapper.add(eventwrap);                      
        }
        system.debug('finalwrapper :::::::::'+ finalwrapper);
        return finalwrapper;
    } 
}