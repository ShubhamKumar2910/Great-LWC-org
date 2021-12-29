public class SendNotificationController {
    
   @AuraEnabled public Event thisevent {get;set;}
   @AuraEnabled public ID eventId {get;set;}

     public SendNotificationController(ApexPages.StandardController controller){
            thisevent=(Event)controller.getRecord();
            eventId = thisevent.Id;
         
     }
    
    
}