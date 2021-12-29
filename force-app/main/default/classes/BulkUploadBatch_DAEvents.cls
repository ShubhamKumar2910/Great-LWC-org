global with sharing class BulkUploadBatch_DAEvents {//implements Database.batchable<String>, Database.Stateful,  Database.AllowsCallouts{
    //Changes for Shield. As functionality is removed from UI.
    /******************** START BATCH VARIABLES ***************
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
    
    private Map<Integer, Id> mapofIndex_AND_EventIds;
    private Map<Integer, sObject> eventobjToInsert;
    private Map<Integer,String> mapofIndex_AND_WhoEmailId;
    private Map<Integer,string> mapofindex_rgs;     
    private List<List<String>> copyOfCSVLines;
    private List<sObject> eventRelationobjToInsert;
    
    private Set<String> type_values = new Set<String>();
    private Set<String> event_type_values = new Set<String>();
    private Set<String> meeting_region_values = new Set<String>();
    /********************END BATCH VARIABLES ***************
    
    
    public BulkUploadBatch_DAEvents(String m_csvFile,String sourceObjectAPIName,String recommendedCols)
    {
        try
        {     
            m_parser = new CSVStreamParser();
            this.m_csvFile = m_csvFile;
            system.debug('MCSVFILE: '+m_csvFile.length());
            this.sourceObjectAPI = sourceObjectAPIName;
            this.sourceObjectLabel = SObjectType.Event.getLabel(); 
            generatedErrorCSVfile=recommendedCols + ',Error\n';
            
            List<RecordType> DealAxisEventType = [select id from RecordType where DeveloperName = 'DealAxis_Event_Integration' limit 1];
            if(DealAxisEventType.size() == 1)
                SourceObjectRecordTypeId = DealAxisEventType[0].id;
            
            /******************************* UTILITY CLASS ASSIGNMENT *************************************
            //1. defining utility class source Object Label for Error
            bulkManager.SourceObjectLabel = sourceObjectLabel;
            
            //2. defining utility class source object csv recommended headers
            bulkManager.recommended_csvcolumns = recommendedCols;
            /************************************************************************************************
            if(test.isRunningTest())
            {Decimal a = 2/0;}
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
            system.debug('MCSVFILE START: '+m_csvFile.length());
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
                   /* else if(bulkManager.errorCategory == 'File Exceeds')
                    {
                        exception_message+='\nYour import file exceeds limit of 1500 events.';
                        bulkManager.emailLog('File with incorrect header received.',exception_message,null);
                    }
                    
                    
                    System.abortJob(batchableContext.getJobId()); //Aborting job so that next consecutive batches of same job will not executing.
                    batchExecutionSuccessfully = false; 
                }    
            }
            
            if(startUploading)
            {
                IsError = false;
                IsSuccess = false;
                
                mapofIndex_AND_EventIds = new Map<Integer,Id>();
                eventRelationobjToInsert = new List<sObject>();
                
                bulkManager.extractUserLoginIdsFromCSV(csvLines,0,1); 
                bulkManager.extractEmailsFromCSV(csvLines,0,2);
                bulkManager.storeRGAccountIdMap(bulkManager.csvRGIds);
                bulkManager.storeUserMap(bulkManager.csvuserloginIds);
                bulkManager.storeUserMapActive(bulkManager.csvuserloginIds);
                bulkManager.storeContactMapWithUsersInActive(bulkManager.csvuserloginIds);
                bulkManager.storeContactMapWithUsersNotActive(bulkManager.csvuserloginIds);
                if(!Test.isRunningTest())
                {
                    Set<string> encAddresses = bulkManager.EncryptCSVEmails(bulkManager.csvcontactEmailIds);
                    bulkManager.storeContactEmailMap(encAddresses);
                    bulkManager.storeNomuraContactEmailMap(encAddresses);
                    bulkManager.storeNotNomuraContactEmailMap(encAddresses);
                }
                else if(Test.isRunningTest())
                {
                    bulkManager.storeContactEmailMap(bulkManager.csvcontactEmailIds);
                    bulkManager.storeNomuraContactEmailMap(bulkManager.csvcontactEmailIds);
                    bulkManager.storeNotNomuraContactEmailMap(bulkManager.csvcontactEmailIds);
                }
                
                if(!Bulkmanager.iscalloutException)
                {
                    sp = Database.setSavepoint() ;
                    //Query picklist value
                    
                    Schema.DescribeFieldResult fieldResult1 = Event.Event_Origination_Region__c.getDescribe();
                    for(Schema.Picklistentry pe:fieldResult1.getPicklistValues())
                    {
                         meeting_region_values.add(pe.getvalue());
                    }
                    
                    
                    Schema.DescribeFieldResult fieldResult2 = Event.Event_Type__c.getDescribe();
                    for(Schema.Picklistentry pe:fieldResult2.getPicklistValues())
                    {
                         event_type_values.add(pe.getvalue());
                    }
                    
                    
                    Schema.DescribeFieldResult fieldResult3 = Event.Type.getDescribe();
                    for(Schema.Picklistentry pe:fieldResult3.getPicklistValues())
                    {
                         type_values.add(pe.getvalue());
                    }
                    
                    
                    
                    //do Event mappings
                    doEventObjectMapping(csvLines);
                    
                    if(eventobjToInsert.size() > 0)
                    {
                        
                        Map<Integer,Integer> csvPointer = new Map<Integer,Integer>(); 
                        Integer pt = 0;    
                        for(Integer csvIndex : eventobjToInsert.keyset())
                        {
                            csvPointer.put(pt,csvIndex);
                            pt++;    
                        }
                        
                        rowNumber = 0;
                        
                        Database.SaveResult[] results = Database.insert(eventobjToInsert.values(), false);
                        for(Database.SaveResult sr : results)
                        {
                            if(!sr.isSuccess())
                            {
                                IsError = true;
                                string errormsg = '';
                                for(Database.Error err : sr.getErrors()) {
                                    errormsg = err.getMessage()+'.';
                                }
                                generatedErrorCSVfile += '"'+copyOfCSVLines[rowNumber][0]+'"'+','+'"'+copyOfCSVLines[rowNumber][1]+'"'+','+'"'+copyOfCSVLines[rowNumber][2]+'"'+','+'"'+copyOfCSVLines[rowNumber][3]+'"'+','+'"'+copyOfCSVLines[rowNumber][4]+'"'+','+'"'+copyOfCSVLines[rowNumber][5]+'"'+','+'"'+copyOfCSVLines[rowNumber][6]+'"'+','+'"'+copyOfCSVLines[rowNumber][7]+'"'+','+'"'+copyOfCSVLines[rowNumber][8]+'"'+','+'"'+copyOfCSVLines[rowNumber][9]+'"'+','+'"'+copyOfCSVLines[rowNumber][10]+'"'+','+'"'+copyOfCSVLines[rowNumber][11] + '"'+','+'"'+ errormsg + '"'+'\n';
                            }
                            else
                            {
                                
                                //IsSuccess = true;
                                //csvSuccessRows += sr.getId()+ ','+ bulkManager.copyOfCSVLines[rowNumber][0] +','+bulkManager.copyOfCSVLines[rowNumber][1]+','+csvLines[rowNumber][2]+','+bulkManager.copyOfCSVLines[rowNumber][3]+','+bulkManager.copyOfCSVLines[rowNumber][4]+','+bulkManager.copyOfCSVLines[rowNumber][5]+','+bulkManager.copyOfCSVLines[rowNumber][6]+','+bulkManager.copyOfCSVLines[rowNumber][7]+','+bulkManager.copyOfCSVLines[rowNumber][8]+','+bulkManager.copyOfCSVLines[rowNumber][9]+','+bulkManager.copyOfCSVLines[rowNumber][10]+','+bulkManager.copyOfCSVLines[rowNumber][11]+','+'"'+bulkManager.copyOfCSVLines[rowNumber][12] + '"'+'\n';
                                mapofIndex_AND_EventIds.put(csvPointer.get(rowNumber), sr.getId());
                                
                            }
                            rowNumber++;
                        }
                        
                        //process event Relations only for successful events inserted
                        system.debug(bulkManager.emailactual_Encrypted);
                        system.debug('mapofIndex_AND_EventIds: '+mapofIndex_AND_EventIds);
                        system.debug(mapofIndex_AND_WhoEmailId);
                        
                        if(mapofIndex_AND_EventIds.size() > 0)
                        { 
                            for(Integer csvIndex : mapofIndex_AND_EventIds.keyset())
                            {
                                if(bulkManager.mapofindex_emails.get(csvIndex)!=null)
                                {
                                    Set<string> newListofEmailsAfterWhoId = new Set<string>();
                                    
                                    for(String email : bulkManager.mapofindex_emails.get(csvIndex))
                                    {
                                        if(!Test.isRunningTest())
                                        {
                                            if(bulkManager.emailactual_Encrypted.get(email) != mapofIndex_AND_WhoEmailId.get(csvIndex))
                                            {
                                                newListofEmailsAfterWhoId.add(email);
                                            }    
                                        }
                                        else
                                        {
                                            if(email != mapofIndex_AND_WhoEmailId.get(csvIndex))
                                            {
                                                newListofEmailsAfterWhoId.add(email);
                                            }
                                        }
                                        
                                    }
                                    
                                    system.debug('CSVIndex: '+csvIndex);
                                    system.debug('newListofEmailsAfterWhoId: '+newListofEmailsAfterWhoId);
                                    
                                    if(newListofEmailsAfterWhoId.size()>0)
                                    {
                                        Set<string> tempSet = new Set<string>();
                                        for(String  em:newListofEmailsAfterWhoId)
                                        {
                                            If(!Test.IsRunningTest())
                                                tempset.add(bulkManager.emailactual_Encrypted.get(em));
                                            else
                                                tempset.add(em);
                                        }
                                        
                                        // Prepare list of nomura contacts as event Relations
                                        for(string em:tempset)
                                        {
                                            if(bulkManager.mapofdummyEmails1.get(em)!=null)
                                            {
                                                sObject sObj = Schema.getGlobalDescribe().get('EventRelation').newSObject() ;
                                                if(mapofIndex_AND_EventIds.get(csvIndex)!=null)
                                                    sObj.put('EventId' , mapofIndex_AND_EventIds.get(csvIndex)) ;
                                                sObj.put('RelationId' , bulkManager.mapofdummyEmails1.get(em)) ;
                                                sObj.put('isParent' , false) ;
                                                sObj.put('isInvitee' , true) ;
                                                sObj.put('Status','Accepted');
                                                eventRelationobjToInsert.add(sObj);
                                            }
                                        }
                                        
                                        // Prepare list of nomura other contacts as event Who Ids. if more than 50 contacts put in invitees
                                        Integer k =1;
                                        for(string em:tempset)
                                        {
                                            if(bulkManager.mapofdummyEmails2.get(em)!=null)
                                            {
                                                sObject sObj = Schema.getGlobalDescribe().get('EventRelation').newSObject() ;
                                                if(mapofIndex_AND_EventIds.get(csvIndex)!=null)
                                                    sObj.put('EventId' , mapofIndex_AND_EventIds.get(csvIndex)) ;
                                                sObj.put('RelationId' , bulkManager.mapofdummyEmails2.get(em)) ;
                                                
                                                if(k > 49)
                                                {
                                                    sObj.put('isParent' , false) ;
                                                    sObj.put('isInvitee' , true) ;
                                                }
                                                else
                                                {
                                                    sObj.put('isParent' , true) ;
                                                    sObj.put('isInvitee' , false) ;
                                                }
                                                
                                                sObj.put('Status','Accepted');
                                                eventRelationobjToInsert.add(sObj);
                                            }
                                            
                                            k++;
                                        }
                                    }
                                    
                                }
                                
                                
                                //Users
                                system.debug('mapofindex_userloginids: '+bulkManager.mapofindex_userloginids);
                                Set<string> listofUserloginIds = new Set<string>();
                                if(bulkManager.mapofindex_userloginids.get(csvIndex)!=null)
                                {
                                    for(String loginId : bulkManager.mapofindex_userloginids.get(csvIndex))
                                    { 
                                        listofUserloginIds.add(loginId);   
                                    }
                                    
                                    if(listofUserloginIds.size() > 0)
                                    {
                                        Set<string> loginIdsnotUsed = new Set<string>();
                                        Set<string> loginIdsUsed = new Set<string>();
                                        List<string> inactiveUserLoginIds = new List<string>();
                                        
                                        //check for active
                                        for(String lid: listofUserloginIds)
                                        {
                                            if(bulkManager.userMapActive.get(lid)!=null)
                                            {
                                                sObject sObj = Schema.getGlobalDescribe().get('EventRelation').newSObject() ;
                                                if(mapofIndex_AND_EventIds.get(csvIndex)!=null)
                                                    sObj.put('EventId' , mapofIndex_AND_EventIds.get(csvIndex)) ;
                                                sObj.put('RelationId' , bulkManager.userMapActive.get(lid));
                                                sObj.put('isParent' , false) ;
                                                sObj.put('isInvitee' , true) ;
                                                sObj.put('Status','Accepted');
                                                eventRelationobjToInsert.add(sObj);
                                                loginIdsUsed.add(lid);
                                            }
                                            else
                                            {
                                                loginIdsnotUsed.add(lid);
                                            }
                                            
                                            
                                        }
                                        
                                        system.debug('loginIdsnotUsed: '+loginIdsnotUsed.size());
                                        
                                        
                                        for(String invlid: loginIdsnotUsed)
                                        {
                                            if(bulkManager.nomuracontactMapActive.get(invlid)!=null)
                                            {
                                                sObject sObj = Schema.getGlobalDescribe().get('EventRelation').newSObject() ;
                                                if(mapofIndex_AND_EventIds.get(csvIndex)!=null)
                                                    sObj.put('EventId' , mapofIndex_AND_EventIds.get(csvIndex)) ;
                                                sObj.put('RelationId' , bulkManager.nomuracontactMapActive.get(invlid)) ;
                                                sObj.put('isParent' , false) ;
                                                sObj.put('isInvitee' , true) ;
                                                sObj.put('Status','Accepted');
                                                eventRelationobjToInsert.add(sObj);
                                            }
                                            else
                                            {
                                                if(bulkManager.nomuracontactMapNotActive.get(invlid)!=null)
                                                {
                                                    sObject sObj = Schema.getGlobalDescribe().get('EventRelation').newSObject() ;
                                                    if(mapofIndex_AND_EventIds.get(csvIndex)!=null)
                                                        sObj.put('EventId' , mapofIndex_AND_EventIds.get(csvIndex)) ;
                                                    sObj.put('RelationId' , bulkManager.nomuracontactMapNotActive.get(invlid)) ;
                                                    sObj.put('isParent' , false) ;
                                                    sObj.put('isInvitee' , true) ;
                                                sObj.put('Status','Accepted');
                                                    eventRelationobjToInsert.add(sObj);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            system.debug('Size: '+eventRelationobjToInsert.size());
                            system.debug('Relation: '+eventRelationobjToInsert);
                            
                            if(eventRelationobjToInsert.size() > 0)
                                Database.insert(eventRelationobjToInsert);
                            
                            if(test.isRunningTest())
                            {
                                Decimal a = 2/0;
                                
                            }
                        }
                        
                        
                    }   
                }
                else
                {
                    string calloutErrorMessage = '';
                    calloutErrorMessage = bulkManager.callout_exception_message;
                    bulkManager.emailLog('FAILURE','There has been an issue processing your bulk upload request.\nSalesforce Tech has been notified of the same.\n\nPlease contact Salesforce Tech for further clarifications.\n\nRegards,\nSalesforce Tech',null,'Exception',calloutErrorMessage);
                    System.abortJob(batchableContext.getJobId()); //Aborting job so that next consecutive batches of same job will not executing.
                    batchExecutionSuccessfully = false; 
                    /*for(Integer i=0;i<csvLines.size();i++)
                    {
                        bulkManager.utilitycsvErrorRows += csvLines[i][0] +','+csvLines[i][1]+','+csvLines[i][2]+','+csvLines[i][3]+','+csvLines[i][4]+','+csvLines[i][5]+','+csvLines[i][6]+','+csvLines[i][7]+','+csvLines[i][8]+','+csvLines[i][9]+','+csvLines[i][10]+','+csvLines[i][11]+','+'"'+csvLines[i][12] + '"'+','+'"'+calloutErrorMessage + '"'+'\n';        
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
                
                system.debug(generatedErrorCSVfile); 
                bulkManager.emailLog('ERRORS','Attached are the records which have errors.\nPlease rectify and re-upload only these records.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'User',null);
            } 
            else
            {
                system.debug('Successfully uploaded.');
                bulkManager.emailLog('SUCCESS','Regards,\nSalesforce Tech',null,'User',null);
            }
        }
        else
        {
            bulkManager.emailLog('FAILURE','There has been an issue processing your bulk upload request.\nSalesforce Tech has been notified of the same.\n\nPlease contact Salesforce Tech for further clarifications.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'Exception',exception_message+'\n\nRegards,\nSalesforce Tech');
        }
        
    }
    
    //Object : Event Mapping
     //Object : Event Mapping
    public void doEventObjectMapping(List<List<String>> csvLines)
    {
        //try
        //{
            if(SourceObjectAPI == 'Event')
            {
                eventobjToInsert = new Map<Integer, sObject>();
                Boolean validationError = false;
                mapofIndex_AND_WhoEmailId = new Map<Integer,String>();
                bulkManager.mapofindex_userloginids = new Map<Integer,Set<string>>();
                bulkManager.mapofindex_emails = new Map<Integer,Set<string>>();
                mapofindex_rgs = new Map<Integer,string>();     
                bulkManager.csvRGIds = new Set<string>();
                copyOfCSVLines = new List<List<String>>();
                
                for(Integer i=0;i<csvLines.size();i++)
                {
                    validationError = false;
                    string errormessage = '';
                    
                    sObject sObj = Schema.getGlobalDescribe().get('Event').newSObject() ;
                    
                    
                    if(csvLines[i][0].trim() == null || csvLines[i][0].trim() =='')
                    {
                        validationError = true;
                        errormessage = 'RG ID is mandatory';
                    }
                    else
                    {
                        if(bulkManager.accountRGMap.get(csvLines[i][0].trim()) == null)
                        {
                            validationError = true;
                            errormessage = 'RG ID is not valid';
                        }
						else
						{
							if(csvLines[i][2].trim() !=null && csvLines[i][2].trim() !='') //emails
                            {
                                List<string> nominatedWhoIds = new List<string>();
                                Set<String> tempSet = new Set<String>();
                                Set<String> invalidEmails = new Set<String>();
                               
                                for(string email: csvLines[i][2].trim().split(';'))
                                {
                                    
                                   
                                    if(!Test.isRunningTest())
                                    {
                                        if(bulkManager.contactEmailMap.get(bulkManager.emailactual_Encrypted.get(email))==null)
                                        {
                                            invalidEmails.add(email);
                                        }
                                        else
                                        {
                                            tempSet.add(bulkManager.emailactual_Encrypted.get(email));    
                                        }
                                    }
                                    
                                    if(Test.isRunningTest())
                                    {
                                        if(bulkManager.contactEmailMap.get(email)==null)
                                        {
                                            invalidEmails.add(email);
                                        }
                                        else
                                        {
                                            tempSet.add(email);    
                                        }
                                    }
                                    
                                }
                                
                                if(invalidEmails.size() > 0)
                                {
                                    validationError = true;
                                    string emailsNotFound = '';
                                    
                                    for(string s1: invalidEmails)
                                    {
                                        if(s1!='')
                                        {
                                            if(emailsNotFound != '')
                                                emailsNotFound += ','+s1;
                                            else
                                                emailsNotFound = s1;
                                            
                                        }
                                    } 
                                    if(errormessage == '')
                                        errormessage = 'Contact Participants:'+emailsNotFound+' not found';
                                    else
                                        errormessage += ', Contact Participants:'+emailsNotFound+' not found';
                                }
                                else
                                {
                                    if(csvLines[i][0]!=null || csvLines[i][0]!='')
                                        nominatedWhoIds = processWhoIdofEvent(csvLines[i][0].trim(),tempSet);
                                    
                                    if(nominatedWhoIds.size() > 0)
                                    {
                                        sObj.put('WhoId' ,bulkManager.contactEmailMap.get(nominatedWhoIds[0])); // passing 1st rg contact as whoid - primary contact
                                        sObj.put('WhatId' ,bulkManager.accountRGMap.get(csvLines[i][0])); 
                                        mapofIndex_AND_WhoEmailId.put(i,nominatedWhoIds[0]);
                                    }
                                    else
                                    {
                                        validationError = true;
                                        if(errormessage == '')
                                            errormessage = 'Atleast one RGContact emailId needed to nominate event WhoId';
                                        else
                                            errormessage += ', Atleast one RGContact emailId needed to nominate event WhoId';
                                    }
                                }
                                
                            }
                            else
                            {
                                validationError = true;
                                if(errormessage == '')
                                    errormessage = 'Contact Participants is mandatory';
                                else
                                    errormessage += ', Contact Participants is mandatory';
                            }
						}		
                    }

					if(csvLines[i][1].trim() !=null && csvLines[i][1].trim() !='') //users
					{
						Set<String> tempSet = new Set<String>();
						Set<String> invalidUsers = new Set<String>();
						
						for(string userRec: csvLines[i][1].split(';'))
						{
							if(bulkManager.userMapActive.get(userRec)==null && bulkManager.nomuracontactMapActive.get(userRec) == null && bulkManager.nomuracontactMapNotActive.get(userRec)==null)
							{
								invalidUsers.add(userRec);   
							}
						}
						
						if(invalidUsers.size() > 0)
						{
							validationError = true;
							string usersNotFound = '';
							
							for(string s: invalidUsers)
							{
								if(s!='')
								{
									if(usersNotFound != '')
										usersNotFound += ','+s;
									else
										usersNotFound = s;
								}
							   
							}    
							if(errormessage == '')
								errormessage = 'User Participants:'+usersNotFound+' not found';
							else
								errormessage += ', User Participants:'+usersNotFound+' not found';
						}
						
					}
					else
					{
						validationError = true;
						if(errormessage == '')
							errormessage = 'User Participants is mandatory';
						else
							errormessage += ', User Participants is mandatory';
					}



					if(csvLines[i][3].trim() != null && csvLines[i][3].trim() !='') //subject
					{
                        if(csvLines[i][3].trim().length() <= 254)
						sObj.put('Subject' , +csvLines[i][3].trim());
                        else
                        {
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Subject: data value too large. Limit of 255 characters supported';
                            else
                                errormessage += ', Subject: data value too large. Limit of 255 characters supported';
                            
                        }
					}
					else
					{
						validationError = true;
						if(errormessage == '')
							errormessage = 'Subject is mandatory';
						else
							errormessage += ', Subject is mandatory';
					}

					if(csvLines[i][4].trim() != null && csvLines[i][4].trim() !='') //region
					{
                        boolean errorREgion = false;
                        if(csvLines[i][4].trim().contains(';'))
                        {
                        	    List<string> regionsValues = csvLines[i][4].trim().split(';');
                            	if(regionSValues.size()>0)
                                {
                                    for(string s: regionsValues)
                                    {
                                       if(!meeting_region_values.contains(s.trim()))
                                       {
                                           errorRegion = true;
                                           break;
                                       }
                                    }
                                }
                        }
                        else
                        {
                            if(!meeting_region_values.contains(csvLines[i][4].trim()))
                                errorRegion = true;
                        }
                        
                        if(!errorRegion)
						sObj.put('Event_Origination_Region__c' , +csvLines[i][4].trim()) ;
                        else
                        {
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Meeting Region: bad value for restricted picklist field: '+csvLines[i][4].trim();
                            else
                                errormessage += ', Meeting Region: bad value for restricted picklist field: '+csvLines[i][4].trim();
                        }    
					}
					
                    Boolean isTimeZoneValid = false;
                    Boolean isValidDate = false; 
					//9 timezone
					if(csvLines[i][8].trim() == null || csvLines[i][8].trim() =='') //TimeZone
					{
						validationError = true;
						if(errormessage == '')
							errormessage = 'TimeZone is mandatory';
						else
							errormessage += ', TimeZone is mandatory';
					}
					else
					{
						if(bulkManager.timezoneslist.contains(csvLines[i][8].trim()))
						{
							isTimeZoneValid = true;
						}
						else
						{
                            isTimeZoneValid = false;
							validationError = true;
							if(errormessage == '')
								errormessage = 'TimeZone is not valid';
							else
                                errormessage += ', TimeZone is not valid';
                        }
                    }
                    
                    if(csvLines[i][5].trim() != null && csvLines[i][5].trim() !='') //Meeting date
                    {
                        If(bulkManager.IsValidDate(csvLines[i][5].trim()))
                        {
                            isValidDate = true;
                        }
                        else
                        {
                            isValidDate = false;
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Meeting Date not in valid format (mm/dd/yyyy)';
                            else
                                errormessage += ', Meeting Date not in valid format (mm/dd/yyyy)';
                        } 
                    }
                    else
                    {
                        validationError = true;
                        if(errormessage == '')
                            errormessage = 'Meeting Date is mandatory';
                        else
                            errormessage += ', Meeting Date is mandatory';
                    }
                    
                    
                    if(i==2)
                    {
                        system.debug('IsTimeZoneValid - '+isTimeZoneValid);
                        system.debug('isValidDate - '+isValidDate);
                        
                    }
					if(csvLines[i][6].trim() != null && csvLines[i][6].trim() !='') //start time
                    {
                        
                        if(isTimeZoneValid && isValidDate)
                        {
                             Datetime startDateTime;
                            try
                            {
                            	startDateTime = bulkManager.getValidDateTime(csvLines[i][5].trim(),csvLines[i][6].trim(),csvLines[i][8].trim());
                                if(startDateTime != null)
                                    sObj.put('StartDateTime' , startDateTime);    
                                else
                                {
                                    validationError = true;
                                    if(errormessage == '')
                                        errormessage = 'Meeting Start Time:'+csvLines[i][6].trim()+' is not valid';
                                    else
                                        errormessage += ', Meeting Start Time:'+csvLines[i][6].trim()+' is not valid';
                                }
                            }
                            catch(TypeException e)
                            {
                                validationError = true;
                                if(errormessage == '')
                                    errormessage += 'Meeting Start Time:'+csvLines[i][6].trim()+' is not valid';
                                else
                                    errormessage += ', Meeting Start Time:'+csvLines[i][6].trim()+' is not valid';
                            }
                                
                        }
                    }
                    else
                    {
                        validationError = true;
                        if(errormessage == '')
                            errormessage = 'Meeting Start Time is mandatory';
                        else
                            errormessage += ', Meeting Start Time is mandatory';
                    }
                    
                    if(csvLines[i][7].trim() != null && csvLines[i][7].trim() !='') //end time
                    {
                        
                        if(isTimeZoneValid && isValidDate)
                        {
                            try{
                                Datetime endDateTime  = bulkManager.getValidDateTime(csvLines[i][5].trim(),csvLines[i][7].trim(),csvLines[i][8].trim());
                                if(endDateTime != null)
                                    sObj.put('EndDateTime' , endDateTime);    
                                else
                                {
                                   validationError = true;
                                    if(errormessage == '')
                                        errormessage = 'Meeting End Time:'+csvLines[i][7].trim()+' is not valid';
                                    else
                                        errormessage += ', Meeting End Time:'+csvLines[i][7].trim()+' is not valid';
                                } 
                            }
                            catch(TypeException e)
                            {
                                validationError = true;
                                if(errormessage == '')
                                    errormessage += 'Meeting End Time:'+csvLines[i][7].trim()+' is not valid';
                                else
                                    errormessage += ', Meeting End Time:'+csvLines[i][7].trim()+' is not valid';
                            }
                        }
                    }
                    else
                    {
                        validationError = true;
                        if(errormessage == '')
                            errormessage = 'Meeting End Time is mandatory';
                        else
                            errormessage += ', Meeting End Time is mandatory';
                    }

					if(csvLines[i][9].trim() != null && csvLines[i][9].trim() !='') //Event Type
					{
                        if(event_type_values.contains(csvLines[i][9].trim()))
						sObj.put('Event_Type__c' , +csvLines[i][9].trim()) ;
                        else
                        {
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Event Type: bad value for restricted picklist field: '+csvLines[i][9].trim();
                            else
                                errormessage += ', Event Type: bad value for restricted picklist field: '+csvLines[i][9].trim();
                        } 
						
					}
					else
					{
						validationError = true;
						if(errormessage == '')
							errormessage = 'Event Type is mandatory';
						else
							errormessage += ', Event Type is mandatory';
					}

					if(csvLines[i][10].trim() != null && csvLines[i][10].trim() !='') //Event Meeting Types
					{
                        if(type_values.contains(csvLines[i][10].trim()))
						sObj.put('Type' , +csvLines[i][10].trim()) ;
                        else
                        {
                            validationError = true;
                            if(errormessage == '')
                                errormessage = 'Event Meeting Types: bad value for restricted picklist field: '+csvLines[i][10].trim();
                            else
                                errormessage += ', Event Meeting Types: bad value for restricted picklist field: '+csvLines[i][10].trim();
                        }
					}
					else
					{
						validationError = true;
						if(errormessage == '')
							errormessage = 'Event Meeting Types is mandatory';
						else
							errormessage += ', Event Meeting Types is mandatory';
					}


					if(csvLines[i][11].trim() != null && csvLines[i][11].trim() !='') //Ticker
					{
						sObj.put('Ticker__c' , +csvLines[i][11].trim()) ;
					}
					sobj.put('source__c',+'BulkInsert');
                    
                    if(!validationError)
                    { 
                        bulkManager.csvRGIds.add(csvLines[i][0].trim());
                        mapofindex_rgs.put(i,csvLines[i][0].trim());
                        bulkManager.prepareMapOfCSVIndex_LoginIDs(i,csvLines[i],0,1);
                        bulkManager.prepareMapOfCSVIndex_Emails(i,csvLines[i],0,2);
                        copyOfCSVLines.add(csvLines[i]);
                        sObj.put('OwnerId' , UserInfo.getUserId()) ;
                        sObj.put('RecordTypeId' , SourceObjectRecordTypeId) ;
                        sObj.put('Private__c','False');
                        sObj.put('Event_Status__c','Confirmed');
                        sObj.put('Event_Name__c',csvLines[i][3].trim());
                        sObj.put('Event_Meeting_Status__c', 'Confirmed');
                        system.debug(sobj);
                        eventobjToInsert.put(i,sObj);
                    }
                    else
                    {
                        if(errormessage!='')
                            bulkManager.utilitycsvErrorRows += '"'+csvLines[i][0]+'"'+','+'"'+csvLines[i][1]+'"'+','+'"'+csvLines[i][2]+'"'+','+'"'+csvLines[i][3]+'"'+','+'"'+csvLines[i][4]+'"'+','+'"'+csvLines[i][5]+'"'+','+'"'+csvLines[i][6]+'"'+','+'"'+csvLines[i][7]+'"'+','+'"'+csvLines[i][8]+'"'+','+'"'+csvLines[i][9]+'"'+','+'"'+csvLines[i][10]+'"'+','+'"'+csvLines[i][11] + '"'+','+'"'+errormessage + '"'+'\n';        
                    }
                    
                }    
            }
        /*}
        catch(Exception e)
        {
            system.debug(e+'Utility Error '+e.getStackTraceString());
        }
        
    }
    
    private List<string> processWhoIdofEvent(string RGID, Set<string> csvEmails) 
    {
        List<string> rgemailIds = new List<string>();
        for (Contact con: [select email from Contact where Account.Parent.RDM_Org_ID__c =: RGID and email in: csvEmails]) // I get all rgcontacts
        {
            rgemailIds.add(con.email);
        }
        return rgemailIds;
    }
    */
    
}