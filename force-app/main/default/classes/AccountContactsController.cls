global with sharing class AccountContactsController 
{
    //added for JIRA 3521 to fix error
    public boolean isView {get;set;}
    public Transient ApexPages.StandardSetController contactSetCont {get; private set;}
    public List<Contact> getContacts()
    {
        return (List<Contact>) contactSetCont.getRecords();
    }   
    
    public AccountContactsController(ApexPages.StandardController stdController) 
    {
    }
	/* SHIELD - START : 
    public boolean isView {get;set;}
    public Transient ApexPages.StandardSetController contactSetCont {get; private set;}
    public string url {get;set;}
    private Integer recordsPerPage = 40;
    
    public AccountContactsController(ApexPages.StandardController stdController) 
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
            Select Id, Salutation, Name, AccountId, Position__c, Email, GRP_Access__c, Phone, key_Person__c, Local_Language_Full_Name__c,
            MiFIDII_in_Scope__c, MiFIDII_Sales_Commentary_Allowed__c, MiFID_II_Product_Subscriptions__c
            From Contact 
            Where Account.ParentId =: stdController.getRecord().Id // based on Contact's RM Account relates to RG
            And Active__c = true
            // SHIELD Order By Name ****  Shield 
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