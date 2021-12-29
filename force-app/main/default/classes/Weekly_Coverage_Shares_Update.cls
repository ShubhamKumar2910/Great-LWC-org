global class Weekly_Coverage_Shares_Update implements Database.Batchable<sObject>,Database.Stateful {
    
    global final ID[] AccntID;
    global final String[] errorMessage;
    string query = 'SELECT ';
    string wherecriteria=' WHERE ';
    Set<string> selectColumns = new Set<string>();
    List<string> setItems1= new List<string>();
    string conditions = '';
    string guid = '';
    List<Shares_Configuration__c> sharesSettings = new List<Shares_Configuration__c>();
    
    global Weekly_Coverage_Shares_Update(string guid){
        if(guid == '')
            sharesSettings = [SELECT Id, Name, fieldAPIName__c, booleanValue__c, IsNull__c, IsCondition__c,IsColumnField__c, SetItems1__c FROM Shares_Configuration__c order by createddate desc];
        else
        {
            sharesSettings = [SELECT Id, Name, fieldAPIName__c, booleanValue__c, IsNull__c, IsCondition__c,IsColumnField__c, SetItems1__c FROM Shares_Configuration__c where guid__c =:guid order by createddate desc];
        }
        this.guid=guid;
        
        if(sharesSettings.size()==0)
            query = 'SELECT id  FROM Coverage_Team_Member__c WHERE End_Date__c = null AND Sales_Team_For_Coverage__r.Active__c = TRUE AND Sales_Team_For_Coverage__r.Is_Dummy__c = FALSE';
        else
        {
            for(Shares_Configuration__c config: sharesSettings){
                
                if(config.IsColumnField__c)
                    selectColumns.add(config.fieldAPIName__c);
                
                if(config.IsCondition__c && config.booleanValue__c && !config.IsNull__c && !config.IsColumnField__c && config.fieldAPIName__c!='Id')
                {
                    if(conditions == '')
                        conditions = config.fieldAPIName__c+'=true';
                    else
                        conditions += ' and '+config.fieldAPIName__c+'=true';
                    
                }   
                else if(config.IsCondition__c && !config.booleanValue__c && config.IsNull__c && !config.IsColumnField__c && config.fieldAPIName__c!='Id'){
                    if(conditions == '')
                        conditions = config.fieldAPIName__c+'=null';
                    else
                        conditions += ' and '+config.fieldAPIName__c+'=null';
                }
                else if(config.IsCondition__c && !config.booleanValue__c && !config.IsNull__c && !config.IsColumnField__c && config.fieldAPIName__c!='Id')
                {
                    if(conditions == '')
                        conditions = config.fieldAPIName__c+'=false';
                    else
                        conditions += ' and '+config.fieldAPIName__c+'=false';
                }
                
                if(config.SetItems1__c!=null && config.SetItems1__c!='' && !config.IsColumnField__c){
                    setItems1 = config.SetItems1__c.split(',');
                    wherecriteria += config.fieldAPIName__c+' IN:setItems1';
                }
                
            }
            String columnfields = '';
            for(String s:selectColumns) {
                columnfields += (columnfields==''?'':',')+s;
            }
            
            if(wherecriteria!='' && conditions!='')
            {
                if(setItems1.size()>0)
                    wherecriteria = wherecriteria.replace('WHERE', 'AND');
                else
                    wherecriteria = wherecriteria.replace('WHERE', '');    
                system.debug(wherecriteria);
                query = query + columnfields + ' FROM Coverage_Team_Member__c where ' +conditions+ wherecriteria;
            }
            else if(wherecriteria!='' && conditions=='')
                query = query + columnfields + ' FROM Coverage_Team_Member__c' + wherecriteria;
            else
                query = query + columnfields + ' FROM Coverage_Team_Member__c';    
            system.debug(query);
        }
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(setItems1.size());
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> Ids = (new Map<Id,SObject>(scope)).keySet(); 
        Map<Id,Coverage_Team_Member__c> cvgmem = new  Map<Id,Coverage_Team_Member__c>([SELECT Account__c,Account_Access__c,End_Date__c,Contact_Access__c,Opportunity_Access__c,Case_Access__c,Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c where Id in:Ids]);
        Map<Id,Set<Id>> salesCodeUserMap = CoverageTeamMemberTriggerBL.getSalesCodeUserDetailsForInsert(cvgmem); 
        CoverageTeamMemberTriggerBL.CreateAccountTeamMember(cvgmem, salesCodeUserMap);
        CoverageTeamMemberTriggerBL.CreateRevenureRollupShares(cvgmem, salesCodeUserMap); 
        RevenueKPIBL.createRevenueSharesFromNewCoverage(cvgmem.values(), salesCodeUserMap);
      
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('errorMessage :'+ errorMessage);
        List<Shares_Configuration__c> delItems = new  List<Shares_Configuration__c> ();
        List<Shares_Configuration__c> updateItems = new  List<Shares_Configuration__c> ();
        
        if(guid!='' && guid!=null){
            delItems = [SELECT Id FROM Shares_Configuration__c where guid__c =:guid];
        }
        if(delItems.size() > 0)
        delete delItems;  
        
        /*List<Shares_Configuration__c> pendingItems = [select id,guid__c from Shares_Configuration__c where guid__c!=:guid];
        if(pendingItems.size()>0)
             Database.executeBatch(new Weekly_Coverage_Shares_Update(pendingItems[0].guid__c), 1);*/
        
    }
}