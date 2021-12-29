trigger AccountVoteRankTrigger on Account_Vote_Ranks__c ( before delete, before insert, before update,
                             after delete, after insert, after update, after undelete) {    
                            
            if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
                System.debug('AccountVoteRankTrigger Before: insert/update');
                for (Account_Vote_Ranks__c vote: Trigger.new) {
                    String region = vote.Regions__c;
                    if(vote.Account_Name_FX__c!=null)
                    vote.AccountName__c = vote.Account_Name_FX__c;     
                    vote.Period_Year__c = vote.Period__c + '-' + vote.Year__c;
                    if(vote.Country__c == null)
                        vote.Product_Service__c = vote.PRODUCT__c + '-' + vote.SERVICE__c;
                    else
                        vote.Product_Service__c = vote.PRODUCT__c + '-' + vote.COUNTRY__c + '-' + vote.SERVICE__c;

                    vote.Is_Americas__c = null;
                    vote.Is_EMEA__c = null;
                    vote.Is_AEJ__c = null;
                    vote.Is_Japan__c = null;
                    vote.Is_Global__c = null;                    
                    vote.Is_Region_Blank__c = null;                   
                    
                   if (region != null) {
                        if (Region.contains('Americas')) vote.Is_Americas__c = 1;
                        if (Region.contains('EMEA')) vote.Is_EMEA__c = 1;
                        if (Region.contains('AEJ')) vote.Is_AEJ__c = 1;
                        if (Region.contains('Japan')) vote.Is_Japan__c = 1;                        
                        if (Region.contains('Global')) vote.Is_Global__c = 1;                                                                                          
                    }                    
                    else{
                        vote.Is_Region_Blank__c = 1;
                    }
                }   
            }
    }