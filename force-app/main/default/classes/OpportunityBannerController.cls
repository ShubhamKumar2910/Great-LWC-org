public class OpportunityBannerController {
    public opportunity currentOpportunity {get; set;}
    public string opportunitytSatus {get;set;}
    
    public OpportunityBannerController(ApexPages.StandardController controller){
     currentOpportunity = [SELECT Id,Name,Active__c from opportunity where id=:ApexPages.currentPage().getParameters().get('id') ];   
     if(currentOpportunity.Active__c){
         opportunitytSatus = 'Active Opportunity';
     }else {
         opportunitytSatus = 'Inactive Opportunity';
     }
    }


}