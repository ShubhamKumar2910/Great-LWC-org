({
	loadData : function(component, event, helper){
        
            
        helper.initialiseAVRLabels(component);
       
    },
    
    saveButton : function(component, event, helper){
    	helper.saveData(component);
	},
    
    cancelButton : function(component, event, helper){
    	$A.get("e.force:closeQuickAction").fire();       
	},
    
    onProductChange : function(component){        
        var productComponent = component.find("product");
        var productChanged = productComponent.get("v.value");        
        var productValues = component.get("v.productDependentValues");
         
        //Get the dependent picklist values and if that matches the one selected by user then enable country field to edit.   
        for(var i = 0; i < productValues.length; i++){
            if(productValues[i].value.includes(productChanged)){                
               	component.set("v.disableCountry", false); 
            }
            else{
              	var country = component.find("country");           
                country.set("v.value", "--None--");
                component.set("v.disableCountry", true);
            }
        }             
    },
    
})