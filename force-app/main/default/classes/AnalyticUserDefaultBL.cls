public without sharing class AnalyticUserDefaultBL {
    public static void CreateAUDShareRecords(Map<Id, Analytics_User_Default__c> newRecords){
        List<Analytics_User_Default__share> RevenueSharesToCreate = new List<Analytics_User_Default__share>();
        Map<Id, Set<Id>> shareMap = new Map<Id, Set<Id>>();
        //create a map of shares where id is the aud and key is list of userorgroupid
        for (List<Analytics_User_Default__share> audShareList: [SELECT ParentId, UserOrGroupId from Analytics_User_Default__share where ParentId in: newRecords.keySet()]) {
            for(Analytics_User_Default__share share: audShareList) {
                Set<Id> userOrGroupIds = shareMap.get(share.ParentId);
                if (null == userOrGroupIds) {
                    userOrGroupIds = new Set<Id>();
                    shareMap.put(share.ParentId, userOrGroupIds);
                }
                userOrGroupIds.add(share.UserOrGroupId);
            }
        }

        //how iterate the newRecords map and find the value of the record in the share map
        //interrogate the set of userorgroupids for the share to see it contains the User__c value on the AUD that has changed
        //if its not in the set, add to a list of shares to create
        Analytics_User_Default__c aud = null;
        Analytics_User_Default__share shareToCreate = null;
        Set<Id> userOrGroupIds = new Set<Id>();
        List<Analytics_User_Default__share> sharesToCreate = new List<Analytics_User_Default__share>();
        for (Id key: newRecords.keySet()) {
            aud = newRecords.get(key);
            shareToCreate = new Analytics_User_Default__share();
            shareToCreate.ParentId = key;
            shareToCreate.UserOrGroupId = aud.User__c;
            shareToCreate.accesslevel = 'Edit';

            //get the shares for this aud
            userOrGroupIds = shareMap.get(key);
            //if the share doesn't exist for this record
            if (!userOrGroupIds.contains(aud.User__c)) {
                sharesToCreate.add(shareToCreate);
            }
        }
        //now save
        if (sharesToCreate.size()>0) {
            System.debug('Creating shares for Analytics_User_Default__c object');
            insert sharesToCreate;
        } 
    }
}