@isTest
public class FactsetDataServiceTest {  
    
    /*@testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Factset_API_Settings__c factsetIdSearchAPISettings = new Factset_API_Settings__c;
        factsetIdSearchAPISettings.Factset_API_URL__c = ''; 
            factsetIdSearchAPISettings.Factset_API_Endpoint__c, 
            factsetIdSearchAPISettings.Factset_API_User_Name__c, factsetIdSearchAPISettings.Factset_SF_IP_Range_API_Key__c, 
            factsetIdSearchAPISettings.API_Method__c
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
    }*/

    
    @isTest(SeeAllData=true)
    static void testGetLegalEntityInformation() {        
        Test.startTest();
        
        Map<String, String[]> andFilters = new Map<String, String[]>();
        String[] avalues = new String[]{'US','GB'};
            andFilters.put(FactsetDataService.fieldfref_entity_country, avalues);
        String[] bvalues = new String[]{'true'};
            andFilters.put(FactsetDataService.fieldfref_entity_status, bvalues);
        String[] cvalues = new String[]{'true'};
            andFilters.put(FactsetDataService.fieldfref_ultimate_parent_id, cvalues);

        FactsetDataService.runningIdSearchHappyPathTest = True;
        FactsetDataService.runningIdSearchTypeAheadNullTest = False;
        FactsetDataService.runningIdSearchTypeAheadNotSuccessTest = False;
        FactsetDataService.runningIdSaearchSadPathTest = False;
        FactsetDataService.runningOnDemandSadPathTest = False;
        FactsetDataWrapper.FactsetEntityReferencesResponseWrapper fserrw = FactsetDataService.getLegalEntityInformation('Nomura Asset', andFilters, null);
        if(fserrw != null){
            FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
        }
        fserrw = FactsetDataService.getLegalEntityInformation('Nomura Asset', null, null);
        if(fserrw != null){
            FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
        }
        
        FactsetDataService.runningIdSearchHappyPathTest = False;
        FactsetDataService.runningIdSearchTypeAheadNullTest = True;
        FactsetDataService.runningIdSearchTypeAheadNotSuccessTest = False;
        FactsetDataService.runningIdSaearchSadPathTest = False;
        FactsetDataService.runningOnDemandSadPathTest = False;
        fserrw = FactsetDataService.getLegalEntityInformation('Nomura Asset', andFilters, null);
        if(fserrw != null){
            FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
        }
        
        FactsetDataService.runningIdSearchHappyPathTest = False;
        FactsetDataService.runningIdSearchTypeAheadNullTest = False;
        FactsetDataService.runningIdSearchTypeAheadNotSuccessTest = True;
        FactsetDataService.runningIdSaearchSadPathTest = False;
        FactsetDataService.runningOnDemandSadPathTest = False;
        fserrw = FactsetDataService.getLegalEntityInformation('Nomura Asset', andFilters, null);
        if(fserrw != null){
            FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
        }
        
        FactsetDataService.runningIdSearchHappyPathTest = False;
        FactsetDataService.runningIdSearchTypeAheadNullTest = False;
        FactsetDataService.runningIdSearchTypeAheadNotSuccessTest = False;
        FactsetDataService.runningIdSaearchSadPathTest = True;
        FactsetDataService.runningOnDemandSadPathTest = False;
        fserrw = FactsetDataService.getLegalEntityInformation('Nomura Asset', andFilters, null);
        if(fserrw != null){
            FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
        }
        
        FactsetDataService.runningIdSearchHappyPathTest = True;
        FactsetDataService.runningIdSearchTypeAheadNullTest = False;
        FactsetDataService.runningIdSearchTypeAheadNotSuccessTest = False;
        FactsetDataService.runningIdSaearchSadPathTest = False;
        FactsetDataService.runningOnDemandSadPathTest = True;
        fserrw = FactsetDataService.getLegalEntityInformation('Nomura Asset', andFilters, null);
        if(fserrw != null){
            FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
        }
        Test.stopTest();
    }
}