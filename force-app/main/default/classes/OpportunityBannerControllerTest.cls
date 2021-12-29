@isTest
private class OpportunityBannerControllerTest {


  static testmethod void createContact() {
     
    Account acct = UtilityTesting.CreateAccount();  
    
    Opportunity opp = new Opportunity();
    opp.name = 'test';
    opp.stagename = 'Closed';
    opp.closedate = system.today();
    opp.active__c=false;
    insert opp;   
       
        
    Test.setCurrentPageReference(new PageReference('Page.OpportunityBannerPage')); 
    System.currentPageReference().getParameters().put('id', opp.id);
    opportunity opty = [select id,name,active__c from opportunity where id=:opp.id];
    
    OpportunityBannerController ctrl = new OpportunityBannerController(new ApexPages.StandardController(opp));
    
    opty.active__c = true;
    update opty;
    OpportunityBannerController ctrl1 = new OpportunityBannerController(new ApexPages.StandardController(opty));

 }
 
 }