public class AccordionSectionWrapper {
    
    @AuraEnabled
    public String label {get;set;}
    @AuraEnabled
    public String title {get;set;}
    @AuraEnabled
    public String name {get;set;}
    @AuraEnabled
    public String auraId {get;set;}
    @AuraEnabled
    public String cmpName {get;set;}
    
    public AccordionSectionWrapper(){
        
    }
    
    public AccordionSectionWrapper(String strLabel, String strTitle, String strName, String strAuraId, String strCmpName){
    	label = strLabel;
        title = strTitle;
        name = strName;
        auraId = strAuraId;
        cmpName = strCmpName;
    }

}