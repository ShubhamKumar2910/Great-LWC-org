public class NotifyContactSponsorChangeBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public List<Id> contactIdList;
    
    public NotifyContactSponsorChangeBatch(List<Id> contactIdList){
        this.contactIdList = contactIdList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
    	String query = null;
        if(contactIdList != null && contactIdList.size() > 0){
            query = 'SELECT Id, FirstName, LastName, AccountId, Account.Name, Account.Parent.Name, '
                  + 'GRP_Access__c, Sponsor_Email_Text__c,LastModifiedDate, LastModifiedBy.Name '
                  + ' FROM Contact WHERE Id IN :contactIdList';
            
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Contact> contactList = (List<Contact>)scope;
        
        if(contactList != null && !contactList.isEmpty()){
                
                //Fetch the Email template
                EmailTemplate emailTemplateObj = [SELECT Id, DeveloperName, IsActive, Subject, Body, HTMLValue FROM EmailTemplate 
                                                  WHERE DeveloperName = 'Notify_Contact_Sponsor_Change' AND IsActive = TRUE LIMIT 1]; 
                if(emailtemplateObj != null){
                    //For each Contact Record, send out the notification
                    for(Contact contactObj : contactList){
                        //Replace Merge Fields
                        String emailBody = emailTemplateObj.HTMLValue;
                        emailBody = emailBody.replace('{!Contact.LastModifiedBy}', contactObj.LastModifiedBy.Name);
                        emailBody = emailBody.replace('{!Contact.LastModifiedDate}', contactObj.LastModifiedDate.formatGMT('yyyy-MM-dd hh:mm:ss a') + ' GMT');
                        emailBody = emailBody.replace('{!Contact.FirstName}', contactObj.FirstName);
                        emailBody = emailBody.replace('{!Contact.LastName}', contactObj.LastName);
                        emailBody = emailBody.replace('{!Contact.RG_Account__c}', contactObj.Account.Parent.Name);
                        
                        //Form Receipient
                        String[] toEmailArray = new String[1];
						toEmailArray[0] = contactObj.Sponsor_Email_Text__c;

                        //Send Mail
                        if(toEmailArray != null && !toEmailArray.isEmpty()){
                            Boolean isSuccess = MailUtility.sendMail(toEmailArray, emailTemplateObj.Subject, emailBody);
                        }
                    }
                }
            }
    }
    
    public void finish(Database.BatchableContext bc){
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
            subject = 'SF - Notify Contact Sponsor Change Batch - Failed';
            emailBody = getEmailBody(apexJob);
            batchName = 'NotifyContactSponsorChangeBatch';
            CommonTools.emailLog(subject, batchName, emailBody, null, null);
        }
        
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = 'The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s).';
                
        return emailBody;
    }

}