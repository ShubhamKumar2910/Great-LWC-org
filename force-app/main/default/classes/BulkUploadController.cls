public class BulkUploadController {
    
    public string fileName{get;set;}
    public Blob csvblob{get;set;}
    public string csvContent{get;set;}
    public static Id batchid{get;set;}
    public boolean displayResult{get;set;}
    public string sourceObject{get;set;}
    public string surveyId{get;set;}
    public string sourceObjectLabel{get;set;}
    public string sourceObjectLabelPlural{get;set;}
    public boolean isError{get;set;}
    public string recommendedCols{get;set;}
    public Id downloadId{get;set;}
    
    public BulkUploadController() {
        displayResult = false;
        isError = false;
        
        sourceObject =  ApexPages.currentPage().getParameters().get('sourceObject');
        surveyId = ApexPages.currentPage().getParameters().get('surveyId');
        if(sourceObject==null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Source Object not passed as parameter.'));
            displayResult = true;
            isError = true;
        }
        else
        {
            if(sourceObject == 'Event')
            {
                sourceObjectLabelPlural = SObjectType.Event.getLabelPlural();
                sourceObjectLabel = SObjectType.Event.getLabel();
               
            }
            else if(sourceObject == 'Survey_Question__c')
            {
                //sourceObjectLabelPlural = SObjectType.Survey_Question__c.getLabelPlural();
                sourceObjectLabelPlural ='Survey Members';
                sourceObjectLabel = SObjectType.Survey_Question__c.getLabel();
                 
            }
            if(getSampleTemplateDownloadID(sourceObject).size()==1)
            {
                for(Id docId:getSampleTemplateDownloadID(sourceObject))
                    downloadid = docId;
            }
            //add more as new objects added to bulk uploader
            displayResult = false;
        }
    }
    
    public Set<Id> getSampleTemplateDownloadID(string sourceObj)
    {
        string documentDeveloperName = '';
        system.debug('***: '+sourceObj);
        if(sourceObj == 'Event')
            documentDeveloperName = 'Deal_Axis_Event_Sample_Template';
        else if(sourceObj == 'Survey_Question__c')
            documentDeveloperName = 'Survey_Sample_Template';
        
        return new Map<Id,Document>([select id from Document where DeveloperName =:documentDeveloperName]).keyset();
    }
    
    public PageReference startUpload()
    {
        displayResult = false;
        try
        {
            if(csvblob == null || fileName == null || fileName == '')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select csv file to upload.'));
                displayResult = true;
            }
            else if(!fileName.contains('.csv'))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You supplied an invalid file for import.'));
                displayResult = true;
            }
            else
            {
                csvContent = csvblob.toString();
                system.debug('csvContent');
                system.debug(csvContent);
                
                if(Test.isRunningTest())
                {
                    //Changes for Shield. As functionality is removed from UI.
                    /*
                    if(sourceObject == 'Event')
                    {
                        csvContent = 'RG Name,RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,28-Feb-2017,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,"test1,test1"\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,28-Feb-2017,5:30:00,17:30:00,America/New_York,,1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,28-Feb-2017,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,28-Feb-2017,5:30:00,17:30:00,MMMMMM,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,28-Feb-2017,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testnom@test.com,ABC-MART INC NPV - Test 2,Americas,28-Feb-2017,13:30:00,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;kmore;sagarda;klamn,,No Emails,Americas,28-Feb-2017,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 3,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),,pmoore;kashiyja;kmore,,No RG,Americas,28-Feb-2017,10:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,,Americas,28-Feb-17,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG434265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,Invalid RG,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,masyhur.tainvest@gmail.comx;wwong@oxbcap.comx;gary.adams1@nomura.comx;abc@gmail.com,Email Invalid,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;sagarda,testrg@test.com;testnom@test.com,Users Invalid,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,kkk;hhh;mmm,,Multiple Errors,rrr,28-Feb-2017,5:30:00,17:30:00,,ggg,1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Region Invalid,KKKK,28-Feb-2017,13:30:00,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Event Type  Invalid,Americas,28-Feb-2017,13:30:00,17:30:00,Europe/Amsterdam,TJJHH,1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Ticker Invalid,Americas,28-Feb-2017,13:30:00,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test2\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,TimeZone Invalid,Americas,28-Feb-2017,13:30:00,17:30:00,Tzndja,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Meeting Start Time Not present,Americas,28-Feb-2017,,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Meeting End Time Not present,Americas,28-Feb-2017,13:30:00,,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,No TimeZone,Americas,28-Feb-2017,13:30:00,17:30:00,,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 4,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,,testrg@test.com;testnom@test.com,Users Required,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test2\n'+
                            'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com;abc@gmail.com,,Americas,28-Feb-2017,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test2\n';
                    }
                    */
                    if(sourceObject == 'Survey_Question__c')
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
                }
                
                //Changes for Shield. As funcitonality is removed from UI.
                /*
                if(sourceObject == 'Event')
                {
                    recommendedCols = 'RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker';
                    batchid = database.executeBatch(new BulkUploadBatch_DAEvents(csvContent,sourceObject,recommendedCols),150);
                
                }
				*/
                if(sourceObject == 'Survey_Question__c')
                {
                    recommendedCols = 'Member,Category';
                    batchid = database.executeBatch(new BulkUploadBatch_ContactSurveys(csvContent,sourceObject,recommendedCols,surveyId),200);
                
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your request to upload '+ sourceObjectLabelPlural +' is submitted successfully. You will receive an upload results via email shortly.'));
                displayResult = true;
                
            }     
        }
        catch(Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct.');
            ApexPages.addMessage(errorMessage);
            displayResult = true;
        }
        
        return null;
    }
    
    /*public void getCurrentUserDefaultREcordType()
    {
        List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Event.RecordTypeInfos;
         for (Schema.RecordTypeInfo info : infos) {
            if (info.DefaultRecordTypeMapping) {
                defaultRecordTypeId = info.RecordTypeId;
            }
        }
        System.debug(defaultRecordTypeId);
    }*/
}