global class BatchUpdatingCampaignOwnerRoles implements Database.Batchable<sObject> {
    /*
	Author 		: Kotaro Wakatsuki 
	Company 	: Nomura 
	Date 		: 05/07/2018
	Description 	: This class is a batch to update Campaign Owner Role field in Campaign object.
					Only Campaign objects with different value in their Campaign Owner Role fields from those of their actual Campaign Owner are in scope.
					Ref: SALES-2644
	*/
	
    public String Query {get; set;}
    public List<Campaign> UpdateCampaignRecords{get; set;}
    
    global BatchUpdatingCampaignOwnerRoles(){
    	Query = 'SELECT Id, Name, Owner.UserRole.Name, Campaign_Owner_Role__c FROM Campaign';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        SavePoint sp;
		UpdateCampaignRecords = new List<Campaign>();
        try
        {
            for(sObject s : scope){
                Campaign camp = (Campaign)s;
                System.debug('Campaign Id:' + camp.Id);
                System.debug('Campaign Name:' + camp.Name);
                System.debug('Campaign Owner Role field: '+ camp.Campaign_Owner_Role__c);
                System.debug('Actual Campaign owner role: '+ camp.Owner.UserRole.Name);
                if(camp.Campaign_Owner_Role__c != camp.Owner.UserRole.Name){
                    System.debug('Campaign Id ' + camp.Id + ' is in an updating list.');
                    camp.Campaign_Owner_Role__c = camp.Owner.UserRole.Name;
                    UpdateCampaignRecords.Add(camp);
                }
                else{
                    System.debug('Campain Id ' + camp.Id + ' is not in an updating list.');
                }
            }
            if(UpdateCampaignRecords.size()>0){
                System.debug(UpdateCampaignRecords.size() + ' campaigns will be updated.');
                update UpdateCampaignRecords;
            }
        }
        catch(Exception e)
        {
             if(sp!=null)
                Database.rollback(sp);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}