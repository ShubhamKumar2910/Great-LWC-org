public class FactsetDataWrapper {
    
    private FactsetDataService.FactsetAPI api {get;set;}
    private FactsetIDSearchRequestWrapper idSearchObj {get;set;}
    private FactsetEntityReferencesRequestWrapper entityReferencesObj {get;set;}
    
    public FactsetDataWrapper(FactsetDataService.FactsetAPI api, String searchPattern){
        this.api = api;
        
        if(api == FactsetDataService.FactsetAPI.IDSEARCH){
        	idSearchObj = new FactsetIDSearchRequestWrapper(api, searchPattern, 50);
        }
    }
    
    public FactsetDataWrapper(FactsetDataService.FactsetAPI api, String searchPattern, Integer resultLimit){
        this.api = api;
        
        if(api == FactsetDataService.FactsetAPI.IDSEARCH){
        	idSearchObj = new FactsetIDSearchRequestWrapper(api, searchPattern, resultLimit);
        }
    }
    
    public FactsetDataWrapper(FactsetDataService.FactsetAPI api, String[] ids, Map<String, String[]> andFilters){
        this.api = api;
        
        if(api == FactsetDataService.FactsetAPI.ENTITYREFERENCES){
        	entityReferencesObj = new FactsetEntityReferencesRequestWrapper(ids, andFilters);
        }
    }
    
    private class FactsetIDSearchRequestQueryWrapper {
        String pattern {get;set;}
        String[] entities {get;set;}
        
        FactsetIDSearchRequestQueryWrapper(String pattern) {
            this.pattern = pattern;
            this.entities = FactsetDataService.entities;
        }
    }
    
    private class FactsetIDSearchRequestWrapper {
        FactsetIDSearchRequestQueryWrapper query {get;set;}
        FactsetSettingsRequestWrapper settings {get;set;} 
        
        FactsetIDSearchRequestWrapper(FactsetDataService.FactsetAPI api, String pattern, Integer result_limit){
            this.query = new FactsetIDSearchRequestQueryWrapper(pattern);
            this.settings = new FactsetSettingsRequestWrapper(result_limit);
        }
    }
    
    public class FactsetIDSearchResponseResultCountWrapper {
        public Integer equities {get;set;}
        public Integer private_companies {get;set;}
        public Integer pevc_firms {get;set;}
        public Integer pevc_funds {get;set;}
        public Integer bonds {get;set;}
        public Integer commodities {get;set;}
        public Integer ownership_holders {get;set;}
        public Integer forex {get;set;}
        public Integer mutual_funds {get;set;}
        public Integer indices {get;set;}
        public Integer indices_realtime {get;set;}
        public Integer people {get;set;} 
        
        FactsetIDSearchResponseResultCountWrapper(){}
    }
    
    public class FactsetIDSearchResponseResultWrapper {
        public String index {get;set;}
        public String symbol {get;set;}
        public String name {get;set;}
        public String fds_id {get;set;}
        
        FactsetIDSearchResponseResultWrapper(){}
    }
    
    public class FactsetIDSearchResponseHeadWrapper { 
        public FactsetIDSearchResponseResultCountWrapper result_count {get;set;}
        public String error;
        public Integer is_success;
        public FactsetIDSearchResponseResultWrapper[] results {get;set;} 
        
        FactsetIDSearchResponseHeadWrapper() {}
    }
    
    public class FactsetIDSearchResponseWrapper { 
        public FactsetIDSearchResponseHeadWrapper typeahead {get;set;}
               
        FactsetIDSearchResponseWrapper() {}
    }
	
    private class FactsetEntityReferencesRequestWrapper {
        String[] ids  {get;set;} 
        FactsetFilterRequestWrapper filters {get;set;}
        
        FactsetEntityReferencesRequestWrapper(String[] ids, Map<String, String[]> andFilters){
            this.ids = ids;
            if(andFilters != null){
                this.filters = new FactsetFilterRequestWrapper(andFilters);
            }
        }
    }
    
	public class FactsetEntityReferencesResponseDataWrapper { 
        public String fsymId {get;set;}
        public String entityProperName {get;set;}
        public String fsymEntityId {get;set;}
        public String ultimateParentId {get;set;}
        public String ultimateParentName {get;set;}
        public String creditParentId {get;set;}
        public String parentEquityId {get;set;}
        public String website {get;set;}
        public String incorporationDate {get;set;}
        public String countryOfRisk {get;set;}
        public String incorporationCountry {get;set;}
        public String businessDescription {get;set;}
        public String phone {get;set;}
        public String headquartersStreet {get;set;}
        public String headquartersCity {get;set;}
        public String headquartersState {get;set;}
        public String headquartersZip {get;set;}
        public String headquartersCountry {get;set;}
        public String emailIR {get;set;}
        public String websiteIR {get;set;}
        public String requestId {get;set;}
        
        public String fsym_entity_id {get; set;}
        public String fs_feid_comp_name {get; set;}
        public String fsym_ultimate_parent_id {get; set;}
        public String fref_ultimate_parent_name {get; set;}
        public String fref_entity_country {get; set;}
        public String fref_entity_status {get; set;}
        public String fref_entity_identifier {get; set;}
        
       	public String factset_entity_id {
            get {
                if(String.isEmpty(fsym_entity_id)){
                    return fsymEntityId;
                }
                return fsym_entity_id;
            }
            set;
        }
        
        public String factset_entity_name {
            get {
                if(String.isEmpty(fs_feid_comp_name)){
                    return entityProperName;
                }
                return fs_feid_comp_name;
            }
            set;
        }
        
        public String factset_ultimate_parent_id {
            get {
                if(String.isEmpty(fsym_ultimate_parent_id)){
                    return ultimateParentId;
                }
                return fsym_ultimate_parent_id;
            }
            set;
        }
        
        public String factset_ultimate_parent_name {
            get {
                if(String.isEmpty(fref_ultimate_parent_name)){
                    return ultimateParentName;
                }
                return fref_ultimate_parent_name;
            }
            set;
        }
        
        public String factset_entity_domicile {
            get {
                if(String.isEmpty(fref_entity_country)){
                    return countryOfRisk;
                }
                return fref_entity_country;
            }
            set;
        }
        
        public String factset_entity_status {
            get {
                if(String.isEmpty(fref_entity_status)){
                    return '';
                }
                return fref_entity_status;
            }
            set;
        }
        
        public String factset_entity_identifier {
            get {
                if(String.isEmpty(fref_entity_identifier)){
                    return '';
                }
                return fref_entity_identifier;
            }
            set;
        }
        
        
        FactsetEntityReferencesResponseDataWrapper() {}
    }
    
    public class FactsetEntityReferencesResponseWrapper { 
        public FactsetEntityReferencesResponseDataWrapper[] data {get;set;}
        FactsetEntityReferencesResponseWrapper() {}
        
        public void prepareFileterdData(Map<String, String[]> andFilters){                        
            String emailErrorSubject = 'Error with factset callout : ';
            String emailErrorBody;                
            try{
                if(this.data == null || this.data.size() == 0){
                    emailErrorSubject += 'Entity References';
                    emailErrorBody = 'Issue with Ondemand Entity Reference, please check the logs';
                    CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);  
                } else {
                    if(andFilters != null){
                        for(String key : andFilters.keySet()){
                            this.data = filterValues(andFilters, key, filterValues(andFilters, key, this.data));
                        }
                    }  else {
                        this.data = filterValues(null, null, this.data);
                    }                      
                }
            }
            catch (System.Exception ee){
                emailErrorSubject += 'Entity References';
                emailErrorBody = ee.getMessage();
                CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
            } 
        }
        
        private FactsetEntityReferencesResponseDataWrapper[] filterValues(Map<String, String[]> andFilters, String key, FactsetEntityReferencesResponseDataWrapper[] filteredData){
            FactsetEntityReferencesResponseDataWrapper[] subFilteredData = new FactsetEntityReferencesResponseDataWrapper[]{};
        	Map<String, String> entityIds = New Map<String, String>();
            
            if(andFilters != null){
                String[] filterValues = andFilters.get(key);
                for(String filterValue : filterValues) {
                    for(FactsetEntityReferencesResponseDataWrapper r : filteredData){
                        Boolean addRecord = False;
                        if(FactsetDataService.fieldfref_entity_country == key && r.factset_entity_domicile == filterValue){
                            addRecord = True;
                        } else if(FactsetDataService.fieldfref_entity_status == key && ((filterValue == 'true' && r.factset_entity_status != 'EXTINCT') || filterValue != 'true')){
                            addRecord = True;
                        } else if(FactsetDataService.fieldfref_ultimate_parent_id == key && ((filterValue == 'true' && String.isNotEmpty(r.factset_ultimate_parent_id)) || filterValue != 'true')){
                            addRecord = True;
                        }
                        
                        if(addRecord && String.isEmpty(entityIds.get(r.factset_entity_id))){
                            subFilteredData.add(r);
                            entityIds.put(r.factset_entity_id, r.factset_entity_id);
                        }
                    } 
                }
            } else {
                
            }
            return subFilteredData;
        }
    }
    
    private class FactsetFilterIncludeRequestWrapper {
        String field {get;set;}
        String[] values {get;set;}
        
        FactsetFilterIncludeRequestWrapper(String field, String[] values){
            this.field = field;
            this.values = values;            
        }
    }
    
    private class FactsetFilterRequestWrapper {
        FactsetFilterIncludeRequestWrapper[] include {get;set;}
        
        FactsetFilterRequestWrapper(Map<String, String[]> andFilters){
            this.include = new FactsetFilterIncludeRequestWrapper[]{};
            for(String key : andFilters.keySet()){
                this.include.add(new FactsetFilterIncludeRequestWrapper(key, andFilters.get(key)));
            }
        }
    }
        
    private class FactsetSettingsRequestWrapper {
        Integer result_limit {get;set;}
        
        FactsetSettingsRequestWrapper(Integer result_limit){
            this.result_limit = result_limit;
        }
    }
    
    public class FactsetResponseFailureWrapper { 
        public String status {get;set;}
        public String timestamp {get;set;}
        public String path	{get;set;}
        public String message {get;set;}
        
        FactsetResponseFailureWrapper(){} 
    }
    
    public String getFacsetRequestBodyJSON(){
        String searchJSONString = '{}';
        
        if(this.api == FactsetDataService.FactsetAPI.IDSEARCH){
        	searchJSONString = JSON.serialize(this.idSearchObj, true); 
        } else if(this.api == FactsetDataService.FactsetAPI.ENTITYREFERENCES){
            searchJSONString = JSON.serialize(this.entityReferencesObj, true);
        }
        
        return searchJSONString;
    }
}