/* To populate Coverage Maintenance preference for salesperson */
global class PopulateCvgMaintenanceForSalescodeBatch implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts{
    global Map<String,Id> cvgPreferenceMap = new Map<String,Id>();
    global List<Id> idList = null;
    global String BATCH_FEED = 'BATCH FEED';
    global Boolean hasError  = false;
    global String exception_message = '';
    global Boolean batchExecutionSuccessfully = true;
    global String generatedErrorCSVfile = '';

    public PopulateCvgMaintenanceForSalescodeBatch(List<Id> salesTeamForCoverageIdList) {
        idList = salesTeamForCoverageIdList;
        generatedErrorCSVfile = 'Id,Name,Desk Code,Sales Desk Region,Sales Desk Division,Error\n';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
            String whereCondition = idList != null ? ' WHERE Id IN: idList' : '';
            String query = 'SELECT Id,Name,Coverage_ID__c,is_Dummy__c,Is_Leaver__c,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Sales_Desk_Region__c,Sales_Desk_Division__c,Desk_Code__c,Company__c,Coverage_Maintenance_Level__c FROM Sales_Team_for_Coverage__c'+whereCondition;
            return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Sales_Team_for_Coverage__c> salesTeamCoverageList){
        try{
            System.debug('SalesTeamCoverageList size: '+salesTeamCoverageList.size());
            if(cvgPreferenceMap.size() == 0){
                for(Coverage_Maintenance_Preferences__c cvgPreference : [SELECT Id,Sales_Desk_Code__c,Sales_Desk_Region__c,Sales_Desk_Division__c,Sales_Client_Hierarchy_Level__c FROM Coverage_Maintenance_Preferences__c]){
                    String cvgPreferenceKey = cvgPreference.Sales_Desk_Code__c+'#'+cvgPreference.Sales_Desk_Region__c+'#'+cvgPreference.Sales_Desk_Division__c;
                    System.debug('Coverage Maintenance Preferences Key: '+ cvgPreferenceKey);
                    cvgPreferenceMap.put(cvgPreferenceKey, cvgPreference.Id);
                }
            }

            List<Sales_Team_for_Coverage__c> recordsToUpdate = new List<Sales_Team_for_Coverage__c>();
            if(cvgPreferenceMap != null){
                for(Sales_Team_for_Coverage__c salesTeamCoverage: salesTeamCoverageList){
                    String deskCode = salesTeamCoverage.Desk_Code__c;
                    String region = salesTeamCoverage.Sales_Desk_Region__c;
                    String division = salesTeamCoverage.Sales_Desk_Division__c;
                    String salesTeamCoverageKey = deskCode+'#'+region+'#'+division;
                    System.debug('Sales Team for Coverage Key: '+ salesTeamCoverageKey);
                    if(deskCode != null){
                        if(cvgPreferenceMap.containsKey(salesTeamCoverageKey)){
                            if(salesTeamCoverage.Coverage_Maintenance_Level__c != cvgPreferenceMap.get(salesTeamCoverageKey)){
                                salesTeamCoverage.Coverage_Maintenance_Level__c = cvgPreferenceMap.get(salesTeamCoverageKey);
                                salesTeamCoverage.Source__c = BATCH_FEED;
                                recordsToUpdate.add(salesTeamCoverage);
                            }
                        }else{
                            deskCode = null;
                            salesTeamCoverageKey = deskCode+'#'+region+'#'+division;
                        }
                    }
                    if(deskCode == null && region != null){
                        if(cvgPreferenceMap.containsKey(salesTeamCoverageKey)){
                            if(salesTeamCoverage.Coverage_Maintenance_Level__c != cvgPreferenceMap.get(salesTeamCoverageKey)){
                                salesTeamCoverage.Coverage_Maintenance_Level__c = cvgPreferenceMap.get(salesTeamCoverageKey);
                                salesTeamCoverage.Source__c = BATCH_FEED;
                                recordsToUpdate.add(salesTeamCoverage);
                            }
                        }else{
                            region = null;
                            salesTeamCoverageKey = deskCode+'#'+region+'#'+division;
                        }
                    }
                    if(deskCode == null && region == null && division != null){
                        if(cvgPreferenceMap.containsKey(salesTeamCoverageKey)){
                            if(salesTeamCoverage.Coverage_Maintenance_Level__c != cvgPreferenceMap.get(salesTeamCoverageKey)){
                                salesTeamCoverage.Coverage_Maintenance_Level__c = cvgPreferenceMap.get(salesTeamCoverageKey);
                                salesTeamCoverage.Source__c = BATCH_FEED;
                                recordsToUpdate.add(salesTeamCoverage);
                            }
                        }
                    }
                }
            }

            if(recordsToUpdate != null){
                System.debug('Records to Update size: ' + recordsToUpdate.size());
                Database.SaveResult[] updateResult = Database.update(recordsToUpdate, false);
                Integer i = 0;
                for (Database.SaveResult output : updateResult){
                    if (!output.isSuccess()){
                        for (Database.Error error : output.getErrors()){
                            // errors here
                            generatedErrorCSVfile = 'Id,Name,Desk_Code__c,Sales_Desk_Region__c,Sales_Desk_Division__c,Error\n';
                            generatedErrorCSVfile += '"'+recordsToUpdate.get(i).Id+'"'+','+'"'+recordsToUpdate.get(i).Name+'"'+','+'"'+recordsToUpdate.get(i).Desk_Code__c+'"'+','+'"'+recordsToUpdate.get(i).Sales_Desk_Region__c+'"'+','+'"'+recordsToUpdate.get(i).Sales_Desk_Division__c+'"'+','+'"'+error.getMessage()+'"'+'\n';
                            hasError = true;
                        }
                    }
                    i++;
                }
            }
        }
        catch(Exception e){
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            System.debug(exception_message);
        }
    }

    global void finish(Database.BatchableContext bc){
        System.debug('Finish Method');
        if(hasError)
        {
            System.debug('Errors processing PopulateCvgMaintenanceForSalescodeBatch. Attached records processing for email');
            System.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','PopulateCvgMaintenanceForSalescodeBatch','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            System.debug('Exception processing PopulateCvgMaintenanceForSalescodeBatch');
            System.debug(exception_message);
            CommonTools.emailLog('FAILURE','PopulateCvgMaintenanceForSalescodeBatch',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }
    }
}