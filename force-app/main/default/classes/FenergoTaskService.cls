public without sharing class FenergoTaskService {
    
    final public static Set<String> approvalActions = new Set<String> {
        	System.Label.Fenergo_Task_Cancel_Action,
            System.Label.Fenergo_Task_Approve_Action,
            System.Label.Fenergo_Task_Refer_Action};
                
    public class FenergoTaskApproval {
        @InvocableVariable(required=true)
        public String actionType; 
        @InvocableVariable(required=true)
        public List<String> fenergoTaskIds;
        @InvocableVariable(required=true)
        public String comment;
    }
    
    @InvocableMethod(label='Approve,Refer,Cancel Fenergo Tasks' description='Returns the message with the list of Fenergo Tasks that were not updated.')
    public static List<String> processFenergoTaskApproval(List<FenergoTaskApproval> fenergoTaskApproval) {
        System.debug('--FenergoTaskService.handleFenergoTaskApproval--');
        String errorMessage = '';
        List<String> returnMessages = new List<String> ();
        if(fenergoTaskApproval!=null && !fenergoTaskApproval.isEmpty()) {
            try {
                processFenergoTaskApproval(fenergoTaskApproval[0].fenergoTaskIds, fenergoTaskApproval[0].actionType, fenergoTaskApproval[0].comment);
                returnMessages.add('Action performed Successfully');
                
                //Event bus is used to publish event which is received by UtilityBarNotificatio and BulkApproval components.
                List<Request_Notification__e> requestNotifications = new List<Request_Notification__e>();
                Request_Notification__e requestNotification = new Request_Notification__e();
                requestNotification.Message__c = 'RequestProcessed';
                requestNotifications.add(requestNotification);
                EventBus.publish(requestNotifications);
            } catch (DMLException e) {
                errorMessage+= e.getMessage();
            } catch (Exception e) {
                errorMessage+= e.getMessage();
            }
            if (String.isNotBlank(errorMessage)) {
                errorMessage+='\r\n'+'<b>Note: No Records are updated until all errors are fixed</b>';
                returnMessages.add(errorMessage);
            }
        }
        return returnMessages;
    }
    
    public static void processFenergoTaskApproval(List<String> taskIds, String action, String taskComment) {
        if (approvalActions.contains(action) && taskIds !=null && !taskIds.isEmpty() && String.isNotBlank(taskComment)) {
            List<Fenergo_Task__c> fenergoTasks = new List<Fenergo_Task__c> ();
            List<User> userInfo = [SELECT Id, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            for (String fenTaskId : taskIds) {
                Fenergo_Task__c fenergoTask = new Fenergo_Task__c (
                    Id = fenTaskId,
                    Approval_Status__c = 'Reviewed',
                    ReviewNotes__c = taskComment,
                    ReviewerId__c = userInfo != null ? userInfo[0].FederationIdentifier : null,
                    ReviewDate__c = datetime.now(),
                    Approval_Review_Outcome__c = action
                );
                fenergoTasks.add(fenergoTask);
            }
            update fenergoTasks;
        } else {
            throw new FenergoTaskServiceException ('<b>Error: Invalid request</b> \n Action Recieved: ' + action + '\n' + 'Task Ids Received: ' + taskIds + '\n' + 'Comment Received: ' + taskComment);
        }
    }
    
    public class FenergoTaskServiceException extends exception {}
}