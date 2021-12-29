public class AccountMiFIDIIDetailWrapper {

    @AuraEnabled
    public Account rmAccount {get;set;}
    
    @AuraEnabled
    public String productSubscriptions {get;set;}
    
    @AuraEnabled
    public String deskCommentary {get;set;}
    
    public AccountMiFIDIIDetailWrapper(){
        
    }
}