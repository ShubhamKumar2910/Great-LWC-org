public class GlblHdSalesContactShareGlblRschrHndlr {
    public static void onAfterUpdate(List<Contact> newRecords,Map<Id,Contact> oldRecords){
        GlblHdSalesContactShareGlblRschrBL.ShareContactWithGlobalHeadResearchAccount(newRecords,oldRecords);           
        
    }
}