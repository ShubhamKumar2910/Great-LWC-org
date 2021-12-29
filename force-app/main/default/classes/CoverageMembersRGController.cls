public class CoverageMembersRGController {

    // the actual account
    public Account a; 
    //public List<AggregateResult> coverageTeamMembers {get; set;} 
 
    //public List<cvgClassMember> coverageMem  {get;set;}
    //public String baseUrl {get; set;}
    //public ID [] totalAccounts = new ID []{};
    //public integer counter = 0;
    //public integer limits =5;
    //public integer recCount = 0;
    //String SalesPerson {get; set;}
    //String SalesTeam {get; set;}
   
    
    
    /* class cvgClassMember 
    { 
        public string Name    { get;set; } 
        public String SalesTeam   { get;set; }
        public string SalesCode {get;set;}
        public string MemberId {get;set;}
    }*/
    
        
  
    public CoverageMembersRGController(ApexPages.StandardController controller) {
        
        system.debug('in constructor :');        
       this.a = (Account) controller.getRecord();        
        system.debug('RG account Id :'+ a.Id);
        
        string prntId = parentId;
        
       // baseUrl = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/';
        
        
        //List<Account> RGChildAccounts = [SELECT Id FROM Account WHERE parentId= : a.Id];
        
       // for(Account childAccount : RGChildAccounts)
       // {
         // totalAccounts.add(childAccount.Id) ;
        //}
        
       //system.debug('totalAccounts :' + totalAccounts);
        //getCoverageRecords();
        //getCoverageRecordsMap();
        //getTotalRecordCount();
        
      // coverageTeamMembers = [SELECT Display_Name__c,Product_Region__c,Product_Group__c,Team_Role__c,CreatedDate,Team_Member__c FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false] ;
      
    }   
    
    public ID parentId{
        get {
            return a.id;
        }
        
        private set;
    }
        
    
   /* public ApexPages.StandardSetController coverageRecords {
        get{
            if(coverageRecords == null){
                coverageRecords = new ApexPages.StandardSetController(([SELECT Team_Member__c, Display_Name__c,Sales_Team_Name__c,Sales_Team_Code__c FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false and End_Date__c = null]));
               
            }
            return coverageRecords;
        }
        private set;
    } */
    
   /* public List<AggregateResult> getCoverageRecords(){
        coverageTeamMembers = [SELECT Display_Name__c,Sales_Team_Name__c,Sales_Team_Code__c,Team_Member__c FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null group by Sales_Team_Name__c,Sales_Team_Code__c,Display_Name__c,Team_Member__c Order by Display_Name__c];   
        system.debug('coverageTeamMembers :'+coverageTeamMembers);
        return coverageTeamMembers;
    }*/
    
   /* public List<cvgClassMember> getCoverageRecordsMap(){
        coverageMem = new List<cvgClassMember>();
        AggregateResult[] aggrs = [SELECT Display_Name__c Name,Sales_Team_Name__c SalesTeam,Sales_Team_Code__c SalesCode,Team_Member__c MemberId FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null group by Sales_Team_Name__c,Sales_Team_Code__c,Display_Name__c,Team_Member__c Order by Display_Name__c limit : limits];
        for(AggregateResult aggr : aggrs){
            system.debug('aggrName :'+ aggr.get('Name'));
            system.debug('aggrSalesTeam :'+ aggr.get('SalesTeam'));
            if(aggr.get('SalesTeam') <> null){
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = string.valueOf(aggr.get('SalesTeam'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.MemberId = string.valueOf(aggr.get('MemberId'));
                coverageMem.add(cvgMem);
            }
            else
            {
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = 'NA';
                cvgMem.SalesCode = 'NA';
                cvgMem.MemberId = string.valueOf(aggr.get('MemberId'));
                coverageMem.add(cvgMem);
            }
        }
        system.debug('coverageMem :'+ coverageMem);
        return coverageMem;
    }
    
     
      public Integer getTotalRecordCount(){ 
        recCount = coverageTeamMembers.size();
          system.debug('recCount :'+ recCount);
        return recCount;
    }
    
    public void previous(){
        if(counter > 0)
        {      
            counter -= limits; 
        }
        
        system.debug('counter in previous :' + counter);
        system.debug('limits in previous :' + limits);
   coverageMem = new List<cvgClassMember>();
        AggregateResult[] aggrs = [SELECT Display_Name__c Name,Sales_Team_Name__c SalesTeam,Sales_Team_Code__c SalesCode,Team_Member__c MemberId FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null group by Sales_Team_Name__c,Sales_Team_Code__c,Display_Name__c,Team_Member__c Order by Display_Name__c limit : limits OFFSET : counter];
        for(AggregateResult aggr : aggrs){
            system.debug('aggrName :'+ aggr.get('Name'));
            system.debug('aggrSalesTeam :'+ aggr.get('SalesTeam'));
            if(aggr.get('SalesTeam') <> null){
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = string.valueOf(aggr.get('SalesTeam'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.MemberId = string.valueOf(aggr.get('MemberId'));
                coverageMem.add(cvgMem);
            }
            else
            {
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = 'NA';
                cvgMem.SalesCode = 'NA';
                cvgMem.MemberId = string.valueOf(aggr.get('MemberId'));
                coverageMem.add(cvgMem);
            }
        }
    }
    
     public void Next(){
       counter += limits ;
      coverageMem = new List<cvgClassMember>();
        AggregateResult[] aggrs = [SELECT Display_Name__c Name,Sales_Team_Name__c SalesTeam,Sales_Team_Code__c SalesCode,Team_Member__c MemberId FROM Coverage_Team_Member__c WHERE Account__c IN : totalAccounts  AND IsDeleted = false AND End_Date__c = null group by Sales_Team_Name__c,Sales_Team_Code__c,Display_Name__c,Team_Member__c Order by Display_Name__c limit : limits OFFSET : counter];
        for(AggregateResult aggr : aggrs){
            system.debug('aggrName :'+ aggr.get('Name'));
            system.debug('aggrSalesTeam :'+ aggr.get('SalesTeam'));
            if(aggr.get('SalesTeam') <> null){
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = string.valueOf(aggr.get('SalesTeam'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.MemberId = string.valueOf(aggr.get('MemberId'));
                coverageMem.add(cvgMem);
            }
            else
            {
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesTeam = 'NA';
                cvgMem.SalesCode = 'NA';
                cvgMem.MemberId = string.valueOf(aggr.get('MemberId'));
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
         System.debug('Counter in HasNext :'+ counter);
        System.debug('Counter+Limits in HasNext :'+ (counter + limits));
        System.debug('recCount in HasNext :'+ recCount);
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
        System.debug('Counter in getPageSize :'+ counter);
        system.debug('recCount-counter :' + (recCount-counter));
        
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
        
        system.debug('counter in pagenumber :' + counter);
        system.debug('limits in pagenumber :' + limits);
         system.debug('recCount in pagenumber :' + recCount);
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
            system.debug('counter : '+ counter);
          pagenumber =  ((counter+limits)/limits)-1 ; 
        }
        }
        
        if(pagenumber < 0){
            pagenumber = -(pagenumber);
        }
        system.debug('pagenumber :'+ pagenumber);
    
        return pagenumber;
    }*/
}