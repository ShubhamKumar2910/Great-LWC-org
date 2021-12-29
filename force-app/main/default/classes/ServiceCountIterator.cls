Global class ServiceCountIterator implements Iterator<Map<String,Object>>, Iterable<Map<String,Object>>  {
     public List<ServiceROIUtility.MonthlyPeriod> monthlyPeriods {get; set;}
    public List<Account_Service_Model__c> modelItems {get; set;}
    public Integer modelIndex {get; set;}
    public Integer periodIndex {get; set;}
    public Integer modelSize {get; set;}
    public Integer periodSize {get; set;}
    
    global Iterator<Map<String,Object>> Iterator() {
        return this;            
    }
    
    public ServiceCountIterator() {
        System.debug('Inside constructor');
        modelIndex = 0;
        periodIndex = 0;
        modelSize = 0;
        periodSize = 0;
        modelItems = [select id, name, item_name__c, call_report_type__c,DealAxis_Type__c, is_contact_count__c, weight__c, inprogress_version__c from Account_Service_Model__c where recordType.name='Actual' and inprogress_version__c != null];
        //modelItems = [select id, name, item_name__c, call_report_type__c, dealaxis_event_type__c, dealaxis_event_meeting_type__c, is_contact_count__c, weight__c, inprogress_version__c from Account_Service_Model__c where recordType.name='Actual' and item_name__c='Analyst : live interactions'];     
        //MonthlyPeriods = ServiceROIUtility.getMonthlyPeriods();
        monthlyPeriods = ServiceROIUtility.getMonthPeriods();
        if (modelItems != null) 
            modelSize = modelItems.size();
        if (monthlyPeriods != null)
            periodSize = monthlyPeriods.size();      
        System.debug('before modelSize = ' + modelSize);
        System.debug('before periodSize = ' + periodSize);  
        overrideDataIfApplicable();
        if (modelItems != null) 
            modelSize = modelItems.size();
        if (monthlyPeriods != null)
            periodSize = monthlyPeriods.size();      
        System.debug('after modelSize = ' + modelSize);
        System.debug('after periodSize = ' + periodSize);       
    }
    
    private void overrideDataIfApplicable() {
        if(!Test.isRunningTest()){
            System.debug('isRunningTest = false. Not Overriding !!');
        } else {
            System.debug('Warning isRunningTest = true. Overriding iterator data !!');
            modelItems = new Account_Service_Model__c[] {modelItems[0]};
            monthlyPeriods = new ServiceROIUtility.MonthlyPeriod [] {monthlyPeriods[monthlyPeriods.size()-1]};
        }   
    
    }
    
    global boolean hasNext() {
        if (isEndReached())
            return false;
        else
            return true;
    }
    
    global Map<String,Object> next() {
        Map<String,Object> modelAndPeriodContainer = null;
        if (isEndReached())
            modelAndPeriodContainer = null;
        else {
            modelAndPeriodContainer = new Map<String,Object>();
            Account_Service_Model__c modelData = getModel();
            ServiceROIUtility.MonthlyPeriod periodData = getPeriod();
            modelAndPeriodContainer.put('MODEL', modelData);
            modelAndPeriodContainer.put('PERIOD', periodData);
        }
        return modelAndPeriodContainer;
    }
    
    private Account_Service_Model__c getModel() {
        Account_Service_Model__c model = null;
        if (isPeriodEndReached() || modelIndex ==0) {
            model = modelItems[modelIndex];
            modelIndex = modelIndex + 1;
            periodIndex = 0;
        }
        else {
            model = modelItems[modelIndex-1];
        }
        return model;
    }
    
    private ServiceROIUtility.MonthlyPeriod getPeriod() {
        ServiceROIUtility.MonthlyPeriod period = null;
        period = monthlyPeriods[periodIndex];
        periodIndex = periodIndex + 1;
        return period;
    }   
    
    private boolean isEndReached() {
        if (isDataAbsent() ||
                        (isPeriodEndReached() &&  isModelEndReached()))
            return true;
        else
            return false;
    }
    
    private boolean isPeriodEndReached() {
        if ( periodIndex >= periodSize)
            return true;
        else
            return false;
    }
    
    private boolean isModelEndReached() {
        if ( modelIndex >= modelSize)
            return true;
        else
            return false;
    }    
    
    private boolean isDataAbsent() {
        if (periodSize == 0 || modelSize == 0 )
            return true;
        else
            return false;
    }

}

/* test class*/
/*

ServiceCountIterator iterator = new ServiceCountIterator();
integer counter = 0;
while (iterator.hasNext()) {
    counter++;
    Map<String,Object> modelAndPeriodContainer = iterator.next();
    Account_Service_Model__c modelData = (Account_Service_Model__c)modelAndPeriodContainer.get('MODEL');
    ServiceROIUtility.MonthlyPeriod periodData = (ServiceROIUtility.MonthlyPeriod)modelAndPeriodContainer.get('PERIOD');
    System.debug(modelData.name +', '+modelData.Item_Name__c  +', '+periodData.startDate+', ' + periodData.endDate);

}
system.debug('No of rows returned = ' + counter);

*/