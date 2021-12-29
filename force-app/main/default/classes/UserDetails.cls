public  WITHOUT SHARING class UserDetails 
{ 
    @AuraEnabled public string Name    { get;set; } 
    @AuraEnabled public String Id   { get;set; }
    @AuraEnabled public string Email {get;set;}
    @AuraEnabled public String UserType {get;set;}   
    //added for allowing the checkuncheckfunctionality SALES-3675
    @AuraEnabled public Boolean canUncheck{get;set;}
    //SALES-3995 added to check the source that calls sendMail
    @AuraEnabled public String Source{get;set;}
}