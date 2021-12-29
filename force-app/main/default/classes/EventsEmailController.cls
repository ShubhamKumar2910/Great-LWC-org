public class EventsEmailController {
 public EventsEmailController() {
       
    }
    public String recipientEmailAdd {get;set;}
    public String emailDesc{get;set;}
    
    public PageReference send() {
        String id = ApexPages.currentPage().getParameters().get('id');
        System.debug('Current page = ' + ApexPages.currentPage());        
        System.debug('event ID = ' + Id );
        System.debug('inside create Email');
       Event events = [
                    SELECT
                        Subject,
                        Who.Name,What.Name,What.Type,
                        ActivityDate,
                                Description,
                        Location
                    FROM
                        Event
                    WHERE
                        id = :Id
                ];  
       Set<ID> inviteeIDs = new Set<ID>();
         //get invitees
         for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :Id]){
            
          inviteeIDs.add(a.RelationId);
          }
       
                // Create an email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(events.Subject);
        String [] recipArray = recipientEmailAdd.split(';');
                String [] toAddresses = recipArray;
                email.setToAddresses(toAddresses);
       // String body = events.Owner.Name + ' has shared the following activity with you.'+ '<br/><br/><br/>';
        String body = emailDesc + '<br/><br/><br/>' ;
        body += '<b>Subject :: </b>'+events.Subject + '<br/>' ;
        body += '<b>Event Date :: </b>'+events.ActivityDate + '<br/>' ;
        body += '<b>Description :: </b>' + events.Description+ '<br/>';
        body += '<b>Location :: </b>' + events.Location+ '<br/>';
        body += '<b>Invitee :: </b>'+ '<br/>';
        for( List<Contact> inviteeContacts : [SELECT NAME from CONTACT where ID in:inviteeIDs])
        {
            for(Contact c : inviteeContacts)
            {
                body += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+c.NAME +'<br/>';
            }
            
        }
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
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        PageReference reRend = new PageReference('/'+id);
                reRend.setRedirect(true);
        return reRend;
    }
}