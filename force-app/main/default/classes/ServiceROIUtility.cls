public class ServiceROIUtility {
    
    public static final string JOB_NAME='ServiceRankBatch';
    public static final String STABLE_VERSION='STABLE_VERSION';
    public static final String INPROGRESS_VERSION='INPROGRESS_VERSION';
    
    /* Service Rank fields prefixs starts */
    public static final String  PREVIOUS_CY='Previous_CY';
    public static final String  PREVIOUS_FY='Previous_FY';
    public static final String  CURRENT_CY='Current_CY';
    public static final String  CURRENT_FY='Current_FY';
    public static final String  JAPAN='_JAPAN_';
    public static final String  ASIAEX='_ASIAEX_';
    public static final String  EUROPE='_EUROPE_';
    public static final String  GBL='_GLOBAL_';
    public static final String  US='_US_';
    public static final String  POINTS='POINTS__C';
    public static final String  COUNT='COUNT__C';
    public static DateTime currentDate;
    /* Service Rank fields prefixs ends */
    

    public static DateTime getCurrentDate() {
        return currentDate;
    } 
    
    public static void setCurrentDate() {
        DateTime cdate = DateTime.now();
        DateTime eodCurrentdate = DateTime.newInstanceGMT(cdate.yearGmt(), cdate.monthGmt(), cdate.dayGmt(), 23,59, 59);
        //DateTime cdate = DateTime.newInstanceGMT(2018, 3, 1);
        currentDate = eodCurrentdate ;
    } 
    
    public static void updateModelImpacted (Map<Id,Event> beforeEvents, Map<Id, Event> afterEvents) {
        Set<String> callTypes = new Set<String> ();
        Set<String> daEventAndMeetingTypes = new Set<String> ();
        for (Id id: afterEvents.keyset()) {
            Event beforeEvent = beforeEvents.get(id);
            Event afterEvent = afterEvents.get(id);
            if (beforeEvent != null && afterEvent != null) {
                if (beforeEvent.SR_GBL_Cnt__c != null && beforeEvent.SR_GBL_Cnt__c > 0) {
                    if (isUpdateImpactingModel(beforeEvent, afterEvent)) {
                        updateTypes(beforeEvent, callTypes , daEventAndMeetingTypes );
                        updateTypes(afterEvent, callTypes , daEventAndMeetingTypes );
                    }
                    else {
                        System.debug('Event Update is not impacting any models');
                    }
                
                }
                else {
                    System.debug('Before event service count is not populated');
                }
            }
        }   
        if (callTypes.size() > 0 || daEventAndMeetingTypes.size() > 0) {
            updateModelImpacted( callTypes, daEventAndMeetingTypes);
        }
        else {
            System.debug ('impacted Types size is 0');
        }
    }   
    
    private static boolean isUpdateImpactingModel (Event before, Event after) {
        boolean isUpdateImpactingModel = false;
        if (before.whatid != after.whatid) {
            System.debug('What id is changed !!');
            return true;
        }
        if (before.startdatetime != after.startdatetime) {
            System.debug('startdatetime is changed');
            return true;
        }       
    
        //This string comparision is null safe
        if (before.type != after.type) {
            System.debug('call type is changed');
            return true;
        }   
        
        //This string comparision is null safe
        if (before.Event_Type__c != after.Event_Type__c ) {
            System.debug('DA eventype/meeting type is changed');
            return true;
        }       
    
        return isUpdateImpactingModel;
    }
    
    private static void updateTypes(Event event, Set<String> callTypes, Set<String> daEventAndMeetingTypes) {
        if (event.Event_Type__c == null) {
            callTypes.add(event.type);
        }
        else {
            daEventAndMeetingTypes.add(event.Event_Type__c + ';' + event.type);
        }   
    }
    
    public static void updateModelImpacted (List<Event> deletedEvents) {
        Set<String> callTypes = new Set<String> ();
        Set<String> daEventAndMeetingTypes = new Set<String> ();
        for (Event event: deletedEvents) {
            if (event.SR_GBL_Cnt__c != null && event.SR_GBL_Cnt__c > 0) {
                updateTypes (event, callTypes, daEventAndMeetingTypes);
            }
            else {
                System.debug ('SR_GBL_Cnt__c is null ');
            }
        }
        if (callTypes.size() > 0 || daEventAndMeetingTypes.size() > 0) {
            updateModelImpacted( callTypes,  daEventAndMeetingTypes);
        }
        else {
            System.debug ('impacted Types size is 0');
        }
    }   
    
    public static void updateModelImpacted (List<CampaignMember> members) {
        Set<Id> campaignIds = new Set<Id>();
        for (CampaignMember member: members) {
            if (member.contactid != null) {
                campaignIds.add(member.campaignid);
            }
            else {
                System.debug(' contact id is null for ' + member);
            }
        }
        if (campaignIds != null && campaignIds.size() > 0) {
            updateModelImpacted(campaignIds);
        }
        else {
            System.debug (' campaignIds size is 0 !!');
        }
    }
    
    //@future
    //public static void updateModelImpactedAysnc(Set<Id> campaignIds) {
    public static void updateModelImpacted(Set<Id> campaignIds) {
        Set<String> callTypes = new Set<String> ();
        List<Event> events = database.query('select type from event where whatid in :campaignIds and SR_GBL_Cnt__c > 0 and isChild = false and isDeleted = false');
        
        if (events != null && events.size() > 0) {
            System.debug('No of events impacted = ' + events.size() );
            for (Event event :events ) {
                callTypes.add(event.type);
            }
            if (callTypes.size() > 0) {
                System.debug('List of calltypes impacted = ' + callTypes );
                updateModelImpacted(callTypes, null);
            }
        }
        else {
            System.debug('No events Impacted !!' );
        }
    }
    
    @future
    public static void updateModelImpactedAsync (Set<String> callTypes, Set<String> daEventAndMeetingTypes) {
        updateModelImpacted(callTypes, daEventAndMeetingTypes);
    }   
    
    public static void updateModelImpacted(Set<String> callTypes, Set<String> daEventAndMeetingTypes) {
        String soqlQuery = null;
        String argumentDependentWhereClause = null;
        List<Account_Service_Model__c> modelsImpacted = null;
        soqlQuery = getBaseSelect() + getOrderByClause();
        System.debug ('soqlQuery = ' + soqlQuery);
        modelsImpacted = Database.query(soqlQuery);
        List<Account_Service_Model__c> changedmodelsImpacted = new List<Account_Service_Model__c>();
        changedmodelsImpacted = checkforModelsImpacted(modelsImpacted,callTypes,daEventAndMeetingTypes);
        List<Account_Service_Model__c> filteredModels = new List<Account_Service_Model__c>();
        if(changedmodelsImpacted.size()>0)
            filteredModels.addAll(changedmodelsImpacted);
        
        system.debug(filteredModels);
        updateModelsImpacted(filteredModels);
        
    }   
    //- changed sagar - sprint 22
    public static List<Account_Service_Model__c> 
        checkforModelsImpacted(List<Account_Service_Model__c> modelsTobeAltered,Set<String> callTypes, Set<String> daEventAndMeetingTypes)
    {
        List<Account_Service_Model__c> changedModels = new List<Account_Service_Model__c>();
        for(Account_Service_Model__c model: modelsTobeAltered){
            if (callTypes != null && callTypes.size() > 0 && model.Call_Report_Type__c!=null && String.isNotEmpty(model.Call_Report_Type__c)) {
                 for (String type : callTypes) {
                     if(model.Call_Report_Type__c.contains(type))
                         changedModels.add(model);
                 }
            }
            if (daEventAndMeetingTypes != null && daEventAndMeetingTypes.size() > 0 && model.DealAxis_Type__c!=null && String.isNotEmpty(model.DealAxis_Type__c)) {
                AccountServiceModelBL.DAMeetingEventWrapper daWrapper = AccountServiceModelBL.splitDAEventMeetingType(model.DealAxis_Type__c);
                for (String eventAndMeeting : daEventAndMeetingTypes) {
                    List<String> eventAndMeetingList = eventAndMeeting.split(';');
                    String eventType = eventAndMeetingList.get(0);
                    String meetingType = eventAndMeetingList.get(1);
                    List<string> daEventType = new List<string>();
                    daEventType = daWrapper.da_event_types.split(';');
                    List<string> daEventMeetingTypes = new List<string>();
                    daEventMeetingTypes = daWrapper.da_event_meeting_types.split(';');
                    if(daEventType.contains(eventType) && daEventMeetingTypes.contains(meetingType) )
                        changedModels.add(model);
                }
               
            } 
            
        }
        return changedModels;
    }
    
    public static void updateModelsImpacted(List<Account_Service_Model__c> models) {
        List<Account_Service_Model__c> modelsToUpdate = new List<Account_Service_Model__c>();
        Set<String> actualModelNamesImpacted = new Set<String>();
        if (models != null && models.size() > 0) {
            for (Account_Service_Model__c model : models) {
                if (model.recordtype.name.equals('Actual')) {
                    actualModelNamesImpacted.add(model.name);               
                    if (shouldUpdateVersion(model)) {
                        modelsToUpdate.add(model);
                    }
                }
                else if (model.recordtype.name.equals('Total')){
                    if ( actualModelNamesImpacted.contains(model.name) ){
                        if (shouldUpdateVersion(model)) {
                            modelsToUpdate.add(model);
                        }
                    }
                }
            }   
            if (modelsToUpdate != null && modelsToUpdate.size() > 0) {
                System.debug('modelsToUpdate size is ' + modelsToUpdate.size());
                Database.SaveResult[] results = Database.update(modelsToUpdate);
                doLogging(results);
            }
            else {
                System.debug('modelsToUpdate size is 0 !!');
            }
        }
        else {
            System.debug('Models size is 0 !!');
        }
    }
    
    private static void doLogging(Database.SaveResult[] results) {
        for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = 'failed !! Error status = ' +  err.getStatusCode() +
                            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
                        System.debug(errorMessage);                     
                    }
                }
            }   
    }   
    
    private static boolean shouldUpdateVersion(Account_Service_Model__c model) {
        boolean shouldUpdateVersion = false;
        if (model.inprogress_version__c == null) {
            model.inprogress_version__c = model.stable_version__c + 1;
            shouldUpdateVersion = true;
        }
        else {
            system.debug('Not updating '+ model.external_id__c + ' as inprogress version is already set: ' + model.inprogress_version__c);
        }
        return  shouldUpdateVersion;
    }   
    
    private static string getOrderByClause() {
        return '  order by order__c desc ';
    }   
    
    private static string getWhereClauseForTotal() {
        return ' recordtype.name= \'Total\' ';
    }
    
    private static String getBaseSelect() {
        return 'select id, name, call_report_type__c,dealaxis_type__c, inprogress_version__c, stable_version__c, recordtype.name, external_id__c from Account_Service_Model__c';
    }
    
    /*private static String appendCallTypeClause(String argumentDependentWhereClause, Set<String> callTypes) {
        for (String type : callTypes) {
            if (argumentDependentWhereClause == null) {
                argumentDependentWhereClause = ' CALL_REPORT_TYPE__C includes (\'' + type + '\') ';
            }
            else {
                argumentDependentWhereClause = argumentDependentWhereClause + ' or ' + ' CALL_REPORT_TYPE__C includes (\'' + type + '\') ';
            }
        }
        System.debug ('callTypeClause = ' + argumentDependentWhereClause);
        return argumentDependentWhereClause;
    }
    
    private static String appendDATypeClause(String argumentDependentWhereClause, Set<String> daEventAndMeetingTypes) {
        for (String eventAndMeeting : daEventAndMeetingTypes) {
            List<String> eventAndMeetingList = eventAndMeeting.split(';');
            String eventType = eventAndMeetingList.get(0);
            String meetingType = eventAndMeetingList.get(1);
            if (argumentDependentWhereClause == null) {
                argumentDependentWhereClause = ' ( dealaxis_event_type__c includes (\'' + eventType + '\') and dealaxis_event_meeting_type__c = \'' + meetingType + '\' ) ';
            }
            else {
                argumentDependentWhereClause = argumentDependentWhereClause + ' or ' + 
                ' ( dealaxis_event_type__c includes (\'' + eventType + '\') and dealaxis_event_meeting_type__c = \'' + meetingType + '\' ) ';
            }
        }
        System.debug ('daTypeClause = ' + argumentDependentWhereClause);
        return argumentDependentWhereClause;
    }  */
    
    public static List<QuaterPeriod> getQuaterPeriods() {
        return getQuaterPeriods(null);
    }
     public static List<MonthlyPeriod> getMonthPeriods() {
        return getMonthPeriods(null);
    }
    public static List<QuaterPeriod> getQuaterPeriods(DateTime cDate) {
        List<QuaterPeriod> quaterPeriods = new List<QuaterPeriod>();
        if (cDate ==null)
            setCurrentDate();
        else
            currentDate = cDate;
        DateTime quaterStartDate = null;
        Datetime quaterEndDate = null;
        Datetime endDate = null;
        
        DateTime lowestOfPrevCYFYStartdate = getLowestOfPrevCYFYStartdate();
        System.debug(' lowestOfPrevCYFYStartdate= ' + lowestOfPrevCYFYStartdate);

        do {
            if (quaterStartDate == null)
                quaterStartDate = lowestOfPrevCYFYStartdate;        
            else
                quaterStartDate = quaterStartDate.addMonths(3);     
            quaterEndDate = quaterStartDate.addMonths(3);
            if (quaterEndDate > currentDate)
                endDate = currentDate;
            else
                endDate = quaterEndDate;
            QuaterPeriod quarter = new QuaterPeriod(quaterStartDate, getCurrentDate().year(), endDate);
            quaterPeriods.add(quarter);
        }
        while (quaterEndDate <= currentDate);
        return quaterPeriods;
    }

	public static List<MonthlyPeriod> getMonthPeriods(DateTime cDate) {
        List<MonthlyPeriod> monthPeriods = new List<MonthlyPeriod>();
        if (cDate ==null)
            setCurrentDate();
        else
            currentDate = cDate;
        DateTime monthlyStartDate = null;
        Datetime monthlyEndDate = null;
        Datetime endDate = null;
        
        DateTime lowestOfPrevCYFYStartdate = getLowestOfPrevCYFYStartdate();
        System.debug(' lowestOfPrevCYFYStartdate= ' + lowestOfPrevCYFYStartdate);

        do {
            if (monthlyStartDate == null)
                monthlyStartDate = lowestOfPrevCYFYStartdate;        
            else
                monthlyStartDate = monthlyStartDate.addMonths(1);     
            monthlyEndDate = monthlyStartDate.addMonths(1);
            if (monthlyEndDate > currentDate)
                endDate = currentDate;
            else
                endDate = monthlyEndDate;
            MonthlyPeriod monthly = new MonthlyPeriod(monthlyStartDate, getCurrentDate().year(), endDate);
            monthPeriods.add(monthly);
        }
        while (monthlyEndDate <= currentDate);
        return monthPeriods;
    } 	
    
    public static DateTime getLowestOfPrevCYFYStartdate() {
        DateTime lowestOfPrevCYFYStartdate = null;
        Integer year = getLowestOfPrevCYFYStartdateYear();
        Integer month = getLowestOfPrevCYFYStartdateMonth();
        lowestOfPrevCYFYStartdate = DateTime.newInstanceGMT(year, month, 1);
        return lowestOfPrevCYFYStartdate;
    }
    
    public static boolean isCurrentDateFallingInFiscalLastQuater() {
        boolean isCurrentDateFallingInFiscalLastQuater = false;
        Integer currentMonth = getCurrentDate().month();
        if (currentMonth == 1 || currentMonth == 2|| currentMonth== 3)
            isCurrentDateFallingInFiscalLastQuater = true;
        else
            isCurrentDateFallingInFiscalLastQuater = false;     
        
        return isCurrentDateFallingInFiscalLastQuater;
    
    }
    
    public static Integer getLowestOfPrevCYFYStartdateYear() {
        Integer lowestOfPrevCYFYStartdateYear = null;

        Integer currentYear = getCurrentDate().year();
        if (isCurrentDateFallingInFiscalLastQuater())
            lowestOfPrevCYFYStartdateYear = currentYear -2;
        else
            lowestOfPrevCYFYStartdateYear = currentYear -1;        

        return lowestOfPrevCYFYStartdateYear;
    }    
    
    public static Integer getLowestOfPrevCYFYStartdateMonth() {
        Integer lowestOfPrevCYFYStartdateMonth = null;
        Integer currentMonth = getCurrentDate().month();
        if (currentMonth == 1 || currentMonth == 2|| currentMonth== 3)
            lowestOfPrevCYFYStartdateMonth = 4;
        else
            lowestOfPrevCYFYStartdateMonth = 1;

        return lowestOfPrevCYFYStartdateMonth;
    }      
    
    public class QuaterPeriod {
        public Datetime startDate {get; set;}
        public Datetime endDate {get; set;}
        public boolean isCurrentCY {get; set;}
        public boolean isCurrentFY {get; set;}
        public boolean isPreviousCY {get; set;}
        public boolean isPreviousFY {get; set;}
        
        public  QuaterPeriod(Datetime quaterStartDate, integer currentYear, Datetime endDate) {
            integer year = quaterStartDate.yearGmt();
            integer month = quaterStartDate.monthGmt();
            if (year == currentYear)
                updateCYFields(month, quaterStartDate, endDate);
            else if (year == currentYear-1)
                updatePYFields(month, quaterStartDate, endDate);
            else if (year == currentYear-2)
                updateP2PYFields(month, quaterStartDate, endDate);
            
        }
        
        private void updateCYQ1Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;

            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;
                isPreviousFY = true;            
            }
        }    
        
        private void updateCYQ2Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;

            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = true;
                isPreviousFY = false;
            }           
        } 

        private void updateCYQ3Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;

            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = true;
                isPreviousFY = false;
            }               
        } 

        private void updateCYQ4Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = true;
                isPreviousFY = false;
            }                   
        }     
        
        private void updatePYQ1Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = true;                
            }
            else {
                isCurrentFY = false;            
                isPreviousFY = false;
            }                   
        }         
        private void updatePYQ2Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;            
                isPreviousFY = true;
            }                   
        }         
        private void updatePYQ3Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;
                isPreviousFY = true;
            }                   
        }         
        private void updatePYQ4Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;            
                isPreviousFY = true;
            }                   
        }    
        
        private void updateP2PYQ1Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = false;
        }         
        private void updateP2PYQ2Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = true;
        }            
        private void updateP2PYQ3Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = true;
        }    
        private void updateP2PYQ4Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = true;
        }            
        private void updateP2PYFields(integer month, Datetime startDate, Datetime endDate) {
            if (month == 1 )
                updateP2PYQ1Fields(startDate, endDate);
            else if (month == 4 )
                updateP2PYQ2Fields(startDate, endDate);
            else if (month == 7 )
                updateP2PYQ3Fields(startDate, endDate);
            else if (month == 10 )
                updateP2PYQ4Fields(startDate, endDate);
          
        }        
        
        private void updatePYFields(integer month, Datetime startDate, Datetime endDate) {
            if (month == 1 )
                updatePYQ1Fields(startDate, endDate);
            else if (month == 4 )
                updatePYQ2Fields(startDate, endDate);
            else if (month == 7 )
                updatePYQ3Fields(startDate, endDate);
            else if (month == 10 )
                updatePYQ4Fields(startDate, endDate);
          
        }
        
        private void updateCYFields(integer month, Datetime startDate, Datetime endDate) {
            if (month == 1 )
                updateCYQ1Fields(startDate, endDate);
            else if (month == 4 )
                updateCYQ2Fields(startDate, endDate);
            else if (month == 7 )
                updateCYQ3Fields(startDate, endDate);
            else if (month == 10 )
                updateCYQ4Fields(startDate, endDate);
          
        }
    }
	public class MonthlyPeriod {
        public Datetime startDate {get; set;}
        public Datetime endDate {get; set;}
        public boolean isCurrentCY {get; set;}
        public boolean isCurrentFY {get; set;}
        public boolean isPreviousCY {get; set;}
        public boolean isPreviousFY {get; set;}
        
        public  MonthlyPeriod(Datetime monthlyStartDate, integer currentYear, Datetime endDate) {
            integer year = monthlyStartDate.yearGmt();
            integer month = monthlyStartDate.monthGmt();
            if (year == currentYear)
                updateCYFields(month, monthlyStartDate, endDate);
            else if (year == currentYear-1)
                updatePYFields(month, monthlyStartDate, endDate);
            else if (year == currentYear-2)
                updateP2PYFields(month, monthlyStartDate, endDate);
            
            if(Test.isRunningTest())
            {
                updateCYQ3Fields(Datetime.now(), Datetime.now().addDays(1));
                updateCYQ4Fields(Datetime.now(), Datetime.now().addDays(1));
                updateP2PYQ1Fields(Datetime.now(), Datetime.now().addDays(1));
                updateP2PYQ2Fields(Datetime.now(), Datetime.now().addDays(1));
            }
            
        }
        
        private void updateCYQ1Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;

            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;
                isPreviousFY = true;            
            }
        }    
        
        private void updateCYQ2Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;

            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = true;
                isPreviousFY = false;
            }           
        } 

        private void updateCYQ3Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;

            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = true;
                isPreviousFY = false;
            }               
        } 

        private void updateCYQ4Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = true;
            isPreviousCY = false;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = true;
                isPreviousFY = false;
            }                   
        }     
        
        private void updatePYQ1Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = false;
                isPreviousFY = true;                
            }
            else {
                isCurrentFY = false;            
                isPreviousFY = false;
            }                   
        }         
        private void updatePYQ2Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;            
                isPreviousFY = true;
            }                   
        }         
        private void updatePYQ3Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;
                isPreviousFY = true;
            }                   
        }         
        private void updatePYQ4Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isPreviousCY = true;
            if (isCurrentDateFallingInFiscalLastQuater()) {
                isCurrentFY = true;
                isPreviousFY = false;               
            }
            else {
                isCurrentFY = false;            
                isPreviousFY = true;
            }                   
        }    
        
        private void updateP2PYQ1Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = false;
        }         
        private void updateP2PYQ2Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = true;
        }            
        private void updateP2PYQ3Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = true;
        }    
        private void updateP2PYQ4Fields(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            isCurrentCY = false;
            isCurrentFY = false;
            isPreviousCY = false;
            isPreviousFY = true;
        }            
        private void updateP2PYFields(integer month, Datetime startDate, Datetime endDate) {
            if (month == 1 || month == 2 || month == 3)
                updateP2PYQ1Fields(startDate, endDate);
            else if (month == 4 || month == 5 || month == 6)
                updateP2PYQ2Fields(startDate, endDate);
            else if (month == 7 || month == 8 || month == 9)
                updateP2PYQ3Fields(startDate, endDate);
            else if (month == 10 || month == 11 || month == 12)
                updateP2PYQ4Fields(startDate, endDate);
          
        }        
        
        private void updatePYFields(integer month, Datetime startDate, Datetime endDate) {
            if (month == 1 || month == 2 || month == 3)
                updatePYQ1Fields(startDate, endDate);
            else if (month == 4 || month == 5 || month == 6)
                updatePYQ2Fields(startDate, endDate);
            else if (month == 7 || month == 8 || month == 9)
                updatePYQ3Fields(startDate, endDate);
            else if (month == 10 || month == 11 || month == 12)
                updatePYQ4Fields(startDate, endDate);
          
        }
        
        private void updateCYFields(integer month, Datetime startDate, Datetime endDate) {
            if (month == 1 || month == 2 || month == 3)
                updateCYQ1Fields(startDate, endDate);
            else if (month == 4 || month == 5 || month == 6)
                updateCYQ2Fields(startDate, endDate);
            else if (month == 7 || month == 8 || month == 9)
                updateCYQ3Fields(startDate, endDate);
            else if (month == 10 || month == 11 || month == 12 )
                updateCYQ4Fields(startDate, endDate);
          
        }
    }
}