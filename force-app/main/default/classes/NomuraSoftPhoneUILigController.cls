//Below class is used to fetch ActivityFlags for Edialer. for JIRA SALES-3119
public with sharing class NomuraSoftPhoneUILigController {

  public string tickerInput{get;set;}

     public List<Ticker__c> tickerList {
     get{
         if(tickerList == null){
                   return new List<Ticker__c>();
                }
                else {
                    return tickerList;
                }
        }

     set{
         if(value == null){
                    tickerList = new List<Ticker__c>();
                }
                else {
                    tickerList = value;
                }
        }
    }


    public NomuraSoftPhoneUILigController(ApexPages.StandardController controller) { 
      }

    public Boolean doneLookup {get; set;}  
    public NomuraSoftPhoneUILigController() { 
        doneLookup=false;
    }  
       
    public List<String> getActivityFlagList() {
        
        List<String> activityFlagList = new List<String>();
        List<L1_Event_Type_Setting__mdt> types =  new List<L1_Event_Type_Setting__mdt>();
        User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : UserInfo.getUserId()];
        Boolean isEqUser = CommonTools.isEquityUser(userObj);
        
		types = [Select Id, Fixed_Income_Activity_Flag__c, Equity_Activity_Flag__c, L0_Type__c FROM L1_Event_Type_Setting__mdt WHERE L0_Type__c = 'eDial' AND Type_Value__c = 'Dialer'];
        
        if(isEqUser){
            String eqActFlag = types[0].Equity_Activity_Flag__c;
            List<String> eqActFlagList = eqActFlag.split(';');
            for(String strObj : eqActFlagList){            
                activityFlagList.add(strObj);
                activityFlagList.sort();
            }        
        }
        else{
            String fiActFlag = types[0].Fixed_Income_Activity_Flag__c;
        	List<String> fiActFlagList = fiActFlag.split(';');
        	for(String strObj : fiActFlagList){
	            activityFlagList.add(strObj);    
                activityFlagList.sort();
    	    } 
        }
                
        return activityFlagList;
    }
    
    public Map<String, String> sectorsMap {get;set;}
    public List<String> getSectorList() {
        Map<String,String> valueMap = PicklistFieldController.getSourceOptionsImpl('Event','Sector__c');
        sectorsMap = new Map<String, String>();
        List<String> sectorsKey = new List<String>();

        for(String key : valueMap.keySet())
        {
            sectorsMap.put(key, valueMap.get(key));
            sectorsKey.add(key);
        } 

        return  sectorsKey;
    }

    
    public void searchTicker() {           
        if (tickerInput == null) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ticker is required to search'));
        } else {
            tickerList = LookupUtil.searchTicker(tickerInput);
            system.debug('Ticker Size :' + tickerList.size());
            doneLookup=true;
        }
    }

    public List<String> getActivityFlagStatusList(){
        /*
         * In future, Use below code to retrieve activityFlagStatus Values if status values are present for activity flags other than IBOR
         * We can have value and label. Value will be like "IBOR#Unsure" and label would be "IBOR"
         */
        /*
        List<String> activityFlagStatusList = new List<String>();
        Map<String,List<String>> actyFlagStatusMap = new Map<String,List<String>>();
        List<Activity_Flag_Status_Mapping__mdt> actyFlagStatusMappingList = 
            [
                SELECT Id, MasterLabel, Label, Activity_Flag__c, Activity_Status__c, Order__c 
                FROM Activity_Flag_Status_Mapping__mdt
                ORDER BY Order__c
            ];

        if(actyFlagStatusMappingList != null && !actyFlagStatusMappingList.isEmpty()) {
            for(Activity_Flag_Status_Mapping__mdt actyFlagStatusObj : actyFlagStatusMappingList){
                List<String> statusList = actyFlagStatusMap.containsKey(actyFlagStatusObj.Activity_Flag__c) ? actyFlagStatusMap.get(actyFlagStatusObj.Activity_Flag__c) : new List<String>();
                statusList.add(actyFlagStatusObj.Activity_Status__c);

                actyFlagStatusMap.put(actyFlagStatusObj.Activity_Flag__c, statusList);
            }
        }

        List<String> activityFlagList = getActivityFlagList();

        for(String activityFlag : activityFlagList){
            if(actyFlagStatusMap.containsKey(activityFlag)){
                activityFlagStatusList.addAll(actyFlagStatusMap.get(activityFlag));
            }
        }   

        return activityFlagStatusList; */

        List<String> activityFlagStatusList = new List<String>();
        
        Map<String,String> iborStatusValuesMap = PicklistFieldController.getSourceOptionsImpl('Event','IBOR_Status__c');
        activityFlagStatusList.addAll(iborStatusValuesMap.keySet());

        return activityFlagStatusList;
    } 

    public String getActivityFlagsHavingStatusValues(){
        String activityFlagsHavingStatusvalues = '';
        Map<String,String> activityFlagMap = new Map<String,String>();

        /* GROUP BY not supported for Custom Metadata Object */
        List<Activity_Flag_Status_Mapping__mdt> actyFlagStatusMappingList = 
            [
                SELECT Id, Activity_Flag__c
                FROM Activity_Flag_Status_Mapping__mdt
            ];

        if(actyFlagStatusMappingList != null && !actyFlagStatusMappingList.isEmpty()) {
            for(Activity_Flag_Status_Mapping__mdt actyFlagStatusMapping : actyFlagStatusMappingList){
                activityFlagMap.put(actyFlagStatusMapping.Activity_Flag__c, actyFlagStatusMapping.Activity_Flag__c);
            }
        }  

        if(activityFlagMap != null && !activityFlagMap.isEmpty()) {
            activityFlagsHavingStatusvalues = String.join(activityFlagMap.values(), ';');
        }

        return activityFlagsHavingStatusvalues;
    }
}