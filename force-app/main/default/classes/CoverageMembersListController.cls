public class CoverageMembersListController {

    // the actual account
    public Account a {get;set;} 
    public boolean isView {get;set;}
    public List<AggregateResult> coverageTeamMembers {get; set;} 
 	public string url {get;set;}
    public List<cvgClassMember> coverageMem  {get;set;}
  
    public ID [] totalAccounts = new ID []{};
    public integer counter = 0;
    public integer limits = 25;
    public integer recCount = 0;
    public String sortColumn = 'Sales_Team_for_Coverage__r.Name';
    public String sortDirection {get; set;}
    public String sortFullExpression;
    public String filterColumn {get; set;}
    public String filterPercent = '%';
  	public String filterFullExpression;
    public Boolean flag {get; set;}
    
    public class cvgClassMember 
    { 
        public string Name    { get;set; } 
        public String SalesTeam   { get;set; }
        public string SalesCode {get;set;}
        public String SalesDeskRegion {get;set;}
        public Date CoverageStartDate {get;set;}
    }
    
   
          
  
    public CoverageMembersListController(ApexPages.StandardController stdController) {
        
        url = ApexPages.currentPage().getUrl();
        List<Account> RGChildAccounts = new List<Account> ();       
        if(test.isRunningTest()){
            url = 'lightning';
        }
        if(url != null){
            if(url.contains('lightning') )
            {
                isView = false;
                a = [SELECT Id,Name FROM Account WHERE Id=: stdController.getRecord().Id];                                     
                RGChildAccounts = [SELECT Id FROM Account WHERE parentId= : stdController.getRecord().Id];
        
            }
            else
            {
                isview = true;
                a = [SELECT Id,Name FROM Account WHERE Id=: apexPages.currentPage().getParameters().get('AccountId')];                                       
                RGChildAccounts = [SELECT Id FROM Account WHERE parentId= : apexPages.currentPage().getParameters().get('AccountId')];
            }
		}
       
        for(Account childAccount : RGChildAccounts)
        {
          totalAccounts.add(childAccount.Id) ;
        }
        
       	system.debug('totalAccounts :' + totalAccounts);
        sortDirection = 'ASC';
        sortColumn = 'Sales_Team_for_Coverage__r.Name';
        filterColumn = 'Sales_Team_for_Coverage__r.Name';
        sortFullExpression = sortColumn + ' ' + sortDirection;
		filterFullExpression = filterPercent;
        flag = true;
        getCoverageRecords();
        getCoverageRecordsMap();
        getTotalRecordCount();
      
    }    
    
    public ApexPages.StandardSetController coverageRecords {
        get{
            if(coverageRecords == null){
                coverageRecords = new ApexPages.StandardSetController(([SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false and End_Date__c = null AND  RecordType.Name = 'Active Coverage' Order by Sales_Team_for_Coverage__r.Name]));
            }
            return coverageRecords;
        }
        private set;
    }
    
    //String to display for filtering
     public String[] getStrings() {
         return new String[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
     }
    
    public void resetPagination(){
        limits = 25;
        counter = 0;
        recCount = 0;
        flag = true;
        
    }
    
      public String sortExpression{
        get{
            return sortColumn;
        }
        set{
            if(value == sortColumn)
                sortDirection = ('ASC'.equalsIgnoreCase(sortDirection)) ? 'DESC': 'ASC';
            else
                sortDirection = 'ASC';
            	sortColumn = value;
        }
   	 }
    
    public void sortedCoverageRecords() {
		//assign sortFullExpression with nulls
        if(sortDirection.equalsIgnoreCase('ASC'))
        	sortFullExpression = sortExpression + ' ' + sortDirection + ' NULLS FIRST';
        else
            sortFullExpression = sortExpression + ' ' + sortDirection + ' NULLS LAST';
 
        // to reset the blockTable when user select different columns
        if(!filterColumn.equalsIgnoreCase(sortExpression) ){
            if(sortExpression.equalsIgnoreCase('MIN(Sales_Desk_Region__c)') && filterFullExpression.equalsIgnoreCase(filterPercent)){
                filterFullExpression = filterPercent;
        			selectedFilter = 'All';    
                resetPagination();                	
            }
            else if(sortExpression.equalsIgnoreCase('MIN(Sales_Desk_Region__c)') && filterColumn.equalsIgnoreCase('Sales_Desk_Region__c') && !(filterFullExpression.equalsIgnoreCase(filterPercent))){ 
            	filterColumn = 'Sales_Desk_Region__c';
            	filterFullExpression = selectedFilter + '%';
            }                    
            else{
                filterFullExpression = filterPercent;
        			selectedFilter = 'All';
                 	resetPagination();                	
            }            
         }
        system.debug('before....sortExpression::' + sortExpression);
        
        // filterColumn used to sort the data according to the column selected
        if(sortExpression.equalsIgnoreCase('Sales_Team_for_Coverage__r.Name'))
            filterColumn = 'Sales_Team_for_Coverage__r.Name';
        else if(sortExpression.equalsIgnoreCase('Sales_Team_for_Coverage__r.Sales_Team__c'))
             filterColumn = 'Sales_Team_for_Coverage__r.Sales_Team__c';
        else if(sortExpression.equalsIgnoreCase('MIN(Sales_Desk_Region__c)'))
             filterColumn = 'Sales_Desk_Region__c';
        else if(sortExpression.equalsIgnoreCase('MIN(Start_Date__c)')){
            filterColumn = 'Start_Date__c';
            flag = false;        
        }
        
        getCoverageRecords();
        getCoverageRecordsMap();
        getTotalRecordCount();
       
    }
    
    // set the filter
    public string selectedFilter {get; set;}
    public void filterRecords()
    {
        resetPagination();
        if(selectedFilter == 'All'){
            filterFullExpression = filterPercent;
        }
            
        else
            filterFullExpression = selectedFilter + '%';
      
        getCoverageRecords();
        getCoverageRecordsMap();
        getTotalRecordCount();
    }
    
    
    public List<AggregateResult> getCoverageRecords(){
        coverageRecords.setPageSize(limits);
        
        // if filter is selected data is returned from query of else otherwise query of if
        if(filterPercent.equalsIgnoreCase(filterFullExpression))
        	coverageTeamMembers = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null  AND RecordType.Name  = \'Active Coverage\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression );   
        else
            coverageTeamMembers = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\' AND ' + filterColumn +' LIKE \'' + filterFullExpression  + '\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression );   
        system.debug('coverageTeamMembers :'+coverageTeamMembers);
        return coverageTeamMembers;
    }
    
    public List<cvgClassMember> getCoverageRecordsMap(){
        coverageRecords.setPageSize(limits);
        coverageMem = new List<cvgClassMember>();
        AggregateResult[] aggrs; 
        
        // if filter is selected data is returned from query of else otherwise query of if
        if(filterPercent.equalsIgnoreCase(filterFullExpression))
            	aggrs = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression + ' limit :limits');
      else
                aggrs  = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\'  AND ' + filterColumn +' LIKE \'' + filterFullExpression  + '\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression + ' limit :limits');

     
        for(AggregateResult aggr : aggrs){            
            if(aggr.get('SalesTeam') <> null){
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = string.valueOf(aggr.get('SalesTeam'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                coverageMem.add(cvgMem);
            }
            else
            {
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = 'NA';
                cvgMem.SalesCode = 'NA';
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                coverageMem.add(cvgMem);
            }
        }        
        return coverageMem;
    }
    
     
      public Integer getTotalRecordCount(){ 
        recCount = coverageTeamMembers.size();          
        return recCount;
    }
    
    public void previous(){
        if(counter > 0)
        {      
            counter -= limits; 
        }
        coverageRecords.setPageSize(limits);       
   		coverageMem = new List<cvgClassMember>();
        AggregateResult[] aggrs; 
       if(filterPercent.equalsIgnoreCase(filterFullExpression))
       	         aggrs = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression + ' limit : limits OFFSET : counter');
        else
                aggrs  = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\' AND ' + filterColumn +' LIKE \'' + filterFullExpression  + '\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression + ' limit : limits OFFSET : counter');

        for(AggregateResult aggr : aggrs){            
            if(aggr.get('SalesTeam') <> null){
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = string.valueOf(aggr.get('SalesTeam'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                coverageMem.add(cvgMem);
            }
            else
            {
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = 'NA';
                cvgMem.SalesCode = 'NA';
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                coverageMem.add(cvgMem);
            }
        }
    }
    
     public void Next(){
       counter += limits ;
         coverageRecords.setPageSize(limits);
      coverageMem = new List<cvgClassMember>();
        AggregateResult[] aggrs; 
       if(filterPercent.equalsIgnoreCase(filterFullExpression))
       	         aggrs = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression + ' limit : limits OFFSET : counter');
        else
                aggrs  = Database.query('SELECT Sales_Team_for_Coverage__r.Name, Sales_Team_for_Coverage__r.Sales_Team__c SalesTeam,Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) SalesDeskRegion,min(Start_Date__c) CoverageStartDate FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null AND RecordType.Name  = \'Active Coverage\'  AND ' + filterColumn +' LIKE \'' + filterFullExpression  + '\' group by Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.Name Order by ' + sortFullExpression + ' limit : limits OFFSET : counter');
         
        for(AggregateResult aggr : aggrs){            
            if(aggr.get('SalesTeam') <> null){
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = string.valueOf(aggr.get('SalesTeam'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                coverageMem.add(cvgMem);
            }
            else
            {
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = 'NA';
                cvgMem.SalesCode = 'NA';
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                coverageMem.add(cvgMem);
            }
        }
    }
    
    public boolean getHasPrevious(){        
        System.debug('Counter in HasPrevious :'+ counter);
        if(counter == 0)
        return false;
        else
        return true;    
         
    }
    
    public boolean getHasNext(){        
        if((counter + limits) > recCount)
            return false;
        else if(counter + limits == recCount)
            return false;
            else 
            return true;
    }
    
    public integer getResultSize(){
        return recCount;
    }
    
    public integer getRecords(){
        return limits;
    }
    
    public integer getPageSize(){
       
        if(counter == 0)
            return limits;
        else if((counter+limits) > recCount)
               return recCount;
        else
            return limits;
       
    }
    
    public integer getPageNumber(){
        integer pagenumber =0;
        integer pgQuotient = 0; 
        
        if(recCount < limits){
            limits = recCount;
        }
        
        if(limits >0 ){
         pgQuotient = recCount/limits; 
        }        
        if(recCount == 0){
            pagenumber = 1;
                }
        else
        {
        if((counter + limits) <= recCount){
            for(integer n=0; n<pgQuotient;n++){
                if(counter == n*limits){
                    pagenumber = n+1;
                }
            }
        }        
        else 
        {            
          pagenumber =  ((counter+limits)/limits)-1 ; 
        }
        }
        
        if(pagenumber < 0){
            pagenumber = -(pagenumber);
        }       
        return pagenumber;
    }
}