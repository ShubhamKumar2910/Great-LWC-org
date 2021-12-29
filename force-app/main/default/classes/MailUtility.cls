public class MailUtility {
    public static Boolean sendMail(String[] toEmailArray, String subject, String emailBody){
        Boolean isSuccess = FALSE;
        
        //Create Mail Object
        Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
                    
        mailObj.setToAddresses(toEmailArray);
        mailObj.setSubject(subject);
        mailObj.setHtmlBody(emailBody);
        
        //Send Mail
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult [] emailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailObj}); 
            if(emailResults != null && emailResults.size() > 0 && emailResults[0].success){
                isSuccess = TRUE;
            }
        }
        
        return isSuccess;
                    
    }


    public static Boolean sendMailWithAttachment(String[] toEmailArray, String[] toCcAddress, String subject, String emailBody, List<Id> contentDocumentIds){
        Boolean isSuccess = FALSE;
        
        //Create Mail Object
        Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
                    
        mailObj.setToAddresses(toEmailArray);
        mailObj.setCcAddresses(toCcAddress);
        mailObj.setSubject(subject);
        mailObj.setHtmlBody(emailBody);
        
        addAttachment(mailObj, contentDocumentIds);

        //Send Mail
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult [] emailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailObj}); 
            if(emailResults != null && emailResults.size() > 0 && emailResults[0].success){
                isSuccess = TRUE;
            }
        }
        
        return isSuccess;
                    
    }
    
    public static Boolean sendMailWithAttachment(String fromEmail, String fromDisplayName, String[] toEmailArray, String[] toCcAddress, String subject, String emailBody, List<Id> contentDocumentIds){
        Boolean isSuccess = FALSE;
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        //Create Mail Object
        Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
        mailObj.setOrgWideEmailAddressId(owea.get(0).Id);        
        mailObj.setReplyTo(fromEmail);
		//mailObj.setSenderDisplayName(fromDisplayName);      
        mailObj.setToAddresses(toEmailArray);
        mailObj.setCcAddresses(toCcAddress);
        mailObj.setSubject(subject);
        mailObj.setHtmlBody(emailBody);
        
        addAttachment(mailObj, contentDocumentIds);

        //Send Mail
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult [] emailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailObj}); 
            if(emailResults != null && emailResults.size() > 0 && emailResults[0].success){
                isSuccess = TRUE;
            }
        }
        
        return isSuccess;
                    
    }

    public static Boolean sendMailWithAttachment(String[] toEmailArray, String[] toCcAddress, String subject, String emailBody, List<Messaging.EmailFileAttachment> attachments){
        Boolean isSuccess = FALSE;
        
        //Create Mail Object
        Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
                    
        mailObj.setToAddresses(toEmailArray);
        mailObj.setCcAddresses(toCcAddress);
        mailObj.setSubject(subject);
        
        EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where DeveloperName = 'NomuraLetterheadWithBody'];
        String templateBody = emailTemplatebody.HTMLValue;
        system.debug('templateBody: ' + templateBody);
        emailBody = templateBody.replace('@templateBody', emailBody);
        
        
        mailObj.setHtmlBody(emailBody);        
       	mailObj.setFileAttachments(attachments);

        //Send Mail
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult [] emailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailObj}); 
            if(emailResults != null && emailResults.size() > 0 && emailResults[0].success){
                isSuccess = TRUE;
            }
        }
        
        return isSuccess;
    }

    public static void addAttachment(Messaging.SingleEmailMessage mailObj, List<Id> contentDocumentIds){
      
        Messaging.EmailFileAttachment[] attachments = new Messaging.EmailFileAttachment[]{}; 
               
        for ( ContentVersion cversion : [SELECT title,PathOnClient, FileType,versiondata, FileExtension 
                                        FROM contentversion 
                                        WHERE ContentDocumentId IN :contentDocumentIds ])
        {

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(cversion.VersionData);            
            attachment.setFileName(cversion.Title + '.' + cversion.FileExtension);
            attachment.setInline(false);
            //attachment.setContentType('application/pdf');
            attachments.add(attachment);        
        }
        mailObj.setFileAttachments(attachments);
    }
}