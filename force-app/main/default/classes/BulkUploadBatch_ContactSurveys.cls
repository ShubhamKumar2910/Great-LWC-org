global with sharing class BulkUploadBatch_ContactSurveys implements Database.batchable<String>, Database.Stateful,  Database.AllowsCallouts{
    
    /******************** START BATCH VARIABLES ****************/
    private CSVStreamParser m_parser;
    
    private String sourceObjectAPI = ''; 
	private String sourceObjectLabel = '';
    private string SourceObjectRecordTypeId = '';
    private String m_csvFile = '';
    private String csvErrorRows = '';
    private String csvSuccessRows = '';
    private String generatedErrorCSVfile='';
    private String exception_message = '';
    
    private Integer rowNumber = 0;
    
    private Boolean batchExecutionSuccessfully = true;
    private Boolean startUploading = false;
    private Boolean IsError = false;
    private Boolean IsSuccess = false;
    
    BulkUploadUtility bulkManager = new BulkUploadUtility();
    
    private Map<Integer, sObject> surveyQuestionsobjToInsert;
	private List<List<String>> copyOfCSVLines;
	private Set<string> existingsurveyQSet;
	Set<string> sfSurveyIds;  
    Map<string, Integer> map_surveyId_OrderNumber;
    private Set<string> categoryItems{get;set;}
    string sfSurveyId = '';
    /********************END BATCH VARIABLES ****************/
    
    
    public BulkUploadBatch_ContactSurveys(String m_csvFile,String sourceObjectAPIName,String recommendedCols,String surveyId)
    {
		try{
        this.sfSurveyId = surveyId;
        m_parser = new CSVStreamParser();
        this.m_csvFile = m_csvFile;
        this.sourceObjectAPI = sourceObjectAPIName;
		this.sourceObjectLabel = SObjectType.Survey_Question__c.getLabel(); 
        generatedErrorCSVfile=recommendedCols + ',Error\n';
        getCategoryItems();
        /******************************* UTILITY CLASS ASSIGNMENT **************************************/
        //1. defining utility class source Object Label for Error
        bulkManager.SourceObjectLabel = sourceObjectLabel;
        
        //2. defining utility class source object csv recommended headers
        bulkManager.recommended_csvcolumns = recommendedCols;
        /*************************************************************************************************/
		}
        catch(Exception e)
        {	
			exception_message += e+'\n'+e.getStackTraceString();
			exception_message += '\n';
			batchExecutionSuccessfully = false;
            bulkManager.emailLog('FAILURE',exception_message,null,'Exception',null);
        }
    }
    
    //Run 1
    global Iterable<String> start(Database.batchableContext batchableContext)
    {
        try
        {
            return new CSVStreamIterator(m_csvFile, CSVStreamParser.lf);
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
			exception_message += '\n';
			batchExecutionSuccessfully = false;
			bulkManager.emailLog('FAILURE',exception_message,null,'Exception',null);
            System.abortJob(batchableContext.getJobId());
            return null;
        }
    }
    
    //Run 2
    global void execute(Database.BatchableContext batchableContext, List<String> scope)  
    {
        SavePoint sp;
                   
        try
        {
            String csvFile = '';
            for(String row : scope)
            {
                if(row.endswith(CSVStreamParser.CR))
                    csvFile += row + CSVStreamParser.LF;
                else
                    csvFile += row + CSVStreamParser.crlf;
            }
            
            //this method will read and parse CSV file line by line
            List<List<String>> csvLines = CSVStreamReader.readCSVFile(csvFile,m_parser);
            
            
            //This method will execute only once, which will validate the CSV header and remove it.
            if(!bulkManager.executeOnlyOnce)
            {
                if(bulkManager.checkcsvheaderanddata(csvLines))
                {
                    startUploading = true;
                    csvLines.remove(0);
                }
                else{
                    startUploading = false;
                    
                    if(bulkManager.errorCategory == 'Blank CSV')
                    {
                        bulkManager.emailLog('ERROR','No data found !!.\n\nRegards,\nSalesforce Tech',null,'User',null);
                    }
                    else if(bulkManager.errorCategory == 'Invalid CSV')
                    {
                        exception_message+='\nInvalid CSV Column Headers:\n'+bulkManager.csvheaders+'\n\nValid CSV Column Headers are:\n'+bulkManager.recommended_csvcolumns+'\n\nRegards,\nSalesforce Tech';
                        bulkManager.emailLog('ERROR',exception_message,null,'User',null);
                    }
                    System.abortJob(batchableContext.getJobId()); //Aborting job so that next consecutive batches of same job will not executing.
                    batchExecutionSuccessfully = false; 
                }    
            }
            
            if(startUploading)
            {
                system.debug('Items Category: '+categoryItems.size()); 
				IsError = false;
                IsSuccess = false;
               
				sfSurveyIds = new Set<string>();          // get all surveyIds from Salesforce which matches ids in CSV
				//sfSurveyIds = extractSFSurveyIDfromCSV(csvLines,0);  // we have set to check if surveyid is valid or not
				
				if(sfSurveyId.length() == 18)
                sfSurveyId = sfSurveyId.substring(0,15);
			
				sfSurveyIds.add(sfSurveyId);  // we have set to check if surveyid is valid or not
                
                //We are actually getting map ready for (surveyid,HighestOrderNumber)
                if(sfSurveyIds.size() > 0)
                {
                    Integer queryLimit = sfSurveyIds.size();
                    map_surveyId_OrderNumber = createmap_surveyId_OrderNumber(sfSurveyIds);
                }
                
                //extract loginids unique
                bulkManager.extractUserLoginIdsFromCSV(csvLines,null,0); 
				bulkManager.storeUserMapActive(bulkManager.csvuserloginIds);
				bulkManager.storeContactMapWithUsersInActive(bulkManager.csvuserloginIds);
                
                Set<string> uniqueSetfromCSV = new Set<string>();
                uniqueSetfromCSV = getUniqueSurveyQuestionsfromCSV(csvLines,sfSurveyId,0,1);
                
                if(uniqueSetfromCSV.size() > 0)
                {
                    existingsurveyQSet = new Set<string>();
                    existingsurveyQSet=getUniqueSurveyQuestionsfromSF(uniqueSetfromCSV);
                }
                
                if(existingsurveyQSet.size()>0)
                {
                    for(string s: existingsurveyQSet)
                    {
                        system.debug(s);
                    }
                }
                sp = Database.setSavepoint();
                doSurveyQuestionsObjectMapping(csvLines);
                
               
                if(surveyQuestionsobjToInsert.size()>0)
                {
                    rowNumber = 0;
                    Database.SaveResult[] results = Database.insert(surveyQuestionsobjToInsert.values(), false);
                    for(Database.SaveResult sr : results)
                    {
                        if(!sr.isSuccess())
                        {
                            IsError = true;
                            string errormsg = '';
                            for(Database.Error err : sr.getErrors()) {
                                errormsg = err.getMessage()+'.';
                            }
                            generatedErrorCSVfile += copyOfCSVLines[rowNumber][0]+','+'"'+ copyOfCSVLines[rowNumber][1] + '"'+','+'"'+ errormsg + '"'+'\n';
                        }
                        rowNumber++;
                    }
                }
                
            }
        }
        catch(Exception e)
        {
            if(sp!=null)
            Database.rollback(sp);
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            system.debug('Exception '+exception_message);
        }
    }
    
    //Run 3 
    global void finish(Database.BatchableContext bc)
    {
        if(batchExecutionSuccessfully)
        {
            
            if(bulkManager.utilitycsvErrorRows!=''  || IsError)
            {
                if(bulkManager.utilitycsvErrorRows!='')
                {
                    generatedErrorCSVfile += bulkManager.utilitycsvErrorRows;
                }
              bulkManager.emailLog('ERRORS','Attached are the records which have errors.\nPlease rectify and re-upload only these records.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'User',null);
            }
            else
            {
                 bulkManager.emailLog('SUCCESS','Regards,\nSalesforce Tech',null,'User',null);
            }            
        }
        else 
        {
            bulkManager.emailLog('FAILURE','There has been an issue processing your bulk upload request.\nSalesforce Tech has been notified of the same.\n\nPlease contact Salesforce Tech for further clarifications.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'Exception',exception_message+'\n\nRegards,\nSalesforce Tech');
        }
    }
    
    //Object : Survey Questions Mapping
    public void doSurveyQuestionsObjectMapping(List<List<String>> csvLines)
    {
        
            if(SourceObjectAPI == 'Survey_Question__c')
            {
                surveyQuestionsobjToInsert = new Map<Integer, sObject>();
                Boolean validationError = false;
                copyOfCSVLines = new List<List<String>>();
                Integer orderNoIndex = 0;
                Set<String> surveyIDSelected = new Set<String>();
                Set<String> surveyIDDuplicate = new Set<String>();
                Map<string, Integer> orderMap = new Map<string, Integer>();
                string csvSID =  '';
                
                for(Integer i=0;i<csvLines.size();i++)
                {
                    validationError = false;
                    string errormessage = '';
                    
                    sObject sObj = Schema.getGlobalDescribe().get('Survey_Question__c').newSObject() ;
                    
                    
                    if(sfSurveyId.trim().length() == 18)
                        csvSID = sfSurveyId.trim().substring(0,15);
                    else
                        csvSID = sfSurveyId.trim();
                    
                    
                    
                    sObj.put('Survey__c' , sfSurveyId.trim()) ; //Survey ID
                    
                    if(csvLines[i][0].trim() !=null && csvLines[i][0].trim() !='') //users
                    {
                        if(bulkManager.userMapActive.get(csvLines[i][0].trim())==null && bulkManager.nomuracontactMapActive.get(csvLines[i][0].trim()) == null)
                        {
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Member:'+csvLines[i][0].trim()+' not found';
                            else
                                errormessage += ', Member:'+csvLines[i][0].trim()+' not found';
                        }
                        else
                        {
                            if(bulkManager.userMapActive.get(csvLines[i][0].trim())!=null)
                            {
                                sObj.put('Member__c' , bulkManager.userMapActive.get(csvLines[i][0].trim()));
                            }
                            else
                            {
                                //sObj.put('Contact__c' , bulkManager.nomuracontactMapActive.get(csvLines[i][1].trim()));
                                
                                //comment below lines when Contact__c lookup is created and uncomment above line.
                                validationError = true;
                                if(errormessage == '')
                                    errormessage = 'Contact:'+csvLines[i][0].trim()+' cannot be assigned';
                                else
                                    errormessage += ', Contact:'+csvLines[i][0].trim()+' cannot be assigned';
                            }
                        }
                    }
                    else
                    {
                        validationError = true;
                        if(errormessage == '')
                            errormessage = 'Member is mandatory';
                        else
                            errormessage += ', Member is mandatory';
                    }
                    
                    
                    if(csvLines[i][1].trim() != null && csvLines[i][1].trim() !='') //Category
                    {
                        if(categoryItems.contains(csvLines[i][1].trim()))
                        {
                            sObj.put('Category__c' ,csvLines[i][1].trim()) ;    
                        }
                        else
                        {
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Category: '+csvLines[i][1].trim()+' is invalid';
                            else
                                errormessage += ', Category: '+csvLines[i][1].trim()+' is invalid';
                        }
                    }
                    else
                    {
                        validationError = true;
                        if(errormessage == '')
                            errormessage = 'Category is mandatory';
                        else
                            errormessage += ', Category is mandatory';
                    }
                    
                    if(!validationError)
                    {
                        string surveyId = '';
                        string userId = '';
                        
                        if(sfSurveyId.trim().length() == 18)
                            surveyId = sfSurveyId.trim().substring(0, 15);
                        else
                            surveyId = sfSurveyId.trim();
                        
                        if(bulkManager.userMapActive.get(csvLines[i][0].trim())!=null)
                        {
                            if(bulkManager.userMapActive.get(csvLines[i][0].trim()).length()==18)
                                userId = bulkManager.userMapActive.get(csvLines[i][0].trim()).substring(0, 15);
                            else
                                userId = bulkManager.userMapActive.get(csvLines[i][0].trim());
                        }
                        else
                        {
                            if(bulkManager.nomuracontactMapActive.get(csvLines[i][0].trim())!=null)
                            {
                                if(bulkManager.nomuracontactMapActive.get(csvLines[i][0].trim()).length()==18)
                                    userId = bulkManager.nomuracontactMapActive.get(csvLines[i][0].trim()).substring(0, 15);
                                else
                                    userId = bulkManager.nomuracontactMapActive.get(csvLines[i][0].trim());
                            }
                        }
                        
                        
                        if(surveyId!='' && userId!='' && csvLines[i][1].trim()!=''){
                            if(existingsurveyQSet.contains(surveyId+userId+csvLines[i][1].trim()) || surveyIDDuplicate.contains(surveyId+userId+csvLines[i][1].trim()))
                            {
                                validationError = true;
                                /*if(errormessage == '')
                                    errormessage = 'Member '+csvLines[i][0].trim()+' exist for the category '+csvLines[i][1]+'.';
                                else
                                    errormessage += ' Member '+csvLines[i][0].trim()+' exist for the category '+csvLines[i][1]+'.';*/
                            }
                            else
                            {
                                surveyIDDuplicate.add(surveyId+userId+csvLines[i][1].trim()); // To process next occuring duplicates
                            }
                        }
                    }
                        
                     
                    
                    if(!validationError)
                    { 
                        copyOfCSVLines.add(csvLines[i]);
                        sObj.put('Choices__c' ,'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None') ;
                        sObj.put('Type__c' ,'Single Select--Horizontal') ;
                                            
                        surveyQuestionsobjToInsert.put(i,sObj);
                        if(map_surveyId_OrderNumber.get(csvSID)==null && !surveyIDSelected.contains(csvSID))
                        {
                            orderNoIndex = 0;
                        }
                        else
                        {
                            if(orderMap.get(csvSID)!=null)
                            {
                                orderNoIndex= orderMap.get(csvSID);
                                orderNoIndex++;    
                            }
                            else
                            {
                                orderNoIndex= map_surveyId_OrderNumber.get(csvSID);
                                orderNoIndex++;   
                            }
                            
                        }
                        sObj.put('OrderNumber__c' ,orderNoIndex) ;
                        surveyIDSelected.add(csvSID);
                        orderMap.put(csvSID, orderNoIndex);
                        orderNoIndex++;
                    }
                    else
                    {
                        if(errormessage!='')
                            bulkManager.utilitycsvErrorRows += csvLines[i][0]+','+'"'+csvLines[i][1] + '"'+','+'"'+errormessage + '"'+'\n';        
                    }
                }   
            }
        
    }
   
    //store set of unique Surev Questions
    private Set<string> getUniqueSurveyQuestionsfromSF(Set<string> CSV_UniqueKeys)
    {
        Set<string> uniqueSet = new Set<string>();
        for(Survey_Question__c record: [select id, Survey__c, Member__c, Category__c from Survey_Question__c where UniqueKey__c in: CSV_UniqueKeys])
        {
            string surveyid = record.Survey__c;
            string memberid = record.Member__c;
            string categoryid = record.Category__c;
            
            if(surveyid.length() == 18)
                surveyid = surveyid.substring(0,15);
				
            
            if(memberid.length() == 18)
                memberid = memberid.substring(0,15);
            
            if(categoryid.length() == 18)
                categoryid = categoryid.substring(0,15);
            
            uniqueSet.add(surveyid+''+memberid+''+categoryid);
        }
        return uniqueSet;
    }
    
    /*
    * Unique = surveyid+memberid+Category
    */
    private Set<string> getUniqueSurveyQuestionsfromCSV(List<List<String>> csvLines,string surveyIdValue,Integer memberIndex, Integer categoryIndex)
    { 
        Set<string> csvSurveyQUniqueSet = new Set<string>();
        for(List<string> rowIndex: csvLines)
        {
            if((rowIndex[memberIndex]!=null && rowIndex[memberIndex]!='') && (rowIndex[categoryIndex]!=null && rowIndex[categoryIndex]!='') && (surveyIdValue!=null && surveyIdValue!=''))
            {
                string surveyId = surveyIdValue;
                string userId = '';
                
                     
                if(bulkManager.userMapActive.get(rowIndex[memberIndex])!=null)
                {
                    if(bulkManager.userMapActive.get(rowIndex[memberIndex]).length()==18)
                        userId = bulkManager.userMapActive.get(rowIndex[memberIndex]).substring(0, 15);
                    else
                        userId = bulkManager.userMapActive.get(rowIndex[memberIndex]);
                }
                else
                {
                    if(bulkManager.nomuracontactMapActive.get(rowIndex[memberIndex])!=null)
                    {
                        if(bulkManager.nomuracontactMapActive.get(rowIndex[memberIndex]).length()==18)
                            userId = bulkManager.nomuracontactMapActive.get(rowIndex[memberIndex]).substring(0, 15);
                        else
                            userId = bulkManager.nomuracontactMapActive.get(rowIndex[memberIndex]);
                    }
                }
                
                
                if(surveyId!='' && userId!='' && rowIndex[categoryIndex]!='')
                csvSurveyQUniqueSet.add(surveyId+''+userId+''+rowIndex[categoryIndex]);
                
            }
        }
        return csvSurveyQUniqueSet;
    }

    private Map<string, Integer> createmap_surveyId_OrderNumber(Set<string> sfIds)
    {
       Map<string, Integer> map_surveyId_OrderNumber = new Map<string, Integer>();  
       List<AggregateResult> results = [select Survey__c, max(OrderNumber__c) ONo from Survey_Question__c where Survey__c in:sfIds group by Survey__c]; 
	   for(AggregateResult q:results)
       {
           map_surveyId_OrderNumber.put(string.valueOf(q.get('Survey__c')).substring(0,15), Integer.valueOf(q.get('ONo')));
       }
        return  map_surveyId_OrderNumber;
    }
    
	private void getCategoryItems()
    {
        categoryItems = new Set<string>();
        Schema.DescribeFieldResult fieldResult = Survey_Question__c.Category__c.getDescribe();
        for(Schema.Picklistentry pe:fieldResult.getPicklistValues())
        {
           categoryItems.add(pe.getvalue());
        }
    }
    
}