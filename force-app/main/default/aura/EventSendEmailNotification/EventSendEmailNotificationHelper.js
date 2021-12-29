({
    initialiseEventFields : function(component) {
        
        var action = component.get("c.populateEventFields");
        var EventId = component.get("v.EventId");       
        action.setParams({"EventId":EventId});         
        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue(); 
                
                var action = component.get("c.getUserName");
                action.setCallback(this,function(response){
                    var user = response.getReturnValue();
                    component.set("v.Sender",user.Name);
                    
                    var userDtls = {};
                    var finalDetails = [];
                    userDtls.Id = user.userId;
                    userDtls.Name = user.Name;
                    userDtls.Email = user.UserEmail;
                    userDtls.UserType = $A.get("$Label.c.Sender");
                    
                    finalDetails.push(userDtls);
                    var userList = component.get("v.UserList");
                    userList.push(userDtls);
                    
                    component.set("v.UserList",userList);
                    component.set("v.SenderUser",userList);
                    
                })
                $A.enqueueAction(action);
                component.set("v.Subject",responseMap[0].Subject);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    FetchInvitees : function(component) {
        
        var action = component.get("c.FetchInvitees");        
        var EventId = component.get("v.EventId");       
        action.setParams({"EventId":EventId}); 
        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue(); 
                console.log('responseMap ::'+responseMap);
                component.set("v.UserList",responseMap);
                component.set("v.InviteeUsers",responseMap);
                
                
            }
        });
        $A.enqueueAction(action);
    }, 
    
    FetchRecipients : function(component){
        component.showSpinner();
        var action = component.get("c.FetchRecipients");
        var EventId = component.get("v.EventId"); 
        var existingId = [];
        var SelectedRegionFID  = $('#FIDSalesMembers').val() == undefined ? '' : $('#FIDSalesMembers').val().toString();
        var SelectedRegionEQ = $('#EQSalesMembers').val() == undefined ? '' : $('#EQSalesMembers').val().toString();
        var SelectedRegionIBD = $('#IBDCoverageMembers').val() == undefined ? '' : $('#IBDCoverageMembers').val().toString();
        console.log($('#InstinetCoverageMembers').val());
        var SelectedRegionInstinet = $('#InstinetCoverageMembers').val() == undefined ? '' : $('#InstinetCoverageMembers').val().toString();
        console.log(SelectedRegionInstinet);
        var AddContactCoverage = component.get('v.AddContactCoverage');
        action.setParams({"FIDRegions" : SelectedRegionFID,
                          "EQRegions" : SelectedRegionEQ,                         
                          "EventId" : EventId,
                          "AddContactCoverage" : AddContactCoverage,
                          "IBDRegions" : SelectedRegionIBD,
                          "InstinetRegions" : SelectedRegionInstinet
                         });
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue();   
                console.log(responseMap);
                var userList = []; 
                var selectUsers = [];
                var inviteeUsers = [];
                component.set("v.UserList",component.get("v.SenderUser"));
                userList = component.get("v.UserList");
                //added for fixing error on the screen SALES-3675
                if(userList == null)
                    userList = [];
                if(userList.length > 0){
                    for(var cvguserindex = 0; cvguserindex < userList.length;cvguserindex++){
                        if(!existingId.includes(userList[cvguserindex].Id)){                        
                            existingId.push(userList[cvguserindex].Id);
                        }
                    } 
                }
                
                if(responseMap.length > 0){ 
                    for(var cvgindex = 0; cvgindex < responseMap.length;cvgindex++){
                        if(!existingId.includes(responseMap[cvgindex].Id)){
                        userList.push(responseMap[cvgindex]); 
                        existingId.push(responseMap[cvgindex].Id);
                        }
                    }
                    
                }
                if(component.get("v.SelectedUsers").length > 0){
                    selectUsers = component.get("v.SelectedUsers");   
                    for(var usrindex = 0; usrindex < selectUsers.length;usrindex++){
                        if(!existingId.includes(selectUsers[usrindex].Id)){                            
                            userList.push(selectUsers[usrindex]); 
                            existingId.push(selectUsers[usrindex].Id);
                        }                       
                    }
                    
                    
                }
                if(component.get("v.InviteeUsers").length > 0){
                    inviteeUsers = component.get("v.InviteeUsers");
                    for(var inviteeindex; inviteeindex < inviteeUsers.length;inviteeUsers++){
                        if(!existingId.includes(inviteeUsers[inviteeindex].Id)){
                            userList.push(inviteeUsers[inviteeindex].Id);
                            existingId.push(selectUsers[usrindex].Id);
                        }
                    }
                    
                }                                
                if(userList.length > 0){
                    component.set("v.UserList",userList);
                }
                 component.hideSpinner();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    
    getUserDetails : function(component,event){
        
        var userDtls = {};
        var indexToRemove = [];
        
        
        userDtls.Id = event.getParam("sObjectId");
        
        userDtls.Name = event.getParam("Name");
        userDtls.Email = event.getParam("Email");
        userDtls.UserType = 'Adhoc';        
        var selectedUsers = component.get("v.SelectedUsers");
        
        if(event.getParam("action") === "delete"){
            
            for(var index = 0 ; index < selectedUsers.length ; index++){
                if(event.getParam("Name") == selectedUsers[index].Name ){
                    indexToRemove.push(index);
                    break;
                }
            }
            
            
            for(var indexl = 0 ; indexl < indexToRemove.length; indexl++){
                selectedUsers.splice(indexToRemove[indexl],1); 
            }
        }
        
        else
        {
            selectedUsers.push(userDtls);
        }
        
        component.set("v.SelectedUsers",selectedUsers);
        
        
    },
    
    FillRegionDropDowns : function(component,event){
        var RegionArray= [];
        RegionArray.push({
            Region : 'Global'                                                                      
        });
        RegionArray.push({
            Region : 'Asia'                                                                      
        });
        RegionArray.push({
            Region : 'Europe'                                                                      
        });
        RegionArray.push({
            Region : 'USA'                                                                      
        });
        RegionArray.push({
            Region : 'JAPAN'                                                                      
        });
        
        
         var RegionArrayIBD= [];
        RegionArrayIBD.push({
            Region : 'Global'                                                                      
        });
        RegionArrayIBD.push({
            Region : 'Asiapac'                                                                      
        });
        RegionArrayIBD.push({
            Region : 'EMEA'                                                                      
        });
        RegionArrayIBD.push({
            Region : 'Americas'                                                                      
        });
        RegionArrayIBD.push({
            Region : 'Japan'                                                                      
        });
        RegionArrayIBD.push({
            Region : 'AEJ'                                                                      
        });        
       

        var $EQSalesMembers = $('#EQSalesMembers').selectize({
            plugins: ['remove_button'],
            persist: true,
            maxItems: 5,
            valueField: 'Region',
            labelField: 'Region',
            searchField: ['Region'],
            // sortField: [{
            //field: 'Region',
            // direction: 'asc'
            // }],
            options: [],
            render: {},
            createFilter: null,
            create: false,
            diacritics: true,
            hideSelected: true,
            onType: function(value) {
                console.log(value);
                //performSkyHighSearch(value);
                
            }
        });
        
        console.log('*****clientAttendeesArray****' + RegionArray);
        var selectizeControl = $EQSalesMembers[0].selectize;
        selectizeControl.clearOptions();             
        selectizeControl.addOption(RegionArray);
        
        console.log('*****Selectize End****');
        
        var $FIDSalesMembers = $('#FIDSalesMembers').selectize({
            plugins: ['remove_button'],
            persist: true,
            maxItems: 5,
            valueField: 'Region',
            labelField: 'Region',
            searchField: ['Region'],
            // sortField: [{
            //field: 'Region',
            // direction: 'asc'
            // }],
            options: [],
            render: {},
            createFilter: null,
            create: false,
            diacritics: true,
            hideSelected: true,
            onType: function(value) {
                console.log(value);
                //performSkyHighSearch(value);
                
            },             
        });
        
        console.log('*****clientAttendeesArray****' + RegionArray);
        var selectizeControl = $FIDSalesMembers[0].selectize;
        selectizeControl.clearOptions();
        selectizeControl.addOption(RegionArray);
        console.log('*****Selectize End****');
        
        
        
        var $IBDCoverageMembers = $('#IBDCoverageMembers').selectize({
        plugins: ['remove_button'],
        persist: true,
        maxItems: 5,
        valueField: 'Region',
        labelField: 'Region',
        searchField: ['Region'],
        // sortField: [{
        //field: 'Region',
        // direction: 'asc'
        // }],
        options: [],
        render: {},
        createFilter: null,
        create: false,
        diacritics: true,
        hideSelected: true,
        onType: function(value) {
            console.log(value);
            //performSkyHighSearch(value);
                
            },             
        });
        
        console.log('*****clientAttendeesArray****' + RegionArrayIBD);
        var selectizeControl = $IBDCoverageMembers[0].selectize;
        selectizeControl.clearOptions();
        selectizeControl.addOption(RegionArrayIBD);
        console.log('*****Selectize End****');

        var $InstinetCoverageMembers = $('#InstinetCoverageMembers').selectize({
            plugins: ['remove_button'],
            persist: true,
            maxItems: 5,
            valueField: 'Region',
            labelField: 'Region',
            searchField: ['Region'],           
            options: [],
            render: {},
            createFilter: null,
            create: false,
            diacritics: true,
            hideSelected: true,
            onType: function(value) {
                console.log(value);
                 
                },             
            });
        
        var selectizeControl = $InstinetCoverageMembers[0].selectize;
        selectizeControl.clearOptions();
        selectizeControl.addOption(RegionArray);
        console.log('*****Selectize End****');
        
        
    },
    
    RemoveSelectedRecipients : function(component,event){
        var userList = component.get("v.UserList");   
        //Added for JIRA-SALES-3675 
        if(userList.length == 1 && (userList[0].canUncheck == undefined || (userList[0].canUncheck != undefined && userList[0].canUncheck == true))){
            userList.splice(0,1); 
        }        
        else
        {
            
            var selItems = component.find("selectedrecipients");           
            var membersToRemove = [];
            var indexToRemove = [];
            for (var i = 0; i < selItems.length; i++) {
                var c = selItems[i];
                if (c.get("v.checked") === true) {
                    membersToRemove.push(c.get("v.name"));
                } 
            }
            console.log('can uncheck ::'+ membersToRemove);
            var userList = component.get("v.UserList");
            
            for(var k=0; k < userList.length; k++){
                
                for(var j = 0 ; j < membersToRemove.length;j++){ 
                     //Added for JIRA-SALES-3675 
                    console.log('can uncheck ::'+ userList[k].canUncheck);
                    if(userList[k].Id == membersToRemove[j] && (userList[k].canUncheck == undefined || (userList[k].canUncheck != undefined && userList[k].canUncheck == true))){
                        indexToRemove.push(k);
                        break;
                    }                        
                }      
            }            
            if(indexToRemove.length === userList.length){
                userList = null;
            }
            else
            {                    
                for(var index = 0 ; index < indexToRemove.length; index++){
                    userList.splice((indexToRemove[index]-[index]),1); 
                }
            }
            
        }
      
        component.set("v.SenderUser",userList);
        component.set("v.UserList",userList);
    },
    
    sendmailToSelf : function(component){
         component.showSpinner();
        var action = component.get("c.sendCntrlEmailToSelf");

        var userList = component.get("v.UserList");
        var EventId = component.get("v.EventId");

        action.setParams({"EventId":EventId,
                          "cmpRecipientList" : JSON.stringify(userList)});

        action.setCallback(this,function(response){
            var state = response.getState();

            var responseMap = response.getReturnValue();
            if(responseMap.IsSuccess){
                component.set("v.isSuccess",true);
                component.set("v.SuccessMessage",responseMap.Message);
                component.set("v.isError",false);
                component.set("v.ErrorMessage",'');
            }
            else
            {
                component.set("v.isSuccess",false);
                component.set("v.SuccessMessage",'');
                component.set("v.isError",true);
                component.set("v.ErrorMessage",responseMap.Message);
            }

            component.hideSpinner();
        });
        $A.enqueueAction(action);
    },

    sendEmail : function(component){
        component.showSpinner();
        var action = component.get("c.sendEmailCmp");
        var userList = component.get("v.UserList");
        var EventId = component.get("v.EventId");

        console.log("in sendEmailNotification");

        action.setParams({"EventId":EventId,
                          "cmpRecipientList" : JSON.stringify(userList)});


        action.setCallback(this,function(response){
            var state = response.getState();



            if(state === "SUCCESS"){
                component.hideSpinner();
                var EventId = component.get("v.EventId");
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": EventId
                });
                navEvt.fire();
            }

        });
        $A.enqueueAction(action);

    },

    checkInstinetContacts : function(component){
        var userList = component.get("v.UserList");
        var includesInstinetContacts = false;
        console.log(userList);
        for(var i = 0; i < userList.length; i++){
            if(userList[i].Email.includes('instinet')){
                includesInstinetContacts = true;
                break;
            }
        }

        if(includesInstinetContacts)
            component.set("v.isOpen", true);
        else
            this.sendEmail(component, includesInstinetContacts);
    },

    cancelAndReturn : function(component,event){
        var EventId = component.get("v.EventId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": EventId
        });
        navEvt.fire();
    },


})