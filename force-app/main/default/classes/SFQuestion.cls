/**
 * Renaming old "Question" to "SFQuestion" class
 * This is to avoid problem with "Question" object which is added by Chatter Answers
 *
 * Class: question
 *  Retrieves the question information and puts it in the question object
 *
 */

public with sharing class SFQuestion { 
    public String   name                   {get; set;}
    public String   id                           {get; set;}
    public String   question               {get; set;}
    public String   orderNumber            {get; set;}
    public String   choices                {get; set;}
    public String   selectedOption         {get;set;}
    public List<String> selectedOptions {get;set;}
    public List<SelectOption> singleOptions{get; set;}
    public List<SelectOption> multiOptions {get; set;}
    public Boolean  required               {get; set;}
    public String   questionType           {get; set;}
    public String   surveyName               {get; set;}
    public String   renderFreeText             {get; set;}
    public String   renderSelectRadio      {get; set;}
    public String   renderSelectCheckboxes {get; set;}
    public String   renderSelectRow        {get; set;}
    public List<String> responses              {get; set;}
    public String   singleOptionsForChart  {get; set;}
    public String   qResultsForChart         {get; set;}
    public List<String> strList              {get; set;} // The question's option as a list of string
    public List<Integer> resultsCounts       {get; set;} // The count of each response to a question's choices
    public List<SelectOption> rowOptions   {get; set;}
    public boolean  noData                 {get; set;}
    public String noOfRowsForTextArea {get; set;}
    
    /*
     * Added by Nomura
     */
    public String category	{get; set;}
    public String member	{get; set;}
    
    public String contactId 		{get; set;}
    public String userId			{get; set;}
    
    public String notes 			{get; set;}

    /* Fills up the question object
     *  param:    Survey_Question__c
     */
    public SFQuestion(Survey_Question__c surveyQuestion) {
       initSurveyQuestion(surveyQuestion);
    }
    
    public SFQuestion(Survey_Question__c surveyQuestion, SurveyQuestionResponse__c surveyQuestionResponse){
        initSurveyQuestion(surveyQuestion);
        initSurveyQuestionResponse(surveyQuestionResponse);
    }
    
    public void initSurveyQuestion(Survey_Question__c sq){
        name = sq.Name;
        id = sq.Id;
        question = sq.Question__c;
        orderNumber = String.valueOf(sq.OrderNumber__c+1);
        choices = sq.Choices__c;
        required = sq.Required__c;
        questionType = sq.Type__c;
        singleOptionsForChart = ' ';
        
        /*
         * Added by Nomura : Start
         */ 
        category = sq.Category__c;
        member = sq.Member__r.Name;
        /*
         * Added by Nomura : End
         */
        selectedOption = '';
        selectedOptions = new List<String>();
        if (sq.Type__c=='Single Select--Vertical'){
            renderSelectRadio='true';
            singleOptions = stringToSelectOptions(choices);

            renderSelectCheckboxes='false';
            renderFreeText='false';
            renderSelectRow = 'false';
            selectedOption = '';
            selectedOptions = new List<String>();
        }
        else if (sq.Type__c=='Multi-Select--Vertical'){
            renderSelectCheckboxes='true';
            multiOptions = stringToSelectOptions(choices);
            renderSelectRadio='false';
            renderFreeText='false';
            renderSelectRow = 'false';
            selectedOption = '';
            selectedOptions = new List<String>();
        }
        else if (sq.Type__c=='Single Select--Horizontal'){
            renderSelectCheckboxes='false';
            rowOptions = stringToSelectOptions(choices);
            renderSelectRadio='false';
            renderFreeText='false';
            renderSelectRow = 'true';
            selectedOption = '';
            selectedOptions = new List<String>();

        }
        else if (sq.Type__c=='Free Text' || sq.Type__c=='Free Text - Single Row Visible'){
            renderFreeText='true';
            renderSelectRadio='false';
            renderSelectCheckboxes='false';
            renderSelectRow = 'false';
            choices='';
            //If it's text area but for single row then only show single row even though it's stil text area
            if(sq.Type__c == 'Free Text - Single Row Visible'){
                noOfRowsForTextArea = '1';
            }else{
                noOfRowsForTextArea = '5';
            }


        }
        //responses= getResponses();
    }
    
    public void initSurveyQuestionResponse(SurveyQuestionResponse__c surveyQuestionResponse){
        if(surveyQuestionResponse != null){
        	contactId = surveyQuestionResponse.Contact__c;
    		userId = surveyQuestionResponse.User__c;
            
            notes = surveyQuestionResponse.Notes__c;
            
            //Setting Response
            if (String.isNotEmpty(questionType) && questionType.equals('Single Select--Vertical')){
                selectedOption = surveyQuestionResponse.Response__c;
            }
            else if (String.isNotEmpty(questionType) && questionType.equals('Multi-Select--Vertical')){
                selectedOptions = new List<String>();
                if(String.isNotEmpty(surveyQuestionResponse.Response__c)){
                    selectedOptions = surveyQuestionResponse.Response__c.split(';');
                }
            }
            else if (String.isNotEmpty(questionType) && questionType.equals('Single Select--Horizontal')){
                selectedOption = surveyQuestionResponse.Response__c;
            }
            else if (String.isNotEmpty(questionType) && questionType.equals('Free Text') || 
                     String.isNotEmpty(questionType) && questionType.equals('Free Text - Single Row Visible')){
                choices = surveyQuestionResponse.Response__c;
            }
        }
    } 

   /** Splits up the string as given by the user and adds each option
    *  to a list to be displayed as option on the Visualforce page
    *  param: str   String as submitted by the user
    *  returns the List of SelectOption for the visualforce page
    */
    private List<SelectOption> stringToSelectOptions(String str){
        if (str == '')
        {
            return new List<SelectOption>();
        }
        //strList = str.split('\n');
        strList = str.split('\\r|\n');

        List<SelectOption> returnVal = new List<SelectOption>();
        Integer i = 0;
        for(String s: strList){
            if (s!='') {
                if (s != 'null' && s!= null) {
                    String sBis = s.replace(' ', '%20');
                    singleOptionsForChart += s.trim()+'|';

                /*RSC2012-02-20
                String st = s.replace (' ', '&nbsp;');
                returnVal.add(new SelectOption(String.valueOf(i),st));
                */
                    //returnVal.add(new SelectOption(String.valueOf(i),s));
                    //Changed by Nomura - Keeping Value same as Label
                    returnVal.add(new SelectOption(s,s));
                    System.debug('*****VALUES: ' + s);
                    i++;
                }
            }
        }
        singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
        return returnVal;
    }
}