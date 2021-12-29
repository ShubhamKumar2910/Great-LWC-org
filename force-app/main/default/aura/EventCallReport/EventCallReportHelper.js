({
    loadActivityValues: function(component,selectedValue){
        var activityMap = {};
        if(component.get('v.isEQUser'))
            activityMap = component.get("v.l0EQActivityMap");
        else
            activityMap = component.get("v.l0FIActivityMap"); 
        
        validationResult:
        
        if(activityMap!=undefined && activityMap[selectedValue]!=undefined && activityMap[selectedValue]!=null){
            
            //Populate values in Activity Flag
            var activities = activityMap[selectedValue].split(';')
            var dependentFields = [];
            for(var k in activities){
                dependentFields.push({ selected: false, value: activities[k], label: activities[k] });
            }
            
            component.find('actFlag').set("v.options", dependentFields);
            
            var activityFlagValues = component.get("v.newCallReport.Activity_Flag__c");
            if(activityFlagValues != undefined && activityFlagValues != null ){
                var selectlist = activityFlagValues.split(';');
                var actualSelectList = [];
                
                for(var index = 0; index <selectlist.length; index++){
                    var selectedActivityFlag = selectlist[index];
                    
                    //Check whether selected element is present in list as per changed L1 Type
                    if(dependentFields != undefined && dependentFields != null && dependentFields.length > 0){
                        for(var innerIndex = 0; innerIndex < dependentFields.length; innerIndex++){
                            var activityFlagElement = dependentFields[innerIndex];
                            if(selectedActivityFlag == activityFlagElement.value){
                                actualSelectList.push(selectedActivityFlag);
                            }
                        }
                    }
                }

                component.find("actFlag").set('v.selectedItems',actualSelectList);

                if(actualSelectList != undefined && actualSelectList != null && actualSelectList.length > 0){
                    component.set("v.newCallReport.Activity_Flag__c", actualSelectList.join(';')); 
                }
                else {
                    component.set("v.newCallReport.Activity_Flag__c", "");   
                }

                this.populateActivityFlagStatusValues(component, actualSelectList);
            }

            component.find('actFlag').reInit();
        }
        
    },
    resetl0dependancy:function(component){
        var activities = component.find('actFlag');
        activities.set("v.options",[]);
        activities.set("v.options_",[]);
        activities.reInit();
        component.set("v.newCallReport.L0_Type__c","");
        component.set("v.newCallReport.Activity_Flag__c","");

        this.resetActivityFlagStatusDetails(component);
    },
    setL0DefaultValue: function(component,l1Value){
        var l1_l0default = component.get("v.l1_l0default");
        if(l1_l0default!=undefined && l1_l0default[l1Value]!=undefined) {
            component.set("v.selectedl0EventType",l1_l0default[l1Value]);
            component.set("v.newCallReport.L0_Type__c", l1_l0default[l1Value]);
            component.set("v.l0default",l1_l0default[l1Value]);
        }
        
    },
    // setSectorDefaultValue: function(component, sectorValue){
    //     var l1_l0default = component.get("v.l1_l0default");
    //     if(l1_l0default!=undefined && l1_l0default[l1Value]!=undefined) {
    //         component.set("v.selectedl0EventType",l1_l0default[l1Value]);
    //         component.set("v.newCallReport.L0_Type__c", l1_l0default[l1Value]);
    //         component.set("v.l0default",l1_l0default[l1Value]);
    //     }
        
    // },
    setL1TypeDefaultValue:function(component,selectedValue){
        var l1values =new Array();
        var recordId = component.get("v.recordId");        
        
        if(recordId == undefined){
            var parentId = component.get("v.relatedToId");
            
            if(parentId != undefined){
                recordId = parentId;
            }else{
                recordId = null;
            }
            
        }
        
        if(component.get('v.isEQUser')){
             var l1_l0default = component.get("v.l1_l0default");
            if(l1_l0default!=undefined && l1_l0default!=null && l1_l0default[selectedValue]!=undefined) {
                for(var dvalue in l1_l0default){
                    l1values.push(dvalue);
                }
            
                if(l1values.length>=1)
                {
                    l1values.sort();
                    component.set('v.availableEventTypes',l1values);
                    component.set('v.selectedl0EventType', l1_l0default[selectedValue]);
                    component.set('v.selectedEventType', selectedValue);
                    component.set("v.newCallReport.Type",selectedValue);

                    var isAnalystUser = component.get("v.isAnalystUser");
                    var selectedl0EventType = component.get("v.selectedl0EventType");
                    if(!isAnalystUser && selectedl0EventType == "General Meeting"){                        
                        component.set('v.selectedEventType', 'Sales Meeting');
                        component.set('v.newCallReport.Type','Sales Meeting');
                    }
                }
            }
        }
        else
        {
            var typeDependantValues = component.get("v.typeDependantValues"); //contains all l1 values
            var l0DependantDefaultValuesMap = component.get("v.l0DependantDefaultValuesMap"); //contains all l1 default values of l0
            if((typeDependantValues!=undefined && typeDependantValues[selectedValue]!=undefined) 
               || (l0DependantDefaultValuesMap!=undefined && l0DependantDefaultValuesMap[selectedValue]!=undefined)){
                
                //populate all l1 values using l0
                if(typeDependantValues[selectedValue]!=undefined && typeDependantValues!=null && typeDependantValues[selectedValue]!=null && typeDependantValues[selectedValue]!=''){
                    //l1values.push('-- None --');
                    var dependantsL1 = typeDependantValues[selectedValue];
                    for(var dvalue in dependantsL1)
                        l1values.push(dependantsL1[dvalue]);
                    if(l1values.length>=1)
                    {
                        l1values.sort();
                        component.set('v.availableEventTypes',l1values);
                    }
                }
                //set up l1 default selected value using l0
                if(l0DependantDefaultValuesMap[selectedValue]!=undefined && l0DependantDefaultValuesMap!=null && l0DependantDefaultValuesMap[selectedValue]!=null && l0DependantDefaultValuesMap[selectedValue]!='')
                {                       
                    component.set("v.selectedEventType",l0DependantDefaultValuesMap[selectedValue]);
                    console.log(l0DependantDefaultValuesMap[selectedValue])
                    component.set("v.newCallReport.Type",l0DependantDefaultValuesMap[selectedValue]);
                    console.log(l0DependantDefaultValuesMap[selectedValue]);
                    component.set("v.newCallReport.L0_Type__c", selectedValue);
                    component.set("v.l0default",selectedValue);
                    
                    var isAnalystUser = component.get("v.isAnalystUser");
                    var selectedl0EventType = component.get("v.selectedl0EventType");
                    if(!isAnalystUser && selectedl0EventType == "General Meeting"){   
                        var selectedValue = 'General Meeting';
                        component.set('v.selectedEventType', 'Sales Meeting');
                        component.set("v.newCallReport.Type", 'Sales Meeting');

                    }

                }
            }     
        }
        //added for JIRA SALES 3510
        this.getObjectiveMandatory(component); 
       
    },

    setSectorValue : function(component,selectedValue){
        var recordId = component.get("v.recordId");        
        
        if(recordId == undefined){
            var parentId = component.get("v.relatedToId");
            
            if(parentId != undefined){
                recordId = parentId;
            }else{
                recordId = null;
            }
            
        }
        if(selectedValue == "0") { // 0 is the API name of None option in sector picklist
            component.set("v.newCallReport.Sector__c","");
        }
        else {
            component.set("v.newCallReport.Sector__c",selectedValue);
        }
        component.set('v.selectedSector', selectedValue);
    },

    isCapIntroUser :  function(component,event,helper){        
        var action = component.get("c.isCapIntro");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue();
                component.set("v.isCapIntro",responseMap);                
                console.log(component.get("v.isCapIntro"));                
                this.hideShowControls(component,event,helper);              
            }
        });
        $A.enqueueAction(action);
    },    
    onChange: function (cmp, event) {
        // Retrieve an array of the selected options
        var selectedOptionValue = event.getParam("value");
    },    
    initialiseEventLabels : function(component){
        var validationResult = [];
        var action = component.get("c.initialiseLabels");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMap = response.getReturnValue();
                
                for (var key in responseMap) {
                    if (responseMap.hasOwnProperty(key)) {                    
                        var innerMap = responseMap[key];
                        console.log('innerMap');
                        console.log(innerMap);
                        
                        for(var f in innerMap){
                            
                            
                            if(key == 'Event' && f == 'Type'){
                                component.set("v.typeLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'L0_Type__c'){
                                component.set("v.l0typeLabel", innerMap[f]);
                            }  
                            if(key == 'Event' && f == 'Sector__c'){
                                component.set("v.SectorLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'Activity_Flag__c'){
                                component.set("v.activityflagLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'IBOR_Status__c'){
                                component.set("v.activityStatusLabel", innerMap[f]);
                            }  
                            if(key == 'Event' && f == 'Subject'){
                                component.set("v.subjectLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'Ticker__c'){
                                component.set("v.tickerLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'WhatId'){
                                component.set("v.relatedToLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'IsPrivate'){
                                component.set("v.privateLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'IsAllDayEvent'){
                                component.set("v.allDayEventLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'WhoId'){
                                component.set("v.ownerLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'StartDateTime'){
                                component.set("v.startDateLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'EndDateTime'){
                                component.set("v.endDateLabel", innerMap[f]);
                            }
                            if(key == 'Event' && f == 'CI_Stage__c'){
                                component.set("v.stageLabel", innerMap[f]); 
                            } 
                            if(key == 'Event' && f == 'DurationInMinutes'){
                                component.set("v.duration", innerMap[f]); 
                            }
                        }
                    }
                }
                
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },    
    initialiseCIStages :function(component){
        
        
        //var meetingCreateType = component.get('v.CreateType');
        // if(meetingCreateType == 'ci_interactions')
        // {
        var action = component.get("c.getCIStages");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var types = [];
                
                var result = response.getReturnValue();
                
                console.log('result');
                console.log(result);
                
                for(var k in result){
                    types.push(result[k].textVal);
                }
                component.set("v.availableCIStages", types);
                
                var utilityAPI = component.find("utilitybar");
                
                if(utilityAPI == undefined){
                    component.set("v.addUtilityBarPaddding", true);
                }
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
        
        //}
    },
    showHideMeetingControls : function(component){
        var typeD = component.find("typeDiv");
        var l0typeD = component.find("l0typeDiv");
        var activityFlagD = component.find("activityFlagDiv");
        var CILabel = $A.get("$Label.c.Event_CI_Interactions");
        var CILabel = $A.get("$Label.c.Event_CI_Interactions");
        var callReportLblNonCPIntro = $A.get("$Label.c.Event_Call_Report_Notes_Non_Cap_Intro");
        var callReportLbl = $A.get("$Label.c.Event_Call_Report_Notes");        
        var massActivityTypeDiv = component.find("massActivityTypeDiv");
        var massActivitySubTypeDiv = component.find("massActivitySubTypeDiv");

        if(component.get("v.createVal") == CILabel){
            $A.util.addClass(l0typeD, "slds-hide"); //hide Meeting Type
            $A.util.removeClass(typeD, "slds-hide"); //show Meeting SubType
            $A.util.addClass(activityFlagD, "slds-hide");
        }
        else
        {
            if(component.get('v.massActivityFlag')){
                $A.util.addClass(l0typeD, "slds-hide");
                $A.util.addClass(typeD, "slds-hide");
                if(component.get('v.isEQUser')){
                    $A.util.addClass(massActivityTypeDiv, "slds-hide");
                    $A.util.removeClass(massActivitySubTypeDiv, "slds-hide");
                }
                else{
                    $A.util.removeClass(massActivityTypeDiv, "slds-hide");
                    $A.util.removeClass(massActivitySubTypeDiv, "slds-hide");
                }                
            }
            else{
                if(component.get('v.isEQUser'))
                {
                    $A.util.addClass(l0typeD, "slds-hide"); //hide Meeting Type
                    $A.util.removeClass(typeD, "slds-hide"); //show Meeting SubType
                    $A.util.removeClass(activityFlagD, "slds-hide");                    
                }
                else
                {
                    $A.util.removeClass(l0typeD, "slds-hide"); //show Meeting Type
                    $A.util.removeClass(typeD, "slds-hide");//show Meeting SubType
                    $A.util.removeClass(activityFlagD, "slds-hide");
                }
            }
            
        }
        
        
    },
    getUserDetails : function(component,helper){
        
        var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var result = JSON.parse(response.getReturnValue());                
                var eqUser = result[0].isEquityUserDetail;
                var japanUser = result[0].isJapanFIUserDetail;
                var userProfileName = result[0].userProfile;
                var isAnalystUser = result[0].IsAnalystUser;
                component.set("v.isAnalystUser", isAnalystUser);

                var activeSalesCodePresent = result[0].isActiveSalesCodePresent;
                component.set("v.isActiveSalesCodePresent", activeSalesCodePresent);

                this.checkForEQUser(component, helper, eqUser);
                this.checkForJapanFIUser(component, helper, japanUser);
                this.checkUserProfile(component, helper, userProfileName);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    checkForEQUser : function(component, helper, eqUser){       
        var isEquityUser = false;
        isEquityUser = eqUser;
        if(isEquityUser!=undefined && isEquityUser!=null || component.get("v.isCapIntro"))
        {
            if(component.get("v.isCapIntro"))
                component.set('v.isEQUser',true);
            else
                component.set('v.isEQUser',isEquityUser);
            this.showHideMeetingControls(component);
            this.initialisel1EventTypes(component,helper);  
            this.initialiseSectors(component);
        }  
    },

    checkForJapanFIUser : function (component, helper, japanUser){        
        var result =  japanUser;
        component.set("v.isJapanFIUser", result);
        var privacyFlag = component.find("privateEventInput").get("v.checked");                                        
        component.set("v.newCallReport.IsPrivate", result);
        
        if(result == true){
            var opportunityLabel = $A.get("$Label.c.Event_Opportunity");
            
            component.set("v.relatedToObject", opportunityLabel);
            //component.find("related-to-opportunity").callPreSelect();  
            component.set("v.newCallReport.Private_Flag__c", true);                                    
        } 
        
     }, 
     checkUserProfile : function(component, helper, userProfileName){      
        var userProfile = userProfileName;
        var coveredAccCheckboxD = component.find("coveredAccCheckboxDiv");
        var massActivityFlag = component.get("v.massActivityFlag");
        var showCoveredAccountDetails = false;

        if(userProfile != null && (userProfile.includes('Nomura - Sales') || userProfile.includes('System Administrator')) && massActivityFlag == false){
            
            var activeSalesCodePresent = component.get("v.isActiveSalesCodePresent");

            if(activeSalesCodePresent == true){
                showCoveredAccountDetails = true;

                $A.util.removeClass(coveredAccCheckboxD, "slds-hide");
                component.set("v.showCoveredAccountDetails", true);
                component.set("v.coveredAccountCheck", true);
            }
        }

        if(showCoveredAccountDetails == false){
            $A.util.addClass(coveredAccCheckboxD, "slds-hide");  
            component.set("v.showCoveredAccountDetails", false);
            component.set("v.coveredAccountCheck", false);      
        }
     },  

    initialisel1EventTypes : function(component,event,helper){
        //console.log('********** initialisel0EventTypes START *******');
        var validationResult = [];
        var typeSelect = component.find("createType").get("v.value");
        var typeDependantValues = component.get("v.typeDependantValues");
        var l0DependantDefaultValuesMap = component.get("v.l0DependantDefaultValuesMap");
        var l0EQActivityMap = component.get("v.l0EQActivityMap");
        var l0FIActivityMap = component.get("v.l0FIActivityMap");
        var l1_l0default = component.get("v.l1_l0default");
        var l0default = '';        

        var defaultDurationMap = component.get('v.defaultDuration');
        var CILabel = $A.get("$Label.c.Event_CI_Interactions");
        var recordId = component.get("v.recordId");
        if(recordId == undefined){
            var parentId = component.get("v.relatedToId");
            
            if(parentId != undefined){
                recordId = parentId;
            }else{
                recordId = null;
            }
            
        }    
        
        if(typeSelect == CILabel)
            component.set("v.isTypeCI","true");
        else
            component.set("v.isTypeCI","false");
        
        var action = component.get("c.getl1EventTypes");
        var isCIType =  component.get("v.isTypeCI");
        action.setParams({
            "isCIType": isCIType
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var types = [];
                var subtypes = [];
                var result = response.getReturnValue();
                console.log(result); 
                var CIDefaultL1 = '';
               
                var l1default = '';
                for(var k in result){
                    
                    if(isCIType.toLowerCase() == 'false'){
                        if(result[k].L0_Type__c!=undefined  && result[k].L0_Type__c!=null && result[k].L0_Type__c!=''){
                           
                            l1_l0default[result[k].MasterLabel] = result[k].L0_Type__c;
                            
                            if(result[k].L1_default__c!=undefined && result[k].L1_default__c!=null && result[k].L1_default__c){
                                l0DependantDefaultValuesMap[result[k].L0_Type__c] = result[k].MasterLabel;
                                
                            }
                            
                            if(result[k].Type_Value__c!=undefined && result[k].Type_Value__c!=null)
                                defaultDurationMap[result[k].Type_Value__c] = result[k].Default_Duration__c;
                            
                            if(result[k].Equity_Activity_Flag__c!=undefined && result[k].Equity_Activity_Flag__c!=null && result[k].Equity_Activity_Flag__c!='' )
                            {
                                 if(!component.get('v.isEQUser'))
									l0EQActivityMap[result[k].L0_Type__c] = result[k].Equity_Activity_Flag__c;
                                else
                                    l0EQActivityMap[result[k].MasterLabel] = result[k].Equity_Activity_Flag__c;
                            }
                            
                            if(result[k].Fixed_Income_Activity_Flag__c!=undefined && result[k].Fixed_Income_Activity_Flag__c!=null && result[k].Fixed_Income_Activity_Flag__c!='')
                            {
                                if(!component.get('v.isEQUser'))
                                    l0FIActivityMap[result[k].L0_Type__c] = result[k].Fixed_Income_Activity_Flag__c;
                                else
                                l0FIActivityMap[result[k].MasterLabel] = result[k].Fixed_Income_Activity_Flag__c;
                            }
                            
                            
                            if(typeDependantValues[result[k].L0_Type__c]!==null && typeDependantValues[result[k].L0_Type__c]!=undefined && typeDependantValues[result[k].L0_Type__c]!==''){
                                var productCloneArray = new Array();
                                var existingArray = typeDependantValues[result[k].L0_Type__c];
                                if(!existingArray.includes(result[k].MasterLabel))
                                {
                                    existingArray.push(result[k].MasterLabel);
                                    typeDependantValues[result[k].L0_Type__c] = existingArray;
                                } 
                            }
                            else
                            {
                                var cloneArray = new Array();
                                cloneArray.push(result[k].MasterLabel);
                                typeDependantValues[result[k].L0_Type__c] = cloneArray;
                            }    
                                                         
                            if(result[k].L0_default__c){
                                l0default = result[k].L0_Type__c;
                                l1default = result[k].MasterLabel;
                            }
                        }
                    }
                    else if(isCIType.toLowerCase() == 'true')
                    {
                        types.push(result[k].MasterLabel);
                        if(result[k].L1_default__c!=undefined 
                           && result[k].L1_default__c!=null && result[k].L1_default__c
                           && (result[k].L0_Type__c==undefined  || result[k].L0_Type__c==null )
                          )
                        {
                            CIDefaultL1 = result[k].MasterLabel;
                        }
                    }
                }
                
                component.set('v.l1_l0default',l1_l0default);
                component.set("v.typeDependantValues", typeDependantValues);
				component.set("v.l0DependantDefaultValuesMap",l0DependantDefaultValuesMap);
                component.set('v.defaultDuration', defaultDurationMap);

                if(isCIType.toLowerCase() == 'true')
                {
                    types.sort();
                    component.set("v.availableEventTypes", types); 
                    if(recordId == null || recordId == undefined){
                        component.set("v.selectedEventType",CIDefaultL1);
                        component.set("v.selectedStageType",component.get('v.defaultStageType'));
                        component.set("v.newCallReport.CI_Stage__c",component.get('v.defaultStageType'));
                        component.set("v.newCallReport.Type",CIDefaultL1);
                    }
                    
                    
                }
                else if(isCIType.toLowerCase() == 'false')
                {
                    for(var key in typeDependantValues)
                    {
                        types.push(key);
                    }
                    types.sort(function (a, b) {
                        return a.toLowerCase().localeCompare(b.toLowerCase());
                    });
                    component.set("v.availablel0EventTypes", types); 
					
					if(component.get('v.isEQUser'))
                        component.set("v.l0EQActivityMap", l0EQActivityMap);
                    else
                        component.set("v.l0FIActivityMap", l0FIActivityMap);

						component.set("v.selectedl0EventType",l0default);
                        component.set("v.newCallReport.L0_Type__c", l0default);
                         component.set("v.l0default",l0default);
                   component.set("v.l1default",l1default);
                       if(!component.get('v.isEQUser'))
						{
                            this.loadActivityValues(component,l0default);
							this.setL1TypeDefaultValue(component,l0default);
						}
						else
						{
                            this.loadActivityValues(component,l1default);
							this.setL1TypeDefaultValue(component,l1default);
						}
						
					} 
                    
                
                
                
                var utilityAPI = component.find("utilitybar");
                if(utilityAPI == undefined){
                    component.set("v.addUtilityBarPaddding", true);
                }
                
                if(component.get('v.defaultInitialiseCallReportLoad'))
                    this.initialiseNewCallReport(component,event,helper,l0default);
				component.set('v.createTypeChange',false);
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);        
    }, 

    initialiseSectors : function (component){

        var validationResult = [];
        var action = component.get("c.getAllSectors");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {                
                var types = [];
                var result = response.getReturnValue(); 

                var sectorList = [];
                for (var sectorKey in result) {
                    sectorList.push({key:sectorKey, value:result[sectorKey]});
                }
                component.set("v.sectorList", sectorList); 
            }
            else if (state === "ERROR") {
                console.log("Error fetching sectors");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } 
            }
            else {
                    console.log("Unknown error");
                }
        });
        $A.enqueueAction(action);
    },
    
    initialiseNewCallReport : function (component,event,helper,l0default){
        var self = this;
        var recordId = component.get("v.recordId");  
        var activityType= component.get("v.activityType");
        var isClientMemo = component.get("v.isClientMemo");
        
        if(recordId == undefined){
            var parentId = component.get("v.relatedToId");
            
            if(parentId != undefined){
                recordId = parentId;
                component.set('v.startChanged' , false);
            }else{
                recordId = null;
            }
            
        }

        //this.getUserDetails(component, helper);
        console.log('initialiseNewCallReport recordId: ' + component.get("v.ClientAttendees"));
        console.log('initialiseNewCallReport recordId: ' + recordId);
        console.log('initialiseNewCallReport parentId: ' + parentId);
        var validationResult = [];
        var action = component.get("c.initialiseNewCallReport");
        var l1_l0defaultMap = component.get('v.l1_l0default');
        var massActivityFlag = component.get('v.massActivityFlag');
        var saveNewCheck = component.get("v.saveNewCheck");
        //this.checkCurrentUserSettings(component);
        
        action.setParams({
            "recordId": recordId,
            "isClientMemo": isClientMemo,
            "saveNewCheck": saveNewCheck
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accountLabel = $A.get("$Label.c.Event_Account");
                var opportunityLabel = $A.get("$Label.c.Event_Opportunity");
                var campaignLabel = $A.get("$Label.c.Event_Campaign");
                var callReport = response.getReturnValue();
                
       
                //following method is used to display default value when navigating from ContatList
                if(massActivityFlag && ((activityType != undefined && ( activityType == 'Voicemail' || activityType == 'Model Request')) || (recordId != undefined && activityType == undefined))){                                       
                    this.setDefaultMassActivityTypes(component, callReport, activityType);
                }
                
				//Meeting Type
				if(callReport.L0_Type__c!=undefined && callReport.L0_Type__c!=null && activityType == undefined){
					component.set("v.selectedl0EventType",callReport.L0_Type__c);
					this.setL1TypeDefaultValue(component,callReport.L0_Type__c);
					component.set("v.newCallReport.L0_Type__c", callReport.L0_Type__c);
                    component.set('v.l0default',callReport.L0_Type__c);
                }
				
				//Meeting SubType
				if(callReport.Type!=undefined && callReport.Type!=null && activityType == undefined){
                    component.set("v.newCallReport.Type",callReport.Type);
                    component.set("v.selectedEventType",callReport.Type);
                    console.log(callReport.Type)
                    
				   if(!component.get('v.isEQUser') && activityType == undefined){ //for fixed Income, default l0
                        var l1_l0default = component.get("v.l1_l0default");
                        if(l1_l0default!=undefined && l1_l0default!=null && l1_l0default[callReport.Type]!=undefined) {
                            component.set('v.selectedl0EventType', l1_l0default[callReport.Type]);
                            console.log(l1_l0default[callReport.Type]);
                             this.loadActivityValues(component,l1_l0default[callReport.Type]);
                        }
                        
                        console.log(component.get("v.isJapanFIUser"));
                        //set default value for Client Memo type for FI user
                        // if(isClientMemo && component.get("v.isJapanFIUser")){
                        //     this.setL0DefaultValue(component, callReport.Type);
                        //     this.setL1TypeDefaultValue(component, callReport.Type);                            
                        // }
                        //else
                         if(isClientMemo){
                            this.setL0DefaultValue(component, callReport.Type);
                            this.setL1TypeDefaultValue(component, component.get("v.selectedl0EventType"));
                        }

                    }
                    else if(component.get('v.isEQUser')&& activityType == undefined)
                    {
                        //set default value for Client Memo type for EQ user
                        if(isClientMemo){
                            this.setL0DefaultValue(component, callReport.Type);
                        }


                        this.loadActivityValues(component,callReport.Type);
                    }
				}
				
				//CI stage
				if(!$A.util.isUndefinedOrNull(callReport.CI_Stage__c) && callReport.CI_Stage__c!='' && callReport.Create_Type__c == 'CI Interactions'){
					component.set("v.selectedStageType",callReport.CI_Stage__c);
					component.set("v.newCallReport.CI_Stage__c",callReport.CI_Stage__c);
				}
				
				//Activity Flag
              	if(callReport.Activity_Flag__c!=undefined && callReport.Activity_Flag__c!=null && callReport.Activity_Flag__c!='')
				{
					component.set("v.newCallReport.Activity_Flag__c", callReport.Activity_Flag__c);
                	if(component.find("actFlag")!=undefined && component.find("actFlag")!=null){
						var activityvalues =callReport.Activity_Flag__c.split(';');
						component.find("actFlag").set('v.selectedItems',activityvalues);
						component.find('actFlag').reInit();   
					}
					
                }

                //Activity Flag Status
              	if(callReport.IBOR_Status__c != undefined && callReport.IBOR_Status__c !=null && callReport.IBOR_Status__c != '')
                {
                    if(component.find("activityStatus") !=  undefined && component.find("activityStatus") != null)
                    {
                        component.set("v.selectedActivityStatus",callReport.IBOR_Status__c);
                        component.set("v.newCallReport.IBOR_Status__c", callReport.IBOR_Status__c);

                        var selectlist = callReport.Activity_Flag__c.split(';');
                        this.populateActivityFlagStatusValues(component, selectlist);

                        
                    }
                }

                //Sector
                if(callReport.Sector__c!=undefined && callReport.Sector__c!=null)
				{
					component.set("v.selectedSector",callReport.Sector__c);
					component.set("v.newCallReport.Sector__c", callReport.Sector__c);
                }

                //Ticker
                if(callReport.Ticker__c!=undefined && callReport.Ticker__c!=null)
				{
                    var ricCodes = [];
                    ricCodes = (callReport.Ticker__c).split(",");
					component.set("v.ricCodes", ricCodes);
					component.set("v.newReport.Ticker__c", callReport.Ticker__c);					
                }
                var start = new Date();
                start  = moment(callReport.StartDateTime);
                if(callReport.Id == undefined){                    
                    var startRounded = self.round(start, moment.duration(30, "minutes"), "ceil");
                    component.set('v.startTimeInitialise',startRounded.toISOString());
                }
                else{                   
                    component.set('v.startTimeInitialise',start.toISOString());
                }
                
                component.set("v.eventOwnerIdHidden", callReport.OwnerId);
                
                var assigned = [];
                console.log('who in cll');
                console.log(callReport.WhoId);
                
                assigned.push(callReport.OwnerId);
                component.set("v.newCallReport.WhoId", callReport.WhoId);
                component.set("v.assignedToSelected", assigned);
                
               if(component.get("v.isCapIntro")){
                    var callReportLblNonCPIntro = $A.get("$Label.c.Event_Call_Report_Notes_Non_Cap_Intro");
                    
                    if(!$A.util.isUndefinedOrNull(callReport.Create_Type__c)){
                        component.set("v.createVal",callReport.Create_Type__c); 
                        component.set("v.newCallReport.Create_Type__c",callReport.Create_Type__c);
                    }
                    else
                    {
                        
                        component.set("v.createVal",callReportLblNonCPIntro); 
                        callReport.Create_Type__c = callReportLblNonCPIntro;
                    }
                    
                    //component.set("v.selectedStageType",callReport.CI_Stage__c);
                    //component.set("v.newCallReport.CI_Stage__c",callReport.CI_Stage__c);
                    component.set("v.SelectedFunds",callReport.Fund__c);
                    component.find("related-to-fund").callPreSelect();
                    
                    this.hideShowControls(component,event,helper);
                    this.updateEventType(component, event);
                    //added for JIRA SALES 3510
                    this.getObjectiveMandatory(component,helper); 
                }
                
                if((callReport.WhatId != undefined && callReport.WhatId != null) && (recordId != null && recordId != undefined && recordId.startsWith("00U"))){
                    var array = [];
                    
                    array.push(callReport.WhatId);
                    
                    
                    if(callReport.WhatId.startsWith("001")){
                        component.set("v.relatedToObject", accountLabel);
                        component.set("v.relatedToAccountSelected", array);
                        component.find("related-to-account").callPreSelect();
                    }
                    if(callReport.WhatId.startsWith("006")){
                        component.set("v.relatedToObject", opportunityLabel);
                        component.set("v.relatedToOpportunitySelected", array);
                        
                        component.find("related-to-opportunity").callPreSelect();
                    }
                    if(callReport.WhatId.startsWith("701")){
                        component.set("v.relatedToObject", campaignLabel);
                        component.set("v.relatedToCampaignSelected", array);
                        component.find("related-to-campaign").callPreSelect();
                    }
                }
                else{
                    
                    if(recordId != undefined){
                        var array = [];
                        array.push(recordId);
                        
                        if(recordId.startsWith("001")){
                            component.set("v.relatedToObject", accountLabel);
                            component.set("v.relatedToAccountSelected", array);
                            
                            var accountLookup = component.find("related-to-account");
                            accountLookup.callPreSelect();
                        }
                        else if(recordId.startsWith("006")){
                            component.set("v.relatedToOpportunitySelected", array);
                            component.set("v.relatedToObject", opportunityLabel);
                            
                            var opportunityLookup = component.find("related-to-opportunity");
                            opportunityLookup.callPreSelect();
                        }
                            else if(recordId.startsWith("701")){
                                component.set("v.relatedToObject", campaignLabel);
                                component.set("v.relatedToCampaignSelected", array);
                                
                                var campaignLookup = component.find("related-to-campaign");
                                campaignLookup.callPreSelect();
                            }else if(recordId == null){
                                component.set("v.relatedToObject", accountLabel);
                                var accountLookup = component.find("related-to-account");
                                accountLookup.callPreSelect();
                            }
                    }
                }
                var lookupReference  = component.find("lookup-assigned-to");
                lookupReference.callPreSelect();
                var lookupReferenceToRic  = component.find("lookup-ric-code");
                lookupReferenceToRic.callPreSelect();
                this.initialiseClientAttendees(component);
                var roundedStartTime = component.get('v.startTimeInitialise');
                callReport.StartDateTime = roundedStartTime;

                 /* Changes to load event end date*/
                 var end = new Date();
                 end  = moment(callReport.EndDateTime).toISOString();                
                 var endDateTime = component.find("endDateInput");
                 endDateTime.set("v.value", end);
                
                //this.checkCurrentUserSettings(component);  //called 2nd time to set private flag
               
                component.set("v.newCallReport", callReport);  
                //added for JIRA SALES 3510
                this.getObjectiveMandatory(component);
                var japanUser = component.get("v.isJapanFIUser");
                this.checkForJapanFIUser(component, event, japanUser);
            }else if (state === "ERROR") {
                
                var errors = response.getError();                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);                
    },
    initialiseDetailedDescription : function (component){
        //console.log('********** initialiseDetailedDescription START *******');
        var validationResult = [];
        var action = component.get("c.initialiseDetailedDescription");
        var recordId = component.get("v.recordId");
        if(recordId == undefined){
            recordId = null;
        }
        action.setParams({
            "recordId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                result.sobjectType = 'Task_LTA__c';
                component.set("v.callReportDetailedDescription", result);
            }else if (state === "ERROR") {
                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);         
    },    
    initialiseInternalInvitees :function (component){        
        var self = this; 
        var validationResult = [];
        var recordId = component.get("v.recordId");
        
        if(recordId == undefined){
            var parentId = component.get("v.relatedToId");            
            if(parentId != undefined){
                recordId = parentId;
            }else{
                recordId = null;
            }
            
        }
        
        var preselectedInternal = component.get("v.InternalInviteesPreloaded");
        
        if(preselectedInternal != undefined){
            component.set("v.internalInviteesSelected", preselectedInternal); 
            component.find("lookup-internal-contact").callPreSelect();
        } 
        
        
        if(recordId != undefined && recordId.startsWith("00U") == true){
            var action = component.get("c.loadInternalInvitees");
            action.setParams({
                "eventId" : recordId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var preselected = [];
                    
                    for(var key in result){
                        preselected.push(result[key].Id);
                    }
                    
                    component.set("v.internalInviteesSelected", preselected); 
                    component.find("lookup-internal-contact").callPreSelect();
                }else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            validationResult.push({
                                message :  errors[0].message
                            });
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
        
    },    
    initialiseClientAttendees :function (component){
        var self = this; 
        var recordId = component.get("v.recordId");
        
        var validationResult = [];
        if(recordId == undefined){
            var parentId = component.get("v.relatedToId");            
            if(parentId != undefined){
                recordId = parentId;
            }else{
                recordId = null;
            }
            
        }
        
        if(recordId != undefined && recordId.startsWith("00U") == true){
            var newCallReport = component.get("v.newCallReport");
            
            console.log("Who Id : " + component.get("v.newCallReport.WhoId"));
            var action = component.get("c.loadClientAttendees");
            action.setParams({
                "eventId" : recordId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('initialiseClientAttendees state: ' + state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var preselected = [];
                    
                    if(result != undefined){
                        var attendees = component.get("v.clientAttendeesSelected");
                        console.log('attendees: ' + attendees);
                        for(var key in result){
                            preselected.push(result[key].Id);
                        }
                        console.log('attendees length: ' + attendees.length);
                        
                        if(attendees.length > 0){
                            for(var k in preselected){
                                //if(attendees.indexOf(result[key].Id) != -1){
                                console.log('attendees ==> indexOf : '+ preselected[k] + ' => ' + attendees.indexOf(preselected[k]));
                                // } 
                            }
                        }
                        
                        
                        
                    }
                    
                    
                    var ClientAttendees = [];
                    ClientAttendees = component.get("v.ClientAttendees");
                    console.log('Client Attendees: ' + ClientAttendees);
                    
                    if(ClientAttendees != undefined){
                        for(var k in ClientAttendees){
                            console.log('ClientAttendees[k]: ' + ClientAttendees[k]);
                            preselected.push(ClientAttendees[k]);                            
                        }                        
                    }
                    console.log(preselected);
                    var callReportLblNonCPIntro = $A.get("$Label.c.Event_Call_Report_Notes_Non_Cap_Intro");
                    
                    var arrsinglelkup = [];
                    for (var s in preselected){                        
                        if(preselected[s] == component.get("v.newCallReport.WhoId")){
                            arrsinglelkup.push(preselected[s]);
                        }
                    }
                    
                    var inviteesinglelkup = [];
                    component.set("v.clientAttendeesSelected", preselected); 
                    component.find("lookup-external-contact").callPreSelect();
                                        
                    if(component.get("v.createVal") != callReportLblNonCPIntro && !$A.util.isUndefinedOrNull(component.get("v.createVal"))  && component.get("v.createVal") != ''){
                        component.set("v.clientAttendeesSelected",arrsinglelkup); 
                        component.find("lookup-manager-contact").callPreSelect();
                        
                        if(preselected.length > 1){
                            for (var s in preselected){
                                if(preselected[s] != component.get("v.newCallReport.WhoId")){
                                    inviteesinglelkup.push(preselected[s]);
                                }
                            }
                            
                        }
                        
                        //component.find("lookup-manager-contact").callPreSelect();
                        if(!$A.util.isUndefinedOrNull(inviteesinglelkup)){
                            console.log(inviteesinglelkup);
                            component.set("v.internalInviteesSelected",inviteesinglelkup);                    
                            component.find("lookup-investor-contact").callPreSelect();
                        }
                    }
                }else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            validationResult.push({
                                message :  errors[0].message
                            });
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }else if(recordId != undefined && recordId.startsWith("003") == true){
            var array = [];
            array.push(recordId);
                        
            component.set("v.clientAttendeesSelected", array); 
            component.find("lookup-external-contact").callPreSelect();
        }else{
            var ClientAttendees = [];
            ClientAttendees = component.get("v.ClientAttendees");
            
            var selected = [];
            
            if(ClientAttendees != undefined){
                for(var k in ClientAttendees){
                    console.log('k:' + ClientAttendees[k]);
                    if(ClientAttendees[k].length == 18){
                        selected.push(ClientAttendees[k]);
                    }else{
                        for(var j in ClientAttendees[k]){
                            selected.push(ClientAttendees[k][j]);
                        }
                    }
                    
                }
            }
            
            
            
            component.set("v.clientAttendeesSelected", selected);             
            component.find("lookup-external-contact").callPreSelect();
            
        }
        
    },    
    navigateToHomepage : function (component){
        
        component.find("navigationService").navigate({
            "type": "standard__namedPage",
            "attributes": {
                "pageName": "home"
            }                
        });              
    },    
    navigateToRecord : function(component, recordId){
        
        component.find("navigationService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId, "actionName" : "view"},
            "state": {}
        });        
    },    
    saveEvent : function(component){
        var _self = this; 
        var validationResult = [];
        var contactData = component.get("v.selectedContactData");
        var saveeventType = component.get("v.SaveEventType");
        if(contactData == undefined){
            contactData = null;
        }
       
        
        var newReport = component.get("v.newCallReport");
        newReport.sobjectType = 'Event';
        if(newReport.Create_Type__c!='CI Interactions')
            newReport.L0_Type__c = component.get('v.l0default');
        else
        {
            newReport.L0_Type__c =null;
            newReport.CI_Stage__c = component.get("v.selectedStageType");
        }
        var internalInviteesSelected = component.get("v.internalInviteesSelected");
        var clientAttendeesSelected = component.get("v.clientAttendeesSelected");
        var detailedDescription = component.get("v.callReportDetailedDescription.LTA_1__c");
        var selectedOwner = newReport.OwnerId;
        var activityFl = component.get("v.massActivityFlag");
        var activityType = component.get("v.activityType");
        var selectAllCheckboxValue = component.get("v.selectAllCheckboxValue");        
        var myContactListSelect = component.get("v.myContactListSelect"); 
        var filters = component.get("v.filters");  
        this.checkForClientMemo(component);
        var isClientMemo = component.get("v.isClientMemo");
        //Validate Event               
        validationResult = _self.validateEvent( newReport, clientAttendeesSelected, internalInviteesSelected, activityFl, component);
        console.log('validationResult: ' + validationResult);
        if(validationResult.length == 0){
            
            var action = null;
            if(saveeventType == 'By Contact' || saveeventType == 'By Account'){
                action = component.get("c.saveNewEventBulk");
                action.setParams({               
                    "e": newReport,
                    "internalInvitees": internalInviteesSelected,
                    "externalInvitees": clientAttendeesSelected,
                    "detailedDescription": detailedDescription,
                    "eventOwnerId" :selectedOwner,
                    "strType" : saveeventType 
                });
            }           
            else{
                action = component.get("c.saveNewEvent");
                action.setParams({               
                    "e": newReport,
                    "internalInvitees": internalInviteesSelected,
                    "externalInvitees": clientAttendeesSelected,
                    "detailedDescription": detailedDescription,
                    "eventOwnerId" :selectedOwner,
                    "contactIdData" : contactData,
                    "activityFlag" : activityFl,
                    "activityType" : activityType,
                    "selectAllCheckboxValue" : selectAllCheckboxValue,                
                    "myContactListSelect" : myContactListSelect,
                    "filters" : filters
                });   
            }
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('State' + state);
                if (state === "SUCCESS") {
                    component.set("v.hasErrors", false);
                    var results = {};
                    results =  response.getReturnValue();
                    console.log('results: ' , results);  
                    var navigateValue = '';
                    
                    Object.entries(results).forEach(([key, value]) => {
                        console.log(key + ' ' + value); 
                        
                        if(saveeventType == 'By Contact' || saveeventType == 'By Account'){
                            if(key.startsWith("Success")){
                                component.showMessage("Created",$A.get("$Label.c.Call_Report_Created_Successfully"),"Success");
                                //_self.navigateToHomepage(component);               
                            } 

                            if(key.startsWith("Error")){
                            validationResult.push({
                            message :  value
                            });
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                            var saveButton = component.find("saveButton");
                            var saveNewButton = component.find("saveNewButton");
                            saveButton.set("v.disabled", false);
                            saveNewButton.set("v.disabled", false);
                            }
                        }
                        else{                        
                            if(key.startsWith("Event ID") && activityFl === false){
                                //_self.navigateToRecord(component, value);
                                navigateValue = value;
                            }
                            if(key.startsWith("Campaign ID") && activityFl === true){
                                //_self.navigateToRecord(component, value);
                                navigateValue = value;
                            }
                            if(key.startsWith("Error")){
                                validationResult.push({
                                    message :  value
                                });
                                component.set("v.hasErrors", true);
                                component.set("v.errorMessages", validationResult);
                                document.body.scrollTop = document.documentElement.scrollTop = 0;
                                var saveButton = component.find("saveButton");
                                var saveNewButton = component.find("saveNewButton");
                                saveButton.set("v.disabled", false);
                                saveNewButton.set("v.disabled", false);
                            }
                        }
            });
            if(component.get("v.hasErrors") === false){
                var saveNewCheck = component.get("v.saveNewCheck");
                if(!saveNewCheck && (saveeventType == 'By Contact' || saveeventType == 'By Account')){
                    _self.navigateToHomepage(component);               
                }
                else if(!saveNewCheck)
                    _self.navigateToRecord(component, navigateValue);
                else{
                    //Manmeet
                    var navigationEvent = $A.get("e.force:navigateToComponent");
        
                    navigationEvent.setParams({
                                        componentDef : "c:ActivityEdit",   
                                        componentAttributes: {  
                                            saveNewCheck : saveNewCheck,
                                            isClientMemo : isClientMemo
                                        },
                                        isredirect : true
                                    });
                        
                        navigationEvent.fire();		
                }
            }
            
            } 
 			else if (state === "ERROR") {
                var saveButton = component.find("saveButton");
                
                var saveNewButton = component.find("saveNewButton");
                saveButton.set("v.disabled", false);
                saveNewButton.set("v.disabled", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } 
                else {
                    console.log("Unknown error");
                }
            }
                        });
                        $A.enqueueAction(action);
            }
                    else
                    {
                var saveButton = component.find("saveButton");
                
                var saveNewButton = component.find("saveNewButton");
                saveButton.set("v.disabled", false);
                saveNewButton.set("v.disabled", false);
                component.set("v.hasErrors", true);
                component.set("v.errorMessages", validationResult);
                document.body.scrollTop = document.documentElement.scrollTop = 0;
        }
    },   

    updateEvent : function(component){
        var _self = this; 
        var validationResult = [];
        //component.set("v.newCallReport.Type",component.find("eventType").get("v.value"));
      
        var newReport = component.get("v.newCallReport");
        if(newReport.Create_Type__c!='CI Interactions')
            newReport.L0_Type__c =component.get("v.l0default"); 
        else
        {
            newReport.L0_Type__c =null;
            newReport.CI_Stage__c = component.get("v.selectedStageType");
        }
        
        var internalInviteesSelected = component.get("v.internalInviteesSelected");
        var clientAttendeesSelected = component.get("v.clientAttendeesSelected");
        var detailedDescription = component.get("v.callReportDetailedDescription.LTA_1__c");
        var activityFl = component.get("v.massActivityFlag");
        var contactData = component.get("v.selectedContactData");
        var selectAllCheckboxValue = component.get("v.selectAllCheckboxValue");        
        var myContactListSelect = component.get("v.myContactListSelect");
        var filters = component.get("v.filters");
        this.checkForClientMemo(component);
        var isClientMemo = component.get("v.isClientMemo");
        console.log("assigned to---" + newReport.OwnerId);
        if(contactData == undefined){
            contactData = null;
        }
        if(detailedDescription == undefined){
            detailedDescription = '';
        }
        //Validate Event
        validationResult = _self.validateEvent(newReport, clientAttendeesSelected, internalInviteesSelected, activityFl, component);
        console.log(validationResult);
        if(validationResult.length == 0){
            var action = component.get("c.updateEvent");
            
            newReport.sobjectType = 'Event';
            
            action.setParams({
                "e": newReport,
                "internalInvitees": internalInviteesSelected,
                "externalInvitees": clientAttendeesSelected,
                "detailedDescription": detailedDescription,
                "eventOwnerId" :newReport.OwnerId,
                "contactIdData" : contactData,
                "activityFlag" : activityFl,
                "selectAllCheckboxValue" : selectAllCheckboxValue,                
                "myContactListSelect" : myContactListSelect,
                "filters" : filters
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();                
                if (state === "SUCCESS") {
                    component.set("v.hasErrors", false);
                    var results = {};
                    results =  response.getReturnValue();                    
                    var navigateValue = '';
                    
                    Object.entries(results).forEach(([key, value]) => {
                         
                        if(key.startsWith("Event ID") && activityFl === false){
                        
                        navigateValue = value;
                    }
                    if(key.startsWith("Campaign ID") && activityFl === true){
                        
                        navigateValue = value;
                    }
                    if(key.startsWith("Error")){
                        validationResult.push({
                            message :  value
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                        var saveButton = component.find("saveButton");
                        var saveNewButton = component.find("saveNewButton");
                        saveButton.set("v.disabled", false);
                        saveNewButton.set("v.disabled", false);
                    }
                });
                if(component.get("v.hasErrors") === false){
                    var saveNewCheck = component.get("v.saveNewCheck");
                    if(!saveNewCheck)
                        _self.navigateToRecord(component, navigateValue);
                    else{
                        //Manmeet
                        var navigationEvent = $A.get("e.force:navigateToComponent");
            
                        navigationEvent.setParams({
                                            componentDef : "c:ActivityEdit",
                                            componentAttributes: {  
                                                saveNewCheck : saveNewCheck,
                                                isClientMemo : isClientMemo
                                            },                                        
                                            isredirect : true
                                        });
                            
                            navigationEvent.fire();		
                    }
                }
            } else if (state === "ERROR") {
                var saveButton = component.find("saveButton");
                
                var saveNewButton = component.find("saveNewButton");
                saveButton.set("v.disabled", false);
                saveNewButton.set("v.disabled", false);
                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }else{
        var saveButton = component.find("saveButton");
        
        var saveNewButton = component.find("saveNewButton");
        saveButton.set("v.disabled", false);
        saveNewButton.set("v.disabled", false);
        component.set("v.hasErrors", true);
        component.set("v.errorMessages", validationResult);
        document.body.scrollTop = document.documentElement.scrollTop = 0;
    }
},    
    updateRelatedTo : function(component){
        console.log('************** updateRelatedTo START ************');
        var _self = this;
        var validationResult = []; 
        var newReport = component.get("v.newCallReport");
        var isJapanFIUser = component.get("v.isJapanFIUser");
        newReport.sobjectType = 'Event';        
        var whatId = newReport.whatId;
        var relatedToObject = component.get("v.relatedToObject");
        console.log('relatedToObject ' + relatedToObject);
        
        if(whatId == undefined){
            var clientAttendeesSelected = component.get("v.clientAttendeesSelected");
            console.log('clientAttendeesSelected: ' + clientAttendeesSelected);
            console.log('whatId: ' + whatId);
            
            if((clientAttendeesSelected != undefined || 
                clientAttendeesSelected != null) && 
               (whatId == undefined  && relatedToObject != 'Opportunity')){
                var recordId = component.get("v.recordId");
                console.log('recordId: ' + recordId);
                var action = component.get("c.populateWhatId");
                var primaryContact = clientAttendeesSelected[0];
                console.log('First contact: ' + primaryContact);
                
                action.setParams({
                    "primaryContactId": primaryContact,
                    "e": newReport
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result =  response.getReturnValue();
                        console.log('result: ' + result);
                        
                        if(newReport.WhatId != result){
                            component.set("v.newCallReport.WhatId", result);
                            
                        }
                        
                        if(result != null && isJapanFIUser == false){                
                            var array = [];
                            array.push(result);
                            component.set("v.relatedToObject", "Account");
                            component.set("v.relatedToAccountSelected", array);
                            
                            component.find("related-to-account").callPreSelect();
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();                        
                        if (errors) {
                            if (errors[0] && errors[0].message) {                                
                                validationResult.push({
                                    message :  errors[0].message
                                });
                                component.set("v.hasErrors", true);
                                component.set("v.errorMessages", validationResult);
                                document.body.scrollTop = document.documentElement.scrollTop = 0;
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }                
    },

    updateRelatedToRic : function(component){
        console.log('************** updateRelatedToRic START ************');
        var newReport = component.get("v.newCallReport");
        newReport.sobjectType = 'Event';        
        var ricCodes =  component.get("v.ricCodes");
        newReport.Ticker__c = ricCodes.join();
        //component.set("v.newReport.Ticker__c", newReport.Ticker__c);
        console.log(newReport.Ticker__c);
    },
        
        updateAssignedTo : function(component, event){
            if(event.getParam("values").length >= 1){
                var accountIds = event.getParam("values");          
                component.set("v.newCallReport.OwnerId", accountIds[0]);
                //component.set("v.assignedToRecordId", accountIds[0]);
                
                //Update for JIRA Sales-3644
                //var assignedUser = component.find("assignedToUser");
                //assignedUser.set("v.recordId", component.get('v.assignedToRecordId'));                
                //assignedUser.reloadRecord();
                //added for JIRA SALES 3510
                this.getObjectiveMandatory(component);                                
            }else
                component.set("v.newCallReport.OwnerId", []);
        },
            
            updateEventType : function(component, event){
                var type = component.get("v.selectedEventType")  ;
                
                var ismass = component.get("v.massActivityFlag");
                component.set("v.newCallReport.Type", type);               
                var CILabel = $A.get("$Label.c.Event_CI_Interactions");
                var callReportLblNonCPIntro = $A.get("$Label.c.Event_Call_Report_Notes_Non_Cap_Intro");
                var callReportLbl = $A.get("$Label.c.Event_Call_Report_Notes");
                
                var recordId = component.get("v.recordId");
                if(recordId == undefined){
                    var parentId = component.get("v.relatedToId");
                    
                    if(parentId != undefined){
                        recordId = parentId;
                    }else{
                        recordId = null;
                    }
                    
                } 
                if(component.get('v.createTypeChange'))
                {
                    this.initialisel1EventTypes(component,event);
                    //this.initialiseSectors(component)
                }
                console.log('Selected Value 1: ' + component.get('v.createVal'));
                console.log('Selected Value 1: ' + component.get("v.newCallReport.Create_Type__c"));
                if(component.get("v.isCapIntro")){
                    component.set("v.newCallReport.Create_Type__c",component.get('v.createVal'));
                    if(component.get("v.createVal") == CILabel){
                        component.set('v.defaultInitialiseCallReportLoad',false);
                        if(!component.get('v.l1Changed')) {
                            this.initialisel1EventTypes(component,event);
                            //this.initialiseSectors(component);
                        }
                        else
                            component.set('v.l1Changed', false);   
                        
                        this.showHideMeetingControls(component);
                        component.set("v.newCallReport.L0_Type__c","");
                        component.set("v.newCallReport.Activity_Flag__c","");
                        component.set("v.newCallReport.IBOR_Status__c","");

                        this.resetActivityFlagStatusDetails(component);
                    }
                    else
                    {
                         component.set('v.defaultInitialiseCallReportLoad',false);
                        if(component.get("v.createVal") == callReportLblNonCPIntro){
                        
                            this.showHideMeetingControls(component); 
                        }
                        else{
                            if(component.get("v.createVal")===callReportLbl)
                            {
                                this.showHideMeetingControls(component);
                            }
                            else
                            {
                                this.showHideMeetingControls(component);
                            }
                        }
                        component.set("v.newCallReport.CI_Stage__c","");
                        var l0default = component.get('v.l0default');
                        component.set("v.selectedl0EventType",l0default);
                        var l1default = component.get('v.l1default');
         
                        if(!component.get('v.l1Changed') && recordId == null)
                        {
                            if(!component.get('v.isEQUser'))
                                this.loadActivityValues(component,l0default);
                            else
                                this.loadActivityValues(component,l1default);
                            
                            if(!component.get('v.isEQUser'))
                                this.setL1TypeDefaultValue(component,l0default);                             
                        }
                        else
                        {
                            this.loadActivityValues(component,type);
                            component.set('v.l1Changed', false);
                        }
                        
                        if(type!=undefined && type!=null && type!='' && component.get('v.isEQUser')){
                            this.setL0DefaultValue(component,type);
                        }
                    }                    
                }
                else
                {
                    var l0default = component.get('v.l0default');
                    component.set("v.selectedl0EventType",l0default);
                    if(!component.get('v.isEQUser'))
                        this.loadActivityValues(component,l0default);
                    else
                        this.loadActivityValues(component,type);     
                    if(type!=undefined && type!=null && type!='' && component.get('v.isEQUser')){
                        this.setL0DefaultValue(component,type);
                    }
                }                 
            },
                
        validateEvent: function(newEvent, clientAttendees, internalInvitees, activityFlag, component){
            var validationResult = [];
            
            var subject = newEvent.Subject;
            var description = newEvent.Description;
            var privacy = newEvent.Private_Flag__c;
            var assignedTo = newEvent.OwnerId;
            var activityType = newEvent.Type;
            var isClientMemo = component.get("v.isClientMemo");
            var isJapanFIUser = component.get("v.isJapanFIUser");

            if(privacy == undefined){
                privacy = false;
            }
            
            var relatedToId =  newEvent.WhatId;                                         
            //Check for subject
            if(subject == undefined || subject == '' || subject.length == 0){
                validationResult.push({
                    message :  $A.get("$Label.c.Please_enter_a_subject_for_the_event")
                });
            }
            
        //Check for privacy
            if(privacy != undefined && privacy == true){
                if(relatedToId == undefined || relatedToId.startsWith("006") == false){
                    validationResult.push({
                        message :  $A.get("$Label.c.Event_Privacy_Error")
                    });
                }else{   
                }
            }
            if(activityFlag != undefined && activityFlag === false){
                
                //Check for at least one contact 
                if( (clientAttendees== '' || clientAttendees == undefined  || clientAttendees.length == 0) && 
                    activityType !== "No Direct Client Interaction" 
                     ){
                    validationResult.push({
                        message :  $A.get("$Label.c.Please_select_at_least_one_Client_Attendee")
                    });                
                }                   
                //No client attendees and no opportunity chosen for Normal users
                else if ( (clientAttendees== '' || clientAttendees == undefined  || clientAttendees.length == 0) &&
                    (relatedToId == undefined || relatedToId.startsWith("006") == false) && !isJapanFIUser ){
                        validationResult.push({
                            message :  $A.get("$Label.c.Please_select_an_Opportunity_or_at_least_one_Client_Attendee")
                        });
                }                   
                //Opportunity is compulsory for Japan FI users
                // else if( isClientMemo && (relatedToId == undefined || relatedToId.startsWith("006") == false) && isJapanFIUser){
                //     validationResult.push({
                //         message :  'Your privacy flag was set to true thus the activity should be related to an opportunity.'
                //     });                         
                // }                

            }
            if(assignedTo == undefined || assignedTo == "" || assignedTo.length == 0){
                validationResult.push({
                    message : $A.get("$Label.c.Please_enter_Assigned_To")
                }); 
            }
            if(newEvent.L0_Type__c === 'Pre-meeting Notification' && newEvent.Type === 'Pre-meeting Notification'){
                let now = new Date();
                if($A.localizationService.isAfter(now,newEvent.EndDateTime)){
                    validationResult.push({
                        message : $A.get("$Label.c.Activity_Type_Subtype_Cannot_Be_Pre_meeting_Notification_After_Meeting")
                    });
                }
            }
            return validationResult;
    },
        
        updateEndDate : function (component, event, eventTypeChanged, startChanged){
                        
            var recordId = component.get('v.recordId');
            
            var durationMap = component.get('v.defaultDuration');           
            var l1default = component.get('v.newCallReport.Type');  
            var durationTime = durationMap[l1default] ;   
            var massActivityFlag = component.get('v.massActivityFlag');
        
            if(!massActivityFlag){
                if((recordId == undefined || eventTypeChanged) || (recordId != undefined && startChanged)){
                    //For setting end time as per user.             
                    var d = new Date();
                    d = component.find("startDateInput").get("v.value");
                    
                    var start  = moment(d);
                    start.add(durationTime, 'minutes');
                    var endDate = new Date();
                    endDate = start.toISOString();
                    
                    var endDateTime = component.find("endDateInput");
                    endDateTime.set("v.value", endDate);                
                }                 
            }
            else{
                var d = new Date();
                d = component.find("startDateInput").get("v.value");
                
                var start  = moment(d);
                start.add(60, 'minutes');
                var endDate = new Date();
                endDate = start.toISOString();
                
                var endDateTime = component.find("endDateInput");
                endDateTime.set("v.value", endDate);  
            }
            
        },
         
        updateDuration : function(component){
            //moment.js is used to find difference between end and start datetime    
            var flag = component.find("allDayEventInput").get("v.checked");
            //to check and update whether it is all day event or not
            if(!flag){
                var startDatetime = moment(component.get('v.newCallReport.StartDateTime'));
                var endDatetime = moment(component.get('v.newCallReport.EndDateTime'));
                var durationDifference = endDatetime.diff(startDatetime, 'minutes');
    
                var durationInMinutes = component.find("durationInMinutes");
                durationInMinutes.set("v.value", durationDifference); 
            }                 
        },

        round :function(date, duration, method) {
            return moment(Math[method]((+date) / (+duration)) * (+duration)); 
        },
                
        updatePrivacyFlag :function (component, event){
            var newReport = component.get("v.newCallReport");
            
            var flag = component.find("privateEventInput").get("v.checked");        
            component.set("v.newCallReport.IsPrivate", flag);
        },
            
        updateAllDayEventFlag :function (component, event){
            var newReport = component.get("v.newCallReport");
            
            var flag = component.find("allDayEventInput").get("v.checked");
            component.set("v.newCallReport.IsAllDayEvent", flag);
            var flag = component.find("allDayEventInput").get("v.checked");
            //to check and update whether it is all day event or not
            if(flag){
                var durationInMinutes = component.find("durationInMinutes");
                durationInMinutes.set("v.value", "1440");
            }
            else
                this.updateDuration(component);
        },
            
            updateInternalInvitees :function (component, event){
                if(event.getParam("values").length >= 1){
                    component.set("v.internalInviteesSelected", event.getParam("values"));

                }
                else{
                    component.set("v.internalInviteesSelected", []);
                }       
            }, 
                
                updateExternalInvitees : function (component, event){
                    var _self = this;
                    var isJapanFIUser = component.get("v.isJapanFIUser");
                    if(event.getParam("values").length >= 1){
                        component.set("v.clientAttendeesSelected", event.getParam("values"));
                        if(isJapanFIUser == false){
                            _self.updateRelatedTo(component);
                        }
                        
                    }
                    else{
                        component.set("v.clientAttendeesSelected", []);
                    } 
                }, 

                updateRicCode : function (component, event){
                    var _self = this;
                    var isJapanFIUser = component.get("v.isJapanFIUser");
                    console.log(event.getParam("values"));
                    console.log(event.getParam("data"));
                    component.set("v.ricCodeSelected", event.getParam("data"));
                    component.set("v.ricCodesIds", event.getParam("values"));
                    var ricCodes = [];
                    var ricCodesTemp = Object.values(component.get('v.ricCodeSelected'));
                    
                    for(var i = 0; i < ricCodesTemp.length; i++) {
                        ricCodes.push(ricCodesTemp[i]['SObjectLabel']);
                    }
                    if(event.getParam("values").length >= 1){
                        component.set("v.ricCodes", ricCodes);
                        if(isJapanFIUser == false){
                            _self.updateRelatedToRic(component);
                        }
                        
                    }
                    else{
                        component.set("v.ricCodes", []);
                        var newReport = component.get("v.newCallReport");
                        newReport.Ticker__c = '';
                    } 
                }, 
                            
        
            
            checkRecordObjectTypeByPrefix : function(recordId){
                var objectType = '';
                
                if(recordId.startsWith("001")){
                    objectType = "Account";
                }
                if(recordId.startsWith("006")){
                    objectType = "Opportunity";
                }
                if(recordId.startsWith("701")){
                    objectType = "Campaign";
                }
                if(recordId.startsWith("003")){
                    objectType = "Contact";
                }
                if(recordId.startsWith("005")){
                    objectType = "User";
                }
                if(recordId.startsWith("00U")){
                    objectType = "Event";
                }
                if(recordId.startsWith("00T")){
                    objectType = "Task";
                }
                
                return objectType;
            }, 
                
                toggleShowHideClass : function(component,event,secId) {
                    
                    var acc = component.find(secId);
                    $A.util.toggleClass(acc, "slds-show");  
                    $A.util.toggleClass(acc, "slds-hide"); 
                }, 
                    
                    
                    saveContact: function(component){
                        var _self = this;
                        
                        var contact = component.get("v.newContact");
                        contact.sobjectType = 'Contact';
                        var selectedAddress = component.get("v.selectedAddress");
                        var validationResult = [];
                        var action = component.get("c.createContact");
                        
                        action.setParams({
                            "c" : contact,
                            "rmAccountId" : selectedAddress
                        });
                        
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var result =  response.getReturnValue();
                                
                                var results = {};
                                results =  response.getReturnValue();
                                
                                console.log(results);
                                Object.entries(results).forEach(([key, value]) => {
                                    if(key.startsWith("Contact ID")){
                                    var c = component.get("v.clientAttendeesSelected");
                                    c.push(value);
                                    component.set("v.clientAttendeesSelected", c);
                                    component.find("lookup-external-contact").callPreSelect();
                                    _self.hideSpinner(component);
                                    _self.closeContactLookup(component);
                                    contact.FirstName = '';
                                    contact.LastName = '';
                                    contact.Email = '';
                                    contact.Phone = ''; 
                                    contact.Salutation = '';
                                    contact.Local_Language_First_Name__c = '';
                                    contact.Local_Language_Last_Name__c = '';
                                    contact.AccountId = '';
                                    //added for JIRA 3521
                                    contact.PositionPicklist__c = '';
                                    contact.Research_Email__c = '';
                                    //added for JIRA 3561
                                    contact.Title = '';
                                    component.set("v.selectedAddress", "");
                                    var addresses = [];
                                    component.set("v.addressOptions", addresses);
                                    component.set("v.newContact", contact);
                                    
                                }
                                                                
                                                                if(key.startsWith("Error")){
                                    component.set("v.showNewContactPopup", true);
                                    _self.hideSpinner(component);
                                    validationResult.push({
                                        message :  value
                                    });
                                    component.find("newcontact-account").callPreSelect();
                                    component.set("v.hasContactErrors", true);
                                    component.set("v.contactErrorMessages", validationResult);
                                    
                                    var box = component.find("contactPopUp");
                                    console.log(box.get("v.class"));
                                    
                                    $A.util.addClass(box, "contactPopUpError");
                                    
                                }
                            });
                            
                        }else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    validationResult.push({
                                        message :  errors[0].message
                                    });
                                    component.set("v.hasErrors", true);
                                    component.set("v.errorMessages", validationResult);
                                    document.body.scrollTop = document.documentElement.scrollTop = 0;
                                }
                            } else {
                                console.log("Unknown error");
                            }
                        }
                    });

        $A.enqueueAction(action);

        }, 
    
    
    closeContactLookup :function(component, event, helper){
        component.set("v.showContactLookup", false);
    },
        
        navigateToContactList : function(component, myContactListSelect){                
            
            component.find("navigationService").navigate({
                "type": "standard__component",
                "attributes": {
                    "componentName" : "c__ContactList" 
                },
                "state" : { 
                    //"myContactListSelect" : myContactListSelect
                }
            }, true);            
    },
        
        
    showSpinner : function(component, event, helper){               
        var spinner = component.find("pageSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
        
        hideSpinner : function(component, event, helper){                  
            var spinner = component.find("pageSpinner");
            $A.util.addClass(spinner, "slds-hide");
        },
            
            
    hideShowControls :function(component,event,helper){
        var CILabel = $A.get("$Label.c.Event_CI_Interactions");
        var callReportLblNonCPIntro = $A.get("$Label.c.Event_Call_Report_Notes_Non_Cap_Intro");
        var callReportLbl = $A.get("$Label.c.Event_Call_Report_Notes");
        console.log('callReportLblNonCPIntro');
        console.log(callReportLblNonCPIntro);
        var stageD = component.find("stageDiv");
        var createD = component.find("createDiv");
        var fundD = component.find("relatedToSearchFundDiv");                       
        var relatedD = component.find("relatedToDiv");
        var relatedSearchD = component.find("relatedToSearchDiv");
        var privateEventD = component.find("privateEventDiv");
        var typeD = component.find("typeDiv");
        var privateEventInputD = component.find("privateEventInput");
        var bluefireEventD = component.find("bluefireEventInput");
        var clientManagerAttendeesD =  component.find("clientManagerAttendeesDiv");
        var clientInvestorAttendeesD = component.find("clientInvestorAttendeesDiv");
        var clientAttendeesDiv = component.find("clientAttendeesDiv");
        var internalAttendeesDiv = component.find("internalAttendeesDiv");
        var attendeesButtonD = component.find("attendeesButtonDiv");
        var accountLookupD = component.find("accountLookupDiv");
        var coveredAccCheckboxD = component.find("coveredAccCheckboxDiv");
        var splitD = component.find("splitDiv");

        if(component.get("v.isCapIntro")){        
            $A.util.removeClass(createD, "slds-hide");
            console.log('createVal');
            console.log(component.get("v.createVal"));
            if(component.get("v.createVal")==CILabel) { 
                $A.util.removeClass(stageD, "slds-hide"); 
                $A.util.removeClass(fundD, "slds-hide");                    
                var recordId = component.get("v.recordId");
                if(recordId == undefined || recordId == ''){
                    component.set('v.newCallReport.Subject','CI Interactions'); 
                    component.set('v.newCallReport.Description','Investor Feedback :');
                }                                
            }
            else
            {
                $A.util.addClass(stageD, "slds-hide"); 
                $A.util.addClass(fundD, "slds-hide");
                var recordId = component.get("v.recordId");
                if(recordId == undefined || recordId == ''){
                    component.set('v.newCallReport.Subject',''); 
                    component.set('v.newCallReport.Description','');
                }
                component.set("v.selectedStageType",""); 
                //component.set("v.selectedEventType","");
            }
            
            if(component.get("v.createVal")===callReportLblNonCPIntro){
                $A.util.addClass(clientManagerAttendeesD, "slds-hide"); 
                $A.util.addClass(clientInvestorAttendeesD, "slds-hide");
                this.showHideMeetingControls(component);
                
                
                component.set("v.selectedStageType","");
                //component.set("v.selectedEventType","");
                if(component.get("v.massActivityFlag")){
                    $A.util.addClass(clientAttendeesDiv, "slds-hide"); 
                }
                else
                {
                    $A.util.removeClass(clientAttendeesDiv, "slds-hide"); 
                }
                
                $A.util.removeClass(internalAttendeesDiv, "slds-hide"); 
                if(component.get("v.massActivityFlag")){
                    $A.util.addClass(relatedD, "slds-hide");
                    $A.util.addClass(accountLookupD, "slds-hide");
                    $A.util.addClass(coveredAccCheckboxD, "slds-hide");
                    $A.util.addClass(splitD, "slds-hide");
                    $A.util.addClass(relatedSearchD, "slds-hide");
                    $A.util.addClass(privateEventD, "slds-hide");
                    $A.util.addClass(privateEventInputD, "slds-hide");
                    $A.util.addClass(bluefireEventD, "slds-hide");
                    $A.util.addClass(attendeesButtonD,"slds-hide");
                }
                else
                {
                    $A.util.removeClass(relatedD, "slds-hide");
                    $A.util.removeClass(accountLookupD, "slds-hide");
                    $A.util.removeClass(coveredAccCheckboxD, "slds-hide");
                    $A.util.removeClass(splitD, "slds-hide");
                    $A.util.removeClass(relatedSearchD, "slds-hide");
                    $A.util.removeClass(privateEventD, "slds-hide");
                    $A.util.removeClass(privateEventInputD, "slds-hide");
                    $A.util.removeClass(bluefireEventD, "slds-hide");
                    $A.util.removeClass(attendeesButtonD,"slds-hide");
                }
            }
            else
            {
                $A.util.removeClass(clientManagerAttendeesD, "slds-hide"); 
                $A.util.removeClass(clientInvestorAttendeesD, "slds-hide");                  
                $A.util.addClass(clientAttendeesDiv, "slds-hide"); 
                $A.util.addClass(internalAttendeesDiv, "slds-hide"); 
                $A.util.addClass(relatedD, "slds-hide");
                $A.util.addClass(accountLookupD, "slds-hide");
                $A.util.addClass(coveredAccCheckboxD, "slds-hide");
                $A.util.addClass(splitD, "slds-hide");
                $A.util.addClass(relatedSearchD, "slds-hide");
                $A.util.addClass(privateEventD, "slds-hide");
                $A.util.addClass(privateEventInputD, "slds-hide");
                $A.util.addClass(bluefireEventD, "slds-hide");
                $A.util.addClass(attendeesButtonD,"slds-hide");
                this.showHideMeetingControls(component);
            }
            
            
        }
        else
        {
            $A.util.addClass(stageD, "slds-hide");  
            $A.util.addClass(createD, "slds-hide");
            $A.util.addClass(fundD, "slds-hide");
            component.set("v.selectedStageType","");
            var recordId = component.get("v.recordId");
            var splitDiv = component.find("splitDiv");
            var massActivity = component.get("v.massActivityFlag");
            console.log('massActivity ***'+ massActivity);
            if((recordId == undefined || recordId == '') && massActivity == false){
                $A.util.removeClass(splitDiv,'slds-hide');
                var clientDiv = component.find("clientAttendeesDiv");
                console.log('clientDiv***'+clientDiv);
                $A.util.removeClass(clientDiv,'marginless'); 
                $A.util.addClass(clientDiv,'marginmore');  
            }
            else{
                var clientDiv = component.find("clientAttendeesDiv");
                $A.util.addClass(clientDiv,'marginless'); 
                $A.util.removeClass(clientDiv,'marginmore');  
            }
        }
        
        component.set('v.newCallReport.Create_Type__c',component.get('v.createVal'));
        var typeSelect = component.find("createType").get("v.value");
        
        if(typeSelect == CILabel){
            component.set("v.isTypeCI","true");
        }
        else
        {
            component.set("v.isTypeCI","false");
        }
        
    },
                            
    initialiseAllData : function(component, event, helper){
        component.set("v.newCallReport", "");
        component.set("v.internalInviteesSelected", [{}]);
        component.set("v.InternalInvitees","");
        component.set("v.clientAttendeesSelected",[{}]);
        component.set("v.clientAttendees","");
        component.set("v.callReportDetailedDescription.LTA_1__c","");
        component.set("v.massActivityFlag","");
        component.set("v.modelRequest","");
        component.set("v.activityType","");
        component.set("v.selectAllCheckboxValue","");
        component.set("v.myContactListSelect","");
        component.set("v.filters","");  
        component.set("v.relatedToAccountSelected","");
        component.set("v.relatedToOpportunitySelected","");
        component.set("v.relatedToCampaignSelected",""); 
        component.set("v.relatedToAccount","");
        component.set("v.selectedAddress","");
        component.set("v.addressQuery","");  
        component.set("v.areJSScriptsLoaded",true);
        component.set("v.needToProcessReRenderLogic",true);
        var accountComp = component.find("related-to-account");
        accountComp.reset();
        var externalClient = component.find("lookup-external-contact");
        externalClient.reset();
        var internalClient = component.find("lookup-internal-contact");
        internalClient.reset();
        component.set("v.hasErrors", false);
        component.init(); 
        
    },                
    setDefaultMassActivityTypes : function(component, callReport, activityType){                 
        //For setting default values for Voicemail and Model request when navigted through ContactList
        if(callReport.Id == undefined){                           
            if(activityType == 'Voicemail'){
                callReport.Type = activityType;                
                callReport.L0_Type__c = 'eDial';                                    
            }
            else{
                callReport.Type = activityType;
                callReport.L0_Type__c = 'Email/Chat';                    
            }
        }
        
        component.set('v.massActivitySubType', callReport.Type);
        component.set('v.massActivityType', callReport.L0_Type__c);
        component.set('v.l0default', callReport.L0_Type__c);
    },
    //Added for JIRA SALES-3521 
    initialisePositionValues : function(component){
        console.log('in initialisePositionValues'); 
    	var action = component.get("c.getPositionPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var types = [];
            if (state === "SUCCESS") {
                var results =  response.getReturnValue();
                for(var k in results){
                    types.push(results[k].textVal);
                }
                component.set("v.avaliableposition", types);              
            }});
        $A.enqueueAction(action);
    },
    getObjectiveMandatory : function(component,helper){
        var validationResult = [];
        var action = component.get("c.isAEJSalesUser");
        var l1type = component.get("v.newCallReport.Type");
        var l0type = component.get("v.newCallReport.L0_Type__c");
        var l1Typedefault = component.get("v.l1default");
        var l0Typedefault = component.get("v.l0default");
        var userRole = component.get('v.assignedToUserField.UserRole.Name');
        var userProfile = component.get('v.assignedToUserField.Profile.Name');
        //var userId = component.get('v.assignedToRecordId');
        var owneid = component.get("v.newCallReport.OwnerId");
        var newReport = component.get("v.newCallReport");
        var assignedto = component.get("v.assignedToSelected");
        console.log('type 1::'+ l1type);
        console.log('type 2 ::'+ l1type);
        console.log('type default ::'+ l1Typedefault);
        console.log('type default ::'+ l0Typedefault);
        console.log('type userRole ::'+ userRole);
        console.log('type userProfile ::'+ userProfile);
        //console.log('type userId ::'+ userId);
        console.log('type userId ::'+ owneid);
        console.log('type userId ::'+ assignedto);
        console.log('type userId ::'+ newReport.OwnerId);
        
        if(l0Typedefault != undefined && l0Typedefault != null && l1Typedefault != undefined && l1Typedefault != null && owneid != undefined && owneid !=null){
            console.log('in mandatory else');
            action.setParams({
                "l0Type" : l0Typedefault,
                "l1Type" : l1Typedefault,
                "assignedto" : owneid
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var isAEJAnalystUser = false;
                    isAEJAnalystUser = response.getReturnValue();
                    if(isAEJAnalystUser!=undefined && isAEJAnalystUser!=null)
                    {                    
                        component.set('v.isObjectiveMandatory',isAEJAnalystUser);
                        console.log('isAEJAnalystUser ::'+isAEJAnalystUser);                    
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {                        
                            validationResult.push({
                                message :  errors[0].message
                            });
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }   
        else{
            console.log('in mandatory else');
        }  
    },

    showOnlyCoveredAccountOppo : function(component){
        var validationResult = [];
        var relatedToData = component.get("v.newCallReport.WhatId");              
        if(relatedToData == null || relatedToData == 'undefined' || relatedToData == ''){
            var action = component.get("c.getDefaultCoveredAccountOpportunity");
            action.setParams({
                "accountId" : component.get("v.accountLookupIdSelected")
            })

            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var result = response.getReturnValue();
                    console.log('-------coveredAccountData-----');
                    console.log(result);
                    var array = []; 
                    if(result != undefined || result != null){
                       
                                           
                        array.push(result);
                       
                    }

                    component.set("v.newCallReport.WhatId", result);
                    component.set("v.relatedToOpportunitySelected", array);
                    component.find("related-to-opportunity").callPreSelect();
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {                        
                            validationResult.push({
                                message :  errors[0].message
                            });
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }                    
                }
            });
            $A.enqueueAction(action);
        } 
    },
   
    checkForClientMemo : function(component){
        var type = component.get("v.newCallReport.Type");        
        if(type != null || type != undefined || type != ''){
            if(type != "No Direct Client Interaction")
                component.set("v.isClientMemo", false);
            else
                component.set("v.isClientMemo", true);
        }            
    },

    initialiseActivityStatus :function(component){
        var activityTypeDependentStatusValuesAction = component.get("c.getActivityFlagStatusValues");
        
        activityTypeDependentStatusValuesAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var activityFlagDependentStatusMap = response.getReturnValue();
                component.set("v.activityFlagDependentStatusMap", activityFlagDependentStatusMap);
            }
        });
        
        $A.enqueueAction(activityTypeDependentStatusValuesAction);
        
    },

    populateActivityFlagStatusValues: function(component, activityFlagSelectList){
        var activityFlagStatusDiv = component.find("activityFlagStatusDiv");
        var activityFlagStatusList = []; 

        for(var i = 0; i<activityFlagSelectList.length; i++){
            var selectedActivityFlag = activityFlagSelectList[i];
            
            //Populate Activity Flag Status Values
            var actyFlagDependentStatusMap = component.get("v.activityFlagDependentStatusMap");
            if(actyFlagDependentStatusMap != undefined && actyFlagDependentStatusMap != null && actyFlagDependentStatusMap.hasOwnProperty(selectedActivityFlag)){
                    var tempActivityFlagStatusList = actyFlagDependentStatusMap[selectedActivityFlag];
                    if(tempActivityFlagStatusList != undefined && tempActivityFlagStatusList != null){
                        for(var index = 0; index < tempActivityFlagStatusList.length; index++){
                            activityFlagStatusList.push(tempActivityFlagStatusList[index]);
                        }
                    }
            }
        }
        component.set("v.activityStatuses", activityFlagStatusList);  
        
        if(activityFlagStatusList != undefined && activityFlagStatusList != null && activityFlagStatusList.length > 0){
            //Show the Activity Flag Status
            $A.util.removeClass(activityFlagStatusDiv, "slds-hide"); 
        }
        else {
            this.resetActivityFlagStatusDetails(component);
        }
    },

    resetActivityFlagStatusDetails: function(component){
        
        //Hide the Activity Flag Status
        var activityFlagStatusDiv = component.find("activityFlagStatusDiv");
        $A.util.addClass(activityFlagStatusDiv, "slds-hide");

        component.set("v.activityStatuses", {}); 
        component.set("v.selectedActivityStatus", "");
        component.set("v.newCallReport.IBOR_Status__c","");
    }

    
})