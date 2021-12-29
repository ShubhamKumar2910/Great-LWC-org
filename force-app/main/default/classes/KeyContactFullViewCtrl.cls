global class KeyContactFullViewCtrl 
{

/*    public boolean isView {get;set;}
    public ApexPages.StandardSetController contactSetCont {get; private set;}
    public string url {get;set;}
    private Integer recordsPerPage = 40;
    
    public KeyContactFullViewCtrl(ApexPages.StandardController stdController) 
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
       
  		system.debug('parentId: '+ stdController.getRecord().Id);
        contactSetCont = new ApexPages.StandardSetController([
        	Select Id, AccountId, Salutation, Name, Local_Language_Full_Name__c, Account.Name, Position__c 
            FROM Contact 
            Where Account.ParentId =: stdController.getRecord().Id // based on Contact's RM Account relates to RG
            And Active__c = true
            and IsDeleted = false
            and key_Person__c = true
            Order By Account.Name, Name
		]);
        contactSetCont.setPageSize(recordsPerPage); 
        
    }
    
    public List<Contact> getContacts()
    {
        return (List<Contact>) contactSetCont.getRecords();
    }
    
      @RemoteAction
    global static Boolean setConsolInfo(String isConsolemode) {
        Boolean isConsole = false;
        if('true'.equals(isConsolemode)){
            isConsole = true;
        }
        return isConsole;
    }
*/

}