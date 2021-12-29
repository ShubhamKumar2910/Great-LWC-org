public class CoverageMembrContainerController {
    
   @AuraEnabled public Account thisAccount {get;set;}
   @AuraEnabled public ID accountId {get;set;}

     public CoverageMembrContainerController(ApexPages.StandardController controller){
            thisAccount=(Account)controller.getRecord();
            accountId = thisAccount.Id;
         system.debug('accountId :'+ accountId);
         
     }
    
    
}