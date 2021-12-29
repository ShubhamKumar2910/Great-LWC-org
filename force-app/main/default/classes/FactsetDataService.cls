public class FactsetDataService {
    private static Boolean onDemandAPIForEntityReference = true;
    public enum FactsetAPI {IDSEARCH, ENTITYREFERENCES}
    public static String fieldfref_entity_country = 'fref_entity_country';
    public static String fieldfref_entity_status = 'fref_entity_status';
    public static String fieldfref_ultimate_parent_id = 'fsym_ultimate_parent_id';
    public static String[] entities = new String[]{'equities','private_companies','pevc_firms', 'ownership_holders'};
    //public static String[] entities = new String[]{'bonds','commodities','forex','indices','indices_realtime','people','pevc_funds','mutual_funds'};
        
    //https://my.apps.factset.com/oa/pages/17496#cap_struct
    private static String onDemandItems = '&items=FSYM_ENTITY_ID,FS_FEID_COMP_NAME,FSYM_ULTIMATE_PARENT_ID,FREF_ULTIMATE_PARENT_NAME,FREF_ENTITY_COUNTRY(HQ,ISO2),FREF_ENTITY_IDENTIFIER(LEI),FREF_ENTITY_STATUS(EXT,DESC)';
    //private static String onDemandItems = '&items=FSYM_ENTITY_ID,FS_FEID_COMP_NAME,FSYM_PARENT_EQUITY,FREF_PARENT_EQUITY_NAME,FSYM_ULTIMATE_PARENT_ID,FREF_ULTIMATE_PARENT_NAME,FSYM_Entity_ID_Type,FSYM_Entity_ID_Value';
        
    private static String customSettingFactsetIdSearchName = 'Factset Id Search';
    private static String customSettingFactsetEntityReferencesName = 'Factset Entity References';
    private static String customSettingFactsetOnDemandEntityReferencesName = 'Factset OnDemand Entity References';
    
    public static Boolean runningIdSearchHappyPathTest = False;
    public static Boolean runningIdSearchTypeAheadNullTest = False;
    public static Boolean runningIdSearchTypeAheadNotSuccessTest = False;
    public static Boolean runningIdSaearchSadPathTest = False;
    public static Boolean runningOnDemandSadPathTest = False;
    
    public static FactsetDataWrapper.FactsetEntityReferencesResponseWrapper getLegalEntityInformation(String searchPattern, Map<String, String[]> andFilters, Integer rowLimit){
        Factset_API_Settings__c factsetIdSearchAPISettings = Factset_API_Settings__c.getValues(customSettingFactsetIdSearchName);
        
        FactsetDataWrapper.FactsetEntityReferencesResponseWrapper fserrw;
        
        String emailErrorSubject = 'Error with factset callout : ';
        String emailErrorBody;
        
        if(rowLimit == null){
            rowLimit = 25;
        }
        String searchJSONString = '{}';
        HttpResponse response;
        String responseJSONString = '{}'; 
        
        FactsetDataWrapper fdw = new FactsetDataWrapper(FactsetAPI.IDSEARCH, searchPattern, rowLimit);
        searchJSONString = fdw.getFacsetRequestBodyJSON();
        system.debug('searchJSONString: '+searchJSONString);
        system.debug('factsetIdSearchAPISettings: '+factsetIdSearchAPISettings);
        if (!Test.isRunningTest()){
			response = MakeCallout.MakeCalloutWithBasicAuthentication(factsetIdSearchAPISettings.Factset_API_URL__c, factsetIdSearchAPISettings.Factset_API_Endpoint__c, factsetIdSearchAPISettings.Factset_API_User_Name__c, factsetIdSearchAPISettings.Factset_SF_IP_Range_API_Key__c, factsetIdSearchAPISettings.API_Method__c, searchJSONString, 'application/json');
        }
        if(response != null || Test.isRunningTest()){
            if (!Test.isRunningTest()){
            	responseJSONString = response.getBody();
            } else if (runningIdSearchHappyPathTest) {
            	responseJSONString = '{"typeahead":{"result_count":{"pevc_firms":10},"error":"null","is_success":1,"results":[{"index": "pevc_firms","symbol": "A-US","name":"Agilent Technologies,Inc.","entity_id":"002LV5-E"},{"index":"pevc_firms","fds_id":"AAPL-US","name":"Apple Inc.","entity_id":"000C7F-E"}]}}';
            }
            else if (runningIdSearchTypeAheadNullTest) {
            	responseJSONString = '{"typeahead":null,"status": "Bad Request", "timestamp": "2020-11-05 16:16:25.963", "path": "/v1/idsearch", "message": "The pattern is required and may not be empty."}';
            }
            else if (runningIdSearchTypeAheadNotSuccessTest) {
            	responseJSONString = '{"typeahead":{"result_count":{"pevc_firms":10},"error":"null","is_success":0,"results":[{"index": "pevc_firms","symbol": "A-US","name":"Agilent Technologies,Inc.","entity_id":"002LV5-E"},{"index":"pevc_firms","fds_id":"AAPL-US","name":"Apple Inc.","entity_id":"000C7F-E"}]}}';
            } 
            else if (runningIdSaearchSadPathTest){
                responseJSONString = '{"status": "Bad Request", "timestamp": "2020-11-05 16:16:25.963", "path": "/v1/idsearch", "message": "The pattern is required and may not be empty."}';
            }
            //system.debug('**idresponse*** ' + responseJSONString);
            if(String.isNotEmpty(responseJSONString)){
            	try{
                    FactsetDataWrapper.FactsetIDSearchResponseWrapper fsidsrw = (FactsetDataWrapper.FactsetIDSearchResponseWrapper)JSON.deserialize(responseJSONString, FactsetDataWrapper.FactsetIDSearchResponseWrapper.class);
                    //system.debug(fsidsrw);
                    FactsetDataWrapper.FactsetIDSearchResponseHeadWrapper typeahead = fsidsrw.typeahead;
                    if(typeahead != null){
                        if(typeahead.is_success == 1) {
                            if (!Test.isRunningTest()){
                                if(onDemandAPIForEntityReference){
                                    fserrw = getEntityReferencesOnDemand(typeahead, andFilters);
                                } else {
                                    fserrw = getEntityReferences(typeahead, andFilters);
                                }
                            } else {
                                fserrw = getEntityReferencesOnDemand(typeahead, andFilters);
                                fserrw = getEntityReferences(typeahead, andFilters);
                            }
                            
                        } else {
                            emailErrorSubject += 'Id Search';
                            emailErrorBody = typeahead.error;
                            CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                        }                
                    } else {
                        try{
                            FactsetDataWrapper.FactsetResponseFailureWrapper fsrfw = (FactsetDataWrapper.FactsetResponseFailureWrapper)JSON.deserialize(responseJSONString, FactsetDataWrapper.FactsetResponseFailureWrapper.class);
                            emailErrorSubject += 'Id Search';
                            emailErrorBody = fsrfw.message;
                            CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                        }
                        catch (System.JSONException ee){
                            emailErrorSubject += 'Id Search';
                            emailErrorBody = ee.getMessage();
                            CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                        }
                    }
                }
                catch (System.JSONException e){
                    emailErrorSubject += 'Id Search';
                    emailErrorBody = e.getMessage();
                    CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                }
            }
            
        }  
        return fserrw;
    }
	
    private static FactsetDataWrapper.FactsetEntityReferencesResponseWrapper getEntityReferences(FactsetDataWrapper.FactsetIDSearchResponseHeadWrapper typeahead, Map<String, String[]> andFilters){
        Factset_API_Settings__c factsetEntityReferencesAPISettings = Factset_API_Settings__c.getValues(customSettingFactsetEntityReferencesName);
        String[] ids = new String[]{};
        String searchJSONString = '{}';
        String responseJSONString = '{}';
        String emailErrorSubject = 'Error with factset callout : ';
        String emailErrorBody;
        FactsetDataWrapper.FactsetEntityReferencesResponseWrapper fserrw;
        
        for(FactsetDataWrapper.FactsetIDSearchResponseResultWrapper result : typeahead.results){
            system.debug(' result.fds_id: ' + result.fds_id + ' result.name: ' + result.name + ' result.fds_id: ' + result.symbol + ' result.fds_id: ' + result.index);
            if(String.isNotEmpty(result.fds_id)){
                ids.add(result.fds_id);
            } else {
                ids.add(result.symbol);
            }                            
        } 
        system.debug(ids);
        if(ids.size() > 0){
            FactsetDataWrapper fdw = new FactsetDataWrapper(FactsetAPI.ENTITYREFERENCES, ids, andFilters);
            searchJSONString = fdw.getFacsetRequestBodyJSON();
            //system.debug(searchJSONString);
            HttpResponse response;
            if (!Test.isRunningTest()){
                response = MakeCallout.MakeCalloutWithBasicAuthentication(factsetEntityReferencesAPISettings.Factset_API_URL__c, factsetEntityReferencesAPISettings.Factset_API_Endpoint__c, factsetEntityReferencesAPISettings.Factset_API_User_Name__c, factsetEntityReferencesAPISettings.Factset_SF_IP_Range_API_Key__c, factsetEntityReferencesAPISettings.API_Method__c, searchJSONString, 'application/json');
            }
            
            if(response != null || Test.isRunningTest()){
                if(!Test.isRunningTest()){
                	responseJSONString = response.getBody();
                } else {
                	responseJSONString = '{ "data": [   {     "fsymId": "001MF1-E",     "entityProperName": "Amazon.com, Inc.",     "fsymEntityId": "001MF1-E",     "ultimateParentId": "001MF1-E",     "ultimateParentName": "Amazon.com, Inc.",     "creditParentId": "001MF1-E",     "parentEquityId": "MCNYYL-R",     "website": "http://www.amazon.com",     "incorporationDate": "1996-05-28",     "countryOfRisk": "US",     "incorporationCountry": "US",     "businessDescription": "Amazon.com, Inc. engages in the provision of Online retail shopping services. It operates through the following business segments: North America, International, and Amazon Web Services (AWS). The North America segment includes retail sales of consumer products and subscriptions through North America-focused websites such as www.amazon.com and www.amazon.ca. The International segment offers retail sales of consumer products and subscriptions through internationally-focused websites. The Amazon Web Services segment involves in the global sales of compute, storage, database, and AWS service offerings for start-ups, enterprises, government agencies, and academic institutions. The company was founded by Jeffrey P. Bezos in July 1994 and is headquartered in Seattle, WA.",     "phone": "+1.206.266.1000",     "headquartersStreet": "410 Terry Avenue North",     "headquartersCity": "Seattle",     "headquartersState": "WA",     "headquartersZip": "98109-5210",     "headquartersCountry": "US",     "emailIR": "amazon-ir@amazon.com",     "websiteIR": "https://ir.aboutamazon.com/overview/default.aspx",     "requestId": "AMZN-US"   } ]}';
                }
                //system.debug('**referenceresponse*** ' + responseJSONString);
                if(String.isNotEmpty(responseJSONString)){
                    try{
                        fserrw = (FactsetDataWrapper.FactsetEntityReferencesResponseWrapper)JSON.deserialize(responseJSONString, FactsetDataWrapper.FactsetEntityReferencesResponseWrapper.class);
                        //system.debug(fserrw);
                        FactsetDataWrapper.FactsetEntityReferencesResponseDataWrapper[] data = fserrw.data;
                        /*if(data == null || data.size() == 0){
                            try{
                                FactsetDataWrapper.FactsetResponseFailureWrapper fsrfw = (FactsetDataWrapper.FactsetResponseFailureWrapper)JSON.deserialize(responseJSONString, FactsetDataWrapper.FactsetResponseFailureWrapper.class);
                                emailErrorSubject += 'Entity References';
                                emailErrorBody = fsrfw.message;
                                CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                            }
                            catch (System.JSONException ee){
                                emailErrorSubject += 'Entity References';
                                emailErrorBody = ee.getMessage();
                                CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                            }              
                        }*/
                    }
                    catch (System.JSONException e){
                        emailErrorSubject += 'Entity References';
                        emailErrorBody = e.getMessage();
                        CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                    }
                }
            } 
        } 
        return fserrw;
    }
    
    private static FactsetDataWrapper.FactsetEntityReferencesResponseWrapper getEntityReferencesOnDemand(FactsetDataWrapper.FactsetIDSearchResponseHeadWrapper typeahead, Map<String, String[]> andFilters){
        Factset_API_Settings__c factsetEntityReferencesAPISettings = Factset_API_Settings__c.getValues(customSettingFactsetOnDemandEntityReferencesName);
        Boolean hasIds =  false;
        String searchJSONString;
        String responseJSONString = '{}';
        String emailErrorSubject = 'Error with factset callout : ';
        String emailErrorBody;
        FactsetDataWrapper.FactsetEntityReferencesResponseWrapper fserrw;
        
        for(FactsetDataWrapper.FactsetIDSearchResponseResultWrapper result : typeahead.results){
            system.debug(' result.fds_id: ' + result.fds_id + ' result.name: ' + result.name + ' result.symbol: ' + result.symbol + ' result.index: ' + result.index);
            if(hasIds){
                searchJSONString += ',';
            } else {
                searchJSONString = 'ids=';
            }
            
            if(String.isNotEmpty(result.fds_id)){
                searchJSONString += result.fds_id;
            } else {
                searchJSONString += result.symbol;
            }  
            hasIds = true;
        } 
        //system.debug(searchJSONString);
        if(String.isNotEmpty(searchJSONString)){           
            searchJSONString += onDemandItems;
            HttpResponse response;
            if(!Test.isRunningTest()){
            	response = MakeCallout.MakeCalloutWithBasicAuthentication(factsetEntityReferencesAPISettings.Factset_API_URL__c, factsetEntityReferencesAPISettings.Factset_API_Endpoint__c, factsetEntityReferencesAPISettings.Factset_API_User_Name__c, factsetEntityReferencesAPISettings.Factset_Password__c, factsetEntityReferencesAPISettings.API_Method__c, searchJSONString, 'application/json');
            }
            if(response != null || Test.isRunningTest()){
                if(!Test.isRunningTest()){
                	responseJSONString = response.getBody();
                    system.debug('**11responseJSONString'+ responseJSONString);
                } else if (!runningOnDemandSadPathTest) {
                	responseJSONString = 'FQL Entity X Time x Item Orientation\nEntity Id,Date,fsym_entity_id,fs_feid_comp_name,fsym_ultimate_parent_id,fref_ultimate_parent_name,fref_entity_country,fref_entity_identifier,fref_entity_status\nEntity,Date,String,String,String,String,String,String,String\nId,Date,fsym_entity_id,fs_feid_comp_name,fsym_ultimate_parent_id,fref_ultimate_parent_name,fref_entity_country,fref_entity_identifier,fref_entity_status\n0KLGGN-E,14-Apr-2021,0KLGGN-E,Nomura Asset Management Co. Ltd. /Private Equity/,003JS5-E,"Nomura Holdings, Inc.",US,H88PPRS67HRMQX6CRF26,';
                }
                //system.debug('**referenceresponse*** ' + responseJSONString);
                if(String.isNotEmpty(responseJSONString)){
                    responseJSONString = CsvToJson.csvToJSON('data', responseJSONString, 3, True, 2, new Integer[]{0,1}, new Integer[]{0, 1});
                    system.debug('**referenceresponse*** ' + responseJSONString);
                    try{
                        fserrw = (FactsetDataWrapper.FactsetEntityReferencesResponseWrapper)JSON.deserialize(responseJSONString, FactsetDataWrapper.FactsetEntityReferencesResponseWrapper.class);           
                        fserrw.prepareFileterdData(andFilters);
                        //system.debug(fserrw);
                    }
                    catch (System.JSONException e){
                        emailErrorSubject += 'Entity References';
                        emailErrorBody = e.getMessage() + responseJSONString;
                        CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
                    }
                }
            } 
        } 
        return fserrw;
    }
}