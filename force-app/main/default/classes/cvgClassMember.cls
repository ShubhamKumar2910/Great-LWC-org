public class cvgClassMember 
    { 
       @Auraenabled public string Name    { get;set; } 
       @Auraenabled public String SalesTeam   { get;set; }
       @Auraenabled public String SalesDesk   { get;set; }
       @Auraenabled  public string SalesCode {get;set;}
       @Auraenabled  public String SalesDeskRegion {get;set;}
       @Auraenabled  public Date CoverageStartDate {get;set;}
        @Auraenabled public String Comment {get;set;}
        @AuraEnabled public String Division {get;set;}
        //@AuraEnabled public String Type {get;set;}
       // @AuraEnabled public String KeyId {get;set;} 
       @AuraEnabled public String CoverageRole {get;set;}
    }