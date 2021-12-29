public class AutoCmpgnMembrStatusTrgBL {
    public static void OnAfterInsertAndUpdate  (List<Campaign> newRecords) {
    List<Campaign> newCamps = [select Id from Campaign where Id IN :newRecords ];
    Map<ID,Set<String>> eCMS = new Map<ID,Set<String>>();
    Set<Id> camps = new Set<Id>();
    List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
    List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
    
    for(Campaign camp : newCamps){
       
            camps.add(camp.Id);
    }    
    System.debug('camps size :: '+ camps.size());
    for(CampaignMemberStatus CMS : [select ID, CampaignID,Label from CampaignMemberStatus where CampaignID IN :camps]) {
        
        Set<String> elCMS = eCMS.get(CMS.CampaignID);
        
        if(null == elCMS) {
            elCMS = new Set<String>();
            eCMS.put(CMS.CampaignId, elCMS);
        }
        
        elCMS.add(CMS.Label);
    }     
    
    for(CampaignMemberStatus cm : [select Id, Label, CampaignId from CampaignMemberStatus where CampaignId IN :camps]) {
            System.debug('cm.label :: ' + cm.Label);
            if(cm.Label == 'Sent' || cm.Label == 'Responded') {             
                 cms2Delete.add(cm);                 
            }
            
            CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=false,
             Label = 'Ready To Send', SortOrder = 3, isDefault = true);
             if(!eCMS.get(cm.CampaignId).contains(cms1.Label)) {
                 System.debug('adding label ' + cms1.Label);
                cms2Insert.add(cms1);
             }            
            
            CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Has Been Sent', SortOrder = 4);
             if(!eCMS.get(cm.CampaignId).contains(cms2.Label)) {
                  System.debug('adding label2 ' + cms1.Label);
                cms2Insert.add(cms2);
             } 
             
            CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Do Not Send', SortOrder = 5);
             if(!eCMS.get(cm.CampaignId).contains(cms3.Label)) {
                  System.debug('adding label3 ' + cms1.Label);
                cms2Insert.add(cms3);
             }  
             
             //CampaignMemberStatus cms4 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             //Label = 'Declined', SortOrder = 6);
             //if(!eCMS.get(cm.CampaignId).contains(cms4.Label)) {
             // cms2Insert.add(cms4);
             //} 
    }
    
   
    
    insert cms2Insert;
    delete cms2Delete;  
    }
    

}