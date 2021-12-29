public without sharing class CallReportController {
    
    @AuraEnabled
    public static Boolean hasErrors {get;set;}
    @AuraEnabled
    public static List<Event> newCallReportList {get;set;}
    @AuraEnabled
    public static String detailedDescription {get;set;}
    @AuraEnabled
    public static String recordId {get;set;}
    @AuraEnabled
    public static Boolean isEquityUser {get;set;}
   
    @AuraEnabled
    public static List<String> internalInviteesSelected {get;set;}
    @AuraEnabled
    public static List<String> clientAttendeesSelected {get;set;}
    @AuraEnabled
    public static List<String> ricCodeSelected {get;set;}
    @AuraEnabled
    public static Map<String, Map<String, String>> labels {get;set;}
    @AuraEnabled
    public static Task_LTA__c callReportDetailedDescription {get;set;}
     @AuraEnabled
    public static String opportunityId {get; set;}
    //added for JIRA SALES-3510
    public static Set<String> lstCallType = new Set<String>{'SRM / Exec Meeting', 'General Meeting'};
    public static Set<String> lstAdminProfile = new Set<String>{'Nomura - Integration', 'System Administrator'};
    public static Profile Profilename {get;set;}
    
    public class UserDetails{
        @AuraEnabled
        public Boolean isEquityUserDetail{get; set;}
        @AuraEnabled
        public Boolean isJapanFIUserDetail{get; set;}
        @AuraEnabled
        public String userProfile{get; set;}    
        @AuraEnabled
        public Boolean IsAnalystUser{get; set;} 
        @AuraEnabled
        public Boolean isActiveSalesCodePresent{get; set;}        
    }
   
    //added for SALES JIRA -3510
    @AuraEnabled
    public static Boolean isAEJSalesUser(String l0Type, String l1Type, String assignedto) {
        Boolean isMandatory = false;  
        User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : assignedto];
        Boolean isValidUser = CommonTools.isAEJUser(userObj);
        if(isValidUser){
            if(Profilename == null)
                Profilename = [Select Id, Name From Profile Where Id =: UserInfo.getProfileId()];
                    
            system.debug('Calling user analyst:'+ assignedto);
            if(!lstAdminProfile.contains(Profilename.name) && lstCallType.contains(l0Type)){
                isMandatory = true;
            }                
        }
        return isMandatory;        
    }    

    @AuraEnabled
    public static String getUserDetails(){
        List<UserDetails> userDetailList = new List<UserDetails>();
        UserDetails userDetailObj = new UserDetails();
        User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : UserInfo.getUserId()];
        userDetailObj.isEquityUserDetail = CommonTools.isEquityUser(userObj);
        userDetailObj.isJapanFIUserDetail = CommonTools.isJapanFIUser(userObj);        
        userDetailObj.userProfile = userObj.Profile.Name;
        userDetailObj.IsAnalystUser = userObj.Is_Analyst__c;
        userDetailObj.isActiveSalesCodePresent = CommonTools.isActiveSalesCodePresent(userObj);

        userDetailList.add(userDetailObj);
                
        return JSON.serialize(userDetailList);
    }



    /**
* [initialiseLabels Returns nested map of field labels to aid Japanese translation]
* @return [Map<String, Map<String, String>>]
*/
    @AuraEnabled
    public static Map<String, Map<String, String>> initialiseLabels(){
        labels = new Map<String, Map<String, String>>();
        
        Map<String, List<String>> fieldsToGetLabelsMap = new Map<String, List<String>>();
        
        fieldsToGetLabelsMap.put('Event', new List<String>{'Subject', 'Type', 'L0_Type__c', 'Activity_Flag__c' , 'WhatId', 'WhoId', 'StartDateTime', 'EndDateTime', 'Ticker__c', 'IsPrivate' , 'IsAllDayEvent', 'Description', 'OwnerId','CI_Stage__c', 'DurationInMinutes', 'Sector__c', 'IBOR_Status__c'});
        
        labels = CommonTools.getSObjectFieldLabelMap(fieldsToGetLabelsMap); 
        
        return labels;
    }
    
    @AuraEnabled
    public static boolean isCapIntro(){
        List<PermissionSetAssignment> lstcurrentUserSet = [SELECT PermissionSet.Name from PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId()];
        
        boolean isCapIntro = false;        
        for(PermissionSetAssignment psa: lstcurrentUserSet){
            if(psa.PermissionSet.Name.equals('Cap_Intro')){
                isCapIntro = true;
                isEquityUser = true;
            }   
        }
        
        return isCapIntro;
        
        
    }   
    
    @AuraEnabled 
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        return PicklistFieldController.getDependentOptionsImpl(objApiName, contrfieldApiName, depfieldApiName);
    }
    @AuraEnabled
    public static List<String> getAllContactData(String myContactListSelect, String filters){
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        String device = 'DESKTOP';
        String filterCondition = CommonTools.createFilterCondition(filters, device);
        String query = 'SELECT ContactId FROM CampaignMember WHERE CampaignId = :myContactListSelect AND Active__c = true';
        
        if(String.isNotEmpty(filterCondition))
            query = query + ' AND ' + filterCondition;
        
        campaignMemberList = (List<CampaignMember>) Database.query(query);
        
        List<String> contactId = new List<String>();
        for(CampaignMember campaignMemberObj : campaignMemberList)
            contactId.add(campaignMemberObj.ContactId);
        return contactId;
    }    
    
    @AuraEnabled
    public static Map<String, String> saveNewEventBulk(Event e,List<String> internalInvitees, List<String> externalInvitees, 
                                                   String detailedDescription, String eventOwnerId, String strType){

        Map<String, String> resultsMap = new Map<String, String>();
        String campaignId = ''; 
        RecordType standardEventRecordType;
        List<Event> lstEventInsert = new List<Event>(); 
		List<Task_LTA__c> lstTaskLTAInsert = new List<Task_LTA__c>();
        Set<Id> setSavedEvents = new Set<Id>();	
        Map<Id, List<Id>> mapAccountCont = new Map<Id, List<Id>>();	 
        Map<Id,Id> mapAccountEvent = new Map<Id,Id>();		
        try{
            standardEventRecordType = [Select Id, DeveloperName 
                                                    From RecordType 
                                                    Where (DeveloperName = 'Standard_Event' AND sObjectType = 'Event')];
            
			if(externalInvitees.size() > 0){
			    for(Contact con: [SELECT Id,Account.RDM_ORG_ID__c,AccountId,RG_Account__c FROM Contact where Id IN: externalInvitees]){
                    System.debug('****** Save New Event con****' + con);
                    Event newEvent;
                    if(strType == 'By Contact'){
						newEvent = new Event();						
				    }
					else{
					    if(!mapAccountCont.containsKey(con.RG_Account__c)){
						    newEvent = new Event();							
						    //add to map to not duplicate
                            List<Id> lstContact = new List<Id> ();
                            lstContact.add(con.Id);
						    mapAccountCont.put(con.RG_Account__c, lstContact);
						}
						else{
						    List<Id> lstcon = mapAccountCont.get(con.RG_Account__c);
							lstcon.add(con.Id);
							mapAccountCont.put(con.RG_Account__c, lstcon);
						}
					}
                    if(newEvent != null){
                            //added for SALES-3119
                            newEvent.WhoId = con.Id;
                            newEvent.Activity_Flag__c = e.Activity_Flag__c;
                            newEvent.L0_Type__c = e.L0_Type__c;                            
							newEvent.OwnerId = eventOwnerId;//check with team
							newEvent.StartDateTime = e.StartDateTime;
							newEvent.EndDateTime = e.EndDateTime;
                        	newEvent.Type = e.Type;
                            newEvent.Subject = e.Subject;
							newEvent.Private_Flag__c = e.Private_Flag__c;
                            newEvent.BlueFire_Signal__c = e.BlueFire_Signal__c;
                            if(e.Private_Flag__c == true){
                                newEvent.Private__c = 'True';    
                            }else{
                               newEvent.Private__c = 'False'; 
                            }
							newEvent.IsAllDayEvent = e.IsAllDayEvent;
							newEvent.Ticker__c = e.Ticker__c;
                            newEvent.Sector__c = e.Sector__c;
							newEvent.Description = e.Description;
							newEvent.Create_Type__c = Label.Event_Call_Report_Notes_Non_Cap_Intro;                                               
							if(standardEventRecordType != null){
								newEvent.RecordTypeId = standardEventRecordType.Id;
							}                                                   
							newEvent.WhatId = con.RG_Account__c;
                            newEvent.IBOR_Status__c = e.IBOR_Status__c;
							lstEventInsert.add(newEvent); 
                    }
				}
				if(lstEventInsert.size()>0){
				    Database.SaveResult[] srList = Database.Insert(lstEventInsert, false);
					// Iterate through each returned result				
	                for (Database.SaveResult sr : srList) {
						if (sr.isSuccess()) {
						    if(detailedDescription != null && detailedDescription.length() > 0){
                                Task_LTA__c tsk = new Task_LTA__c();
                                tsk.LTA_1__c = detailedDescription;
                                tsk.Parent_Task__c = sr.getId();								
                                lstTaskLTAInsert.add(tsk);  
                                }
                            setSavedEvents.add(sr.getId());                             
						}
						else{
                            // Operation failed, so get all errors
                             for(Database.Error err : sr.getErrors()) {
                                    resultsMap.put('Error', err.getMessage()); 
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Fields that affected this error: ' + err.getFields());
                             }
                        }
					}
					if(lstTaskLTAInsert.size() > 0)
					    insert lstTaskLTAInsert;                    
                    //create invitees for the events in bulk                    
                    if(setSavedEvents.size()>0){
					   createInviteeEventRelationsBulk(externalInvitees, internalInvitees, setSavedEvents, eventOwnerId,mapAccountCont,strType); 
                       resultsMap.put('Success', 'Records Saved Sucessfully');
                    }
                }
			    
			}
        }catch(Exception ex){
            system.debug(' Error: ' +  ex.getMessage());
            //resultsMap.put('Error', ex.getMessage()); 
        }
            return resultsMap;
    }
    @AuraEnabled
    public static Map<String, String> saveNewEvent(Event e,List<String> internalInvitees, List<String> externalInvitees, 
                                                   String detailedDescription, String eventOwnerId, List<String> contactIdData, 
                                                   Boolean activityFlag, String activityType, Boolean selectAllCheckboxValue, String myContactListSelect, String filters){                                                      
                                                       Savepoint sp = Database.setSavepoint();
                                                       Map<String, String> resultsMap = new Map<String, String>();
                                                       String campaignId = ''; 
                                                       RecordType standardEventRecordType;
                                                       RecordType standardMassActivityRecordType;    
                                                       RecordType noDirectClientInteractionRecordType;
                                                       final String voicemailCampaignType = 'Voicemail';
                                                       final String modelRequestCampaignType = 'Model Request';  
                                                       final String noDirectClientInteractionEventType = 'No Direct Client Interaction';
                                                       
                                                       try{
                                                           RecordType[] standardRecordTypeArray = [Select Id, DeveloperName 
                                                                                                   From RecordType 
                                                                                                   Where (DeveloperName = 'Standard_Event' AND sObjectType = 'Event')
                                                                                                   OR (DeveloperName = 'Mass_Activity' AND sObjectType = 'Campaign')
                                                                                                   OR (DeveloperName = 'No_Direct_Client_Interaction' AND sObjectType = 'Event')];
                                                           
                                                           for(RecordType standardRecordType : standardRecordTypeArray){
                                                               if('Standard_Event'.equalsIgnoreCase(standardRecordType.DeveloperName)){
                                                                   standardEventRecordType = standardRecordType;
                                                               }
                                                               else if('Mass_Activity'.equalsIgnoreCase(standardRecordType.DeveloperName)){
                                                                   standardMassActivityRecordType = standardRecordType;
                                                               }
                                                               else if('No_Direct_Client_Interaction'.equalsIgnoreCase(standardRecordType.DeveloperName)){
                                                                   noDirectClientInteractionRecordType = standardRecordType;
                                                               }
                                                           }
                                                           
                                                           if(activityFlag == true){
                                                               Campaign newCampaign = new Campaign();
                                                               
                                                               newCampaign.Name = e.Subject;
                                                               
                                                               if(standardMassActivityRecordType != null){
                                                                   newCampaign.RecordTypeId = standardMassActivityRecordType.Id;
                                                               }  
                                                               
                                                               newCampaign.Type = activityType;            
                                                               newCampaign.IsActive = true;
                                                               
                                                               DateTime startDateTime = e.StartDateTime;
                                                               newCampaign.StartDate = startDateTime.date();
                                                               
                                                               DateTime endDateTime = e.EndDateTime;
                                                               newCampaign.EndDate = endDateTime.date();
                                                               
                                                               newCampaign.StartDateTime__c = e.StartDateTime;
                                                               newCampaign.EndDateTime__c = e.EndDateTime;
                                                               
                                                               newCampaign.OwnerId = eventOwnerId;
                                                               newCampaign.Ticker__c = e.Ticker__c;
                                                               
                                                               Database.SaveResult campaignSaveResult = Database.insert(newCampaign, false); 
                                                               
                                                               if (campaignSaveResult.isSuccess()) {
                                                                   // Operation was successful, so get the ID of the record that was processed
                                                                
                                                                   resultsMap.put('Campaign ID', campaignSaveResult.getId());
                                                               }
                                                               else {
                                                                   // Operation failed, so get all errors                
                                                                   for(Database.Error err : campaignSaveResult.getErrors()) {
                                                                       resultsMap.put('Error', err.getStatusCode() + ': ' + err.getMessage());                 
                                                                   }
                                                               }
                                                               campaignId += campaignSaveResult.getId();
                                                               
                                                               //For insertingCampaignMember into newly created campaign
                                                               insertCampaignMember(campaignId, contactIdData, myContactListSelect, selectAllCheckboxValue, filters);
                                                           }
                                                           
                                                           Event newEvent = new Event();
                                                           System.debug('---before newEvent.L0_Type__c---' + e.L0_Type__c);
                                                           newEvent.OwnerId = eventOwnerId;
                                                           newEvent.StartDateTime = e.StartDateTime;
                                                           newEvent.EndDateTime = e.EndDateTime;
                                                           newEvent.Activity_Flag__c = e.Activity_Flag__c;
                                                           newEvent.IBOR_Status__c = e.IBOR_Status__c;
                                                           newEvent.L0_Type__c = e.L0_Type__c;
                                                           newEvent.Type = e.Type;                                                           
                                                           newEvent.Subject = e.Subject;
                                                           newEvent.Private_Flag__c = e.Private_Flag__c;
                                                           newEvent.IsAllDayEvent = e.IsAllDayEvent;
                                                           newEvent.Ticker__c = e.Ticker__c;
                                                           newEvent.Sector__c = e.Sector__c;
                                                           newEvent.Description = e.Description;
                                                           
                                                           newEvent.BlueFire_Signal__c = e.BlueFire_Signal__c;
                                                           
                                                           if(e.Private_Flag__c == true){
                                                               newEvent.Private__c = 'True';    
                                                           }else{
                                                               newEvent.Private__c = 'False';
                                                           }
                                                           
                                                           if(isCapIntro()){
                                                          newEvent.CI_Stage__c = e.CI_Stage__c; 
                                                          newEvent.Create_Type__c = e.Create_Type__c;
                                                          newEvent.Fund__c = e.Fund__c;                                                               
                                                           if(newEvent.Create_Type__c != Label.Event_Call_Report_Notes_Non_Cap_Intro){                                                               
                                                               newEvent.Private__c = 'False';
                                                           }
                                                           else{
                                                           }
                                                           
                                                      }
                                                           else
                                                           {
                                                               newEvent.Create_Type__c = Label.Event_Call_Report_Notes_Non_Cap_Intro;
                                                           }
                                                      
                                                           if(externalInvitees.size() > 0){
                                                               
                                                               newEvent.WhoId = externalInvitees[0];
                                                               List<Contact> ctext = new List<Contact>();
                                                               List<Contact> cint = new List<Contact>();
                                                                if(newEvent.Create_Type__c != Label.Event_Call_Report_Notes_Non_Cap_Intro){
                                                               ctext = [SELECT Id,Account.RDM_ORG_ID__c FROM Contact where Id=:newEvent.WhoId];
                                                                    if(internalInvitees.size() >0){
                                                               cint = [SELECT Id,Account.RDM_ORG_ID__c FROM Contact where Id=:internalInvitees[0]];
                                                                    }
                                                                    if(cint.size() > 0){
                                                                        newEvent.Rep_Name__c = ctext[0].Account.RDM_ORG_ID__c +','+cint[0].Account.RDM_ORG_ID__c ;
                                                                    }
                                                                }
                                                           }
                                                           
                                                           if(standardEventRecordType != null && !(noDirectClientInteractionEventType.equalsIgnoreCase(e.Type)) ){
                                                               newEvent.RecordTypeId = standardEventRecordType.Id;
                                                           }
                                                           else if(noDirectClientInteractionRecordType != null && noDirectClientInteractionEventType.equalsIgnoreCase(e.Type)){
                                                               newEvent.RecordTypeId = noDirectClientInteractionRecordType.Id;
                                                           }
                                                           
                                                           if(activityFlag != true){
                                                               newEvent.WhatId = e.WhatId;
                                                           }else{
                                                               newEvent.WhatId = campaignId;
                                                           }
                                                           
                                                           Database.SaveResult eventSaveResult = Database.insert(newEvent, false);
                                                           
                                                           if (eventSaveResult.isSuccess()) {
                                                               // Operation was successful, so get the ID of the record that was processed
                                                               
                                                               resultsMap.put('Event ID', eventSaveResult.getId());
                                                               
                                                               if(detailedDescription != null && detailedDescription.length() > 0){
                                                                   Task_LTA__c t = new Task_LTA__c();
                                                                   t.LTA_1__c = detailedDescription;
                                                                   t.Parent_Task__c = eventSaveResult.getId();
                                                                   
                                                                   insert t;  
                                                                   
                                                               }
                                                                                                                              
                                                           createExternalInviteeEventRelations(externalInvitees,internalInvitees, newEvent.Id);
                                                         if(newEvent.Create_Type__c == Label.Event_Call_Report_Notes_Non_Cap_Intro){
                                                          updateEventRelationsforInternalContacts(internalInvitees, newEvent.Id, newEvent.OwnerId);
                                                          }
                                                               
                                                              // createExternalInviteeEventRelations(externalInvitees, newEvent.Id);
                                                              // updateEventRelationsforInternalContacts(internalInvitees, newEvent.Id, newEvent.OwnerId);
                                                           }else{
                                                               // Operation failed, so get all errors                
                                                               for(Database.Error err : eventSaveResult.getErrors()) {
                                                                   
                                                                   resultsMap.put('Error', err.getMessage()); 
                                                                   Database.rollback(sp);
                                                                   //resultsMap.put('Error', err.getStatusCode() + ': ' + err.getMessage());                 
                                                                   
                                                               }
                                                           }
                                                       }catch(Exception ex){
                                                           system.debug(' Error: ' +  ex.getMessage());
                                                       }
                                                       
                                                       return resultsMap;
                                                       
                                                   }
    
    @AuraEnabled
    public static Map<String, String> updateEvent(Event e, List<String> internalInvitees, List<String> externalInvitees, String detailedDescription, 
                                                  String eventOwnerId,  List<String> contactIdData , 
                                                  Boolean activityFlag, Boolean selectAllCheckboxValue, String myContactListSelect, String filters){
                                                      Savepoint sp = Database.setSavepoint();
                                                      Map<String, String> resultsMap = new Map<String, String>();
                                                      String result = '';
                                                      String campaignId = '';
                                                      RecordType standardEventRecordType;
                                                      RecordType standardMassActivityRecordType;    
                                                      RecordType noDirectClientInteractionRecordType;
                                                      final String voicemailCampaignType = 'Voicemail';
                                                      final String modelRequestCampaignType = 'Model Request';  
                                                      final String noDirectClientInteractionEventType = 'No Direct Client Interaction';
                                                      List<CampaignMember> campaignMemberList = new List<CampaignMember>();
                                                      Event newEvent = new Event();
                                                      newEvent.Id = e.Id;
                                                      newEvent.WhatId = e.WhatId;
                                                      newEvent.OwnerId = eventOwnerId;
                                                      
                                                      RecordType[] standardRecordTypeArray = [Select Id, DeveloperName 
                                                                                                   From RecordType 
                                                                                                   Where (DeveloperName = 'Standard_Event' AND sObjectType = 'Event')
                                                                                                   OR (DeveloperName = 'Mass_Activity' AND sObjectType = 'Campaign')
                                                                                                   OR (DeveloperName = 'No_Direct_Client_Interaction' AND sObjectType = 'Event')];
                                                           
                                                        for(RecordType standardRecordType : standardRecordTypeArray){
                                                            if('Standard_Event'.equalsIgnoreCase(standardRecordType.DeveloperName)){
                                                                standardEventRecordType = standardRecordType;
                                                            }
                                                            else if('Mass_Activity'.equalsIgnoreCase(standardRecordType.DeveloperName)){
                                                                standardMassActivityRecordType = standardRecordType;
                                                            }
                                                            else if('No_Direct_Client_Interaction'.equalsIgnoreCase(standardRecordType.DeveloperName)){
                                                                noDirectClientInteractionRecordType = standardRecordType;
                                                            }
                                                        }

                                                      if(externalInvitees.size() > 0){
                                                          newEvent.WhoId = externalInvitees[0];
                                                                                                       List<Contact> ctext = new List<Contact>();
                                                               List<Contact> cint = new List<Contact>();
                                                                if(newEvent.Create_Type__c != Label.Event_Call_Report_Notes_Non_Cap_Intro){
                                                               ctext = [SELECT Id,Account.RDM_ORG_ID__c FROM Contact where Id=:newEvent.WhoId];
                                                                    if(internalInvitees.size() >0){
                                                               cint = [SELECT Id,Account.RDM_ORG_ID__c FROM Contact where Id=:internalInvitees[0]];
                                                                    }
                                                                    if(cint.size() > 0){
                                                                        newEvent.Rep_Name__c = ctext[0].Account.RDM_ORG_ID__c +','+cint[0].Account.RDM_ORG_ID__c ;
                                                                    }
                                                                    
                                                               
                                                                }
                                                      }
                                                      newEvent.Activity_Flag__c = e.Activity_Flag__c;
                                                      newEvent.IBOR_Status__c = e.IBOR_Status__c;
                                                      newEvent.L0_Type__c = e.L0_Type__c;
                                                      newEvent.StartDateTime = e.StartDateTime;
                                                      newEvent.EndDateTime = e.EndDateTime;
                                                      newEvent.Type = e.Type;
                                                      newEvent.Subject = e.Subject;
                                                      newEvent.Private_Flag__c = e.Private_Flag__c;
                                                      newEvent.IsAllDayEvent = e.IsAllDayEvent;
                                                      newEvent.Ticker__c = e.Ticker__c;
                                                      newEvent.Sector__c = e.Sector__c;
                                                      newEvent.Description = e.Description;                                                       
                                                      newEvent.BlueFire_Signal__c = e.BlueFire_Signal__c;
                                                      
                                                      if(e.Private_Flag__c == true){
                                                          newEvent.Private__c = 'True';    
                                                      }else{
                                                          newEvent.Private__c = 'False';
                                                      }
                                                                                                            
                                                      if(isCapIntro()){
                                                          newEvent.CI_Stage__c = e.CI_Stage__c; 
                                                          newEvent.Create_Type__c = e.Create_Type__c;
                                                          newEvent.Fund__c = e.Fund__c;
                                                           if(newEvent.Create_Type__c != Label.Event_Call_Report_Notes_Non_Cap_Intro){
                                                               newEvent.WhatId = null;
                                                               newEvent.Private__c = 'False';
                                                           }
                                                          else{
                                                          }
                                                      }
                                                       else
                                                           {
                                                               newEvent.Create_Type__c = Label.Event_Call_Report_Notes_Non_Cap_Intro;
                                                           }
                                                      if(standardEventRecordType != null && !(noDirectClientInteractionEventType.equalsIgnoreCase(e.Type)) ){
                                                               newEvent.RecordTypeId = standardEventRecordType.Id;
                                                           }
                                                           else if(noDirectClientInteractionRecordType != null && noDirectClientInteractionEventType.equalsIgnoreCase(e.Type)){
                                                               newEvent.RecordTypeId = noDirectClientInteractionRecordType.Id;
                                                           }
                                                      Database.SaveResult updateEventResult = Database.update(newEvent, false);
                                                      if (updateEventResult.isSuccess()) {
                                                          // Operation was successful, so get the ID of the record that was processed
                                                      
                                                          
                                                          resultsMap.put('Event ID', updateEventResult.getId());
                                                          
                                                          if(detailedDescription != null && detailedDescription.length() > 0){
                                                              List<Task_LTA__c> t = [Select Id, LTA_1__c, Parent_Task__c
                                                                                     From Task_LTA__c
                                                                                     Where Parent_Task__c = :updateEventResult.getId()];
                                                              
                                                              if(t.size() > 0){
                                                                  t[0].LTA_1__c = detailedDescription;
                                                                  update t;
                                                              }else{
                                                                  Task_LTA__c taskLTA = new Task_LTA__c();
                                                                  
                                                                  taskLTA.LTA_1__c = detailedDescription;
                                                                  taskLTA.Parent_Task__c = updateEventResult.getId();
                                                                  
                                                                  insert taskLTA;
                                                              } 
                                                              
                                                          }
                                                          
                                                          if(activityFlag == true){
                                                              Campaign newCampaign = new Campaign();
                                                              newCampaign.Id = e.WhatId;
                                                              newCampaign.Name = e.Subject;
                                                              newCampaign.IsActive = true;
                                                              DateTime startDateTime = e.StartDateTime;               
                                                              newCampaign.StartDate = startDateTime.date();
                                                              DateTime endDateTime = e.EndDateTime;
                                                              newCampaign.EndDate = endDateTime.date();
                                                              newCampaign.StartDateTime__c = e.StartDateTime;
                                                              newCampaign.EndDateTime__c = e.EndDateTime;
                                                              newCampaign.OwnerId = eventOwnerId;
                                                              newCampaign.Ticker__c = e.Ticker__c;
                                                              
                                                              Database.SaveResult updateCampaignResult = Database.update(newCampaign, false);
                                                              if (updateCampaignResult.isSuccess()) {
                                                                  resultsMap.put('Campaign ID', updateCampaignResult.getId());
                                                              }
                                                              else{
                                                                  for(Database.Error err : updateCampaignResult.getErrors()) {
                                                                      resultsMap.put('Error', err.getStatusCode() + ': ' + err.getMessage());                 
                                                                  }
                                                              }
                                                              
                                                              campaignId += updateCampaignResult.getId();
                                                              
                                                              insertCampaignMember(campaignId, contactIdData, myContactListSelect, selectAllCheckboxValue, filters);                
                                                          }
                                                          
                                                          createExternalInviteeEventRelations(externalInvitees,internalInvitees, newEvent.Id);
                                                          
                                                         if(newEvent.Create_Type__c == Label.Event_Call_Report_Notes_Non_Cap_Intro){
                                                          updateEventRelationsforInternalContacts(internalInvitees, newEvent.Id, newEvent.OwnerId);
                                                          }
                                                      }else{               
                                                          for(Database.Error err : updateEventResult.getErrors()) {
                                                              
                                                              resultsMap.put('Error', err.getMessage()); 
                                                              Database.rollback(sp);
                                                              
                                                          }
                                                      }
                                                      return resultsMap; 
                                                      
                                                  }
    
    @AuraEnabled
    public static Task_LTA__c initialiseDetailedDescription(String recordId){
        callReportDetailedDescription = new Task_LTA__c();
        callReportDetailedDescription.LTA_1__c = '';
        //New Record
        if(recordId == null || recordId.length() == 0 || recordId.startsWith('001') || recordId.startsWith('701')|| recordId.startsWith('006') || recordId.startsWith('003') ){
            callReportDetailedDescription.LTA_1__c = '';
            
        }else{
            List<Task_LTA__c> detailedDescription = [Select Id, LTA_1__c, Parent_Task__c
                                                     From Task_LTA__c
                                                     Where Parent_Task__c = :recordId
                                                     Limit 1];        
            
            if(detailedDescription.size() == 0 || detailedDescription == null){
                callReportDetailedDescription.LTA_1__c = '';
            }else{
                callReportDetailedDescription.LTA_1__c = detailedDescription[0].LTA_1__c;
            }
        }
        return callReportDetailedDescription;
        
        
    }
    
    @AuraEnabled
    public static Event initialiseNewCallReport(String recordId, Boolean isClientMemo, Boolean saveNewCheck){
        newCallReportList = new List<Event>();
        Event newCallReport = new Event();
        final String userId = UserInfo.getUserId();

        if(recordId == null || recordId.length() == 0 || recordId.startsWith('001') || 
            recordId.startsWith('701')|| recordId.startsWith('006') || recordId.startsWith('003')){
                     
            User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : UserInfo.getUserId()];
            Boolean isJapanFIUser = CommonTools.isJapanFIUser(userObj); 
            Boolean userIsAnalyst = userObj.Is_Analyst__c;

            System.debug('---isJapanFIUser--' + isJapanFIUser) ;
            System.debug('---userIsAnalyst--' + userIsAnalyst) ;
            //if its save&new is clicked retrive last Activity details
            if(saveNewCheck || isJapanFIUser){
                String query = 'Select Subject, Type, L0_Type__c, Activity_Flag__c, IBOR_Status__c, StartDateTime,  EndDateTime, ' 
                                + ' IsAllDayEvent,  Ticker__c, Sector__c,  BlueFire_Signal__c, Create_Type__c, CI_Stage__c,Fund__c, RecordTypeId, OwnerId '
                                + ' From Event ' 
                                + ' WHERE ';

                if(isClientMemo && isJapanFIUser)
                    query += ' RecordType.DeveloperName = \'No_Direct_Client_Interaction\' AND ';
                else if(!isClientMemo && isJapanFIUser)
                    query += ' RecordType.DeveloperName = \'Standard_Event\' AND ';
                //when users clicks save&new then values should be retained, so last modified event should be displayed by default
                if(saveNewCheck)
                    query += ' CreatedById = :userId AND isChild = false Order By LastModifiedDate DESC Limit 1';
                else
                    query += ' OwnerId = :userId AND isChild = false Order By CreatedDate DESC Limit 1';
           
                newCallReportList = Database.query(query);

                //users recently created event found. so populate fetched values
                if(newCallReportList != null && newCallReportList.size() > 0){                    
                    for(Event eventObj : newCallReportList){
                        DateTime startDate = datetime.now();
                        newCallReport.Subject = eventObj.Subject;
                        newCallReport.Type = eventObj.Type;
                        newCallReport.L0_Type__c = eventObj.L0_Type__c;
                        newCallReport.Activity_Flag__c = eventObj.Activity_Flag__c;
                        newCallReport.IBOR_Status__c = eventObj.IBOR_Status__c;
                        newCallReport.StartDateTime = startDate;
                        newCallReport.EndDateTime = startDate.addHours(1);
                        newCallReport.IsAllDayEvent = false;
                        newCallReport.Create_Type__c = eventObj.Create_Type__c;
                        newCallReport.CI_Stage__c = eventObj.CI_Stage__c;
                        newCallReport.Fund__c = eventObj.Fund__c;   
                        newCallReport.RecordTypeId =eventObj.RecordTypeId; 
                        newCallReport.OwnerId = eventObj.OwnerId;                                   
                    }                   
                    newCallReportList.add(newCallReport);
                }
                else{
                    // user creating event for first time. so populate default values
                    for(Event eventObj : newCallReportList){
                        DateTime startDate = datetime.now();
                        newCallReport.Subject = eventObj.Subject;
                        newCallReport.Type = eventObj.Type;
                        newCallReport.L0_Type__c = eventObj.L0_Type__c;
                        newCallReport.Activity_Flag__c = eventObj.Activity_Flag__c;
                        newCallReport.IBOR_Status__c = eventObj.IBOR_Status__c; //TODO: Check for this
                        newCallReport.StartDateTime = startDate;
                        newCallReport.EndDateTime = startDate.addHours(1);
                        newCallReport.IsAllDayEvent = false;
                        newCallReport.Create_Type__c = eventObj.Create_Type__c;
                        newCallReport.CI_Stage__c = eventObj.CI_Stage__c;
                        newCallReport.Fund__c = eventObj.Fund__c;                   
                        
                    }
               
                    if(userIsAnalyst )
                        newCallReport.Type = 'Analyst Meeting';
                    else 
                        newCallReport.Type = 'Sales Meeting';
                    if(isClientMemo)
                        newCallReport.Type = 'No Direct Client Interaction';
                    
                    newCallReport.OwnerId = Userinfo.getUserId();
                    
                    RecordType standardEventRecordType = [Select Id, DeveloperName 
                                                            From RecordType 
                                                            Where DeveloperName = 'Standard_Event'];
                    if(standardEventRecordType != null){
                        newCallReport.RecordTypeId = standardEventRecordType.Id;
                    }
                    System.debug('--- else --' + newCallReport);
                    newCallReportList.add(newCallReport);
                }

            }
            else{
                //default value for other than Japan users
                DateTime startDate = datetime.now();
                newCallReport.WhatId = null;
                newCallReport.StartDateTime = startDate;
                newCallReport.EndDateTime = startDate.addHours(1);
                newCallReport.IsPrivate = false;
                newCallReport.Description = '';
                newCallReport.Subject = '';
                newCallReport.Ticker__c = '';
                newCallReport.Sector__c = '';
                newCallReport.Activity_Flag__c = null;
                newCallReport.IBOR_Status__c = null;
                newCallReport.L0_Type__c = null;
                newCallReport.IsAllDayEvent = false;
                internalInviteesSelected = new List<String>();
                clientAttendeesSelected = new List<String>();
                newCallReport.Create_Type__c = null;
                newCallReport.CI_Stage__c = null;
                newCallReport.Fund__c = null;      

                if(userIsAnalyst)
                    newCallReport.Type = 'Analyst Meeting';
                else
                    newCallReport.Type = 'Sales Meeting';
                if(isClientMemo)
                    newCallReport.Type = 'No Direct Client Interaction';
                
                newCallReport.OwnerId = Userinfo.getUserId();
                
                RecordType standardEventRecordType = [Select Id, DeveloperName 
                                                        From RecordType 
                                                        Where DeveloperName = 'Standard_Event'];
                if(standardEventRecordType != null){
                    newCallReport.RecordTypeId = standardEventRecordType.Id;
                }
                System.debug('---normal user else --' + newCallReport);
                newCallReportList.add(newCallReport);     
            }
        }
        else{
            newCallReport = [Select Id, OwnerId, Type, Activity_Flag__c, IBOR_Status__c, L0_Type__c,StartDateTime, Private_Flag__c, EndDateTime, IsPrivate, Description,
                             Subject, IsAllDayEvent, WhatId, Ticker__c, Sector__c, WhoId, BlueFire_Signal__c,Create_Type__c,CI_Stage__c,Fund__c
                             From Event 
                             Where Id = :recordId
                             Limit 1];
        }
        System.debug('---newCallReportList--' + newCallReportList);
        System.debug('---newCallReport--' + newCallReport);          
        return newCallReport;
    }
       
    public static void createInviteeEventRelationsBulk(List<String> externalInvitees,List<String> internalInvitees, Set<Id> eventIds, Id eventOwnerId, Map<Id,List<Id>> mapAccountContact , String strType){
	    
		List<EventRelation> relationsToInsertexternal = new List<EventRelation>();
		List<EventRelation> relationsToInsertinternal = new List<EventRelation>();        
        List<EventRelation> existingRelations = new List<EventRelation>();
        List<EventRelation> existingRelationToDelete = new List<EventRelation>();
        if(strType == 'By Account'){
            Map<Id, Contact> nomuraEmployeeMap =  new Map<Id, Contact>([SELECT Id 
                                                                        FROM Contact 
                                                                        WHERE 
                                                                        Id IN (SELECT RelationId 
                                                                               From EventRelation 
                                                                               WHERE EventId IN: eventIds)  
                                                                        and Account.Parent.RDM_ORG_ID__c = 'CPG12345']); 
            
            Map<Id, User> userIdMap = new Map<Id, User>([SELECT Id 
                                                         FROM User 
                                                         WHERE Id IN (SELECT RelationId 
                                                                      FROM EventRelation 
                                                                      WHERE EventId IN:eventIds) ]);        
            
            existingRelations = [Select Id, RelationId, EventId
                                 From EventRelation
                                 Where EventId IN : eventIds];
            
            if(existingRelations.size() > 0){
                for(EventRelation er : existingRelations){
                    String relationId = er.RelationId;
                    
                    if(relationId.startsWith('003') && userIdMap.containsKey(relationId) == false && nomuraEmployeeMap.containsKey(relationId) == false){
                           existingRelationToDelete.add(er);
                       }
                }
                
                if(existingRelationToDelete.size() > 0) {
                    delete existingRelationToDelete;
                }
            }
        }        
		for(Event evt : [Select Id, Subject, WhatId, WhoId from Event where Id IN: eventIds]){
            
		    //grouping account 
		    if(strType == 'By Account'){
			    List<Id> lstContacts = mapAccountContact.get(evt.WhatId);
                for(Id s : lstContacts){
					EventRelation er = new EventRelation();
					er.RelationId = s ;
					er.EventId = evt.Id;
					er.IsWhat =false;
					er.IsParent = true;
                    if(lstContacts.size() > 1){
					    er.IsInvitee = true;                       
                    }
					relationsToInsertexternal.add(er);
				}
				
			}
			
			//common logic			
			if(internalInvitees != null && internalInvitees.size()>0){
					for(String s : internalInvitees){                                                
						  if( s != '' && eventOwnerId != s ){
							EventRelation  er= new EventRelation();
							er.RelationId = s ;
							er.eventId = evt.Id;
							er.IsWhat =false;
							er.IsParent = false; 
							//er.IsInvitee = true;
							relationsToInsertinternal.add(er);
						  }
					}					
				}
		}
		if(relationsToInsertexternal.size() > 0)
			insert relationsToInsertexternal;
	    if(relationsToInsertinternal.size() > 0)
			insert relationsToInsertinternal;
		
		
	}
    public static void createExternalInviteeEventRelations(List<String> externalInvitees,List<String> internalInvitees, Id eventId){
       
        List<EventRelation> existingRelations = new List<EventRelation>();
        List<EventRelation> existingRelationToDelete = new List<EventRelation>();
        
        Map<Id, Contact> nomuraEmployeeMap =  new Map<Id, Contact>([SELECT Id 
                                                                    FROM Contact 
                                                                    WHERE 
                                                                    Id IN (SELECT RelationId 
                                                                           From EventRelation 
                                                                           WHERE EventId=:eventId)  
                                                                    and Account.Parent.RDM_ORG_ID__c = 'CPG12345']); 
        
        Map<Id, User> userIdMap = new Map<Id, User>([SELECT Id 
                                                     FROM User 
                                                     WHERE Id IN (SELECT RelationId 
                                                                  FROM EventRelation 
                                                                  WHERE EventId=:eventId) ]);
        
        
        
        
        existingRelations = [Select Id, RelationId, EventId
                             From EventRelation
                             Where EventId = : EventId];
        
        List<Event> eventUnderProcess = [Select Id,Create_Type__c From Event where Id=: eventId];
        
        if(existingRelations.size() > 0){
            for(EventRelation er : existingRelations){
                String relationId = er.RelationId;
                
                if(relationId.startsWith('003') && 
                   userIdMap.containsKey(relationId) == false && 
                   nomuraEmployeeMap.containsKey(relationId) == false){
                       existingRelationToDelete.add(er);
                   }
            }
            
            if(existingRelationToDelete.size() > 0) {
                delete existingRelationToDelete;
            }
        }
        
        List<EventRelation> relationsToInsert = new List<EventRelation>();
        
        for(String s : externalInvitees){
            EventRelation er = new EventRelation();
            er.RelationId = s ;
            er.EventId = eventId;
            er.IsWhat =false;
            er.IsParent = true;
            if(externalInvitees.size() > 1)
                er.IsInvitee = true;
            
            relationsToInsert.add(er);
            
        }
        if(eventUnderProcess[0].Create_Type__c != Label.Event_Call_Report_Notes_Non_Cap_Intro && !Test.isRunningTest()){
             
        for(String s : internalInvitees){
            EventRelation er = new EventRelation();
            er.RelationId = s ;
            er.EventId = eventId;
            er.IsWhat =false;
            er.IsParent = true;
            //commented to make the event single event
            //er.IsInvitee = true;
            
            relationsToInsert.add(er);
            
        }
        }
        
        
        if(relationsToInsert.size() > 0 ){
            insert relationsToInsert;
        }
        
    }
    
    public static void updateEventRelationsforInternalContacts(List<String> internalContacts, Id eventId, Id eventOwnerId){
        
        Set<String> internalContactsSet = new Set<String>(internalContacts);
        System.debug('---internalContacts----' + internalContacts);
        
        List<Contact> nomuraEmployeeIds =  [SELECT Id 
                                            FROM Contact 
                                            WHERE 
                                            Id IN (SELECT RelationId 
                                                   From EventRelation 
                                                   WHERE EventId=:eventId)  
                                            and Account.Parent.RDM_ORG_ID__c = 'CPG12345']; 
        
        List<User> userIds = [SELECT Id 
                              FROM User 
                              WHERE Id IN (SELECT RelationId 
                                           FROM EventRelation 
                                           WHERE EventId=:eventId) ];
        
        List<EventRelation> existingEventRelations = [SELECT Id , RelationId 
                                                      From EventRelation 
                                                      WHERE EventId=:eventId                                                        
                                                      AND (RelationId IN : nomuraEmployeeIds OR RelationId IN : userIds) ];
        if(existingEventRelations.size() > 0){
            delete existingEventRelations;    
        }
        List<EventRelation> eventRelationsTobeAdded = new List<EventRelation>();
        
        for(String s : internalContacts){
            if( eventOwnerId != s ){
                EventRelation  er= new EventRelation();
                er.RelationId = s ;
                er.eventId = eventId;
                er.IsWhat =false;
                er.IsParent = false;
                //commented to make the event single event
                //er.IsInvitee = true;
                eventRelationsTobeAdded.add(er);
            }
        }
        
        if(eventRelationsTobeAdded.size() > 0){
            insert eventRelationsTobeAdded;
        }
    }
    
    @AuraEnabled
    public static List<SObject> loadInternalInvitees(String eventId){
        
        List<SObject> internalInvitees =  new List<SObject>();
        
        List<SObject> contacts = loadInternalContacts(eventId);
        List<SObject> users = loadInternalUsers(eventId);
        
        internalInvitees.addAll(contacts);
        internalInvitees.addAll(users);
        
        return internalInvitees;
    }
    
    @AuraEnabled
    public static List<Contact> loadInternalContacts(String eventId){
        
        List<Contact> nomuraEmployees =  new List<Contact>();
        
        nomuraEmployees = [SELECT Id, FirstName, LastName, Email, Account.Name
                           FROM Contact 
                           WHERE Id IN (SELECT RelationId 
                                        From EventRelation 
                                        WHERE EventId = :eventId)  
                           AND Account.Parent.RDM_ORG_ID__c = 'CPG12345'];
        
        
        return nomuraEmployees;
    }
    
    @AuraEnabled
    public static List<User> loadInternalUsers(String eventId){
        
        List<User> nomuraEmployees =  new List<User>();
        
        nomuraEmployees = [SELECT Id, FirstName, LastName, Email
                           FROM User 
                           WHERE Id IN (SELECT RelationId 
                                        From EventRelation 
                                        WHERE EventId = :eventId)  
                          ];
        
        
        return nomuraEmployees;
    }
    
    
    @AuraEnabled
    public static List<Contact> loadClientAttendees(String eventId){
        
        List<Contact> clientAttendees =  new List<Contact>();
        
        clientAttendees = [SELECT Id, FirstName, LastName, Email, Account.Name, Account.Parent.RDM_ORG_ID__c
                           FROM Contact 
                           WHERE Id IN (SELECT RelationId 
                                        From EventRelation 
                                        WHERE EventId = :eventId)  
                           AND Account.Parent.RDM_ORG_ID__c <> 'CPG12345'];
        
        System.debug('-------clientAttendees: ' + clientAttendees);
        return clientAttendees;
    }
    
    @AuraEnabled
    public static String populateWhatId(String primaryContactId){ 
                
        String result;
        
        if(primaryContactId.length() > 0){
            
            List<Contact> contacts = new List<Contact>();
            
            contacts = [SELECT Id, AccountId, Account.ParentId  
                        FROM Contact 
                        WHERE Id = :primaryContactId];
            
            if(contacts.size() > 0){
                if(contacts[0].Account.ParentId != null){
                    result = contacts[0].Account.ParentId;
                }else{
                    result = contacts[0].AccountId;
                }
                
            }
        }
        return result;        
    }
    
    @AuraEnabled
    public static List<L1_Event_Type_Setting__mdt> getl1EventTypes(String isCIType){
        List<L1_Event_Type_Setting__mdt> types =  new List<L1_Event_Type_Setting__mdt>();
        if(isCIType == 'false'){
            List<L1_Event_Type_Setting__mdt> eventTypes =  new List<L1_Event_Type_Setting__mdt>();
            eventTypes = [SELECT Id, MasterLabel,L0_Type__c,L0_default__c, Equity_Activity_Flag__c,
            Fixed_Income_Activity_Flag__c,Fixed_Income_Activity_Flag_Default__c,Equity_Activity_Flag_Default__c, L1_default__c,
            L1_FI_default__c, L1_EQ_default__c,Type_Value__c, Available_for_standard_record_type__c, Available_for_Equity__c,Available_for_Fixed_Income__c, Default_Duration__c
                        FROM L1_Event_Type_Setting__mdt 
                        Where Available_for_standard_record_type__c = true and Active__c = true order by L0_Type__c asc];

            //to display L1 types to FI users as well
            User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : UserInfo.getUserId()];
            isEquityUser = CommonTools.isEquityUser(userObj);
            if(isEquityUser){                
                for(L1_Event_Type_Setting__mdt typeObj : eventTypes){
                    L1_Event_Type_Setting__mdt obj = new L1_Event_Type_Setting__mdt();
                    if(typeObj.Available_for_Equity__c){                        
                        obj.MasterLabel = typeObj.MasterLabel;
                        obj.L0_Type__c = typeObj.L0_Type__c;
                        obj.L0_default__c = typeObj.L0_default__c;
                        obj.L1_default__c = typeObj.L1_EQ_default__c;
                        obj.Equity_Activity_Flag__c = typeObj.Equity_Activity_Flag__c;
                        obj.Fixed_Income_Activity_Flag__c = typeObj.Fixed_Income_Activity_Flag__c;
                        obj.Fixed_Income_Activity_Flag_Default__c = typeObj.Fixed_Income_Activity_Flag_Default__c;
                        obj.Equity_Activity_Flag_Default__c = typeObj.Equity_Activity_Flag_Default__c;
                        obj.Type_Value__c = typeObj.Type_Value__c;
                        obj.Available_for_standard_record_type__c = typeObj.Available_for_standard_record_type__c;
                        obj.Default_Duration__c = typeObj.Default_Duration__c;
                    }
                    types.add(obj);
                }                
            }
            else{
                for(L1_Event_Type_Setting__mdt typeObj : eventTypes){
                    L1_Event_Type_Setting__mdt obj = new L1_Event_Type_Setting__mdt();
                    if(typeObj.L1_FI_default__c || typeObj.Available_for_Fixed_Income__c){
                        obj.MasterLabel = typeObj.MasterLabel;
                        obj.L0_Type__c = typeObj.L0_Type__c;
                        obj.L0_default__c = typeObj.L0_default__c;
                        obj.L1_default__c = typeObj.L1_FI_default__c;
                        obj.Equity_Activity_Flag__c = typeObj.Equity_Activity_Flag__c;
                        obj.Fixed_Income_Activity_Flag__c = typeObj.Fixed_Income_Activity_Flag__c;
                        obj.Fixed_Income_Activity_Flag_Default__c = typeObj.Fixed_Income_Activity_Flag_Default__c;
                        obj.Equity_Activity_Flag_Default__c = typeObj.Equity_Activity_Flag_Default__c;
                        obj.Type_Value__c = typeObj.Type_Value__c;
                        obj.Available_for_standard_record_type__c = typeObj.Available_for_standard_record_type__c;
                        obj.Default_Duration__c = typeObj.Default_Duration__c;                        
                    }
                    types.add(obj);
                }                               
            }
        }
        else
        {
            types = [SELECT Id, MasterLabel,L0_Type__c,L0_default__c,Equity_Activity_Flag__c,Fixed_Income_Activity_Flag__c,Fixed_Income_Activity_Flag_Default__c,Equity_Activity_Flag_Default__c,L1_default__c,Type_Value__c, Available_for_standard_record_type__c, Default_Duration__c
                     FROM L1_Event_Type_Setting__mdt 
                     Where Available_for_CI_Interactions__c = true and Active__c = true
                     Order By L0_Type__c ASC]; 
        }
        
        return types;
    } 
    
    @AuraEnabled
    public static Map<String,String> getAllSectors(){
        Map<String,String> valueMap = PicklistFieldController.getSourceOptionsImpl('Event','Sector__c');
        return valueMap;
    } 

    @AuraEnabled
    public static Map<String,List<String>> getActivityFlagStatusValues(){
        Map<String,List<String>> actyFlagStatusMap = new Map<String,List<String>>();
        List<Activity_Flag_Status_Mapping__mdt> actyFlagStatusMappingList = 
            [
                SELECT Id, MasterLabel, Label, Activity_Flag__c, Activity_Status__c, Order__c 
                FROM Activity_Flag_Status_Mapping__mdt
                ORDER BY Order__c
            ];

        if(actyFlagStatusMappingList != null && !actyFlagStatusMappingList.isEmpty()) {
            for(Activity_Flag_Status_Mapping__mdt actyFlagStatusObj : actyFlagStatusMappingList){
                List<String> statusList = actyFlagStatusMap.containsKey(actyFlagStatusObj.Activity_Flag__c) ? actyFlagStatusMap.get(actyFlagStatusObj.Activity_Flag__c) : new List<String>();
                statusList.add(actyFlagStatusObj.Activity_Status__c);

                actyFlagStatusMap.put(actyFlagStatusObj.Activity_Flag__c, statusList);
            }
        }   

        return actyFlagStatusMap;
    } 

    @AuraEnabled
    public static Map<String, String> createContact(Contact c, String rmAccountId){ 
        String[] contactId = new String[]{};
            Map<String, String> resultsMap = new Map<String, String>();
        Boolean validationPass = true;
        //Validation
        if(String.isEmpty(rmAccountId)){
            resultsMap.put('Error', 'Please select an account and a valid address');
            validationPass = false;              
        }
        if(validationPass == true){
            Contact con = new Contact();
            con.Salutation = c.Salutation;
            con.FirstName = c.FirstName;
            con.LastName = c.LastName;
            con.Email = c.Email;
            con.Phone = c.Phone;
            con.AccountId = rmAccountId;
            //Added for JIRA 3521
            con.PositionPicklist__c = c.PositionPicklist__c;
            //Added for JIRA 3561
            con.Title = c.Title;
                        
            Account rmAccount = [Select Id, ParentId From Account Where Id = :rmAccountId Limit 1];
            
            if(rmAccount != null){
                con.RG_Account__c = rmAccount.ParentId;
            }
            
            Database.SaveResult contactResult = Database.insert(con, false);
            if (contactResult.isSuccess()) {
                resultsMap.put('Contact ID', contactResult.getId());
                contactId.add(contactResult.getId());
            }else{
                for(Database.Error err : contactResult.getErrors()) {
                    resultsMap.put('Error', err.getMessage());                 
                }
            }
        }
        //return contactId;   
        return resultsMap;     
    }
    
    @AuraEnabled
    public static Contact[] getAccountContacts(Id accountId){ 
        
        Contact[] contacts = new Contact[]{};
            
            contacts =[Select Id, FirstName, LastName, Email, Phone, AccountId, Account.Name
                       From Contact
                       Where AccountId = :accountId
                       Limit 10];
        
        return contacts;        
    }
    
    public static void insertCampaignMember(String campaignId, List<String> contactIdData, String myContactListSelect, Boolean selectAllCheckboxValue, String filters){
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        if( myContactListSelect != null && myContactListSelect.length() !=0 && !'1'.equalsIgnoreCase(myContactListSelect) &&  selectAllCheckboxValue == true){
            contactIdData = getAllContactData(myContactListSelect, filters);
        }            
        //code to insert campaignmembers into campaign               
        if(contactIdData != null && contactIdData.size() > 0){
            for(String contactIdStr : contactIdData){
                CampaignMember campaignMemberObj = new CampaignMember(CampaignId = campaignId, ContactId = contactIdStr, Status='Done');
                campaignMemberList.add(campaignMemberObj);
            }
            List<Database.SaveResult> resultList = Database.insert(campaignMemberList, false);            
        }  
    }
    
    @AuraEnabled
    public static List<Account>  getAccountAddresses(String accountId){
        
        List<Account> addresses = [Select Id, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode
                                   From Account
                                   Where ParentId = :accountId
                                   and Active__c = true
                                   Order By BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry ASC];
        
        return addresses;
    }
    
     @AuraEnabled
    public static List<PicklistAttributes> getCIStages(){
        List<PickListAttributes> options = new List<PickListAttributes>();
        Schema.DescribeFieldResult fieldResult = Event.CI_Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        PicklistAttributes picklstattr1 = new PicklistAttributes();
        picklstattr1.labelVal = '';
        picklstattr1.textVal = '';
        options.add(picklstattr1);
        for(Schema.PicklistEntry f : ple){
            PicklistAttributes picklstattr = new PicklistAttributes();
            picklstattr.labelVal = f.getLabel();
            picklstattr.textVal = f.getValue();
            options.add(picklstattr);
        }
        
        system.debug('options :' + options);
        
        return options;
    }
    //added for JIRA 3521
    @AuraEnabled 
    public static List<PicklistAttributes> getPositionPicklistValues(){
        List<PickListAttributes> options = new List<PickListAttributes>();
        Schema.DescribeFieldResult fieldResult = Contact.PositionPicklist__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            PicklistAttributes picklstattr = new PicklistAttributes();
            picklstattr.labelVal = f.getLabel();
            picklstattr.textVal = f.getValue();
            options.add(picklstattr);
        }        
        system.debug('options :' + options);
        return options;
    } 

    

    @AuraEnabled
     public static String getDefaultCoveredAccountOpportunity(String accountId){
         String oppoId = CallReportControllerExtension.getDefaultCoveredAccountOppoData(accountId);
         System.debug('---------oppoId-----' + oppoId);
         return oppoId;
     }

}