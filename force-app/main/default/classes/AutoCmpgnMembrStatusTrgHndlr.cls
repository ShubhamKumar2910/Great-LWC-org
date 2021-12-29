public class AutoCmpgnMembrStatusTrgHndlr {

    public static void OnAfterInsertAndUpdate(List<Campaign> newRecords){
      AutoCmpgnMembrStatusTrgBL.OnAfterInsertAndUpdate(newRecords) ;
}
}