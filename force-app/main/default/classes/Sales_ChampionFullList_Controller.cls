public class Sales_ChampionFullList_Controller {
    
    public Account a;
    public List<Sales_Champion__c> salesChampionAccount {get; set;}
    public ID [] totalAccounts = new Id[]{};
    public Set<ID> totalRGAccounts = new Set<ID> ();
    public integer counter = 0;
    public integer limits = 25;
    public integer recCount = 0;
    public string userID = UserInfo.getUserId();
    public string sortColumn;
    public string sortDirection {get; set;}
    public string sortFullExpression;
    public string filterColumn {get; set;}
    public string filterPercent = '%';
    public string filterFullExpression;
    public string selectedFilter {get; set;}
    
    
    
    public Sales_ChampionFullList_Controller(ApexPages.StandardController controller){
        
        system.debug('in constructor Sales_ChampionFullList_Controller');
        
        sortColumn = 'Account__r.Name';
        sortDirection = 'ASC';
        sortFullExpression = sortColumn + ' ' + sortDirection;
        filterColumn = 'Account__r.Name';
        filterFullExpression = filterPercent;
        
        getSalesRecords();
        getTotalRecordCount();
    }

    //String to display for filtering
     public String[] getStrings() {
         return new String[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
     }
    
    public void resetPagination(){
        system.debug('resetPagination');
        limits = 25;
        counter = 0;
        recCount = 0;
    }
    public string sortExpression{
        get{
            return sortColumn;
        }
        set{
            if(value == sortColumn)
                sortDirection = ('ASC'.equalsIgnoreCase(sortDirection)) ? 'Desc' : 'ASC';
            else
                sortDirection = 'ASC';
            sortColumn = value;
        }
    }
    
    public void sortedSalesRecords(){
        //assign sortFullExpression with nulls
        if('ASC'.equalsIgnoreCase(sortDirection))
            sortFullExpression = sortExpression + ' ' + sortDirection + ' NULLS FIRST';
        else
            sortFullExpression = sortExpression + ' ' + sortDirection + ' NULLS LAST';
        
        // to reset the blockTable when user select different columns
        if(!filterColumn.equalsIgnoreCase(sortExpression)){
            filterFullExpression = filterPercent;
            selectedFilter = 'All';
           
        }
        
        // filterColumn used to sort the data according to the column selected
        if(sortExpression.equalsIgnoreCase('Account__r.Name'))
            filterColumn = 'Account__r.Name';
        else if(sortExpression.equals('Sales_Champion__r.Name'))
            filterColumn = 'Sales_Champion__r.Name';
        else if(sortExpression.equalsIgnoreCase('Champion_Type__c'))
            filterColumn = 'Champion_Type__c';
        else
            filterColumn = 'Region__c';
                
        
       resetPagination();
       system.debug('sortFullExpression' + sortFullExpression);
        getSalesRecords();
        getTotalRecordCount();
    }
    
    // set the filter
    public void filterRecords(){
        resetPagination();
        if(selectedFilter == 'ALL')
            filterFullExpression = filterPercent;
        else
            filterFullExpression = selectedFilter + filterPercent;
        
        getSalesRecords();
        getTotalRecordCount();
    }
    
    
    public ApexPages.StandardSetController salesRecords{
        get{          
            salesRecords = new ApexPages.StandardSetController((Database.query('SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE ' + filterColumn + ' LIKE \''+ filterFullExpression +'\' and Account__r.isDeleted = false and Sales_Champion__r.ID = \'' + userId + '\' Order By ' + sortFullExpression  + ' limit ' + limits)));
            salesRecords.setPageSize(limits);
            return salesRecords;
        }
        private set;
    }
    
    public List<Sales_Champion__c> getSalesRecords(){
        system.debug('limits::'+ limits);
        salesChampionAccount = salesRecords.getRecords();
        
        return salesChampionAccount;
    }
    
    public Integer getTotalRecordCount(){
        List<Sales_Champion__c> salesRecordForCount = Database.query('SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE ' + filterColumn + ' LIKE \''+ filterFullExpression +'\' and Account__r.isDeleted = false and Sales_Champion__r.ID = \'' + userId + '\'  Order By ' + sortFullExpression);
        recCount = salesRecordForCount.size();
        System.debug('recCount::' + recCount);
        return recCount;
    }
    
    public void previous(){
        if(counter > 0)
            counter -= limits;
        
        System.debug('counter in previous::' + counter);
        System.debug('limits in previous::' + limits);
        salesRecords.setPageSize(limits);
        salesChampionAccount = Database.query('SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE ' + filterColumn + ' LIKE \''+ filterFullExpression +'\'  and Account__r.isDeleted = false and Sales_Champion__r.ID = \'' + userId + '\'  Order By ' + sortFullExpression  + ' limit '+limits + ' OFFSET '+counter);
    }
    
    public void next(){
        counter += limits;
        System.debug('counter in next::' + counter);
        salesRecords.setPageSize(limits);
        salesChampionAccount = Database.query('SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE ' + filterColumn + ' LIKE \''+ filterFullExpression +'\'  and Account__r.isDeleted = false and Sales_Champion__r.ID = \'' + userId + '\'  Order By ' + sortFullExpression  + ' limit '+limits + ' OFFSET '+counter);
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
            limits = recCount;
        
        
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