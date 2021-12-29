public class CoverageRGController {
    
    public List<cvgWrapperClass> cvgList{get; set;}
    public class cvgWrapperClass{
        public String accountId {get;set;}
        public String accountName {get;set;}
        public String RGKey {get; set;}
        public String clientType {get; set;}
        public Integer YTDRevenue {get; set;}
    }
    
    // the actual account
    public Account a; 
    public List<Account> CoverageRGAccount {get; set;} 
    public ID [] totalAccounts = new ID []{}; 
    public Set<ID> totalRGAccounts = new Set<Id> ();
    public integer counter = 0;
    public integer limits =5;
    public integer recCount = 0;
    public string userId = UserInfo.getUserId() ;
    public Integer ytdData;    
    public Boolean flag {get; set;}
    public Boolean columnFlagJapan{get; set;}
     
    public CoverageRGController(ApexPages.StandardController controller) {
        this.a = (Account) controller.getRecord();   
               
        User callingUser = [SELECT Id,User_Profile_Name__c,Name, Region__c FROM User WHERE Id = : userId] ;  
      	if(callingUser.Region__c == 'Japan')
            columnFlagJapan = true;
        else
            columnFlagJapan = false;
        
        List<Coverage_Team_Member__c> cvgMem= [SELECT Account__c FROM Coverage_Team_Member__c 
                                               WHERE Sales_Team_for_Coverage__c IN 
                                               (SELECT Sales_Team_for_Coverage__c FROM Sales_Team_User__c WHERE User__c = :userId) 
                                               AND End_Date__c = NULL]; /* AND Sales_Team_for_Coverage__r.Active__c = TRUE */
        
        for(Coverage_Team_Member__c cvgMember : cvgMem)
        {
          totalAccounts.add(cvgMember.Account__c) ;
        }
        
        Set<Account> ParentAccountRG = new Set<Account>([SELECT ParentId FROM Account WHERE Id IN :totalAccounts]);
        
        for(Account acc : ParentAccountRG){
            totalRGAccounts.add(acc.ParentId);
        }
        getCoverageRecords();
        getTotalRecordCount();      
    }   
    
     public void getCoverageRecords(){
        Map<ID, Integer> revenueMap = new Map<ID, Integer>();
        cvgList = new List<cvgWrapperClass>();
        List<Account> accountList = getAccounts();
        System.debug('accountList:::'+ accountList);
        List<AggregateResult> ytdList = getYTDRevenue();      
         // map ytdRevenue
         for(AggregateResult aggr : ytdList){
            revenueMap.put( String.valueOf(aggr.get('RG')), integer.valueOf(aggr.get('YTDRevenue')));
        } 
        //insert data into wrapper class
         for(Account accountObj: accountList){
         	 cvgWrapperClass cvgMember =  new cvgWrapperClass();
             cvgMember.accountId = accountObj.Id;
             cvgMember.accountName = accountObj.Name;
             cvgMember.RGKey = accountObj.RDM_Org_ID__c;
             cvgMember.clientType = accountObj.Client_Type__c;
             
             ytdData = revenueMap.get(accountObj.Id) !=  null ? revenueMap.get(accountObj.Id) : null ;
             if(ytdData != null)
                 cvgMember.YTDRevenue = revenueMap.get(accountObj.Id);
             else
                 cvgMember.YTDRevenue = 0;             
            cvgList.add(cvgMember); 
            
         }
    }
     
    //return the Account details
    public List<Account> getAccounts(){
        List<Account> accountList = [SELECT Id,Name,Client_Type__c,RDM_Org_ID__c FROM Account WHERE ID IN : totalRGAccounts Order by Name Limit:limits OFFSET : counter];
        return accountList;
    }
    
    //return the ytdRevenue details if coverage_id__c is present for resp. active user
    public List<AggregateResult> getYTDRevenue(){
        List<Sales_Team_for_Coverage__c> coverageTeam = 
            Database.query('SELECT Coverage_Id__c, sales_Desk_Region__c, Sales_Desk_Division__c FROM Sales_Team_for_Coverage__c WHERE Active__c = TRUE AND Id IN (SELECT Sales_Team_for_Coverage__c FROM Sales_Team_User__c WHERE User__c = :userId)');
        List<AggregateResult> ytdList;
        Set<String> coverageIds = new Set<String>();
    
        if(coverageTeam <> null){           
            for(Sales_Team_for_Coverage__c cvg : coverageTeam){
                // if region is Japan and Division is Equity then don't show revenue.
                if(('Equity').equalsIgnoreCase(cvg.Sales_Desk_Division__c) && ('Japan').equalsIgnoreCase(cvg.Sales_Desk_Region__c)) 
                	flag = false; 
                else
                    flag = true;
                coverageIds.add(cvg.Coverage_Id__c);
            }        
            // if user belong to japan calculate yen gross revenue else usd
			if(columnFlagJapan == true && flag == true)
                ytdList = Database.query('SELECT rg__c RG, SUM(fytd_gross_yen__c) YTDRevenue from revenue__c where sales_id__c IN: coverageIds  and rg__c IN: totalRGAccounts group by rg__c'); 
            else      
            	ytdList = Database.query('SELECT rg__c RG, SUM(fytd_gross_usd__c) YTDRevenue from revenue__c where sales_id__c IN: coverageIds  and rg__c IN: totalRGAccounts group by rg__c'); 
            return ytdList;
        }
        else{
            flag = false;
            return null;    
        }
    }
    
    public Integer getTotalRecordCount(){           
      List<Account> RGAccountForCount = [SELECT Id,Name,Client_Type__c,RDM_Org_ID__c FROM Account WHERE ID IN : totalRGAccounts Order by Name ];
        recCount = RGAccountForCount.size();
          system.debug('recCount :'+ recCount);
        return recCount;
    }
    
    public void previous(){
        if(counter > 0){      
            counter -= limits; 
        }
        getCoverageRecords();
    }
    
     public void Next(){
       counter += limits ;
        getCoverageRecords();
     }
    
    public boolean getHasPrevious(){        
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
        else{
            if((counter + limits) <= recCount){
                for(integer n=0; n<pgQuotient;n++){
                    if(counter == n*limits){
                        pagenumber = n+1;
                    }
                }
            }        
            else{
              pagenumber =  ((counter+limits)/limits)-1 ; 
            }
        }
        if(pagenumber < 0){
            pagenumber = -(pagenumber);
        }
        return pagenumber;
    }
}