/* Controller associated with pages rendering the survey.
 * Used by SurveyPage, ResultsPage, TakeSurvey
 */
global virtual with sharing class ViewSurveyController {
    public String  qQuestion                      {get; set;}
    public Boolean qRequired                      {get; set;}
    public String  qChoices                       {get; set;}
    public String surveyName                        {get; set;}
    public String surveyHeader                {get; set;}
    /*public String surveyId                          {get; 
        set{
            this.surveyId = value;
            init();
        }
    }*/
    public String surveyId                      {get; set;}
    public String renderSurveyPreview           {get; set;}  
    public String questionName                    {get; set;}  
    public String questionType                    {get; set;}
    public Boolean questionRequired             {get; set;}
    public List<SelectOption> singleOptions   {get; set;} 
    public List<SFQuestion> allQuestions        {get; set;}
    public List<String> responses                   {get; set;}
    public Integer allQuestionsSize               {get; set;}
    public String  templateURL                {get; set;}
    public String  surveyThankYouText         {get; set;}
    public String surveyContainerCss {get; set;}
    public String  surveyThankYouURL          {get; set;}
    public String contactId {get;set;}
    public String anonymousAnswer {get;set;}
    public List<SelectOption> anonymousOrUser {get;set;}
    public Boolean isInternal {get;set;}
    public String baseURL {get;set;}
    
    public String userId{get;set;}
    public String userName{get;set;}
    public Boolean thankYouRendered{get;set;}
    public List<String> newOrder {get;set;}
    
    /* votesInII : Added by Nomura */
    public String votesInII {get;set;}
    public String contactName {get;set;}
    public String accountName {get; set;}
    
    
    
    
    /* Retrieves the list of questions, the survey name, after retrieving the 
       necessary parameters from the url.
    */
 //------------------------------------------------------------------------------// 
    public ViewSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        surveyId = Apexpages.currentPage().getParameters().get('id');
        contactId = Apexpages.currentPage().getParameters().get('cId');
        
        if(contactId == null || contactId.length()<15){
            contactId = 'none';
        }
        
        /* Changes for Contact's Votes In II attribute value */
        setContactInformation(contactId);
        
        // By default the preview is not showing up
        renderSurveyPreview = 'false';

        init();
    } 
    
    /* ViewShareSurveyComponentController - Removed by Nomura */
    /*public ViewSurveyController(viewShareSurveyComponentController controller)
    {
        surveyId = Apexpages.currentPage().getParameters().get('id');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
        if(contactId == null || contactId.length()<15){
            contactId = 'none';
        }
        
        // Changes for Contact's Votes In II attribute value
        setContactInformation(contactId);
        
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        init();
    }*/
    
    
    public void init()
    {
        if (surveyId != null){ 
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SFQuestion>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            
            anonymousOrUser = new List<SelectOption>();
            anonymousOrUser.add(new SelectOption('Anonymous',System.Label.LABS_SF_Anonymous));
            anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
            /*
             * Changed the value from 'Anonymous' to UserInfo.getUserId() by Nomura
             */
            anonymousAnswer = UserInfo.getUserId();
            isInternal =true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;
            
            userId = UserInfo.getUserId();
            userName = UserInfo.getName();
            
            String profileId = UserInfo.getProfileId();
            try
            {
                Profile p = [select Id, UserType from Profile where Id=:profileId];
                if (p.UserType == 'Guest')
                {
                    isInternal = false;
                }
                else
                {
                    isInternal = true;
                }
            }
            catch (Exception e){
                isInternal = false;
            }
            
            
            thankYouRendered=false;
        }       
    }
    
    public void setContactInformation(String contactId){
        /* Changes for fetching Votes in II  */
        if(contactId != 'none'){
            Contact contactObj = [SELECT Id, Votes_in_II__c, Active__c, Affiliation_Id__c, Contact_ID__c,
                                  Name, Account.RDM_Org_Id__c, Account.Name
                                  FROM Contact
                                  WHERE Id = :contactId
                                 ];
            if(contactObj != null){
                votesInII = contactObj.Votes_in_II__c;
                contactName = contactObj.Name;
                accountName = contactObj.Account.Name;
            }
        }
        if(String.isEmpty(votesInII)){
            votesInII = 'None';
        }
    }
    
//----------------------------------------------------------------------------//    
    
    /* Called during the setup of the page. 
       Retrieve questions and responses from DB and inserts them in 2 lists. */
    public Integer setupQuestionList(){

        getAQuestion();
        return allQuestions.size();
    }
    
   /** Sets the survey's name variable
    *  param: sID   The survey ID as specified in the DB
    */
    public void setSurveyNameAndThankYou(String sId){
        Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, thankYouLink__c, Survey_Header__c, Survey_Container_CSS__c FROM Survey__c WHERE Id =:sId];
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null)
        {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyThankYouURL = s.thankYouLink__c;
        surveyContainerCss = s.Survey_Container_CSS__c;
    }
    
//------------------------------------------------------------------------------//   
  public Pagereference updateSurveyName(){
      Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
      s.Name = surveyName;
      try{
        update s;
      }catch (Exception e){
        Apexpages.addMessages(e);
      }
      return null;
  } 

//------------------------------------------------------------------------------//      
    public Pagereference updateSurveyThankYouAndLink(){
        Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
        s.thankYouText__c = surveyThankYouText;
        s.thankYouLink__c = surveyThankYouURL;
        try{
            update s;
        }catch(Exception e){
            Apexpages.addMessages(e);
        }
        return null;
    }

  //------------------------------------------------------------------------------//    
  /** When requested from the page - when the user clicks on 'Update Order' -
      this function will reorganize the list so that it is displayed in the new order
   */
   public Pagereference refreshQuestionList(){
    setupQuestionList();
    return null;
   }
   
   
 
//------------------------------------------------------------------------------//      

    

//------------------------------------------------------------------------------//    
  private static boolean checkRequired(String response, Survey_Question__c question){
    if(question.Required__c == true){
        if(response == null || response =='NO RESPONSE')
          return false;
    }
    return true;
  } 

   /** Redirects the page that displays the detailed results of the survey, 
       from all users who took the survey.
    */
    public PageReference resultPage() {
        return new PageReference('/apex/ResultsPage?id='+surveyId);
    }

 
//------------------------------------------------------------------------------//  

//------------------------------------------------------------------------------//  

  /** Fills up the List of questions to be displayed on the Visualforce page
   */   
    public List<SFQuestion> getAQuestion() {
        Set<Id> questionIds = new Set<Id>();
        Map<ID, SurveyQuestionResponse__c> questionResponseMap = new Map<ID, SurveyQuestionResponse__c>();
        
        qQuestion = '';
        qChoices ='';
        
        /* Changes for fetching Values of Other_Category__c  : Nomura : Start */
        //Picklist values for Category__c
        String otherCategoryValues = '';
        Schema.DescribeFieldResult fieldResult = Survey_Question__c.Other_Category__c.getDescribe();
        List<Schema.PicklistEntry>  pickListValues = fieldResult.getPicklistValues();
          
        for(Schema.PicklistEntry pickListValue : pickListValues){
            otherCategoryValues = otherCategoryValues + pickListValue.getValue() + ';'; 
        }
        if(String.isNotEmpty(otherCategoryValues)){
            otherCategoryValues = otherCategoryValues.substring(0, otherCategoryValues.lastIndexOf(';'));
        }
        /* Changes for fetching Values of Other_Category__c  : Nomura : End */
        
        /*
         * Added Category__c, Member__c and Member__r.Name in below SOQL query by Nomura
         * Included condition for Category__c to exclude values (EXCLUDES (:otherCategoryValues) in case of Multi-Select picklist)
         */ 
        List<Survey_Question__c> allQuestionsObject = 
                                        [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                                        s.OrderNumber__c, s.Name, s.Choices__c,
                                        s.Category__c, s.Member__c, s.Member__r.Name 
                                        From Survey_Question__c s 
                                        WHERE s.Survey__c =: surveyId 
                                         AND Category__c NOT IN :otherCategoryValues.split(';')
                                        ORDER BY s.OrderNumber__c];
        System.debug(allQuestionsObject);
        
        //Changes for fetching Question Responses by Nomura
        if(allQuestionsObject != null && allQuestionsObject.size() > 0){
            for(Survey_Question__c surveyQuestion : allQuestionsObject){
                questionIds.add(surveyQuestion.Id);
            }
        }
        
        List<SurveyQuestionResponse__c> questionResponseList =
            [SELECT Id, Survey_Question__c, Response__c, Contact__c, User__c, Notes__c 
             FROM SurveyQuestionResponse__c
             WHERE Survey_Question__c IN :questionIds AND Contact__c = :contactId
            ];
     
        for(SurveyQuestionResponse__c response : questionResponseList){
            questionResponseMap.put(response.Survey_Question__c, response);
        }
        
        allQuestions = new List<SFQuestion>();
        
        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
        for (Survey_Question__c q : allQuestionsObject){ 
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0) {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
            }
            old_OrderNumber = q.OrderNumber__c;
            SFQuestion theQ = new SFQuestion(q, questionResponseMap.get(q.Id));
            allQuestions.add(theQ);
        }
        allQuestionsSize = allQuestions.size();
        return allQuestions;
    }   
    
    public void submitResults()
    {
        try {
            Set<Id> surveyQuestionIdSet = new Set<Id>();
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
            List <SurveyQuestionResponse__c> sqrInsertList = new List<SurveyQuestionResponse__c>();
            List <SurveyQuestionResponse__c> sqrUpdateList = new List<SurveyQuestionResponse__c>();
           
            for (SFQuestion q : allQuestions) {
                SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
                if (q.renderSelectRadio == 'true') {

                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }

                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        /* Changed by Nomura */
                        //sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                        sqr.Response__c = q.selectedOption;
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } 
                else if (q.renderFreeText == 'true') {
                    if (q.required && q.choices == '') {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    
                    sqr.Response__c = q.choices;
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } 
                else if (q.renderSelectCheckboxes == 'true') {
                    if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    
                    /* Changes by Nomura for storing Multi Select options in single row separated by ; */
                    String selectedMultiSelectResponse = '';
                    for(String opt : q.selectedOptions){
                        if(String.isNotEmpty(opt)){
                            selectedMultiSelectResponse = selectedMultiSelectResponse + opt + ';';
                        }
                    }
                    if(String.isNotEmpty(selectedMultiSelectResponse)){
                        selectedMultiSelectResponse = selectedMultiSelectResponse.substring(0, selectedMultiSelectResponse.lastIndexOf(';'));
                    }
                    
                    sqr = new SurveyQuestionResponse__c();
                    sqr.Survey_Question__c = q.Id;
                    sqr.Response__c = selectedMultiSelectResponse;
                    sqrList.add(sqr);
                    
                    //Commented by Nomura
                    /*for (String opt : q.selectedOptions) {
                        sqr = new SurveyQuestionResponse__c();
                        if (opt == '' || opt == null) {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    }*/
                } 
                else if (q.renderSelectRow == 'true') {
                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }

                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        /* Changed by Nomura */
                        //sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                        sqr.Response__c = q.selectedOption;
                    }
                    
                    /* Notes */
                    if(q.notes == null || q.notes == ''){
                        sqr.Notes__c = '';
                    }
                    else {
                        sqr.Notes__c = q.notes;
                    }
                    
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            }
            
            for (SurveyQuestionResponse__c sqr : sqrList){
                surveyQuestionIdSet.add(sqr.Survey_Question__c);
            }
                
            /* Changes for Nomura : Start */
            if(surveyQuestionIdSet.size() > 0){
                List<SurveyQuestionResponse__c> surveyQuestionResponseList = 
                    [SELECT Id, Name, Response__c, 
                     Survey_Question__c, Contact__c, User__c, Notes__c
                     FROM SurveyQuestionResponse__c
                     WHERE Survey_Question__c IN :surveyQuestionIdSet AND Contact__c = :contactId
                    ];
                
                if(surveyQuestionResponseList != null && surveyQuestionResponseList.size() > 0){
                    
                    for(SurveyQuestionResponse__c sqrObj : sqrList){
                        Boolean recordPresent = FALSE;
                        for(SurveyQuestionResponse__c questionResponseObj : surveyQuestionResponseList){
                            if(questionResponseObj.Survey_Question__c == sqrObj.Survey_Question__c)
                            {
                                recordPresent = TRUE;
                                
                                /* Perform Update only when Response__c or Notes__c is changed*/
                                String currentResponse = sqrObj.Response__c;
                                String currentNotes = sqrObj.Notes__c;
                                if((!currentResponse.equalsIgnoreCase(questionResponseObj.Response__c)) ||
                                   (!currentNotes.equalsIgnoreCase(questionResponseObj.Notes__c == null ? '' : questionResponseObj.Notes__c)) ){
                                    //Capture the response
                                    questionResponseObj.Response__c = sqrObj.Response__c;
                                    questionResponseObj.Notes__c = sqrObj.Notes__c;
                                    questionResponseObj.User__c = userId;
                                    
                                    sqrUpdateList.add(questionResponseObj);
                                    
                                    break;
                                }
                            }
                        }
                        
                        if(recordPresent == FALSE){
                            if(recordToBeInserted(sqrObj)){
                                sqrInsertList.add(getSurveyQuestionResponseDetails(sqrObj)); 
                            }
                        }
                    }
                }
                else {
                    for(SurveyQuestionResponse__c sqrObj : sqrList){
                        if(recordToBeInserted(sqrObj)){
                            sqrInsertList.add(getSurveyQuestionResponseDetails(sqrObj));
                        }
                    }
                }
            }
            
            if(sqrInsertList.size() > 0){
                insert sqrInsertList;
            }
            
            if(sqrUpdateList.size() > 0){
                update sqrUpdateList;
            }
            
            /* Changes for Nomura : End */
                
            thankYouRendered=true;
            
        }catch(Exception e){
            if(isInternal) {
                Apexpages.addMessages(e);
            }else{
                System.debug('Exception: ' + e.getMessage());
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured while saving response'));
            }
        }

    }
    
    /* 
     * Function created by Nomura 
     */
    private SurveyQuestionResponse__c getSurveyQuestionResponseDetails(SurveyQuestionResponse__c sqrObj){
        //TODO : Put Contact and User
        SurveyQuestionResponse__c surveyQuestionResponseObj = new SurveyQuestionResponse__c();
        surveyQuestionResponseObj.Survey_Question__c = sqrObj.Survey_Question__c;
        surveyQuestionResponseObj.Response__c = sqrObj.Response__c;
        surveyQuestionResponseObj.User__c = userId;
        surveyQuestionResponseObj.Contact__c = contactId;
        surveyQuestionResponseObj.Notes__c = sqrObj.Notes__c;
        
        return surveyQuestionResponseObj;    
    }
    
    /* 
     * Function created by Nomura 
     */
    private Boolean recordToBeInserted(SurveyQuestionResponse__c sqrObj){
        Boolean recordToBeInserted = TRUE;
        
        if((sqrObj.Response__c != null && String.isNotEmpty(sqrObj.Response__c)) ||
           (sqrObj.Notes__c != null && String.isNotEmpty(sqrObj.Notes__c))){
            recordToBeInserted = TRUE;       
        }
        else {
            recordToBeInserted = FALSE;
        }
        
        return recordToBeInserted;
    }
    
}