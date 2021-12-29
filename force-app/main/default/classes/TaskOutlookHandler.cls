global class TaskOutlookHandler {
    @InvocableMethod
    public static void populateWhatId(List < Id > tid) {
        System.debug('in populate whatId' + tid[0]);
        Task[] updateTask = [select whatId, whoId from Task where id =: tid[0]];
        if (updateTask.size() > 0) {
            Task t = updateTask[0];
            if (null != t.whoId && null == t.whatID) {
                System.debug('outlook handler whatID is null');
                Contact[] contacs = [SELECT AccountId FROM Contact WHERE Id =: t.whoId];
                if (contacs.size() > 0) {
                    Account[] contactAccounts = [select id, name, parentId from Account WHERE id =: contacs[0].AccountId];
                    if (contactAccounts.size() > 0) {
                        if (null != contactAccounts[0].parentid) {
                            t.whatId = contactAccounts[0].parentid;
                            
                            update t;
                        }
                     }
                  }
              }
          }
      }

}