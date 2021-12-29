global class AccountRecentViewedContactsController 
{
    /* SHIELD - START : 
    public boolean isView {get;set;}
    
    public ApexPages.StandardSetController contactSetCont {get; private set;}
    
    private Integer recordsPerPage = 40;
    public string url {get;set;}
    
    public AccountRecentViewedContactsController(ApexPages.StandardController stdController) 
    {
        
        url = ApexPages.currentPage().getUrl();
        
        system.debug('url :' + url);
        if(test.isRunningTest()){
            url = 'lightning';
        }
        if(url.contains('lightning'))
        {
            isView = false;
        }
        else
        {
            isview = true;
        }
        
  
        contactSetCont = new ApexPages.StandardSetController([
        	Select Id, Salutation, Name, AccountId, Position__c, Email, GRP_Access__c, Phone, key_Person__c, Local_Language_Full_Name__c
            From Contact 
            Where Account.ParentId =: stdController.getRecord().Id // based on Contact's RM Account relates to RG
            And Active__c = true
            And LastViewedDate != null
            // Order By LastViewedDate DESC NULLS LAST, Name ** Shield 
		]);
        contactSetCont.setPageSize(recordsPerPage); 
        
    }
    
    public List<Contact> getContacts()
    {
        return (List<Contact>) contactSetCont.getRecords();
    }
    SHIELD - END : */
     /* @RemoteAction
    global static Boolean setConsolInfo(String isConsolemode) {
        Boolean isConsole = false;
        if('true'.equals(isConsolemode)){
            isConsole = true;
        }
        return isConsole;
    }*/


}