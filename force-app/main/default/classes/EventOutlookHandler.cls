global class EventOutlookHandler {

    @InvocableMethod
    public static void populateWhatId(List < Id > tid) {
        System.debug('in populate whatId' + tid[0]);
        Event[] updateEvent = [select whatId, whoId from Event where id =: tid[0]];
        if (updateEvent.size() > 0) {
            Event t = updateEvent[0];
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