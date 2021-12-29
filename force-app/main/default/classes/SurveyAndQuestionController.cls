global virtual with sharing class SurveyAndQuestionController{// extends SurveyAndQuestionController{
  
  public List<SelectOption> questionTypeOptions {get; set;}
  public String  showBasicValues                {get; set;}
  public String  showSingleSelect               {get; set;}
  public String  showSingleSelectPreview        {get; set;}
  public String  showMultiSelect                {get; set;}
  public String  showMultiSelectPreview         {get; set;}
  public String  showFreeText                   {get; set;}
  public String  showFreeTextPreview            {get; set;}
  public String  showRowQuestion                {get; set;}
  public String  showRowQuestionPreview         {get; set;}
  public String  showSelectQuestionType         {get; set;}
  public List<SelectOption> singleOptions       {get; set;}
  public List<SelectOption> multiOptions        {get; set;}
  public List<SelectOption> rowOptions          {get; set;}
  public String  questionReference              {get; set;}
  //public String  reportId                       {get; set;}
  private Boolean saveAndNew;
  private String  surveyRef;
  private String surveyOrderNumber;
  private Survey_Question__c questionToUpdate;
  /***/
  public String  qQuestion                      {get; set;}
  public Boolean qRequired                      {get; set;}
  public String  qChoices                       {get; set;}
  public String surveyName                  {get; set;}
  public String surveyHeader                {get; set;}
  public String surveyId                    {get; set;} 
  public String renderSurveyPreview         {get; set;}  
  public String questionName                {get; set;}  
  public String questionType                {get; set;}
  public Boolean questionRequired           {get; set;}
  public List<SFQuestion> allQuestions        {get; set;}
  public List<String> responses             {get; set;}
  public Integer allQuestionsSize           {get; set;}
  public String  templateURL                {get; set;}
  public String  surveyThankYouText         {get; set;}
  public String  surveyThankYouURL          {get; set;}
  public List<String> newOrder {get;set;}
  public String newOrderW {get;set;}
    
  public string fileName{get;set;}
  public Blob csvblob{get;set;}
  public string csvContent{get;set;}
  public string alertMessageText{get;set;}
  public string alertMessageType{get;set;}
  public String  visibilityClass{get; set;}
  public static Id batchid{get;set;}
  public static Id downloadid{get;set;}  
    
    
  /*
   * qCategory, categoryOptions and surveyQuestionObj Added by Nomura
   */
  public String qCategory	{get; set;}
  public List<SelectOption> categoryOptions {get; set;}
  public Survey_Question__c surveyQuestionObj {get; set;}   
    
  /* 
   * surveyDetailsLink,  surveyVoteCategoryLink, surveyVoteCollectorLink Added by Nomura
   */
  public String surveyDetailsLink {get; set;}
  public String surveyVoteCategoryLink {get; set;}
  public String surveyVoteCollectorLink {get; set;}
    
  public Message pageMessage {
      get{
          if(pageMessage == null){
              pageMessage = new Message();
          }
          return pageMessage;
      }
      set;
  }
    
  public Map<Id,String> availableMembersMap = new Map<Id,String>();
    
  public  SurveyAndQuestionController (ApexPages.StandardController stdController){
      if(getSampleTemplateDownloadID().size()==1)
      {
          for(Id docId:getSampleTemplateDownloadID())
          downloadid = docId;
      }
      visibilityClass = 'slds-hide';
     /**/
    // Get url parameters
    surveyId = Apexpages.currentPage().getParameters().get('id');
    newOrder = new List<String>();
    // By default the preview is not showing up
    renderSurveyPreview = 'false';

    if (surveyId != null){ 
      // Retrieve all necessary information to be displayed on the page
      allQuestions = new List<SFQuestion>();
      setSurveyNameAndThankYou(surveyId);
    }
    /**/
    surveyRef = surveyId;
    /*
     * Commented by Nomura
     */ 
    /*setupQuestionTypeOptions();*/
    
    /*
     * Added by Nomura
     */
    setupCategoryOptions();
    setChoices();
    surveyQuestionObj = new Survey_Question__c();
      
    resetViewsToFalse(true);
    showSelectQuestionType = 'True';
      
    setReportLinks(surveyId);
    
    /* Commented By Nomura : Start */  
    /*ReportFinderUtil rfu = new ReportFinderUtil();
    reportId = rfu.findReportId('Survey with Questions and Responses');*/
    /* Commented By Nomura : End */   
   
  }
    
  public void setReportLinks(String surveyId){
  	Set<String> reportNames = new Set<String>();
    reportNames.add('Contact_Survey_Details');
    reportNames.add('Contact_Survey_Vote_Category');
    reportNames.add('Contact_Survey_Vote_Collector');
      
    List<Report> reportList = [SELECT Id, Name, DeveloperName, FolderName FROM Report
                               WHERE DeveloperName IN :reportNames];
    if(reportList != null && reportList.size() > 0){
        for(Report reportObj : reportList){
            String customizedSurveyId = surveyId != null ? (surveyId.substring(0,15)) : surveyId;
            if('Contact_Survey_Details'.equalsIgnoreCase(reportObj.DeveloperName)){
                surveyDetailsLink = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + 
                 '/' + reportObj.Id + '?pv0=' + customizedSurveyId + '&isdtp=vw';
            }
            else if('Contact_Survey_Vote_Category'.equalsIgnoreCase(reportObj.DeveloperName)){
                surveyVoteCategoryLink = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + 
                 '/' + reportObj.Id + '?pv0=' + customizedSurveyId + '&isdtp=vw';
            }
            else if('Contact_Survey_Vote_Collector'.equalsIgnoreCase(reportObj.DeveloperName)){
                surveyVoteCollectorLink = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + 
                 '/' + reportObj.Id + '?pv0=' + customizedSurveyId + '&isdtp=vw';
            }
        } 
    }      
  }  

  public void resetMessageDisplay()
  {
      visibilityClass = 'slds-hide';
      system.debug(visibilityClass);
  }
    
  public Set<Id> getSampleTemplateDownloadID()
  {
      return new Map<Id,Document>([select id from Document where DeveloperName = 'Survey_Sample_Template']).keyset();
  }
    
  
  public Pagereference makeNewQuestionLink(){
    questionReference = null;
    resetViewsToFalse(true);
    return null;
  }
  
  public Pagereference editQuestion(){
    if (questionReference == null)
     return null;
    setupEditQuestion();
    //Disable question type drop down as it's an older question
    showSelectQuestionType = 'False';
    return null;
  }
  
  public Pagereference addQuestion(){
    showSelectQuestionType = 'True';
    resetViewsToFalse(true);
    return null;
  }
  
  private void setupEditQuestion(){
    /*
	 * Added Category__c, Member__c, Member__r.Name by Nomura
	 */
    questionToUpdate =     [Select Type__c, Question__c, Id, Choices__c, Required__c, 
                           OrderNumber__c, Survey__c, Name,
                           Category__c, Member__c, Member__r.Name 
                           From Survey_Question__c 
                           where Id = :questionReference];
    questionType = questionToUpdate.Type__c;
    setupQuestionFields();
    setupEditFields(questionToUpdate);
  }

  private void setupEditFields(Survey_Question__c q){
    /*
     * qQuestion and qRequired commented by Nomura
     * qCategory, surveyQuestionObj.Member__c added by Nomura
     * /
    /*qQuestion = q.Question__c;
    qRequired = q.Required__c;*/
    qCategory = q.Category__c;
    surveyQuestionObj.Member__c = q.Member__c;
    qChoices = q.Choices__c;
    surveyRef = q.Survey__c;    
  }

  private void setupQuestionTypeOptions(){
  
    //get picklist values
    Schema.DescribeFieldResult fieldResult = Survey_Question__c.Type__c.getDescribe();
    List<Schema.PicklistEntry>  ple = fieldResult.getPicklistValues();
  
    //set/add them to selectOption list
    questionTypeOptions = new List<SelectOption>();
    questionTypeOptions.add(new SelectOption('--SELECT--', System.Label.LABS_SF_SELECTTYPE));
    for(Schema.PicklistEntry pe: ple){
      questionTypeOptions.add(new SelectOption(pe.getLabel(), pe.getValue()));
    }
  }
    
  /*
   * Function Added by Nomura
   */   
  private void setupCategoryOptions(){
  	//Picklist values for Category__c
    Schema.DescribeFieldResult fieldResult = Survey_Question__c.Category__c.getDescribe();
    List<Schema.PicklistEntry>  pickListValues = fieldResult.getPicklistValues();
      
    categoryOptions = new List<SelectOption>();
    categoryOptions.add(new SelectOption('--SELECT--', System.Label.LABS_SF_SELECTTYPE));
    for(Schema.PicklistEntry pickListValue : pickListValues){
    	categoryOptions.add(new SelectOption(pickListValue.getLabel(), pickListValue.getValue()));      
    }      
      
  }
    
  /*
   * Function Added by Nomura
*/
    private void setChoices(){
        qchoices = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
    }  
    
    private void resetViewsToFalse(Boolean clearFields){
        /*
* Added by Nomura
*/
        questionType = 'Single Select--Horizontal';  
        
        showSingleSelect =        'True'; //Changed by Nomura from False to True
        showSingleSelectPreview = 'False';
        showMultiSelect =         'False';
        showMultiSelectPreview=   'False';
        showFreeText =            'False';
        showFreeTextPreview=      'False';
        showRowQuestion=          'False';
        showRowQuestionPreview=   'False';
        qRequired =                FALSE;
        if(clearFields){
            /*
* Changed from blank('') to Default options by Nomura
*/
            qchoices = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
            qQuestion =                '';
            /*
* qCategory, surveyQuestionObj.Member__c added by Nomura
*/
            qCategory = '';
            surveyQuestionObj.Member__c = null;
        }
    }
    public PageReference startUpload()
    {
        try
        {
            system.debug(csvblob);
            if(csvblob == null || fileName == null || fileName == '')
            {
                alertMessageText = 'Please select csv file to upload.';
                alertMessageType = 'slds-theme--info';
                visibilityClass = 'slds-show';
                system.debug('please select');
            }
            else if(!fileName.contains('.csv'))
            {
                alertMessageText = 'You supplied an invalid file for import.';
                alertMessageType = 'slds-theme--error';
                visibilityClass = 'slds-show';
            }
            else
            {
                csvContent = csvblob.toString();
                system.debug('csvContent');
                system.debug(csvContent);
                
                if(Test.isRunningTest())
                {
                    csvContent = 'Member,Category\n'+
                        'pmoore,Has the client been briefed on the Instinet model?\n'+
                        'kambsag,Accounting Tax\n'+
                        'kashiyja,Aerospace and Defense\n'+
                        'kashiyja,Agriculture Incl Agrochemicals/Fertilizers\n'+
                        'pmoore,Australia or New Zealand\n'+
                        'kneubert,Cable and Satellite\n'+
                        'skilcull,"Beverages, Foods and Tobacco"\n'+
                        'garrettk,"Broadcasting, Advertising"\n'+
                        'rossim,"Brokers, Asset Managers and Exchanges"\n'+
                        'pmoore,kmmmk\n'+
                        'cindyk,Chemicals\n'+
                        'klm,cindyk,Chemicals\n';
                    
                }
                string recommendedCols = 'Member,Category';
                batchid = database.executeBatch(new BulkUploadBatch_ContactSurveys(csvContent,'Survey_Question__c',recommendedCols,surveyId),200);
                alertMessageText = 'Your request to upload Survey Members is submitted successfully. You will receive an upload results via email shortly.';
                alertMessageType = 'slds-theme--success';
                visibilityClass = 'slds-show';
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your request to upload Survey Members is submitted successfully.'));
                
            }    
            
        }
        catch(Exception e)
        {
            alertMessageText = 'An error has occured while importing data Please make sure input csv file is correct.';
            alertMessageType = 'slds-theme--error';
            visibilityClass = 'slds-show';
        }

        
        return null;
    }	
  public Pagereference setupQuestionFields(){
    resetViewsToFalse(true);
    showSelectQuestionType = 'True';
    if(questionType=='Multi-Select--Vertical'){
     showMultiSelect='True';
    }
    else if(questionType == 'Single Select--Vertical'){
      showSingleSelect = 'True';
    }
    else if(questionType == 'Free Text' || questionType == 'Free Text - Single Row Visible'){
      showFreeText = 'True';
    }
    else if(questionType == 'Single Select--Horizontal'){
      showRowQuestion = 'True';
    }
    return null;
  }  
 
  public Pagereference saveAndNewQuestion(){
    saveAndNew = True;
    if(questionReference == null || questionReference.length() <5)
      return saveNewQuestion();
    else 
      return updateQuestion();  
  }
  
  

  
  public Pagereference controllerSavQuestion(){
    resetMessageDisplay();
    if(questionReference == null || questionReference.length() <5){
      return saveNewQuestion();
    }
    else{ 
      return updateQuestion();
    }
      
  }
  


  
  private Pagereference updateQuestion(){
    Boolean validRecord = TRUE;
    String categoryDefaultValue = '--SELECT--';
    //questionToUpdate is setup in an earlier call to editQuestion()
    //questionToUpdate.Name = questionToName(qQuestion); /* Commented by Nomura */
    questionToUpdate.Choices__c = qChoices;
    questionToUpdate.Required__c = qRequired;
    questionToUpdate.Type__c = questionType;
    /*
     * Commented by Nomura
     */ 
    /*questionToUpdate.Question__c = qQuestion;*/
	
    /*
     * Added by Nomura
     */
    if(categoryDefaultValue.equalsIgnoreCase(qCategory)){
         validRecord = FALSE; 
         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Category is required')); 
    }
	questionToUpdate.Category__c = qCategory;
    questionToUpdate.Member__c = surveyQuestionObj.Member__c; 
    try{
      if(validRecord)
      {
          if(doesRecordExist(questionToUpdate.Id, questionToUpdate)){
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Question'));
          }
          else {
              update questionToUpdate;
              resetViewsToFalse(true);
              deleteOldResponses(questionToUpdate.id);
              questionReference = null;
              pageMessage.setMessage('Question was updated!', 'success');
          }
      }
    }catch(Exception e){
      Apexpages.addMessages(e);
      pageMessage.setMessage(e.getMessage(), 'error');
    }
    
    return saveOrUpdateReturn();
  }
  
  private void deleteOldResponses(String qId){
    List <SurveyQuestionResponse__c> sResponses = [select id, Survey_Question__c from SurveyQuestionResponse__c where Survey_Question__c = :qId];
    if(sResponses != null)
     delete sResponses;
  }
  
  private Pagereference saveOrUpdateReturn(){
    setupQuestionList();
    Pagereference pr = new Pagereference('/apex/SurveyPage?id='+surveyRef);
    questionType = '--SELECT--';
    if(saveAndNew != null  && saveAndNew == true){
      saveAndNew = False;
      showSelectQuestionType = 'True';      
      return pr;
    }
    else{  
      showSelectQuestionType = 'False';      
      return pr; 
    }
  }

  public Integer getNewQuestionNum(){
    if(allQuestions == null)
     return 0;
    else{
     return allQuestions.size();
    }    
  }

  private Pagereference saveNewQuestion(){ 
    Boolean validRecord = TRUE;
	String categoryDefaultValue = '--SELECT--';
     
    Survey_Question__c newQuestion = new Survey_Question__c();
    newQuestion.Survey__c = surveyRef;
    //newQuestion.Name = questionToName(qQuestion); //Commented by Nomura
    newQuestion.Choices__c = qChoices;
    newQuestion.Required__c = qRequired;
    newQuestion.Type__c = questionType;
    newQuestion.OrderNumber__c = getNewQuestionNum();
    /*
     * Commented by Nomura
     */
    /*newQuestion.Question__c = qQuestion;*/
    
    /*
     * Added by Nomura
     */
    if(categoryDefaultValue.equalsIgnoreCase(qCategory)){
		validRecord = FALSE; 
		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Category is required')); 
	}  
    newQuestion.Category__c = qCategory;
    newQuestion.Member__c = surveyQuestionObj.Member__c;
    resetViewsToFalse(true);
    try{
        if(validRecord){
            if(doesRecordExist(null, newQuestion)){
            	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Question'));
            }
            else {
                insert newQuestion;
        		pageMessage.setMessage('New question was added!', 'success');
            }
        }
    }catch(Exception e){
        pageMessage.setMessage(e.getMessage(), 'error');
    }
    return saveOrUpdateReturn();
  }
  
  private Boolean doesRecordExist(Id questionId, Survey_Question__c question){
      Boolean recordPresent = FALSE;
      List<Survey_Question__c> surveyQuestionList = new List<Survey_Question__c>();
      if(questionId != null){
          surveyQuestionList = [SELECT Id, Category__c, Member__c, Choices__c, Type__c
                                FROM Survey_Question__c
                                WHERE Survey__c = :surveyId
                               ];
      }
      else {
          surveyQuestionList = [SELECT Id, Category__c, Member__c, Choices__c, Type__c
                                FROM Survey_Question__c
                                WHERE Survey__c = :surveyId AND Id <> :questionId
                               ];
      }
      
      if(surveyQuestionList != null && surveyQuestionList.size() > 0){
          for(Survey_Question__c surveyQuestion : surveyQuestionList){
              if(surveyQuestion.Category__c != null && surveyQuestion.Category__c.equalsIgnoreCase(question.Category__c) &&
                 surveyQuestion.Member__c != null && surveyQuestion.Member__c == question.Member__c &&
                 surveyQuestion.Choices__c != null && surveyQuestion.Choices__c.equalsIgnoreCase(question.Choices__c) &&
                 surveyQuestion.Type__c != null && surveyQuestion.Type__c.equalsIgnoreCase(question.Type__c)){
                     recordPresent = TRUE;
                     break;
                 }
          }
      }
      
      return recordPresent;
  }
    
  private String questionToName(String q){
    if(q.length()<75)
     return q;
    else
     return q.substring(0, 75)+'...';
  }
  
  public Pagereference previewQuestion(){
    if(questionType  == 'Multi-Select--Vertical'){
      showMultiSelectPreview = 'True';
      multiOptions = stringToSelectOptions(qChoices);
    }
    else if(questionType == 'Single Select--Vertical'){
     showSingleSelectPreview = 'True';
     singleOptions = stringToSelectOptions(qChoices);
    }
    else if(questionType =='Free Text' || questionType == 'Free Text - Single Row Visible'){
      showFreeTextPreview = 'True';
    }
    else if(questionType == 'Single Select--Horizontal'){
      showRowQuestionPreview = 'True';
      rowOptions = stringToSelectOptions(qChoices);
    }
    return null;
  }



  
  private List<SelectOption> stringToSelectOptions(String str){
    List<String> strList = str.split('\\r|\n');
    List<SelectOption> returnVal = new List<SelectOption>();
    for(String s: strList){
      returnVal.add(new SelectOption(s,s));
    }
    return returnVal;
    
  }
/****/

  /* Called during the setup of the page. 
     Retrieve questions and responses from DB and inserts them in 2 lists. */
  public Integer setupQuestionList(){
    /*allQuestions.clear();
    List<Survey_Question__c> allQuestionsObject = 
                    [Select Type__c, Id, Survey__c, Required__c, 
                    Question__c, OrderNumber__c, Name, Choices__c
                    From Survey_Question__c  
                    WHERE Survey__c =: surveyId
                    order by OrderNumber__c];
    for (Survey_Question__c q : allQuestionsObject){
      question theQ = new question(q);
      allQuestions.add(theQ);
    }
    //responses = getResponses();//taken out because it was SOQL heavy//*/
    getAQuestion();
    return allQuestions.size();
  }
  
  
   /** Sets the survey's name variable
  *  param: sID The survey ID as specified in the DB
  */
  public void setSurveyNameAndThankYou(String sId){
    Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c, Survey_Header__c FROM Survey__c WHERE Id =:sId];
    surveyName = s.Name;
    surveyHeader = s.Survey_Header__c;
    templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
    surveyThankYouText = s.thankYouText__c;
    surveyThankYouURL = s.thankYouLink__c;
  }
  
//------------------------------------------------------------------------------//   
  public Pagereference updateSurveyName(){
    Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
    s.Name = surveyName;
    try{
      update s;
    }catch (Exception e){
      Apexpages.addMessages(e);
      pageMessage.setMessage(e.getMessage(), 'error');
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

        pageMessage.setMessage(e.getMessage(), 'error');
    }
    return null;
  }

  
   public PageReference updateOrderList()
  {
    resetMessageDisplay();
    if(newOrderW.length() <= 0)
    {
        return null;
    }

      try {
          newOrderW = newOrderW.substring(0, newOrderW.length() - 1);

          List<String> idsToUpdate = newOrderW.split(',', -1);
          List<Survey_Question__c> qsToUpdate = new List<Survey_Question__c>();

          Map<Id, Survey_Question__c> questionMap = new Map<Id, Survey_Question__c>([select Id, OrderNumber__c from Survey_Question__c where Id in :idsToUpdate]);
          Survey_Question__c sqToUpdate;

          for (Integer i = 0; i < idsToUpdate.size(); i++) {
              sqToUpdate = questionMap.get(idsToUpdate.get(i));
              sqToUpdate.OrderNumber__c = i;
              qsToUpdate.add(sqToUpdate);
          }

          update qsToUpdate;
          pageMessage.setMessage('Question Order was successfully updated!', 'success');
      }catch(Exception e){
          Apexpages.addMessages(e);
          pageMessage.setMessage(e.getMessage(), 'error');

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
  

   /** Redirects the page that displays the detailed results of the survey, 
       from all users who took the survey.
    */
    public PageReference resultPage() {
      return new PageReference('/apex/ResultsPage?id='+surveyId);
    }

   
    
  
//------------------------------------------------------------------------------//      
    public Pagereference deleteRefresh(){
        if (questionReference == null ){
            return null;
        }
      try{
        Survey_Question__c sq = [Select Id, Name FROM Survey_Question__c WHERE Id =: questionReference];
        delete sq;
         questionReference = null;

         allQuestions.clear();
         Double j = 0.0;
        /*
         * Category__c, Member__c, Member__r.Name Added by Nomura 
         */
        List<Survey_Question__c> allQuestionsObject =
                        [Select Type__c, Id, Survey__c, Required__c,
                        Question__c, OrderNumber__c, Name, Choices__c,
                        Category__c, Member__c, Member__r.Name 
                        From Survey_Question__c
                        WHERE Survey__c =: surveyId
                        order by OrderNumber__c];
        for (Integer i =0; i< allQuestionsObject.size(); i++){
          allQuestionsObject[i].OrderNumber__c= j;
            SFQuestion theQ = new SFQuestion(allQuestionsObject[i]);
          allQuestions.add(theQ);
          j = j+1.0;
        }
        //TODO : Check Whether this is required or not
        responses = getResponses();
        update allQuestionsObject;
    }catch(Exception e){
      Apexpages.addMessages(e);
      pageMessage.setMessage(e.getMessage(), 'error');
    }
      return saveOrUpdateReturn();
  }



//------------------------------------------------------------------------------//  

   /** 
    */
  public List<String> getResponses() {
    //TODO : Put User and Contact
    List<SurveyQuestionResponse__c> qr = [Select Survey_Question__c, Response__c, Name From SurveyQuestionResponse__c limit 100];
    List<String> resp = new List<String>();
    for (SurveyQuestionResponse__c r : qr) {
      resp.add(r.Response__c);
    }
    
    return resp;
  }  

   
  
  /** Fills up the List of questions to be displayed on the Visualforce page
   */ 
  public List<SFQuestion> getAQuestion() {
    /*
     * Category__c, Member__c, Member__r.Name
     */
    List<Survey_Question__c> allQuestionsObject = 
                    [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                    s.OrderNumber__c, s.Name, s.Choices__c,
                    s.Category__c, s.Member__c, s.Member__r.Name 
                    From Survey_Question__c s 
                    WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
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
        SFQuestion theQ = new SFQuestion(q);
      allQuestions.add(theQ);
    }
    allQuestionsSize = allQuestions.size();
    return allQuestions;
  }
    
  

}