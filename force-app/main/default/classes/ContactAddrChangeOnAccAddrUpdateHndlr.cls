public class ContactAddrChangeOnAccAddrUpdateHndlr {
    public static void onAfterUpdate(List<Account> newRecords,Map<Id,Account> oldRecords){
        ContactAddrChangeOnAccAddrUpdateBL.MarkAccountsAsRestrictedBasedonRestrictedCountries(newRecords,oldRecords);
        ContactAddrChangeOnAccAddrUpdateBL.ContactAddrChangeOnAccAddrUpdate(newRecords,oldRecords);
        ContactAddrChangeOnAccAddrUpdateBL.contactMailingAddrChangeOnAccOfficeAddrUpdate(newRecords,oldRecords);
    }
    
    public static void onBeforeInsert(List<Account> newRecords){
       ContactAddrChangeOnAccAddrUpdateBL.PopulateBlankAddressFieldsForRMAccount(newRecords);
    }
}