public with sharing class TieringController {
    
    public TieringController(){
        
    }
    
    public class TieringDetails implements GenericInterface {
        
       public TieringDetails(){}
        
       @AuraEnabled
       public String americasGMTier;
       @AuraEnabled
       public String europeGMTier;
       @AuraEnabled
       public String japanGMTier;
       @AuraEnabled
       public String asiaExGMTier;
       @AuraEnabled
       public String globalGMTier; 
       @AuraEnabled
       public String americasEQRschTier;
       @AuraEnabled
       public String europeEQRschTier;
       @AuraEnabled
       public String japanEQRschTier;
       @AuraEnabled
       public String asiaExEQRschTier;
       @AuraEnabled
       public String globalEQRschTier;  
        
    }
    
    @AuraEnabled
    public static TieringDetails getTieringDetails(Id recordId){
        TieringDetails tieringObj = new TieringDetails();
        String strQuery = '';
        
        if(recordId != null){
            String sObjectType = CommonTools.getSObjectType(recordId);
            
            if('Account'.equalsIgnoreCase(sObjectType)){
                tieringObj = getTieringDetailsForAccount(recordId);
            }
            else if('Contact'.equalsIgnoreCase(sObjectType)){
                tieringObj = getTieringDetailsForContact(recordId);
            }
        }
        
        return tieringObj;
    }
    
    @AuraEnabled
    public static TieringDetails getTieringDetailsForAccount(Id recordId){
        TieringDetails tieringObj = new TieringDetails();
        
        Account accountObj = [SELECT Id, RDM_Org_Id__c, 
                              EQ_Research_Americas_Tier__c, EQ_Research_Europe_Tier__c, EQ_Research_Japan_Tier__c, EQ_Research_AsiaEx_Tier__c, EQ_Research_Global_Tier__c, 
                              GM_Americas_Tier__c, GM_Europe_Tier__c, GM_Japan_Tier__c, GM_AsiaEx_Tier__c, GM_Global_Tier__c 
                              FROM Account
                              WHERE Id = :recordId
                             ];
        if(accountObj != null){
            tieringObj.americasGMTier = accountObj.GM_Americas_Tier__c;
            tieringObj.europeGMTier = accountObj.GM_Europe_Tier__c;
            tieringObj.japanGMTier = accountObj.GM_Japan_Tier__c;
            tieringObj.asiaExGMTier = accountObj.GM_AsiaEx_Tier__c;
            tieringObj.globalGMTier = accountObj.GM_Global_Tier__c;
            tieringObj.americasEQRschTier = accountObj.EQ_Research_Americas_Tier__c;
            tieringObj.europeEQRschTier = accountObj.EQ_Research_Europe_Tier__c;
            tieringObj.japanEQRschTier = accountObj.EQ_Research_Japan_Tier__c;
            tieringObj.asiaExEQRschTier = accountObj.EQ_Research_AsiaEx_Tier__c;
            tieringObj.globalEQRschTier = accountObj.EQ_Research_Global_Tier__c;
        }
        
        return tieringObj;
    }
    
    @AuraEnabled
    public static TieringDetails getTieringDetailsForContact(Id recordId){
        TieringDetails tieringObj = new TieringDetails();
        
        Contact contactObj = [SELECT Id, RG_Account__r.RDM_Org_Id__c, 
                              RG_Account__r.EQ_Research_Americas_Tier__c, 
                              RG_Account__r.EQ_Research_Europe_Tier__c, 
                              RG_Account__r.EQ_Research_Japan_Tier__c, 
                              RG_Account__r.EQ_Research_AsiaEx_Tier__c, 
                              RG_Account__r.EQ_Research_Global_Tier__c, 
                              RG_Account__r.GM_Americas_Tier__c, 
                              RG_Account__r.GM_Europe_Tier__c, 
                              RG_Account__r.GM_Japan_Tier__c, 
                              RG_Account__r.GM_AsiaEx_Tier__c, 
                              RG_Account__r.GM_Global_Tier__c 
                              FROM Contact
                              WHERE Id = :recordId
                             ];
        if(contactObj != null){
            tieringObj.americasGMTier = contactObj.RG_Account__r.GM_Americas_Tier__c;
            tieringObj.europeGMTier = contactObj.RG_Account__r.GM_Europe_Tier__c;
            tieringObj.japanGMTier = contactObj.RG_Account__r.GM_Japan_Tier__c;
            tieringObj.asiaExGMTier = contactObj.RG_Account__r.GM_AsiaEx_Tier__c;
            tieringObj.globalGMTier = contactObj.RG_Account__r.GM_Global_Tier__c;
            tieringObj.americasEQRschTier = contactObj.RG_Account__r.EQ_Research_Americas_Tier__c;
            tieringObj.europeEQRschTier = contactObj.RG_Account__r.EQ_Research_Europe_Tier__c;
            tieringObj.japanEQRschTier = contactObj.RG_Account__r.EQ_Research_Japan_Tier__c;
            tieringObj.asiaExEQRschTier = contactObj.RG_Account__r.EQ_Research_AsiaEx_Tier__c;
            tieringObj.globalEQRschTier = contactObj.RG_Account__r.EQ_Research_Global_Tier__c;
        }
        
        return tieringObj;
    }

}