public class LegalAgreementTriggerBL {

 public static void populateLastSuccessfulLoadDateLookup(List<Legal_Agreement__c> newLegalAgreementList)
    {
        String Param_Name = 'LastUpdatedTimeStamp';
        String Conf_Name = 'ImporterJob_Legal_Agreement__c';

        List<Configuration__c> Conf_Id_List = [SELECT Id FROM Configuration__c WHERE Param_Name__c = :Param_Name AND Name = :Conf_Name];

        if(Conf_Id_List != null && Conf_Id_List.size() > 0)
        {
            for(Legal_Agreement__c legalAgreement : newLegalAgreementList)
            {
                legalAgreement.Last_Successful_Load_Date_Time__c = Conf_Id_List.get(0).Id;
            }
        }
    }
}