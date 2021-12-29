public with sharing class AccountServiceModelCloneController {
     private ApexPages.StandardController controller {get; set;}
    public Account_Service_Model__c record {get;set;}
 
    public AccountServiceModelCloneController(ApexPages.StandardController controller) {
 
        this.controller = controller;
        record = (Account_Service_Model__c)controller.getRecord();
    }
 
    public PageReference cloneAccountServiceModel() {
        
         Savepoint sp = Database.setSavepoint();
         Account_Service_Model__c cloned;
         try {
             
             cloned = record.clone(false);
             insert cloned;
         } catch (Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
        return new PageReference('/'+cloned.id);
 
    }
}