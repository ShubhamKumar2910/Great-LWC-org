trigger RGCoverageRequestCrtMultipleeRMReqs on RG_Coverage_Request__c (before insert) {
  /*  System.debug('RGCoverageRequestCreateRMReq ' );
    ID userId = UserInfo.getUserId() ;
    System.debug('userId ' + userId);
    for(RG_Coverage_Request__c ar : Trigger.new) {
        ID accountID = ar.RG_Account__c;
        System.debug('Id of Account RG :: ' + accountID);
        Account [] accounts = [Select name, RG_Account__c, RM_Account__c from Account where  id= :accountID];
        if(null!=accounts && accounts.size()>0){
            System.debug('name :: ' + accounts[0].name + ' :: is RG :: ' + accounts[0].RG_Account__c);
            if(accounts[0].RG_Account__c){
                System.debug('is an RG Account');
                Account [] rmAccounts = [Select name, RG_Account__c, RM_Account__c from Account where Active__c= true and Restricted_Flag__c=false and parent.id= :accountID];
                System.debug('no of child accounts :: ' + rmAccounts.size());
                List<Coverage_Access_Request__c> rmCoverageRequests = new List<Coverage_Access_Request__c>();
                for(Account rmAccount:rmAccounts){
                    Coverage_Access_Request__c rmCoverageAccessRequest = new Coverage_Access_Request__c();
                    rmCoverageAccessRequest.Account__c = rmAccount.id;
                    rmCoverageAccessRequest.Type_of_Coverage__c = 'Add';
                    rmCoverageAccessRequest.Reason_for_Request__c = ar.Reason_for_Request__c;
                    rmCoverageAccessRequest.Start_Date__c = ar.Start_Date__c;
                    rmCoverageAccessRequest.End_Date__c = ar.End_Date__c;
                    rmCoverageAccessRequest.Product__c = ar.Product__c;
                    rmCoverageAccessRequest.Product_Group__c = ar.Product_Group__c;
                    rmCoverageAccessRequest.Product_Region__c = ar.Product_Region__c;
                    rmCoverageAccessRequest.Role__c = ar.Role__c;
                    rmCoverageAccessRequest.Sales_Team_for_Coverage__c = ar.Sales_Team_for_Coverage__c;
                    rmCoverageAccessRequest.Type_of_Coverage__c  = ar.Type_of_Coverage__c;                    
                    rmCoverageRequests.add(rmCoverageAccessRequest);
                    System.debug('added rm covereage');
                }
                if(rmCoverageRequests.size()>0){
                    System.debug('rm covereage size ' + rmCoverageRequests.size());
                    insert rmCoverageRequests;
                    System.debug('inserted rm covereage');
                }
            }
        }
       
        
    }*/
}