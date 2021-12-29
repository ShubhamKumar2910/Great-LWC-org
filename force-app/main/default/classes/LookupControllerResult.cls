global class LookupControllerResult implements Comparable {
    @AuraEnabled public string SObjectLabel {get;set;}
    @AuraEnabled public Id SObjectId {get;set;}
    @AuraEnabled public string emailAddress {get;set;}
    @AuraEnabled public string salesCode {get;set;}
    @AuraEnabled public string salesCodeUserLoginId {get;set;}
    @AuraEnabled public string metaEntity {get;set;}
    @AuraEnabled public string salesDeskRegion {get;set;}
    @AuraEnabled public string company {get;set;}
    
    public Contact contactObj;
    public User userObj;
    public SObject sobj;

    public LookupControllerResult(String label, string objid, string emailAdd, string salesCode,string salesCodeUserLoginId, String metaEntity, String salesDeskRegion, String company)
    {
        this.SObjectLabel = label;
        this.SObjectId = objid;
        this.emailAddress = emailAdd;
        this.salesCode = salesCode;
        this.salesCodeUserLoginId = salesCodeUserLoginId;
        this.metaEntity = metaEntity;
        this.salesDeskRegion = salesDeskRegion;
        this.company = company;
    }
    
    //Shield Changes. This constructor is used when Sobject will be User/Contact
    public LookupControllerResult(String label, string objid, string emailAdd, string salesCode,string salesCodeUserLoginId, String metaEntity, SObject sobj)
    {
        this.SObjectLabel = label;
        this.SObjectId = objid;
        this.emailAddress = emailAdd;
        this.salesCode = salesCode;
        this.salesCodeUserLoginId = salesCodeUserLoginId;
        this.metaEntity = metaEntity;
        if(sobj.getSObjectType() == Contact.sObjectType)
        	this.contactObj = (Contact)sobj;
        else
            this.userObj = (User)sobj;
    }
    
    global Integer compareTo(Object compareTo){        
       	LookupControllerResult lcr = (LookupControllerResult) compareTo;
        Integer returnValue = 0;
        
        if(userObj != null){
            if(userObj.Name > lcr.userObj.Name)
        	    returnValue = 1;
            else if(userObj.Name < lcr.userObj.Name)
                returnValue = -1;   
        }            
        else if(contactObj != null){
            if(contactObj.Name > lcr.contactObj.Name)
        	    returnValue = 1;
            else if(contactObj.Name < lcr.contactObj.Name)
                returnValue = -1;        
        }
        
        return returnValue;
    }
    
}