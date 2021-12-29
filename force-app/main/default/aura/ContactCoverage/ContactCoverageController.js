({
    doInit : function(component, event, helper){
        component.setRecordDetails();
        helper.getCampaignMemCount(component)
        helper.getCampaignMemData(component);
    },
    
    setRecordDetails : function(component, event, helper){
        //Used when called from Contact_Coverage__c Formula Field
        if(component.get("v.recordId") === null || component.get("v.recordId") === ""){
            var pageReferenceDetails = component.get("v.pageReference");
            if(pageReferenceDetails != null){
            	component.set("v.recordId", pageReferenceDetails.state.c__recordId);
                component.set("v.calledFromFormulaField", true);
            }
        }
    },
    
    updateColumnSorting: function(component, event, helper){ 
        var isAccount = component.get("v.isAccount");             
        console.log('isAccount **'+ isAccount);
        var dataTable;
        if(isAccount == true)
           dataTable = component.find("contactCoverageTable");
        else
          dataTable = component.find("contactCoverageTable1");
    	var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(component, fieldName, sortDirection);
    },

    loadMoreData : function(component, event, helper){
        if (component.get('v.contactCoverageData').length < component.get('v.totalRecordCount')) {
            event.getSource().set("v.isLoading", true);
            console.log('in outer if');  
             var helperFunc = helper.fetchData(component, component.get('v.rowsToLoad'));
        
            helperFunc.then($A.getCallback(function(data){
                console.log('coverage length **'+component.get('v.contactCoverageData').length);
                console.log('total length **'+component.get('v.totalNumberOfRows'));
                console.log('total length 2**'+component.get('v.totalRecordCount'));
                console.log('finite loading **'+component.get('v.enableInfiniteLoading'));
                console.log('is loading **'+event.getSource().get("v.isLoading"));
                
                if (component.get('v.contactCoverageData').length >= component.get('v.totalRecordCount')) {
                    console.log('in if');
                        component.set('v.enableInfiniteLoading', false);
                    } else {
                        var currentData = component.get('v.contactCoverageData');
                        //Appends new data to the end of the table
                        var newData = currentData.concat(data);
                        component.set('v.contactCoverageData', newData); 
                        console.log('in else **'+newData.length);                    
                   }
                   event.getSource().set("v.isLoading", false);
            })             
            ) //close of then
            .catch(function(err){
                console.log("error"+ err);
            });
       }
        else{
            console.log('in outer else');  
       }
    },

    //SALES-3695
    sendContactCoverageEmail : function(component, event, helper){
        location.href = "mailto:" + component.get("v.sendContactCoverageEmail");
    }
})