public class EmailImpersonatableUserController {
    // *** Constructor ***
    public EmailImpersonatableUserController(){
    }

    
    // *** Public Properties ***
    public List<String> InitApprovedUserList  {get;set;}
    public List<String> NewApprovedUserList  {get;set;}

    
    // *** Actions ***
    // EmailEditImpersonatableUser page - Initialization
    public PageReference initEmailEditImpersonatableUser(){
        InitApprovedUserList = new List<String>(getUserIdList());
        NewApprovedUserList = new List<String>();
        return null;
    }
    // EmailEditImpersonatableUser page - Apply button
    public PageReference applyImpersonatableUsers(){
        saveMassEmailImpersonatableUser();
        return null;
    }

    // *** Private Methods ***
    // To get a user id list of Approved Users from MassEmailImpersonatableUser__c objects for UserMultiSelectComponent
    private List<String> getUserIdList(){
        List<MassEmailImpersonatableUser__c> users = [SELECT ApprovedUser__r.Id FROM MassEmailImpersonatableUser__c WHERE Owner.Id=:UserInfo.getUserId()];
        List<String> newList = new List<String>();
        for(MassEmailImpersonatableUser__c u : users){
            newList.add(u.ApprovedUser__r.Id);
        }
        return newList;
    }
    // To save current user id lists into MassEmailImpersonatableUser__c
    private void saveMassEmailImpersonatableUser(){
        List<MassEmailImpersonatableUser__c> deleteList = [SELECT Id FROM MassEmailImpersonatableUser__c WHERE Owner.Id=:UserInfo.getUserId()];
        delete deleteList;

        List<MassEmailImpersonatableUser__c> newList = new List<MassEmailImpersonatableUser__c>();
        for(String userId : NewApprovedUserList){
            MassEmailImpersonatableUser__c usr = new MassEmailImpersonatableUser__c();
            usr.ApprovedUser__c = userId;
            newList.add(usr);
        }

        insert newList;
    }
}