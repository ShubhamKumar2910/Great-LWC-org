/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 03/07/2018
	Description : Queueable job to send email notifictions    
				  for ETrading Enablement Requests 
	
*/  
public with sharing class ETradingEnablementSendEmail implements Queueable
{
	private Map<Id, ETradingEnablement__c> eTradingEnablements;
	
    public ETradingEnablementSendEmail(Map<Id, ETradingEnablement__c> eTradingEnablements)
    {
    	this.eTradingEnablements = eTradingEnablements;
    }
    
    public void execute(QueueableContext context) 
    {
   		// The trigger that calls this job deals with 200 records at once so 
   		// a Mass email message (250 record limit) can be used with the   
   		// Target Object Ids set to the list of Users (Salesperson)
    	if (!eTradingEnablements.isEmpty())
    	{
    		List<Id> pendingApprovalStatusUserIds = getStatusETradingEnablements('Pending Approval');  
    		List<Id> processingStatusUserIds = getStatusETradingEnablements('Being Processed');
    		List<Id> completedStatusUserIds = getStatusETradingEnablements('Complete');
    		
    		if (!pendingApprovalStatusUserIds.isEmpty())
    		{
    			sendEmail(pendingApprovalStatusUserIds, 'ETradingEnablement_Approval');
    		}
    		
    		if (!processingStatusUserIds.isEmpty())
    		{
    			sendEmail(processingStatusUserIds, 'ETradingEnablement_Processing'); 
    		}
    		
    		if (!completedStatusUserIds.isEmpty())
    		{
    			sendEmail(completedStatusUserIds, 'ETradingEnablement_Complete'); 
    		}
    	}
    	
    }
    
    private List<Id> getStatusETradingEnablements(String status)
    {
    	List<Id> userIds = new List<Id>();
    	
    	for (Id  userId : eTradingEnablements.keySet())
    	{
 			ETradingEnablement__c eTradingEnablement = eTradingEnablements.get(userId);   		
    		
    		if (eTradingEnablement.Status__c == status)
    		{
    			userIds.add(userId);
    		}
    	}
    	
    	return userIds;
    }
    
    private void sendEmail(List<Id> userIds, String emailTemplateDeveloperName)
    {
    	System.debug('ETradingEnablementSendEmail : sendEmail : emailTemplateDeveloperName : ' + emailTemplateDeveloperName);
    	
    	EmailTemplate emailTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = :emailTemplateDeveloperName LIMIT 1];
    	
    	if (emailTemplate != null)
    	{
    		Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
			mail.setTargetObjectIds(userIds);
			mail.saveAsActivity = false;
			mail.setSenderDisplayName('System Administator');
			mail.setTemplateId(emailTemplate.Id);
			
			Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail } );
    	}
    	
    }
}