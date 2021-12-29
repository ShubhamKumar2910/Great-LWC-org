public class ContactBannerController {
    public contact currentContact {get; set;}
    public string contacttSatus {get;set;}
    
    public ContactBannerController (ApexPages.StandardController controller){
     currentContact = [SELECT Id,Name,Active__c from contact where id=:ApexPages.currentPage().getParameters().get('id') ];   
     if(currentContact.Active__c){
         contacttSatus = 'Active Contact';
     }else {
         contacttSatus = 'Inactive Contact';
     }
    }


}