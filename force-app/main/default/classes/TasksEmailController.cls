public class TasksEmailController {
    public TasksEmailController() {
       
    }
    public String recipientEmailAdd{get;set;}
    public String emailDesc{get;set;}
    
    public PageReference send() {
        String id = ApexPages.currentPage().getParameters().get('id');
        System.debug('Current page = ' + ApexPages.currentPage());        
        System.debug('Task ID = ' + Id );
        System.debug('inside create Email');
        Task tasks = [
                    SELECT
                        Subject,
                        Who.Name,What.Name,What.Type,
                        ActivityDate,
            			Description,
                        Status,
                        Priority,
                        Owner.Name
                    FROM
                        Task
                    WHERE
                        id = :Id
                ];  
       
        
       
 		// Create an email
 		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
 		email.setSubject(Tasks.Subject);
        String [] recipArray = recipientEmailAdd.split(';');
 		String [] toAddresses = recipArray;
 		email.setToAddresses(toAddresses);
        String body = Tasks.Owner.Name + ' has shared the following activity with you.'+ '<br/><br/><br/>';
        body += emailDesc + '<br/><br/><br/>' ;
        body += '<b>Activity Date :: </b>'+Tasks.ActivityDate + '<br/>' ;
      	body += '<b>Comments :: </b>' + Tasks.Description+ '<br/>';
      	body += '<b>Assigned To :: </b>' + Tasks.Who.Name+ '<br/>';
        body += '<b>Owner :: </b>' + Tasks.Owner.Name+ '<br/>';
        body += '<b>Status :: </b>' + Tasks.Status+ '<br/>';
        body += '<b>Priority :: </b>' + Tasks.Priority+ '<br/>';
        //body += '<b>Type :: </b>' + Tasks.Type+ '<br/>';
        body += '<b>Related To :: </b>' + Tasks.What.Name+ '<br/>';
        body += '<b>Related To Type :: </b>' + Tasks.What.Type+ '<br/>';
      	email.setHtmlBody(body);
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
 		 for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
          Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
          efa.setFileName(a.Name);
          efa.setBody(a.Body);
          fileAttachments.add(efa);
        }
		email.setFileAttachments(fileAttachments);
 		Messaging.SendEmailResult [] r =
  				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        PageReference reRend = new PageReference('/'+id);
		reRend.setRedirect(true);
        return reRend;
    }
}