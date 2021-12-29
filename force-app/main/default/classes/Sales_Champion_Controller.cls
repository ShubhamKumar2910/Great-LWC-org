public class Sales_Champion_Controller {
    
    
    public List<Sales_Champion__c> salesChampionAccount {get; set;}
    public ID [] totalAccounts = new Id[]{};
    public Set<ID> totalRGAccounts = new Set<ID> ();
    public integer counter = 0;
    public integer limits = 5;
    public integer recCount = 0;
    public string userID = UserInfo.getUserId();
    //public string userId = UserInfo.getUserId();
    
    public Sales_Champion_Controller(ApexPages.StandardController controller){
        
        system.debug('in constructor');
        
        getSalesRecords();
        getTotalRecordCount();
    }

    public ApexPages.StandardSetController salesRecords{
        get{
            if(salesRecords == null){
                salesRecords = new ApexPages.StandardSetController(([SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE Account__r.isDeleted = false and Sales_Champion__r.Id =: userID Order By Account__R.Name limit : limits ]));
            }
            return salesRecords;
        }
        private set;
    }
    
    public List<Sales_Champion__c> getSalesRecords(){
        salesChampionAccount = salesRecords.getRecords();
        return salesChampionAccount;
    }
    
    public Integer getTotalRecordCount(){
        List<Sales_Champion__c> salesRecordForCount = [SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE Account__r.isDeleted = false and Sales_Champion__r.Id =: userID Order By Account__R.Name];
        recCount = salesRecordForCount.size();
        System.debug('recCount::' + recCount);
        return recCount;
    }
    
    public void previous(){
        if(counter > 0)
            counter -= limits;
        
        System.debug('counter in previous::' + counter);
        System.debug('limits in previous::' + limits);
        salesChampionAccount = [SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE Account__r.isDeleted = false and Sales_Champion__r.Id =: userID Order By Account__R.Name limit : limits OFFSET :counter];
    }
    
    public void next(){
        counter += limits;
        System.debug('counter in next::' + counter);
        salesChampionAccount = [SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE Account__r.isDeleted = false and Sales_Champion__r.Id =: userID Order By Account__R.Name limit : limits OFFSET :counter];
    }
    
    public boolean getHasPrevious(){
        System.debug('Counter in hasPrevious::' + counter);
        if(counter == 0)
            return false;
        else
            return true;
    }

    public boolean getHasNext(){
        if((counter + limits) > recCount)
            return false;
        else if((counter + limits) == recCount)
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
        System.debug('counter in getPageSize::' + counter);
        if(counter == 0)
            return limits;
        else if((counter + limits) > recCount)
            return recCount;
        else
            return limits;
    }

    public integer getPageNumber(){
        integer pageNumber = 0;
        integer pgQuotient = 0;
        
        System.debug('counter in getPageSize::' + counter);
        if(recCount < limits)
            pgQuotient = recCount/limits;
        
        if(limits > 0)
            pgQuotient = recCount/ limits;
            
        
        if(recCount == 0)
            pageNumber = 1;
        else{
            if((counter + limits) <= recCount){
                for(integer n=0; n<pgQuotient; n++){
                    if(counter == n*limits)
                        pageNumber = n+1;
                }
            }
            else
                pageNumber = ((counter + limits) / limits) -1;
            System.debug('counter in getPageNumber::' + counter + ' pageNumber' + pageNumber);
        }
        
        if(pageNumber < 0)
            pageNumber = -(pageNumber);
        
         System.debug('pageNumber in getPageNumber::' + pageNumber);
        return pageNumber;
    }



}