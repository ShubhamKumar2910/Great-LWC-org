/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 11/07/2018
	Description : Queueable job to update records for the      
				  ETradingEnablementTriggerHandler trigger handler 
	
*/
public with sharing class LinkETradingEnablementRecords {} 

// Commenting out the original code as it is not required anymore but still keeping the backup here as commented code in case we needd it 
// ToDo : in future once eTrading is released, this file will be deleted
/*public with sharing class LinkETradingEnablementRecords implements Queueable 
{
	Map<Id, Id> eTradingEnablementRequestIdCoverageRecordIds = new Map<Id, Id>();
	
	public LinkETradingEnablementRecords(Map<Id, Id> eTradingEnablementRequestIdCoverageRecordIds)
    {
    	this.eTradingEnablementRequestIdCoverageRecordIds = eTradingEnablementRequestIdCoverageRecordIds;
    }
    
    public void execute(QueueableContext context) 
    {
    	if (!eTradingEnablementRequestIdCoverageRecordIds.isEmpty())
    	{
    		List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();
    		
    		for (ETradingEnablement__c eTradingEnablement : [SELECT Id, Coverage__c, Status__c 
    														 FROM ETradingEnablement__c 
    														 WHERE Id IN : eTradingEnablementRequestIdCoverageRecordIds.keySet()])
    		{
    			eTradingEnablement.Coverage__c = eTradingEnablementRequestIdCoverageRecordIds.get(eTradingEnablement.Id);
    			eTradingEnablements.add(eTradingEnablement);
    		}
    		
    		if (!eTradingEnablements.isEmpty())
    		{
    			update eTradingEnablements;
    		}
    	}
    }
}
*/