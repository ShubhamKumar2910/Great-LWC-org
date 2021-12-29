public with sharing class ResourceUtilizationController {

    //Static field defination for display purpose
    public static final String JAPAN='Japan';
    public static final String ASIAEX='AsiaEx';
    public static final String EUROPE='Europe';
    public static final String AMERICAS='Americas';
    public static final String GBL='Global';
    public static final String TOTAL_RECORD_TYPE='Total';
    public static final String PRODUCT_TOTAL='Total';
    public static final String CURRENT_FISCAL_YEAR='Current Fiscal Year';
    public static final String CURRENT_CALENDER_YEAR='Current Calender Year';
    public static final String PREVIOUS_FISCAL_YEAR='Previous Fiscal Year';
    public static final String PREVIOUS_FISCAL_CALENDER='Previous Calender Year';
    public static final String DEFAULT_MODEL='Equity Core (value)'; 
    
    //private ApexPages.StandardController stdCtrl;
    private Account accRec;
    Id accountid;
    
    public String model {get; set;}
    public String period{get; set;}
    public List<selectOption> modelOptions{get; set;}
    
    public Account_Service_rank__c[] serviceRanks{get; set;}
    public ServiceRankWrapper[] serviceRankWrapper {get; set;}
    
    public Account_Revenue_rank__c[] revenueRanks{get; set;}
    public RevenueRankWrapper[] revenueRankWrapper {get; set;}
    
    public ROIRank[] roiRanks {get; set;}
    
    public void loadDefaultReport(){
        model=ResourceUtilizationController.DEFAULT_MODEL;
        period='Current_FY_';
        search(); 
    } 
    
    public ResourceUtilizationController(ApexPages.StandardController std) {
        accRec=(Account)std.getRecord();
        populateModelOptions();
        loadDefaultReport();
    }
    public List<selectOption> getPeriodOptions() {
        List<selectOption> periodOptions = new List<selectOption>();
        periodOptions.add(new selectOption('Current_FY_',ResourceUtilizationController.CURRENT_FISCAL_YEAR));
        periodOptions.add(new selectOption('Current_CY_',ResourceUtilizationController.CURRENT_CALENDER_YEAR));
        periodOptions.add(new selectOption('Previous_FY_',ResourceUtilizationController.PREVIOUS_FISCAL_YEAR));
        periodOptions.add(new selectOption('Previous_CY_',ResourceUtilizationController.PREVIOUS_FISCAL_CALENDER));
        return periodOptions;
    }
    
    public void populateModelOptions() {
        List<Account_Service_Model__c> totalModelObjects = [select name from Account_Service_Model__c where recordtype.name='Total' order by name];
        if (totalModelObjects != null && totalModelObjects.size() > 0) {
            modelOptions = new List<selectOption>();
            for (Account_Service_Model__c model: totalModelObjects) {
                modelOptions.add(new selectOption(model.name,model.name));
            }   
        }   
    }
    
    public void search() {
        //Id accountid = System.currentPageReference().getParameters().get('accountid');
        accountid = accRec.Id;
        System.debug('Inside search model = ' + model + ', period = '+ period + ', account = ' + accountid);
        searchServiceRanks();        
        searchRevenueRanks();   
        populateROIRanks();
        
    }
    
    private void populateROIRanks() {
        roiRanks = null;
        if ((serviceRankWrapper != null && serviceRankWrapper.size() > 0) ||
                    (revenueRankWrapper != null && revenueRankWrapper.size() > 0))    {
                roiRanks = getEmptyRegionRows();
                ServiceRankWrapper totalServiceRankWrapper = getTotalServiceRankWrapper();
                RevenueRankWrapper totalRevenueRankWrapper = getTotalRevenueRankWrapper();
                        system.debug('totalRevenueRankWrapper size: '+totalRevenueRankWrapper);
                if (serviceRankWrapper != null && serviceRankWrapper.size() > 0)
                    updateServiceRanks(roiRanks, totalServiceRankWrapper);
                if (revenueRankWrapper != null && revenueRankWrapper.size() > 0) 
                    updateRevenueRanks(roiRanks, totalRevenueRankWrapper);
            }       
    }
    
    private ServiceRankWrapper getTotalServiceRankWrapper() {
        ServiceRankWrapper totalServiceRankWrapper = null;
        if (serviceRankWrapper != null) {
            for (integer index = 0; index < serviceRankWrapper.size(); index ++) {
                if (serviceRankWrapper[index].recordType.equals(ResourceUtilizationController.TOTAL_RECORD_TYPE)){
                    System.debug('Inside Service rank');
                    totalServiceRankWrapper = serviceRankWrapper[index];
                    break;
                }
            }
        }
        return totalServiceRankWrapper;
    }
    
    private RevenueRankWrapper getTotalRevenueRankWrapper() {
        RevenueRankWrapper totalRevenueRankWrapper = null;
        if (revenueRankWrapper != null) {
            system.debug('revenueRankWrapper.size(): '+revenueRankWrapper.size());
            for (integer index = 0; index < revenueRankWrapper.size(); index ++) {
              
                if (revenueRankWrapper[index].product.equals(ResourceUtilizationController.PRODUCT_TOTAL)){
                      system.debug('found');
                    system.debug('---revenueRankWrapper[index]---' + revenueRankWrapper[index]);
                    totalRevenueRankWrapper = revenueRankWrapper[index];
                    break;
                }
            }
        }
        return totalRevenueRankWrapper;
    }   
    
    private void searchServiceRanks() {
        if (serviceRanks!= null)
            system.debug('serviceRanks before: '+serviceRanks.size());                                               
        populateServiceRanks(accountid, model);
        populateServiceRankWrapper( period);
        if (serviceRanks!= null)
            system.debug('serviceRanks after: '+serviceRanks.size()); 
        if (serviceRankWrapper != null)
            system.debug('serviceRankWrapper after: '+serviceRankWrapper.size());
    }
    
    private void searchRevenueRanks() {
        if (revenueRanks!= null)
            system.debug('revenueRanks before: '+revenueRanks.size());                                               
        populateRevenueRanks(accountid, model);
        populateRevenueRankWrapper( period);
        if (revenueRanks!= null)
            system.debug('revenueRanks after: '+revenueRanks.size()); 
        if (RevenueRankWrapper != null)
            system.debug('revenueRankWrapper after: '+revenueRankWrapper.size());
    }   
    
    private void populateServiceRanks(Id accountid, String model) {
    
        String soqlQuery = getBaseSoql() + getPeriodSpecificWhereCondition() + getOrderByClause();
        System.debug('soql = ' + soqlQuery);
        serviceRanks = Database.query(soqlQuery);
        if (serviceRanks == null || serviceRanks.size() <= 0) {
            System.debug('No service rank data found !!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No service rank data found !!'));
        }
    }
    
    private String getPeriodSpecificWhereCondition() {
        String periodSpecificWhereCondition = null;
            if ( period.equals('Current_FY_') ) {
                periodSpecificWhereCondition = ' and (Current_FY_JAPAN_COUNT__C > 0 or Current_FY_ASIAEX_COUNT__C > 0 or Current_FY_EUROPE_COUNT__C > 0 or Current_FY_US_COUNT__C > 0 or  Current_FY_GLOBAL_COUNT__C > 0)';
            }
            else if ( period.equals('Current_CY_') ) {
                periodSpecificWhereCondition = ' and (Current_CY_JAPAN_COUNT__C > 0 or Current_CY_ASIAEX_COUNT__C > 0 or Current_CY_EUROPE_COUNT__C > 0 or Current_CY_US_COUNT__C > 0 or  Current_CY_GLOBAL_COUNT__C > 0)';         
            }
            else if ( period.equals('Previous_FY_') ) {
                periodSpecificWhereCondition = ' and (Previous_FY_JAPAN_COUNT__C > 0 or Previous_FY_ASIAEX_COUNT__C > 0 or Previous_FY_EUROPE_COUNT__C > 0 or Previous_FY_US_COUNT__C > 0 or  Previous_FY_GLOBAL_COUNT__C > 0)';            
            }
            else if ( period.equals('Previous_CY_') ) {
                periodSpecificWhereCondition = ' and (Previous_CY_JAPAN_COUNT__C > 0 or Previous_CY_ASIAEX_COUNT__C > 0 or Previous_CY_EUROPE_COUNT__C > 0 or Previous_CY_US_COUNT__C > 0 or  Previous_CY_GLOBAL_COUNT__C > 0)';            
            }       
    
        return periodSpecificWhereCondition;
    }
    
    private String getOrderByClause() {
        return ' order by model__r.order__c';
    
    }
    
    private String getBaseSoql() {
        return 'select model__r.Item_Name__c,Current_FY_JAPAN_RANK__C,Current_FY_JAPAN_COUNT__C,Current_FY_ASIAEX_RANK__C,Current_FY_ASIAEX_COUNT__C,Current_FY_EUROPE_RANK__C,Current_FY_EUROPE_COUNT__C,Current_FY_US_RANK__C,Current_FY_US_COUNT__C,Current_FY_GLOBAL_RANK__C,Current_FY_GLOBAL_COUNT__C,Current_CY_JAPAN_RANK__C,Current_CY_JAPAN_COUNT__C,Current_CY_ASIAEX_RANK__C,Current_CY_ASIAEX_COUNT__C,Current_CY_EUROPE_RANK__C,Current_CY_EUROPE_COUNT__C,Current_CY_US_RANK__C,Current_CY_US_COUNT__C,Current_CY_GLOBAL_RANK__C,Current_CY_GLOBAL_COUNT__C,Previous_FY_JAPAN_RANK__C,Previous_FY_JAPAN_COUNT__C,Previous_FY_ASIAEX_RANK__C,Previous_FY_ASIAEX_COUNT__C,Previous_FY_EUROPE_RANK__C,Previous_FY_EUROPE_COUNT__C,Previous_FY_US_RANK__C,Previous_FY_US_COUNT__C,Previous_FY_GLOBAL_RANK__C,Previous_FY_GLOBAL_COUNT__C,Previous_CY_JAPAN_RANK__C,Previous_CY_JAPAN_COUNT__C,Previous_CY_ASIAEX_RANK__C,Previous_CY_ASIAEX_COUNT__C,Previous_CY_EUROPE_RANK__C,Previous_CY_EUROPE_COUNT__C,Previous_CY_US_RANK__C,Previous_CY_US_COUNT__C,Previous_CY_GLOBAL_RANK__C,Previous_CY_GLOBAL_COUNT__C,model__r.recordtype.name from account_service_rank__c  where account__r.id= :accountid and model__r.name= :model and is_stable_version__c = true' ;
    }
    
    private void populateServiceRankWrapper(String period) {
        serviceRankWrapper = null;
        if (serviceRanks != null) {
            serviceRankWrapper = new ServiceRankWrapper[serviceRanks.size()];
            for (integer index = 0; index < serviceRanks.size() ; index ++) {
                serviceRankWrapper[index] = new ServiceRankWrapper(serviceRanks[index], period);
            }
        }
    }
    
    private void populateRevenueRanks(Id accountid, String model) {
        revenueRanks = [select product__c,Current_FY_JAPAN_RANK__C,Current_FY_ASIAEX_RANK__C,Current_FY_EUROPE_RANK__C,Current_FY_US_RANK__C,Current_FY_GLOBAL_RANK__C,Current_CY_JAPAN_RANK__C,Current_CY_ASIAEX_RANK__C,Current_CY_EUROPE_RANK__C,Current_CY_US_RANK__C,Current_CY_GLOBAL_RANK__C,Previous_FY_JAPAN_RANK__C,Previous_FY_ASIAEX_RANK__C,Previous_FY_EUROPE_RANK__C,Previous_FY_US_RANK__C,Previous_FY_GLOBAL_RANK__C,Previous_CY_JAPAN_RANK__C,Previous_CY_ASIAEX_RANK__C,Previous_CY_EUROPE_RANK__C,Previous_CY_US_RANK__C,Previous_CY_GLOBAL_RANK__C
                        from account_revenue_rank__c  where account__r.id= :accountid  ];
        if (revenueRanks == null || revenueRanks.size() <= 0) {
            System.debug('No Revenue rank data found !!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No revenue rank data found !!'));
        }                       
    }
    
    private void populateRevenueRankWrapper(String period) {
        revenueRankWrapper = null;
        if (revenueRanks != null) {
            revenueRankWrapper = new RevenueRankWrapper[revenueRanks.size()];
            for (integer index = 0; index < revenueRanks.size() ; index ++) {
                revenueRankWrapper[index] = new RevenueRankWrapper(revenueRanks[index], period);
            }
            sortRevenueRankWrappers();
        }
        
    }   
    
    private void sortRevenueRankWrappers() {
            revenueRankWrapper.sort();
    }
    
    public void updateRevenueRanks (List<ResourceUtilizationController.ROIRank> roiRanks, ResourceUtilizationController.RevenueRankWrapper wrapperRev) {
       if (wrapperRev != null) {
           for(ResourceUtilizationController.ROIRank wrapperRoi: roiRanks)
                {
                    /*if(wrapperRoi.region.equals(ResourceUtilizationController.JAPAN))
                        wrapperRoi.revenueRank = wrapperRev.japanRank;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.ASIAEX))
                        wrapperRoi.revenueRank = wrapperRev.asiaRank;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.EUROPE))
                        wrapperRoi.revenueRank = wrapperRev.europeRank;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.AMERICAS))
                        wrapperRoi.revenueRank = wrapperRev.usRank;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.GBL))
                        wrapperRoi.revenueRank = wrapperRev.globalRank;
                    */
                    
                     //For sales-2633
                    if(wrapperRoi.region.equals(ResourceUtilizationController.JAPAN))
                        wrapperRoi.revenueRank = wrapperRev.japanRankToDisplay;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.ASIAEX))
                        wrapperRoi.revenueRank = wrapperRev.asiaRankToDisplay;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.EUROPE))
                        wrapperRoi.revenueRank = wrapperRev.europeRankToDisplay;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.AMERICAS))
                        wrapperRoi.revenueRank = wrapperRev.usRankToDisplay;
                    if(wrapperRoi.region.equals(ResourceUtilizationController.GBL))
                        wrapperRoi.revenueRank = wrapperRev.globalRankToDisplay;
                }
            }   
        }

    public void updateServiceRanks (List<ResourceUtilizationController.ROIRank> roiRanks, ResourceUtilizationController.ServiceRankWrapper wrapperSer) {
        if (wrapperSer != null) {
            for(ResourceUtilizationController.ROIRank wrapperRoi: roiRanks)
            {
                if(wrapperRoi.region.equals(ResourceUtilizationController.JAPAN)){
                        wrapperRoi.serviceRank = wrapperSer.japanRank;
                    	wrapperRoi.serviceRankPrevious = wrapperSer.japanPreviousRank;
                }
                if(wrapperRoi.region.equals(ResourceUtilizationController.ASIAEX)){
                        wrapperRoi.serviceRank = wrapperSer.asiaRank;
                    	wrapperRoi.serviceRankPrevious = wrapperSer.asiaPreviousRank;
                }
                if(wrapperRoi.region.equals(ResourceUtilizationController.EUROPE)){
                        wrapperRoi.serviceRank = wrapperSer.europeRank;
                    	wrapperRoi.serviceRankPrevious = wrapperSer.europePreviousRank;                    
                }
                if(wrapperRoi.region.equals(ResourceUtilizationController.AMERICAS)){
                        wrapperRoi.serviceRank = wrapperSer.usRank;
                    	wrapperRoi.serviceRankPrevious = wrapperSer.usPreviousRank;
                }
                if(wrapperRoi.region.equals(ResourceUtilizationController.GBL)){
                        wrapperRoi.serviceRank = wrapperSer.globalRank;
                    	wrapperRoi.serviceRankPrevious = wrapperSer.globalPreviousRank;
                }
				/*
                system.debug('----wrapperSer---' + wrapperSer);
                if(wrapperRoi.region.equals(ResourceUtilizationController.JAPAN))
                        wrapperRoi.serviceRank = (String)wrapperSer.japanRank != null ? wrapperSer.japanRank : '' + wrapperSer.japanPreviousRank != null ? '(' + wrapperSer.japanPreviousRank + ')' : '(-)';
                    if(wrapperRoi.region.equals(ResourceUtilizationController.ASIAEX))
                        wrapperRoi.serviceRank = wrapperSer.asiaRank + wrapperSer.asiaPreviousRank != null ? '(' + wrapperSer.asiaPreviousRank + ')' : '(-)';
                    if(wrapperRoi.region.equals(ResourceUtilizationController.EUROPE))
                        wrapperRoi.serviceRank = wrapperSer.europeRank + wrapperSer.europePreviousRank != null ? '(' + wrapperSer.europePreviousRank + ')' : '(-)';
                    if(wrapperRoi.region.equals(ResourceUtilizationController.AMERICAS))
                        wrapperRoi.serviceRank = wrapperSer.usRank + wrapperSer.usPreviousRank != null ? '(' + wrapperSer.usPreviousRank + ')' : '(-)';
                    if(wrapperRoi.region.equals(ResourceUtilizationController.GBL))
                        wrapperRoi.serviceRank = wrapperSer.globalRank + wrapperSer.globalPreviousRank != null ? '(' + wrapperSer.globalPreviousRank + ')' : '(-)';
               */
            }
        }   
    }       
    
    public ROIRank[] getEmptyRegionRows() {
        ROIRank[] roiRanks = new ROIRank[5];
        roiRanks[0] = new ROIRank(ResourceUtilizationController.JAPAN);
        roiRanks[1] = new ROIRank(ResourceUtilizationController.ASIAEX);
        roiRanks[2] = new ROIRank(ResourceUtilizationController.EUROPE);
        roiRanks[3] = new ROIRank(ResourceUtilizationController.AMERICAS);
        roiRanks[4] = new ROIRank(ResourceUtilizationController.GBL);
        
        return roiRanks;
    }           
    
    public class ServiceRankWrapper
    {
        public String itemName { get; set; }
        public decimal japanRank { get; set; }
        public decimal japanPreviousRank { get; set; }
        public decimal japanCount { get; set; }        
        
        public decimal asiaRank { get; set; }
        public decimal asiaPreviousRank { get; set; }
        public decimal asiaCount { get; set; }
               
        public decimal europeRank { get; set; }
        public decimal europePreviousRank { get; set; }
        public decimal europeCount { get; set; }        
        
        public decimal usRank { get; set; }
        public decimal usPreviousRank { get; set; }
        public decimal usCount { get; set; }        
        
        public decimal globalRank { get; set; }
        public decimal globalPreviousRank { get; set; }
        public decimal globalCount { get; set; }        
        
        public String recordType { get; set; }
        
        private decimal validateValue (Decimal value) {
            if (value > 0) {
                return value;
            }
            else    {
                return null;
            }   
        }
        
        public Account_Service_rank__c serviceRankObj { get; private set; }
        
        public ServiceRankWrapper(Account_Service_rank__c serviceRankObj, String period)
        {
            this.serviceRankObj = serviceRankObj;
            this.itemName = serviceRankObj.model__r.Item_Name__c;
            this.recordType = serviceRankObj.model__r.recordtype.name;
            if ( period.equals('Current_FY_') ) {
                this.japanRank = validateValue(serviceRankObj.Current_FY_JAPAN_RANK__C);
                this.japanPreviousRank = validateValue(serviceRankObj.Previous_FY_JAPAN_RANK__C);
                this.japanCount = validateValue(serviceRankObj.Current_FY_JAPAN_COUNT__C);
                this.asiaRank = validateValue(serviceRankObj.Current_FY_ASIAEX_RANK__C);
                this.asiaPreviousRank = validateValue(serviceRankObj.Previous_FY_ASIAEX_RANK__C);
                this.asiaCount = validateValue(serviceRankObj.Current_FY_ASIAEX_COUNT__C);
                this.europeRank = validateValue(serviceRankObj.Current_FY_EUROPE_RANK__C);
                this.europePreviousRank = validateValue(serviceRankObj.Previous_FY_EUROPE_RANK__C);
                this.europeCount = validateValue(serviceRankObj.Current_FY_EUROPE_COUNT__C);
                this.usRank = validateValue(serviceRankObj.Current_FY_US_RANK__C);
                this.usPreviousRank = validateValue(serviceRankObj.Previous_FY_US_COUNT__C);
                this.usCount = validateValue(serviceRankObj.Current_FY_US_COUNT__C);
                this.globalRank = validateValue(serviceRankObj.Current_FY_GLOBAL_RANK__C);
                this.globalPreviousRank = validateValue(serviceRankObj.Previous_FY_GLOBAL_RANK__C);
                this.globalCount = validateValue(serviceRankObj.Current_FY_GLOBAL_COUNT__C);
            }
            else if ( period.equals('Current_CY_') ) {
                this.japanRank = validateValue(serviceRankObj.Current_CY_JAPAN_RANK__C);
                this.japanPreviousRank = validateValue(serviceRankObj.Previous_CY_JAPAN_RANK__C);
                this.japanCount = validateValue(serviceRankObj.Current_CY_JAPAN_COUNT__C);
                this.asiaRank = validateValue(serviceRankObj.Current_CY_ASIAEX_RANK__C);
                this.asiaPreviousRank = validateValue(serviceRankObj.Previous_CY_ASIAEX_RANK__C);
                this.asiaCount = validateValue(serviceRankObj.Current_CY_ASIAEX_COUNT__C);
                this.europeRank = validateValue(serviceRankObj.Current_CY_EUROPE_RANK__C);
                this.europePreviousRank = validateValue(serviceRankObj.Previous_CY_EUROPE_RANK__C);
                this.europeCount = validateValue(serviceRankObj.Current_CY_EUROPE_COUNT__C);
                this.usRank = validateValue(serviceRankObj.Current_CY_US_RANK__C);
                this.usPreviousRank = validateValue(serviceRankObj.Previous_CY_US_RANK__C);
                this.usCount = validateValue(serviceRankObj.Current_CY_US_COUNT__C);
                this.globalRank = validateValue(serviceRankObj.Current_CY_GLOBAL_RANK__C);
                this.globalPreviousRank = validateValue(serviceRankObj.Previous_CY_GLOBAL_RANK__C);
                this.globalCount = validateValue(serviceRankObj.Current_CY_GLOBAL_COUNT__C);
            }
            else if ( period.equals('Previous_FY_') ) {
                this.japanRank = validateValue(serviceRankObj.Previous_FY_JAPAN_RANK__C);
                this.japanPreviousRank = validateValue(0);
                this.japanCount = validateValue(serviceRankObj.Previous_FY_JAPAN_COUNT__C);
                this.asiaRank = validateValue(serviceRankObj.Previous_FY_ASIAEX_RANK__C);
                this.asiaPreviousRank = validateValue(0);
                this.asiaCount = validateValue(serviceRankObj.Previous_FY_ASIAEX_COUNT__C);
                this.europeRank = validateValue(serviceRankObj.Previous_FY_EUROPE_RANK__C);
                this.europePreviousRank = validateValue(0);
                this.europeCount = validateValue(serviceRankObj.Previous_FY_EUROPE_COUNT__C);
                this.usRank = validateValue(serviceRankObj.Previous_FY_US_RANK__C);
                this.usPreviousRank = validateValue(0);
                this.usCount = validateValue(serviceRankObj.Previous_FY_US_COUNT__C);
                this.globalRank = validateValue(serviceRankObj.Previous_FY_GLOBAL_RANK__C);
                this.globalPreviousRank = validateValue(0);
                this.globalCount = validateValue(serviceRankObj.Previous_FY_GLOBAL_COUNT__C);
            }
            else if ( period.equals('Previous_CY_') ) {
                this.japanRank = validateValue(serviceRankObj.Previous_CY_JAPAN_RANK__C);
                this.japanPreviousRank = validateValue(0);
                this.japanCount = validateValue(serviceRankObj.Previous_CY_JAPAN_COUNT__C);
                this.asiaRank = validateValue(serviceRankObj.Previous_CY_ASIAEX_RANK__C);
                this.asiaPreviousRank = validateValue(0);
                this.asiaCount = validateValue(serviceRankObj.Previous_CY_ASIAEX_COUNT__C);
                this.europeRank = validateValue(serviceRankObj.Previous_CY_EUROPE_RANK__C);
                this.europePreviousRank = validateValue(0);
                this.europeCount = validateValue(serviceRankObj.Previous_CY_EUROPE_COUNT__C);
                this.usRank = validateValue(serviceRankObj.Previous_CY_US_RANK__C);
                this.usPreviousRank = validateValue(0);
                this.usCount = validateValue(serviceRankObj.Previous_CY_US_COUNT__C);
                this.globalRank = validateValue(serviceRankObj.Previous_CY_GLOBAL_RANK__C);
                this.globalPreviousRank = validateValue(0);
                this.globalCount = validateValue(serviceRankObj.Previous_CY_GLOBAL_COUNT__C);
            } 
        }
        
    }
    
    public class RevenueRankWrapper implements Comparable
    {
        public String product { get; set; }
        
        public String japanRankToDisplay { get; set; }
        public decimal japanRank { get; set; }
        public String asiaRankToDisplay { get; set; }
        public decimal asiaRank { get; set; }
        public String europeRankToDisplay { get; set; }
        public decimal europeRank { get; set; }
        public String usRankToDisplay { get; set; }
        public decimal usRank { get; set; }
        public String globalRankToDisplay { get; set; }
        public decimal globalRank { get; set; }
        
        public integer order { get; set; }
        
        public Account_Revenue_rank__c revenueRankObj { get; private set; }
        
		private String getRankValue(Decimal revenueRankCount)
		{
			if(revenueRankCount == null)
			{
				return '-';
			}
			else
			{
				return ''+revenueRankCount;
			}
			
		}
		
        public RevenueRankWrapper(Account_Revenue_rank__c revenueRankObj, String period)
        {
            this.revenueRankObj = revenueRankObj;
            if (revenueRankObj.Product__c.equals(ResourceUtilizationController.PRODUCT_TOTAL))
                order = 100;
            else
                order = 1;
            this.product = revenueRankObj.Product__c;
            if ( period.equals('Current_FY_') ) {
                this.japanRankToDisplay = getRankValue(revenueRankObj.Current_FY_JAPAN_RANK__C) + ' (' + getRankValue(revenueRankObj.Previous_FY_JAPAN_RANK__C) + ')';
                this.asiaRankToDisplay = getRankValue(revenueRankObj.Current_FY_ASIAEX_RANK__C) + ' (' + getRankValue(revenueRankObj.Previous_FY_ASIAEX_RANK__C) + ')';
                this.europeRankToDisplay = getRankValue(revenueRankObj.Current_FY_EUROPE_RANK__C)+ ' (' + getRankValue(revenueRankObj.Previous_FY_EUROPE_RANK__C) + ')';
                this.usRankToDisplay = getRankValue(revenueRankObj.Current_FY_US_RANK__C)+ ' (' + getRankValue(revenueRankObj.Previous_FY_US_RANK__C) + ')';
                this.globalRankToDisplay = getRankValue(revenueRankObj.Current_FY_GLOBAL_RANK__C)+ ' (' + getRankValue(revenueRankObj.Previous_FY_GLOBAL_RANK__C) + ')';
                this.japanRank = revenueRankObj.Current_FY_JAPAN_RANK__C;
                this.asiaRank = revenueRankObj.Current_FY_ASIAEX_RANK__C;                   
                this.europeRank = revenueRankObj.Current_FY_EUROPE_RANK__C;                 
                this.usRank = revenueRankObj.Current_FY_US_RANK__C;                 
                this.globalRank = revenueRankObj.Current_FY_GLOBAL_RANK__C;
            }
            else if ( period.equals('Current_CY_') ) {
                this.japanRankToDisplay = getRankValue(revenueRankObj.Current_CY_JAPAN_RANK__C) + ' (' + getRankValue(revenueRankObj.Previous_CY_JAPAN_RANK__C) + ')';
                this.asiaRankToDisplay = getRankValue(revenueRankObj.Current_CY_ASIAEX_RANK__C) + ' (' + getRankValue(revenueRankObj.Previous_CY_ASIAEX_RANK__C) + ')';
                this.europeRankToDisplay = getRankValue(revenueRankObj.Current_CY_EUROPE_RANK__C)+ ' (' + getRankValue(revenueRankObj.Previous_CY_EUROPE_RANK__C) + ')';
                this.usRankToDisplay = getRankValue(revenueRankObj.Current_CY_US_RANK__C)+ ' (' + getRankValue(revenueRankObj.Previous_CY_US_RANK__C) + ')';
                this.globalRankToDisplay = getRankValue(revenueRankObj.Current_CY_GLOBAL_RANK__C)+ ' (' + getRankValue(revenueRankObj.Previous_CY_GLOBAL_RANK__C) + ')';
                this.japanRank = revenueRankObj.Current_CY_JAPAN_RANK__C;
                this.asiaRank = revenueRankObj.Current_CY_ASIAEX_RANK__C;                   
                this.europeRank = revenueRankObj.Current_CY_EUROPE_RANK__C;                 
                this.usRank = revenueRankObj.Current_CY_US_RANK__C;                 
                this.globalRank = revenueRankObj.Current_CY_GLOBAL_RANK__C;                 
            }
            else if ( period.equals('Previous_FY_') ) {
                this.japanRankToDisplay = getRankValue(revenueRankObj.Previous_FY_JAPAN_RANK__C) + ' (-)';
                this.asiaRankToDisplay = getRankValue(revenueRankObj.Previous_FY_ASIAEX_RANK__C) + ' (-)';
                this.europeRankToDisplay = getRankValue(revenueRankObj.Previous_FY_EUROPE_RANK__C)+ ' (-)';
                this.usRankToDisplay = getRankValue(revenueRankObj.Previous_FY_US_RANK__C)+ ' (-)';
                this.globalRankToDisplay = getRankValue(revenueRankObj.Previous_FY_GLOBAL_RANK__C)+ ' (-)';
                this.globalRank = revenueRankObj.Previous_FY_GLOBAL_RANK__C;
                this.japanRank = revenueRankObj.Previous_FY_JAPAN_RANK__C;
                this.asiaRank = revenueRankObj.Previous_FY_ASIAEX_RANK__C;                  
                this.europeRank = revenueRankObj.Previous_FY_EUROPE_RANK__C;                    
                this.usRank = revenueRankObj.Previous_FY_US_RANK__C;                    
                this.globalRank = revenueRankObj.Previous_FY_GLOBAL_RANK__C;                    
            }
            else if ( period.equals('Previous_CY_') ) {
                this.japanRankToDisplay = getRankValue(revenueRankObj.Previous_CY_JAPAN_RANK__C) + ' (-)';
                this.asiaRankToDisplay = getRankValue(revenueRankObj.Previous_CY_ASIAEX_RANK__C) + ' (-)';
                this.europeRankToDisplay = getRankValue(revenueRankObj.Previous_CY_EUROPE_RANK__C)+ ' (-)';
                this.usRankToDisplay = getRankValue(revenueRankObj.Previous_CY_US_RANK__C)+ ' (-)';
                this.globalRankToDisplay = getRankValue(revenueRankObj.Previous_CY_GLOBAL_RANK__C)+ ' (-)';
                this.japanRank = revenueRankObj.Previous_CY_JAPAN_RANK__C;
                this.asiaRank = revenueRankObj.Previous_CY_ASIAEX_RANK__C;                  
                this.europeRank = revenueRankObj.Previous_CY_EUROPE_RANK__C;                    
                this.usRank = revenueRankObj.Previous_CY_US_RANK__C;                    
                this.globalRank = revenueRankObj.Previous_CY_GLOBAL_RANK__C;                    
            }   
        }

         // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            Integer returnValue = 0;
            
            if (this !=null && compareTo != null) {
                // Cast argument to RevenueRankWrapper
                RevenueRankWrapper compareToObj= (RevenueRankWrapper)compareTo;
                // The return value of 0 indicates that both elements are equal.
                if (this.order > compareToObj.order) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if (this.order < compareToObj.order) {
                    // Set return value to a negative value.
                    returnValue = -1;
                } else {
                    returnValue = this.product.compareTo(compareToObj.product);
                }   
            }   
            return returnValue;      
        }
    }   
    
    public class ROIRank
    {
        public String region { get; set; }
        public decimal serviceRank { get; set; }
        public decimal serviceRankPrevious { get; set; }
       //public decimal revenueRank { get; set; }
        
        //public String serviceRank { get; set; }
     	public String revenueRank { get; set; }
       
        public ROIRank(String region) {
            this.region = region;
        }
    }       
}