/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class is a generic Email Notification for sending the email to internal Users.
**                As it sends emails to internal users sending right set of methods, it doesn't consume
**                Salesforce's daily limit of number of emails (currently 5000 per day)    
**                
**
**/

public class EmailNotificationService implements Queueable{
    private Map<String, Map<String, Set<String>>> TargetIdSetByEmailTempNameMapByWhatIdMap;
    private Integer count;
    // e.g. Map<schRecId, Map<schApprEmailTempId, Set<u1Id, u2Id>>>
    private EmailNotificationService(Map<String, Map<String, Set<String>>> TargetIdSetByEmailTempNameMapByWhatIdMap, Integer cnt) {
        this.TargetIdSetByEmailTempNameMapByWhatIdMap = TargetIdSetByEmailTempNameMapByWhatIdMap;
        this.count = cnt;
    }

    private EmailNotificationService() {}

    private Map<String, String> EmailTempIdByEmailTempName {
        get{
            if(EmailTempIdByEmailTempName==null) {
                EmailTempIdByEmailTempName = new Map<String, String>();
                if(TargetIdSetByEmailTempNameMapByWhatIdMap!=null) {
                    Set<String> EmailTempNameSet = new Set<String>(); 
                    for(String whatObjId : TargetIdSetByEmailTempNameMapByWhatIdMap.keySet()) {
                        Map<String, Set<String>> TargetIdSetByEmailTempIdMap = TargetIdSetByEmailTempNameMapByWhatIdMap.get(whatObjId);
                        if(TargetIdSetByEmailTempIdMap!=null) {
                            EmailTempNameSet.addAll(TargetIdSetByEmailTempIdMap.keySet());
                        }
                    }
                    if(!EmailTempNameSet.isEmpty()) {
                        List<EmailTemplate> EmailTempList = [SELECT Id, DeveloperName 
                                FROM EmailTemplate 
                                WHERE DeveloperName IN :EmailTempNameSet];
                        for(EmailTemplate oEmailTemp : EmailTempList) {
                            EmailTempIdByEmailTempName.put(oEmailTemp.DeveloperName, oEmailTemp.Id);
                            System.debug('Added : '+oEmailTemp.DeveloperName+' => '+oEmailTemp.Id);
                        }
                    }
                }
            }
            return EmailTempIdByEmailTempName;
        }

        set;
    }

    public static void sendUsingSingleEmail(Map<String, Map<String, Set<String>>> TargetIdSetByEmailTempNameMapByWhatIdMap) {
        System.debug('#### EmailNotificationService::sendUsingSingleEmail');
        if(TargetIdSetByEmailTempNameMapByWhatIdMap!=null && !TargetIdSetByEmailTempNameMapByWhatIdMap.isEmpty()) {
            ID jobId = System.enqueueJob(new EmailNotificationService(TargetIdSetByEmailTempNameMapByWhatIdMap, 5));
            System.debug('Enqueued Job with jobId : '+jobId);
        }
    }
    
    public void execute(QueueableContext context) {
		System.debug('#### EmailNotificationService.execute()');
        try {
            if(TargetIdSetByEmailTempNameMapByWhatIdMap!=null && !TargetIdSetByEmailTempNameMapByWhatIdMap.isEmpty()) {
                List<Messaging.SingleEmailMessage> SingleEmailMessageList = new List<Messaging.SingleEmailMessage>();
                Integer emailLimit = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations();
                while(SingleEmailMessageList.size() < emailLimit && !TargetIdSetByEmailTempNameMapByWhatIdMap.isEmpty()) {
                    Messaging.SingleEmailMessage emailMsg = createSingleEmailHelper();
                    if(emailMsg!=null) {
                        System.debug('adding email to email-list');
                        SingleEmailMessageList.add(emailMsg);
                    }
                }

                // if there are emails to be sent out
                if(!SingleEmailMessageList.isEmpty()) {
                    System.debug('There are '+SingleEmailMessageList.size()+' emails to send in this transaction');
                    Messaging.SendEmailResult[] SendResults = Messaging.sendEmail(SingleEmailMessageList);
                    for(Messaging.SendEmailResult sendResult : SendResults) {
                        if (sendResult.success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: '
                                + sendResult.errors[0].message);
                        }
                    }
                }

                // finally check if there are more emails to send
                if(!TargetIdSetByEmailTempNameMapByWhatIdMap.isEmpty() /*&& this.count>0*/) {
                    // When unit test is running then jobs cannot be chained so check whether test is running or not
                    if (!Test.isRunningTest()) {
                        ID jobId = System.enqueueJob(new EmailNotificationService(TargetIdSetByEmailTempNameMapByWhatIdMap, this.count-1));
                        System.debug('There are more emails to send -> Enqueued Job with jobId : '+jobId);
                    }
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new EmailNotificationServiceException('Error Occured in EmailNotificationServiceException::sendUsingSingleEmail() : '+ex.getMessage());
        }
    }

    private Messaging.SingleEmailMessage createSingleEmailHelper() {
        System.debug('#### EmailNotificationService::sendUsingSingleEmail');
        Messaging.SingleEmailMessage emailMsg;
        String whatObjId, emailTempId, targetId;
        System.debug('TargetIdSetByEmailTempNameMapByWhatIdMap : '+TargetIdSetByEmailTempNameMapByWhatIdMap);
        for(String whatId : TargetIdSetByEmailTempNameMapByWhatIdMap.keySet()) {
            if(String.isBlank(whatId)) {
                TargetIdSetByEmailTempNameMapByWhatIdMap.remove(whatId);
                System.debug('1 - blank whatid');
                break;
            }
            whatObjId = whatId;
            Map<String, Set<String>> TargetIdSetByEmailTempNameMap = TargetIdSetByEmailTempNameMapByWhatIdMap.get(whatId);
            if(TargetIdSetByEmailTempNameMap==null || TargetIdSetByEmailTempNameMap.isEmpty())  {
                System.debug('2 - blank templNameMap for whatId : '+whatId);
                TargetIdSetByEmailTempNameMapByWhatIdMap.remove(whatId);
                break;
            }
            // this means we have found the sub map
            for(String emailTempName : TargetIdSetByEmailTempNameMap.keySet()) {
                emailTempId = EmailTempIdByEmailTempName.get(emailTempName);
                if(String.isBlank(emailTempId)) {
                    System.debug('3 - email template not found with name : '+emailTempName);
                    TargetIdSetByEmailTempNameMap.remove(emailTempName);
                    if(TargetIdSetByEmailTempNameMap.isEmpty()) {
                        System.debug('4 - templNameMap is now blank');
                        TargetIdSetByEmailTempNameMapByWhatIdMap.remove(whatId);
                    } else {
                        System.debug('5 - templNameMap modified');
                        TargetIdSetByEmailTempNameMapByWhatIdMap.put(whatId, TargetIdSetByEmailTempNameMap);
                    }
                } else {
                    // this means we have found the template id and now fetch the user id, i.e. TargetId
                    Set<String> TargetIdSet = TargetIdSetByEmailTempNameMap.get(emailTempName);
                    System.debug('TargetIdSet : '+TargetIdSet);
                    if(TargetIdSet!=null && !TargetIdSet.isEmpty()) {
                        targetId = (new List<String>(TargetIdSet)).get(0);
                        System.debug('6- Found User from set : '+TargetIdSet);
                        TargetIdSet.remove(targetId);
                    }
                    if(TargetIdSet==null || TargetIdSet.isEmpty()) {
                        System.debug('7- all the user to whom this record should be sent is now empty');
                        TargetIdSetByEmailTempNameMap.remove(emailTempName);
                    } else {
                        System.debug('8- remaining set +'+TargetIdSet);
                        TargetIdSetByEmailTempNameMap.put(emailTempName, TargetIdSet);
                    }

                    if(TargetIdSetByEmailTempNameMap.isEmpty()) {
                        System.debug('9- removing from templateNameSet');
                        TargetIdSetByEmailTempNameMapByWhatIdMap.remove(whatId);
                    } else {
                        System.debug('10- updating templateNameSet');
                        TargetIdSetByEmailTempNameMapByWhatIdMap.put(whatId, TargetIdSetByEmailTempNameMap);
                    }
                }
                break;
            }
            break;
        }

        if(String.isNotBlank(whatObjId) && String.isNotBlank(emailTempId) && String.isNotBlank(targetId)) {
            // compose the email template
            System.debug('whatObjId=>'+whatObjId+', emailTempId=>'+emailTempId+', targetId=>'+targetId);
            emailMsg = Messaging.renderStoredEmailTemplate(emailTempId, null, whatObjId);
            emailMsg.setTargetObjectId(targetId);
            emailMsg.setSaveAsActivity(false);
        }
        return emailMsg;
    }

    public class EmailNotificationServiceException extends Exception {}
}




/*
EmailTemplate emailTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'test_sch_req' LIMIT 1];
//Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, 'a1N0p0000000dQwEAI');
//message.setTemplateId(emailTemplate.Id);
message.setTargetObjectId('0050I000008Ond0QAC');
//message.setWhatId('a1N0p0000000dQwEAI');
message.setSaveAsActivity(false);
Messaging.SingleEmailMessage[] messages = 
    new List<Messaging.SingleEmailMessage> {message};
         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
if (results[0].success) {
    System.debug('The email was sent successfully.');
} else {
    System.debug('The email failed to send: '
          + results[0].errors[0].message);
}

 */