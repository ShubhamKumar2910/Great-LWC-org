global class CoverageRowsWrapper {
    @AuraEnabled
    public boolean isChecked{get;set;}
    
    @AuraEnabled
    public string recordId{get;set;}
    
    @AuraEnabled
    public sobject sobjectData{get;set;}
    
    @AuraEnabled
    public CoverageDataWrapper coverageData{get;set;}
    
    @AuraEnabled
    public boolean isWrapper{get;set;} //false means soql data, for wrapper = true
    
    @AuraEnabled
    public string errorMessage{get;set;} 
}