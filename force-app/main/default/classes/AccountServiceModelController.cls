public class AccountServiceModelController {

    public static void validateData(List<Account_Service_Model__c> models) {
        AccountServiceModelBL.validateData(models);
    }
    
    public static void populateExternalId(List<Account_Service_Model__c> models) {
        AccountServiceModelBL.populateExternalId(models);
    }

    public static void modifyTotalRecord(List<Account_Service_Model__c> models) {
        AccountServiceModelBL.modifyTotalRecord(models);
    }
    
    public static void updateModelVersion(List<Account_Service_Model__c> models) {
        AccountServiceModelBL.updateVersions(models);
    }
    
    public static void flagDuplicatesIfAny(List<Account_Service_Model__c> models) {
        AccountServiceModelBL.flagDuplicatesIfAny(models);
    }

	public static void updateConfigForModelName(){
        AccountServiceModelBL.updateConfigForModelName();
    }    
}