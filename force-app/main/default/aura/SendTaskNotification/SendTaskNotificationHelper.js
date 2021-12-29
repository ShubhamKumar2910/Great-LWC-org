({
    initialiseEventFields : function(component) {
        
        var action = component.get("c.populateTaskFields");
        var TaskId = component.get("v.TaskId");       
        action.setParams({"TaskId":TaskId});         
        
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
                    userDtls.UserType = 'Sender';
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
    
    
   /* getUserDetails : function(component,event){
        
        var userDtls = {};
        var finalDetails = [];
        userDtls.Id = event.getParam("sObjectId");
        userDtls.Name = event.getParam("Name");
        userDtls.Email = event.getParam("Email");
        userDtls.UserType = 'Adhoc';
        finalDetails.push(userDtls);
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
        
    },*/
    
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
    
    
      RemoveSelectedRecipients : function(component,event){
        var userList = component.get("v.UserList");        
        
        if(userList.length == 1){
            userList.splice(0,1); 
        }
        
        else
        {
            
            var selItems = component.find("selectedUsers");           
            var membersToRemove = [];
            var indexToRemove = [];
            for (var i = 0; i < selItems.length; i++) {
                var c = selItems[i];
                if (c.get("v.value") === true) {
                    membersToRemove.push(c.get("v.text"));
                }
            }
            
            var userList = component.get("v.UserList");
            
            for(var k=0; k < userList.length; k++){
                
                for(var j = 0 ; j < membersToRemove.length;j++){ 
                    
                    if(userList[k].Id == membersToRemove[j]){
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
        
        component.set("v.UserList",userList);
    },
    
   /* RemoveSelectedRecipients : function(component,event){
        
        
         var userList = component.get("v.UserList");
        
        if(userList.length == 1){
            userList.splice(0,1); 
        }
        
        else
        {
        var selItems = component.find("selectedUsers");        
        var membersToRemove = [];
        var indexToRemove = [];
        for (var i = 0; i < selItems.length; i++) {
            var c = selItems[i];  
            if (c.get("v.value") === true) {
                membersToRemove.push(c.get("v.text"));
            }
        }
        var userList = component.get("v.UserList");
        
        for(var k=0; k < userList.length; k++){
            
            for(var j = 0 ; j < membersToRemove.length;j++){ 
                
                if(userList[k].Id == membersToRemove[j]){
                    indexToRemove.push(k);
                    break;
                }            
            }      
        }
        
        for(var index = 0 ; index < indexToRemove.length; index++){
            userList.splice(indexToRemove[index],1); 
        }
        }
        component.set("v.UserList",userList);
    },*/
    
   
    
    sendEmail : function(component,event){
        component.showSpinner();
        var action = component.get("c.sendCntrlEmail");
        var userList = component.get("v.UserList");        
        var TaskId = component.get("v.TaskId");
        
        
        
        action.setParams({"TaskId":TaskId,
                          "cmpRecipientList" : JSON.stringify(userList)}); 

        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                  component.hideSpinner();
                 var TaskId = component.get("v.TaskId");
          var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({                    
                    "recordId": TaskId  
                });
                navEvt.fire();          
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    cancelAndReturn : function(component,event){
        var TaskId = component.get("v.TaskId");
          var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({                    
                    "recordId": TaskId  
                });
                navEvt.fire();    
    },
    
    displaySelectedUsers : function(component,event){
                      
                var userList = []; 
                var selectUsers = [];
             
                component.set("v.UserList",component.get("v.SenderUser"));
                userList = component.get("v.UserList");
                if(component.get("v.SelectedUsers").length > 0){
                 selectUsers = component.get("v.SelectedUsers");   
                    for(var usrindex = 0; usrindex < selectUsers.length;usrindex++){
                       userList.push(selectUsers[usrindex]); 
                    }
                }
                                           
                if(userList.length > 0){
                component.set("v.UserList",userList);
                }
            }
    
    
    
    
    
    
    
    
})