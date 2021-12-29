public class GlblHdSalesContactShareGlblRschrAccHndlr {
    
   
    public static void onAfterUpdate(List<Account> newRecords,Map<Id,Account> oldRecords){
        List<Account> TriggerRecordsFromGUI = new List<Account>();
        List<Account> TriggerRecordsFromScheduler =  new List<Account>();
        
        for(Account accnt : newRecords){
            if(string.isNotBlank(accnt.Called_From__c)){
                TriggerRecordsFromScheduler.add(accnt);
            }
            else
            {
               TriggerRecordsFromGUI.add(accnt); 
            }
        }
        
        // !System.isBatch() was added to following codition for changes for Jira SALES-2906 to fix a issue in where 
        // we were getting an Exception that -  Database.executeBatch cannot be called from a batch start, batch execute, or future method.
        // Basically, there are some RM Accounts on which Called_From__c field is non-empty and mostly Called_From__c = 'Scheduler'
        // Now under SALES-2906 a batch Job runs to set the MiFIDII Entitlements from RM Account. In doing so it sets the flag on Account at 
        // begning of the Batch job and resets it at the end of the same batch job to basically control rerunning the job more than once if user 
        // makes changes again and again from UI
        // But now, for the accounts Called_From__c = 'Scheduler', TriggerRecordsFromScheduler.size() > 0 was getting satisfied and it was trying to start
        // another batch job again and se we were seeing this exception.
        // Fix - I reached out to dev team to find out the usange of this field Called_From__c = 'Scheduler', but nobody has a clue why this
        // field is here and what is its use. Also, ideally we should be reseting this field to empty once it has been used by the jobs
        // but I couldn't confirm this with anyone. So I am putting a safest fix that don't start another Job when a batch job is already
        // in progress.
        // Also, what I understood from the team that this is a very old code and may not be relavent anymore
        // Also it is good to clean this field because, eveytime we make a small change on Accounts where Called_From__c != null
        // will re-run the same jobs again.
        if(TriggerRecordsFromScheduler.size() > 0 && !System.isBatch()){            
           GlblHdSalesContactShareGlblRschrAccBL.ShareContactWithGlobalHeadResearchAccountForScheduler(TriggerRecordsFromScheduler,oldRecords); 
        }
            
        else if(TriggerRecordsFromGUI.size() > 0){
             GlblHdSalesContactShareGlblRschrAccBL.ShareContactWithGlobalHeadResearchAccount(TriggerRecordsFromGUI,oldRecords);
        }
       
        
    }
    
     public static void onAfterInsert(List<Account> newRecords){
        GlblHdSalesContactShareGlblRschrAccBL.ShareContactWithGlobalHeadResearchAccount(newRecords);
        
    }
    
     public static void onBeforeInsert(List<Account> newRecords){
        GlblHdSalesContactShareGlblRschrAccBL.MarkAccountsAsRestrictedBasedonRestrictedCountries(newRecords);
        
    }
    
     public static void onBeforeUpdate(List<Account> newRecords,Map<Id,Account> oldRecords){
        for(Account accountRec: newRecords){
            Id rmRecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Account', 'RM_Account');
            system.debug('RM RecordType Id: '+rmRecordTypeId);
            if(accountRec.RecordTypeId == rmRecordTypeId){
                Account oldAccount = oldRecords.get(accountRec.Id);
                system.debug('Old Account: '+oldAccount.ParentId);
                system.debug('New  Account: '+accountRec.ParentId);
                //section updated for JIRA 3643, check for active and reparenting
                if(oldAccount.ParentId!=null && accountRec.ParentId!= null && (accountRec.ParentId != oldAccount.ParentId)) //If current RG is not equal to old RG
                {
                    //if(oldAccount.Previous_RG__c == null || oldAccount.Previous_RG__c == '' || oldAccount.Previous_RG__c == 'NA' )
                    accountRec.Previous_RG__c = oldAccount.ParentId ;
                }
                else if(oldAccount.ParentId!=null && accountRec.ParentId == null && (accountRec.ParentId != oldAccount.ParentId)) //If current RG is not equal to old RG
                {
                    accountRec.Previous_RG__c = oldAccount.ParentId ;
                }
                else if((oldAccount.ParentId == null && (accountRec.Previous_RG__c == null || accountRec.Previous_RG__c == '')  && (accountRec.ParentId != oldAccount.ParentId)) ||((accountRec.Active__c != oldAccount.Active__c) && accountRec.Active__c == true)){
                    accountRec.Previous_RG__c = 'NA';
                }
                
                 //added for JIRA 3163
                 if(accountRec.Previous_RG__c <> null && accountRec.Previous_RG__c <> '' && accountRec.Previous_RG__c <>'NA'){
                    String PreviousRG = accountRec.Previous_RG__c;
                    PreviousRG = PreviousRG.substring(0,15);
                    system.debug('PreviousRG **'+ PreviousRG);
                    if(PreviousRG == accountRec.Current_RG__c)
                     	accountRec.Previous_RG__c = '';
                } 
            }  
        }
    }
    
    public static void AddRSRGRMForScramblingIfAccountIsCapIntroOnly(List<Account> newRecords,Map<Id,Account> oldRecords){
       /* system.debug('in AddRSRGRMForScramblingIfAccountIsCapIntroOnly');
        List<Configuration__c> config = [SELECT Parameter_Value__c  from Configuration__c where Param_Name__c = 'AccountsToScramble' ];
        string textAdd = '' ;
        string textDelete = '';          
        
    
        for(Account accountRec : newRecords){
            system.debug('accountRec.CapIntro_Only__c :'+ accountRec.CapIntro_Only__c);
            
            
            if(accountRec.CapIntro_Only__c){
                system.debug(' in loop :'+ accountRec.CapIntro_Only__c);                
                system.debug('config :' + config);
                system.debug('accountRec.RDM_Org_ID__c :'+ accountRec.RDM_Org_ID__c);
                if(!String.valueOf(config[0].Parameter_Value__c).contains(accountRec.RDM_Org_ID__c)){
                    system.debug('accountRec.Parent.CapIntro_Only__c :'+ accountRec.Parent.CapIntro_Only__c);
                    system.debug('recName :'+ accountRec.RecordType.Name);
                    system.debug('condition :'+ accountRec.RecordType.Name == 'RM Account' && accountRec.Parent.CapIntro_Only__c ==false);
                    if(accountRec.RDM_Org_ID__c.contains('RM') && accountRec.Parent.CapIntro_Only__c ==false){
                    textAdd = textAdd + accountRec.RDM_Org_ID__c + ';';
                }
                else
                {
                    if(accountRec.RDM_Org_ID__c.contains('RG') || accountRec.RDM_Org_ID__c.contains('RS') ){
                        textAdd = textAdd + accountRec.RDM_Org_ID__c + ';';
                    }                    
                }
            }
                   
            }
            
            else
            {
                              
                if(config[0].Parameter_Value__c.contains(accountRec.RDM_Org_ID__c)){
                    //config[0].Parameter_Value__c  =  string.valueOf(config[0].Parameter_Value__c).remove(accountRec.RDM_Org_ID__c+';'); 
                    textDelete = textDelete + accountRec.RDM_Org_ID__c + ';';
                }
            }
        
        }
        
        system.debug('textAdd :'+ textAdd);
         system.debug('textDelete :'+ textDelete);
        
        if(!string.isBlank(textAdd)){
            textAdd = textAdd.removeEnd(';');
            config[0].Parameter_Value__c = config[0].Parameter_Value__c + ';' + textAdd;
        }
        
         if(!string.isBlank(textDelete)){
            //textDelete = textDelete.removeEnd(';');
             string [] textToBeRemoved = new string[]{};
             textToBeRemoved = textDelete.split(';');
             
             system.debug('textToBeRemoved :'+ textToBeRemoved);
             string textToBeErased = '';
             textToBeErased = config[0].Parameter_Value__c;
             for(string val : textToBeRemoved){
                 if(textToBeErased.contains(';' + val)){
                     textToBeErased =  string.valueOf(textToBeErased).remove(';' +val);
                 }
                 else
                 {
                   textToBeErased =  string.valueOf(textToBeErased).remove(';' + val);  
                 }
                 
                 system.debug('textToBeErased :'+ textToBeErased);
             }
             
             config[0].Parameter_Value__c = textToBeErased;
            
        }
        
        
        update config[0]; */
        
        GlblHdSalesContactShareGlblRschrAccBL.AddRSRGRMForScramblingIfAccountIsCapIntroOnly(newRecords,oldRecords);
        
    }
    
    
   
}