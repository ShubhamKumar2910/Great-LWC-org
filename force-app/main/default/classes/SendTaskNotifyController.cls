public class SendTaskNotifyController {
    
   @AuraEnabled public Task thistask {get;set;}
   @AuraEnabled public ID taskId {get;set;}

     public SendTaskNotifyController(ApexPages.StandardController controller){
            thistask=(Task)controller.getRecord();
            taskId = thistask.Id;
         
     }
    
    
}