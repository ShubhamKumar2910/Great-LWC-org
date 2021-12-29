global class CreateRevenueKPISharesBatch implements Database.Batchable<sObject>,Schedulable{
	String query = 'SELECT id, RG__c, OwnerId FROM Revenue_KPI__c where IsDeleted=false';
	
	global CreateRevenueKPISharesBatch() {	}
	global CreateRevenueKPISharesBatch(Account account) {
		if (null != account) {
			query = 'SELECT id, RG__c, OwnerId FROM Revenue_KPI__c where IsDeleted=false and RG__c = \'' + account.Id + '\'';
		} 
	}
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
		System.debug(logginglevel.INFO,'firing query '+query);
		return Database.getQueryLocator(query);
	}
	
	global void execute (Database.BatchableContext bc, List<sObject> scope) {
        
		List<Revenue_KPI__c> kpis = (List<Revenue_KPI__c>) scope;
		RevenueKPIBL.createRevenueShareRecords(kpis);
	}
	
	global void finish(Database.BatchableContext BC){
 		// Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Revenue KPI Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('Sent batch job finish email from CreateRevenueKPISharesBatch to '+a.CreatedBy.Email);
	}

    global void execute(SchedulableContext sc) {
        CreateRevenueKPISharesBatch b = new CreateRevenueKPISharesBatch(); //ur batch class
        database.executebatch(b);
    }
    
}