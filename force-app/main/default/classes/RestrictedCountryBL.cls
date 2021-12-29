public class RestrictedCountryBL 
{
    public static Map<string,string> getCountryIsoByCodes(){
        Map<string,string> mapCodes = new  Map<string,string>();
        for(ISO_Country__c countrydata: [select name, Country_Code__c,Country__c from ISO_Country__c]){
            mapCodes.put(countrydata.Country_Code__c.trim(), countrydata.Country__c.trim());
        }
        return mapCodes;
    }
      public static Map<string,string> getCodesByCountry(){
        Map<string,string> mapCodes = new  Map<string,string>();
        for(ISO_Country__c countrydata: [select name, Country_Code__c,Country__c from ISO_Country__c]){
            mapCodes.put(countrydata.Country__c.trim().tolowerCase(),countrydata.Country_Code__c.trim());
        }
        return mapCodes;
    }
    public static void setUnsetRestrictedAccounts(List<Restricted_Countries__c> restrictions, Boolean flagStatus)
    {
        List<String> restrictedCountries = new List<String>();
        for(Restricted_Countries__c restrCountries : restrictions)
        {
            restrictedCountries.add(restrCountries.Restricted_Country_Name__c);
        }
        
        try
        {
            updateAccountRestrictedFlag(restrictedCountries, flagStatus);
        }
        catch(exception ex)
        {
            restrictions[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
        }
    } 
    
    
    public static void updateAccountRestrictedFlag(List<String> countries, Boolean flagStatus)
    {
        List<Account> accsToUpdate = new List<Account>(); 
        Map<string,string> mapCodes = new  Map<string,string>();
        Set<string> domicileCodes = new Set<string>();
        mapCodes = RestrictedCountryBL.getCodesByCountry();
        for(string res_country: countries){
            if(mapCodes.get(res_country.trim().toLowerCase())!=null)
                domicileCodes.add(mapCodes.get(res_country.trim().toLowerCase()).trim());
        }   
        
        for(Account loopAcc : [
            SELECT Id, Name 
            FROM Account 
            WHERE Domicile_Country__c IN :domicileCodes 
            AND (Restricted_Flag__c != : flagStatus OR Called_From__c != 'Scheduler')  
        ])
        {
            loopAcc.Restricted_Flag__c = flagStatus;
            loopAcc.Called_From__c = 'Scheduler';  
            accsToUpdate.add(loopAcc); 
        }
        
        update accsToUpdate;
    }
    
}