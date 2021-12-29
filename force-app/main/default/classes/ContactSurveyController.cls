public with sharing class ContactSurveyController {
    public Id contactId {get; set;}
    public List<Survey__c> surveyList {get; set;}
    public List<Survey_Question__c> surveyQuestionList {get; set;}
    public Map<Id,Survey__c> filteredSurveyMap = new Map<Id, Survey__c>();
   
    public String surveys {get; set;}
    public List<SelectOption> surveyOptions{get; set;}
    public String takeSurveyLink {get; set;}
    public Boolean flag {get; set;}
    
     public ContactSurveyController(ApexPages.StandardController controller){         
        init();
        populateSurveyOptions();
    }
    
    public void init() {
        contactId = ApexPages.currentPage().getParameters().get('id');        
        Contact contactObj = [SELECT Id, Account.RDM_Org_Id__c, RG_Account__r.RDM_Org_Id__c FROM Contact WHERE Id = :contactId];
        if(contactObj != null && contactObj.RG_Account__r.RDM_Org_Id__c <> 'CPG12345'){
            surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Survey__c 
                          WHERE IsDeleted = FALSE AND
                                Start_Date__c <= TODAY AND End_Date__c >= TODAY];            
        }        
        filterSurveyList();
    }
    
    public void filterSurveyList(){
        //filter survey to display only active surveya and in which user name is present
        Map<Id, Survey__c> surveyMap = new Map<Id, Survey__c>(); 
        Id currentUserId = UserInfo.getUserId();
        Set<Id> filteredSurveyIdSet = new Set<Id>();
        
        if(surveyList != null && surveyList.size() > 0){
            
            for(Survey__c surveyObj : surveyList){
                surveyMap.put(surveyObj.Id, surveyObj);
            }
            
            surveyQuestionList = [SELECT Id, Name, Category__c, Member__c, Survey__c
                                  FROM Survey_Question__c WHERE Survey__c IN :surveyMap.keySet()];
            system.debug('surveyQuestionList:::' + surveyQuestionList);
            if(surveyQuestionList != null && surveyQuestionList.size() > 0){
                for(Survey_Question__c surveyQuestionObj : surveyQuestionList){
                    if(surveyQuestionObj.Member__c == currentUserId){
                        filteredSurveyIdSet.add(surveyQuestionObj.Survey__c);
                        
                    }
                }
                if(filteredSurveyIdSet.size() > 0){
                    for(Id surveyId : filteredSurveyIdSet){
                        if(surveyMap.containsKey(surveyId)){
                        	filteredSurveyMap.put(surveyId, surveyMap.get(surveyId));
                       }
                    }   
                }
            }
        }        
    }

    public void populateSurveyOptions(){
        surveyOptions = new List<SelectOption>();
        surveyOptions.add(new SelectOption('','--Select--'));
        for(Id surveyId: filteredSurveyMap.keySet()) {
            Survey__c surveyObj = filteredSurveyMap.get(surveyId);            
            surveyOptions.add(new SelectOption(surveyObj.Id, surveyObj.Name));
        }       
    }
    
    public Pagereference redirect(){
        flag = false;
        if(surveys != null){
            flag = true;
    		takeSurveyLink = '/apex/takesurvey?id=' + surveys + '&cId=' + contactId + '&caId=none&flag='+ flag;            
        }
        return null;         
    }
    
   
}