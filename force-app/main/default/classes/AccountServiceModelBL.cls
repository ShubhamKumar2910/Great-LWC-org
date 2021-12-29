public class AccountServiceModelBL {

   
    private static RecordType totalRecordType = [select id from RecordType where DeveloperName = 'Total' AND sObjectType = 'Account_Service_Model__c'];
    
    public static Set<String> profileNameSet = new Set<String>{'Nomura - Integration','System Administrator'};

    
    public static void updateVersions(List<Account_Service_Model__c> models)
    {
        if (models != null && models.size() > 0) {
            //Set<id> actualUsersList = createListOfActualUsers(models);
            boolean isUpdatedByActualUser = isUpdatedByActualUser(profileNameSet);
            for(Account_Service_Model__c  model : models){
                if(isActualRecordType(model) && isUpdatedByActualUser){
                    if(model.inprogress_version__c == null){
                        if (model.stable_version__c != null)
                            model.inprogress_version__c = model.stable_version__c + 1;
                        else
                            model.inprogress_version__c =  1;
                    }   
                }
            }
        }   
        
    }   
    
    private static Set<Id> createListOfActualUsers (List<Account_Service_Model__c> models) {
        Set<Id> actualUserIds = new Set<Id>();
       /* List<Id> lastModifiedByIds = new List<Id>();
        if (models != null && models.size() > 0) {
            for(Account_Service_Model__c  model : models){
               lastModifiedByIds.add(model.LastModifiedById);
            }
        }    
        
        for (User user : [select id from user where id in :lastModifiedByIds and profile.name not in ('Nomura - Integration','System Administrator')])   {
            actualUserIds.add(user.id);
        } */
        return actualUserIds;
    }    
    
    private static boolean isUpdatedByActualUser(Set<String> profileSet) {
        boolean isUpdatedByActualUser = false;
        /*Id lastModifiedById = model.lastmodifiedbyid;
        if (lastModifiedById == null) {
            lastModifiedById = model.createdById;
        }
        system.debug('actualUsersList = ' + actualUsers);
        isUpdatedByActualUser = actualUsers.contains(lastModifiedById);*/
        /*boolean isUpdatedByBatch = system.isBatch() || system.isScheduled();
        isUpdatedByActualUser = !isUpdatedByBatch;*/
        
        string userId = UserInfo.getUserId() ;
        User callingUser = [SELECT Id,profile.Name FROM User WHERE Id = : userId] ; 
        system.debug('Calling user profile = ' + callingUser.profile.name);
        if(profileSet != null && profileSet.size() > 0){
            if(profileSet.contains(callingUser.profile.name)){
                isUpdatedByActualUser = false;
            }
            else {
                isUpdatedByActualUser = true;
            }
        }
        
        System.debug('isUpdatedByActualUser = '+ isUpdatedByActualUser);
        return isUpdatedByActualUser;
    }    
    
    public static void validateData(List<Account_Service_Model__c> models) {
        if (models != null && models.size() > 0) {
            for(Account_Service_Model__c  model : models){
                if(isActualRecordType(model)){
                    validateOrder(model);
                    validateEventType(model);
                    //validateEventMeetingType(model);
                }
            }
        }   
    }   
    
    public static DAMeetingEventWrapper splitDAEventMeetingType(string commaSeperatedListTypes){
        string[] meeting_da = commaSeperatedListTypes.split(';');
        
        Set<string> daeventTypesSet = new Set<string>();
        Set<string> daeventMeetingTypesSet = new Set<string>();
        string daeventTypes = '';
        string daeventMeetingTypes = '';
        
        for(string da_event: meeting_da){
            string[] eventMeetingTypes = da_event.split('~'); //1on1~Analyst Conference Call
            if(eventMeetingTypes.size()>0){
                daeventTypesSet.add(eventMeetingTypes[0]);
                daeventMeetingTypesSet.add(eventMeetingTypes[1]);
            }
        }
        
        for(string daeventType : daeventTypesSet){
            if(daeventTypes == '')
                daeventTypes = daeventType;
            else if(daeventTypes != '')
                daeventTypes += ';'+ daeventType;
        }
        
        for(string daeventMeetingType : daeventMeetingTypesSet){
            if(daeventMeetingTypes == '')
                daeventMeetingTypes = daeventMeetingType;
            else if(daeventMeetingTypes != '')
                daeventMeetingTypes += ';'+daeventMeetingType;
        }
        
        DAMeetingEventWrapper daWrapper = new DAMeetingEventWrapper();
        daWrapper.da_event_types = daeventTypes;
        daWrapper.da_event_meeting_types = daeventMeetingTypes;
       return daWrapper;
    }
    
    public static void flagDuplicatesIfAny(List<Account_Service_Model__c> models) {
        System.debug('Inside flagDuplicatesIfAny');
        Map<String, Map<String,List<String>>> existingCallReportTypes = new Map<String, Map<String,List<String>>>();
        Map<String, Map<String,List<String>>> existingDATypes = new Map<String, Map<String,List<String>>>();
        updateExistingTypes(existingCallReportTypes, existingDATypes);
        System.debug('existingCallReportTypes = ' + existingCallReportTypes);
        System.debug('existingDATypes = ' + existingDATypes);
        for(Account_Service_Model__c  model : models){
            String duplicateModelName = null;
            if (model.CALL_REPORT_TYPE__C != null) {
                duplicateModelName  = getExitingModelForType(model.name, model.CALL_REPORT_TYPE__C, 
                                                                existingCallReportTypes, model.external_id__c,null);
            }
            else if (model.DealAxis_Type__c != null) {
                /*duplicateModelName  = getExitingModelForType(model.name,
                                            model.DEALAXIS_EVENT_TYPE__C,
                                            existingDATypes,
                                            model.external_id__c,
                                            model.dealaxis_event_meeting_type__c);*/
                DAMeetingEventWrapper daWrapper = splitDAEventMeetingType(model.DealAxis_Type__c);
                duplicateModelName  = getExitingModelForType(model.name,
                                            daWrapper.da_event_types,
                                            existingDATypes,
                                            model.external_id__c,
                                            daWrapper.da_event_meeting_types);
                
            }   
            System.debug('duplicateModelName = ' + duplicateModelName);
            if (duplicateModelName != null) {
                System.debug('Duplicate detected in model ' + duplicateModelName);
                model.addError(System.Label.Account_Service_Model_Error_Message_For_Duplicate + ' ' + duplicateModelName);
            }
            else {
                System.debug('Duplicates not detected');
            }
        }       
    }
    
    private static String getExitingModelForType(String modelName, String types, Map<String, Map<String,List<String>>> existingCallReportTypes
                                                , String currentModel, string suffix) {
        String exitingModelForType = null;
        List<String> typeList = types.split(';');
        for (String type: typeList) {
            Map<String,List<String>> typeDataList = existingCallReportTypes.get(modelName);
            if (typeDataList != null && typeDataList.size() > 0) {
                String key = type;
                if (suffix != null) {
                    key = key+ suffix;
                }
                //handle updates
                if (currentModel != null) {
                    System.debug(currentModel + ' is not null');
                    	for (String typeData: typeDataList.get(key)) {
	                        if (!(currentModel.equals(typeData)))  {
	                            exitingModelForType = typeData;
	                        }
                        }   
                   
                }
                else {
                    //handle inserts: Ideally should not happen as moved to after trigger
                    System.debug('currentModel is null');
                    exitingModelForType = typeDataList.get(key)[0];
                }
            }
            if (exitingModelForType != null)
                break;
        }   
        return exitingModelForType;
    }
    
    private static void updateExistingTypes (Map<String, Map<String,List<String>>> existingCallReportTypes, 
                                                    Map<String, Map<String,List<String>>> existingDATypes ) {
    
        for (Account_Service_Model__c model: [select name, external_id__c, CALL_REPORT_TYPE__C,DealAxis_Type__c
                                                from Account_Service_Model__c where Recordtype.DeveloperName = 'Actual']) {
            String modelName = model.name;
            String fullyQualifiablename = model.external_id__c;
            String callReportType = model.CALL_REPORT_TYPE__C;
            String daEventType = '';
            String daEventMeetingType = '';
            DAMeetingEventWrapper daWrapper;
                                                    if(model.DealAxis_Type__c!=null){
                                                        daWrapper = splitDAEventMeetingType(model.DealAxis_Type__c);
                                                        daEventType = daWrapper.da_event_types;
                                                        daEventMeetingType = daWrapper.da_event_meeting_types;
                                                    }
            if (callReportType != null) {
                updateExistingTypes(callReportType,null,modelName,existingCallReportTypes, fullyQualifiablename);
            }
            else {
                updateExistingTypes(daEventType,daEventMeetingType,modelName,existingDATypes, fullyQualifiablename);
            }
        }
    }
    
    private static void updateExistingTypes(String types,String suffix,string modelName,
                                            Map<String, Map<String,List<String>>> existingModelTypesMap,
                                            String fullyQualifiablename) {
        List<String> typeList = types.split(';');
        for (String type: typeList) {
            Map<String,List<String>> existingType = existingModelTypesMap.get(modelName);
            if (existingType == null) {
                existingType = new Map<String,List<String>>();
            }
            String key = type;
            if (suffix != null) {
                key = key+ suffix;
            }
            
            List<String> fullyQualifiablenameList = existingType.get(key);
            if (fullyQualifiablenameList == null) {
                fullyQualifiablenameList = new List<String>();
            }
            fullyQualifiablenameList.add(fullyQualifiablename);
            existingType.put(key, fullyQualifiablenameList);
            existingModelTypesMap.put(modelName, existingType);
        }
    }
    
    private static void validateOrder(Account_Service_Model__c model) {
        if(model.order__c <= 0 || model.order__c == null){
            System.debug('Please select order greater than 0 !!');
            model.addError(System.Label.Account_Service_Model_Error_Message_For_Order);
        }
    }
    
    private static void validateEventType(Account_Service_Model__c model) {
        if ((model.DealAxis_Type__c == null && model.Call_Report_Type__c == null)
            ||(model.DealAxis_Type__c != null && model.Call_Report_Type__c != null))
        {
            System.debug('Please select either Call Report Type or DealAxis Event Type !!');
            model.addError(System.Label.Account_Service_Model_Error_Message_For_Type);
        }
    }   
    
    /*private static void validateEventMeetingType(Account_Service_Model__c model) {
       //if (model.DealAxis_Event_Type__c != null && model.DealAxis_Event_Meeting_Type__c == null) {
        if (model.DealAxis_Event_Type__c != null && model.dealaxis_event_meeting_type__c == null) {
            System.debug('Please select DealAxis Event Meeting Type !!');
            model.addError('Please select DealAxis Event Meeting Type !!');
        }   
        //else if (model.DealAxis_Event_Type__c == null && model.DealAxis_Event_Meeting_Type__c != null) {
        else if (model.DealAxis_Event_Type__c == null && model.dealaxis_event_meeting_type__c != null) {
            System.debug('Please select DealAxis Event Type !!');
            model.addError('Please select DealAxis Event Type !!');
        } 
    }*/
    
    public static void populateExternalId(List<Account_Service_Model__c> models) {
        if (models != null && models.size() > 0) {
            for(Account_Service_Model__c  model : models){
                if(isActualRecordType(model) ){
                    model.External_Id__c = model.Name + ':' + model.Item_Name__c;
                }
            }
        }   
    }

    /*  Get Distinct model name of affected records having recordType as Actual to break trigger recursion.
        Get all models (Acutal/total) for each model. (select id, model, recordtype where model= (XXXX) and isDeleted=false.)
        Create List of actual model
        Create Map of Total Model type: Model vs TotalModelType
        Iterate through affected Model.
            if present in total and not present in actual then add to List of TotalModelsToBeDeleted.
            If present in actual and not present in total then add to list of TotalModelstoBeadded. (Order shuld be 0, externalid)
        Insert TotalModels toBe added..
        Delete TotalModelsToBeDeleted */
        
        
    public static void modifyTotalRecord(List<Account_Service_Model__c> models) {
        System.debug('Inside modifyTotalRecord');
        Set<String> modelNames = new Set<String>();
        Set<String> actualModelList = new Set<String>();
        Set<String> actualModelsUpdatedByUser = createActualModelsUpdatedByUser(models);
        Map<String, Account_Service_Model__c> totalModelMap = new Map<String, Account_Service_Model__c>();
        List<Account_Service_Model__c> totalModelRecordToBeAdded = new List<Account_Service_Model__c>();
        List<Account_Service_Model__c> totalModelRecordToBeDeleted = new List<Account_Service_Model__c>();
        List<Account_Service_Model__c> totalModelRecordToBeUpdated = new List<Account_Service_Model__c>();
        
        populateAffectedModelNames(modelNames, models);
        updateAcutalAndTotalModel(modelNames, actualModelList, totalModelMap);
        UpdateTotalRecordsToModify(modelNames, actualModelList, totalModelMap,totalModelRecordToBeAdded,totalModelRecordToBeDeleted,totalModelRecordToBeUpdated, actualModelsUpdatedByUser);
        insertTotalRecords(totalModelRecordToBeAdded);
        deleteTotalRecords(totalModelRecordToBeDeleted);
        updateTotalRecords(totalModelRecordToBeUpdated);
    }   
    
    private static Set<String> createActualModelsUpdatedByUser(List<Account_Service_Model__c> models) {
        Set<String> actualModelsUpdatedByUser = new Set<String>();
       //Set<Id> actualUsersList = createListOfActualUsers(models);
       boolean isUpdatedByActualUser = isUpdatedByActualUser(profileNameSet);
        for (Account_Service_Model__c model: models) {
            if (isUpdatedByActualUser) {
                actualModelsUpdatedByUser.add(model.name);
            }   
        }
        system.debug('actualModelsUpdatedByUser = ' + actualModelsUpdatedByUser);
        return actualModelsUpdatedByUser;
    }
    
    private static void updateTotalRecords (List<Account_Service_Model__c> totalModelRecordToBeUpdated) {
        if (totalModelRecordToBeUpdated != null && totalModelRecordToBeUpdated.size() > 0) {
            System.debug('Inside updateTotalRecords');      
            update totalModelRecordToBeUpdated;
        }
    }      

    private static void insertTotalRecords (List<Account_Service_Model__c> totalModelRecordToBeAdded) {
        if (totalModelRecordToBeAdded != null && totalModelRecordToBeAdded.size() > 0) {
            System.debug('Inside insertTotalRecords');      
            insert totalModelRecordToBeAdded;
        }
    }   
    
    private static void deleteTotalRecords (List<Account_Service_Model__c> totalModelRecordToBeDeleted) {
        if (totalModelRecordToBeDeleted != null && totalModelRecordToBeDeleted.size() > 0) {
            System.debug('Inside deleteTotalRecords');  
            delete totalModelRecordToBeDeleted;
        }
    }
    
    private static void UpdateTotalRecordsToModify (Set<String> modelNames, Set<String> actualModelList
                                                    , Map<String, Account_Service_Model__c> totalModelMap
                                                    ,List<Account_Service_Model__c> totalModelRecordToBeAdded
                                                    ,List<Account_Service_Model__c> totalModelRecordToBeDeleted
                                                    ,List<Account_Service_Model__c> totalModelRecordToBeUpdated
                                                    , Set<String> actualModelsUpdatedByUser) {
        if (modelNames != null && modelNames.size() > 0) {
            System.debug('Inside UpdateTotalRecordsToModify');                                                  
            for(String modelName:modelNames){
                System.debug(totalModelMap);
                System.debug(actualModelList);
                boolean isTotalRecordPresent = totalModelMap.containsKey(modelName);
                boolean isActualRecordPresnt = actualModelList.contains(modelName);
                boolean shouldTotalRecordFlaggedForRecalculation = shouldTotalRecordFlaggedForRecalculation(totalModelMap.get(modelName));
                System.debug('modelName = '+modelName +  ', isTotalRecordPresent = ' + isTotalRecordPresent + ', isActualRecordPresnt = ' + isActualRecordPresnt);
                if (isActualRecordPresnt && !isTotalRecordPresent) {
                    Account_Service_Model__c model = new Account_Service_Model__c();
                    model.name= modelName;
                    model.RecordTypeID=totalRecordType.Id;
                    model.External_Id__c=modelName+':'+'Total';
                    model.Item_Name__c='Total';
                    model.Order__c=0;
                    model.inprogress_version__c=1;
                    System.debug('Creating total record for :' +modelName );
                    totalModelRecordToBeAdded.add(model);
                }
                else if (isTotalRecordPresent && !isActualRecordPresnt) {
                    System.debug('Deleting total record for :' +modelName );
                    totalModelRecordToBeDeleted.add(totalModelMap.get(modelName));
                }
                else if (isTotalRecordPresent && isActualRecordPresnt 
                                && shouldTotalRecordFlaggedForRecalculation
                                    && isAcutalModelUpdatedByUser(actualModelsUpdatedByUser, modelName)) {
                    System.debug('Marking total model for recalucaltion as actual model is changed. :' +modelName );
                    totalModelRecordToBeUpdated.add(totalModelMap.get(modelName));
                }
            }           
        }
    }    

    private static boolean isAcutalModelUpdatedByUser(Set<String> actualModelsUpdatedByUser, String modelName) {
        boolean isAcutalModelUpdatedByUser = false;
        isAcutalModelUpdatedByUser =  actualModelsUpdatedByUser.contains(modelName);
        system.debug('isAcutalModelUpdatedByUser for ' + modelName + ' = ' +  isAcutalModelUpdatedByUser);
        return isAcutalModelUpdatedByUser;
    
    }
    
    private static boolean shouldTotalRecordFlaggedForRecalculation(Account_Service_Model__c totalModel) {
        boolean shouldTotalRecordFlaggedForRecalculation = false;
        if (totalModel != null && totalModel.inprogress_version__c == null) {
            if (totalModel.stable_version__c != null)
                totalModel.inprogress_version__c = totalModel.stable_version__c + 1;
            else
                totalModel.inprogress_version__c =  1;          
            shouldTotalRecordFlaggedForRecalculation = true;
        }
        return shouldTotalRecordFlaggedForRecalculation;
    }
    
    private static void updateAcutalAndTotalModel (Set<String> modelNames, Set<String> actualModelList, Map<String, Account_Service_Model__c> totalModelMap) {
        if (modelNames != null && modelNames.size() > 0) {
            for(Account_Service_Model__c  model : [select id, name, recordTypeid, stable_version__c, inprogress_version__c, item_name__c from Account_Service_Model__c where name in :modelNames and isDeleted=false]){
                System.debug('Inside updateAcutalAndTotalModel = ' + model);    
                if(isActualRecordType(model) ){
                    System.debug('Adding '+ model.name+ ':' + model.item_name__c + ' to actuals');
                    actualModelList.add(model.name);
                }
                else if (isTotalRecordType(model)) {
                    System.debug('Adding '+ model.name+ ':' + model.item_name__c + 'to Totals');
                    totalModelMap.put(model.name, model);
                }
                else {
                    System.debug('Ignoring !!');
                }
            }           
        }
    }   

    private static void populateAffectedModelNames (Set<String> modelNames, List<Account_Service_Model__c> models) {
        if (models != null && models.size() > 0) {
            System.debug('Inside populateAffectedModelNames');  
            for(Account_Service_Model__c  model : models){
                if(isActualRecordType(model)){
                    modelNames.add(model.name);
                }
            }           
        }
    }
    
    private static boolean isActualRecordType(Account_Service_Model__c model) {
        System.debug(model.RecordTypeid);
        if (model.RecordTypeid != totalRecordType.id)
            return true;
        else
            return false;
    }
    
    private static boolean isTotalRecordType(Account_Service_Model__c model) {
        System.debug(model.RecordTypeid);
        if (model.RecordTypeid == totalRecordType.id)
            return true;
        else
            return false;
    }
    
    public static void updateConfigForModelName(){
        List<AggregateResult> aggregatedAccountServiceModelList = new List<AggregateResult>();
        List<String> serviceModelNameList = new List<String>();
        String strServiceModelNames = '';
        Set<String> nomuraIntegrationProfileSet = new Set<String>{'Nomura - Integration'};
        Boolean isUpdatedByActualUser = isUpdatedByActualUser(nomuraIntegrationProfileSet);    
        
        if(isUpdatedByActualUser){
            aggregatedAccountServiceModelList = [SELECT Name ServiceModelName FROM Account_Service_Model__c GROUP By Name];
            
            if(aggregatedAccountServiceModelList != null && aggregatedAccountServiceModelList.size() > 0){
                 for(AggregateResult aggregatedRecord : aggregatedAccountServiceModelList){
                    serviceModelNameList.add(String.valueOf(aggregatedRecord.get('ServiceModelName')));
                 }
                
                if(serviceModelNameList.size() > 0){
                    strServiceModelNames = String.join(serviceModelNameList, ';');
                }
                
                if(String.isNotEmpty(strServiceModelNames)){
                    CommonTools.updateParameterValueInConfiguration('ActivityServiceModelNames','Names', strServiceModelNames);
                }
                
            }
        }
    }
    
    public class DAMeetingEventWrapper{
        public string da_event_types;
        public string da_event_meeting_types;
    }
}