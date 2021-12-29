public class SurveyDynamicCustomLinkController {
    public Id contactId {get; set;}
    public List<Survey__c> surveyList {get; set;}
    public List<Survey_Question__c> surveyQuestionList {get; set;}
    public Map<Id,Survey__c> filteredSurveyMap = new Map<Id, Survey__c>();
    
    public SurveyDynamicCustomLinkController(ApexPages.StandardController controller){
        init();
    }
    
    public void init() {
        contactId = ApexPages.currentPage().getParameters().get('id');
        
        Contact contactObj = [SELECT Id, Account.RDM_Org_Id__c FROM Contact WHERE Id = :contactId];
        
        if(contactObj != null && contactObj.Account.RDM_Org_Id__c <> 'CP12345'){
            surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Survey__c 
                          WHERE IsDeleted = FALSE AND
                                Start_Date__c <= TODAY AND End_Date__c >= TODAY];
        }
        filterSurveyList();
    }
    
    public void filterSurveyList(){
        Map<Id, Survey__c> surveyMap = new Map<Id, Survey__c>(); 
        Id currentUserId = UserInfo.getUserId();
        Set<Id> filteredSurveyIdSet = new Set<Id>();
        
        if(surveyList != null && surveyList.size() > 0){
            
            for(Survey__c surveyObj : surveyList){
                surveyMap.put(surveyObj.Id, surveyObj);
            }
            
            surveyQuestionList = [SELECT Id, Name, Category__c, Member__c, Survey__c
                                  FROM Survey_Question__c WHERE Survey__c IN :surveyMap.keySet()];
            
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
    
    public Component.Apex.PageBlock getSurveyDynamicCustomLinks() {
     Component.Apex.PageBlock dynamicPageBlock = new Component.Apex.PageBlock();
     dynamicPageBlock.mode = 'maindetail';
        
     Component.Apex.PanelGrid panelGrid = new Component.Apex.PanelGrid();
     
     if(filteredSurveyMap.size() > 0 && String.isNotBlank(contactId)){
         
         panelGrid.columns = 12; 
     	 panelGrid.width = '100%';
     	 dynamicPageBlock.childComponents.add(panelGrid);   
         
         for( Id surveyId : filteredSurveyMap.keySet()){
             Survey__c surveyObj = filteredSurveyMap.get(surveyId);
             
             String surveyURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + 
                 '/apex/takesurvey' + '?id=' + surveyObj.Id + '&cId=' + contactId + '&caId=none';
             
             //Creating Custom Link
             Component.Apex.outputLink customLink = new Component.Apex.outputLink();  
             customLink.value = 'javascript:;';
             customLink.title = surveyObj.Name;
             customLink.onclick = 'openContactSurvey(\'' + surveyURL + '\',\'' + surveyObj.Name + '\')';
                 
             Component.Apex.outputText outputText = new Component.Apex.outputText();
             outputText.value = surveyObj.Name;
             outputText.style = 'font-family: Arial,Helvetica,sans-serif; font-size: 90%; color: #000;';
             
             customLink.childComponents.add(outputText);
             
            
             //Inserting Space
             Component.Apex.outputText htmlSpace = new Component.Apex.outputText();
             htmlSpace.value = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
             htmlSpace.escape = FALSE;
             
             //Adding Components
             panelGrid.childComponents.add(customLink);
             panelGrid.childComponents.add(htmlSpace);
         }
     }
     else {
        panelGrid.columns = 1;
        panelGrid.frame = 'none';
        /*panelGrid.border = 1;*/
        panelGrid.width = '100%';
     	dynamicPageBlock.childComponents.add(panelGrid);   
         
        Component.Apex.outputText outputText = new Component.Apex.outputText();
        outputText.value = 'No Active Surveys';
        outputText.style = 'font-family: Arial,Helvetica,sans-serif; font-size: 90%; color: #000;';
         
        //Adding Components
        panelGrid.childComponents.add(outputText); 
     }
        
     return dynamicPageBlock;   
    }
    
    
}