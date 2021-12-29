({
	getContactDetails : function(component) {

        var action = component.get("c.getContactDetails");
        var recId = component.get("v.recordId");
        console.log('Contact record id = ' +recId );
        var me = this;
        
        action.setParams({
             "contactId": recId
        });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State:' + state);
            if (state === "SUCCESS") {
                me.toggleSpnner(component); 
				var responseMap = response.getReturnValue();
                console.log('responseMap : ' + responseMap);
				component.set("v.contact", responseMap);
                var formattedName = '<h1><b>' + responseMap.Name + '</b></h1>';
                component.set("v.contactName", formattedName);
                var contact = component.get("v.contact");
                console.log('Contact : ' + contact.Id + ' ' + contact.FirstName);
            }else if (state === "ERROR") {
                		me.toggleSpnner(component); 
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            else {
                   me.toggleSpnner(component);  
                }
                });

        $A.enqueueAction(action);
	},
	validate : function(component) {
		var me = this;
        if (me.validateForm(component)) {
            console.log('Validation passed');
        }
        else {
            console.log('Validation failed !!');
            return;
        }
        var action = component.get("c.validate");
        var market = component.find('market');
        var asset = component.find('asset');
        var sector = component.find('sector');
        var flags = $('[id$=flagsMultiSelect]').select2("val");  
        var me = this;
        
        var contactIdStr = component.get("v.recordId").toString();
        var marketObjs = market.get('v.selectedObjects');
        var assetObjs = asset.get('v.selectedObjects');
        var sectorObjs = sector.get('v.selectedObjects');
        
        var clonedMarketObjs = new Array();
        for (var i =0 ; i < marketObjs.length ; i++) {
            var clonedMarketObj = {};
            clonedMarketObj.id = marketObjs[i].id;
            clonedMarketObj.text = marketObjs[i].text;
            clonedMarketObj.picklist__c = marketObjs[i].picklist;
            clonedMarketObjs.push(clonedMarketObj);
        }
        
        var clonedAssetObjs = new Array();
        for (var i =0 ; i < assetObjs.length ; i++) {
            var clonedAssetObj = {};
            clonedAssetObj.id = assetObjs[i].id;
            clonedAssetObj.text = assetObjs[i].text;
            clonedAssetObj.picklist__c = assetObjs[i].picklist;
            clonedAssetObjs.push(clonedAssetObj);
        }        
        
        var clonedSectorObjs = new Array();
        for (var i =0 ; i < sectorObjs.length ; i++) {
            var clonedSectorObj = {};
            clonedSectorObj.id = sectorObjs[i].id;
            clonedSectorObj.text = sectorObjs[i].text;
            clonedSectorObj.picklist__c = sectorObjs[i].picklist;
            clonedSectorObjs.push(clonedSectorObj);
        }   
        
        var clonedMarketObjsStr = JSON.stringify(clonedMarketObjs).toString();
        var clonedAssetObjsStr = JSON.stringify(clonedAssetObjs).toString();
        var clonedSectorObjsStr = JSON.stringify(clonedSectorObjs).toString();
        
        var flagsStr = flags.toString();       
        
        console.log(market.get('v.label') + ' = ' +clonedMarketObjsStr );
        console.log(asset.get('v.label') + ' = ' +clonedAssetObjsStr );
        console.log(sector.get('v.label') + ' = ' +clonedSectorObjsStr );
        console.log('Contact record id = ' +contactIdStr  );
        console.log('Flags = ' +flagsStr);
        
        action.setParams({
             "contactId": contactIdStr,
             "marketListstr": clonedMarketObjsStr,
             "assetListstr": clonedAssetObjsStr,
             "sectorListstr": clonedSectorObjsStr,  
             "flags": flagsStr
        });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State:' + state);
            me.enableDisableCreateButton(component, 'true');
            if (state === "SUCCESS") {
                me.toggleSpnner(component);
				var responseMap = response.getReturnValue();
                component.set("v.dataRows", responseMap);
                if (responseMap !=null && responseMap.length > 0) {
                    component.set("v.showTable", "true");
                    var validRows = new Array();
                    for (var i =0 ; i <responseMap.length ; i ++ ) {
                        if (responseMap[i].RESULT== 'PASSED'){
                            validRows.push(responseMap[i]);
                        }
                    }
                    if (validRows.length > 0) {
                        component.set("v.validDataRows", validRows);
                        me.enableDisableCreateButton(component, 'false');
                    }
                }
                console.log('responseMap : ' + responseMap);
            }else if (state === "ERROR") {
                		me.toggleSpnner(component);
                        component.set("v.showTable", "false");
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            else {
                   me.toggleSpnner(component); 
                   component.set("v.showTable", "false");
                }
                });
		me.toggleSpnner(component);
        component.set("v.showTable", "false");
        $A.enqueueAction(action);
	}    ,

    toggleSpnner: function (cmp, event) {
        	var spinner = cmp.find("ciSpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
	    },
    
    validateForm : function (component) {
        var me = this;
        var isValidationPassedForMarket = me.validateFormElement(component.find('market'));
        console.log('Validation passed status for market = ' + isValidationPassedForMarket );
        var isValidationPassedForAsset = me.validateFormElement(component.find('asset'));
        console.log('Validation passed status for asset = ' + isValidationPassedForAsset );
        var isValidationPassedForSector = me.validateFormElement(component.find('sector'));
        console.log('Validation passed status for sector = ' + isValidationPassedForSector );
		return isValidationPassedForMarket && isValidationPassedForAsset && isValidationPassedForSector;
    },
    
    validateFormElement: function(formElementCmp) {
        var isValidationPassed = false;
        var valueList = formElementCmp.get('v.selectedObjects')
        if (valueList != null && valueList.length > 0 ) {
            //Validate Values
            var errorMessage = null;
            for (var i = 0 ; i <valueList.length -1 ; i++ ) {
                if (errorMessage != null)
                    break;
                var optionA = valueList[i];
                var optionACodes = optionA.id.toString().split(':');
                var optionAText = optionA.text;
                for (var j = i+1 ; j <valueList.length; j++ ) {
                    var optionB = valueList[j];
                    var optionBCodes = optionB.id.toString().split(':');
                    var optionBText = optionB.text;
                    if (errorMessage != null)
                    	break;
                    //check if down the heirachy exits
                    for (var k = 0; k <optionACodes.length-1;  k++ ){
                        var optionAParentCode = optionACodes[k];
                        var optionBCode = optionBCodes[optionBCodes.length-1]; 
                        if (optionAParentCode == optionBCode) {
                            errorMessage = 'Please either select ' + optionAText + ' or ' + optionBText + '.';
                            console.log(errorMessage);
                            break;
                        }
                    }
                }
            }  
            if (errorMessage == null) {
             	isValidationPassed = true;
            	formElementCmp.highlightErrorMethod("false");               
            }
            else {
             	isValidationPassed = false;
            	formElementCmp.highlightErrorMethod("true", errorMessage);               
            }
        }
        else {
            isValidationPassed = false;
            formElementCmp.highlightErrorMethod("true","Please complete this field.");
            //formElementCmp.set("v.highlightError", "true");
        }
        return isValidationPassed;
    },
    
    createCI: function(component, event) {
 		var me = this;
		console.log('Helper createCI called.');

		var validRows = component.get("v.validDataRows");
		var action = component.get("c.createCI");
		var validRowsStr = JSON.stringify(validRows);

		console.log('validRowsStr = ' +validRowsStr );
		
		action.setParams({
		     "validRowsStr": validRowsStr
		});
	       
		action.setCallback(this, function(response) {
		    var state = response.getState();
		    console.log('State:' + state);
		    if (state === "SUCCESS") {
			me.toggleSpnner(component);
					var responseMap = response.getReturnValue();
			component.set("v.dataRows", responseMap);
			if (responseMap !=null && responseMap.length > 0) {
			    component.set("v.showTable", "true");
			}
			console.log('responseMap : ' + responseMap);
		    }else if (state === "ERROR") {
					me.toggleSpnner(component);
				component.set("v.showTable", "false");
				var errors = response.getError();
				if (errors) {
				    if (errors[0] && errors[0].message) {
					console.log("Error message: " + errors[0].message);
				    }
				} else {
				    console.log("Unknown error");
				}
			    }
		    else {
			   me.toggleSpnner(component); 
			   component.set("v.showTable", "false");
			}
			});
		me.toggleSpnner(component);
		me.enableDisableCreateButton(component, 'true');
		component.set("v.showTable", "false");
		$A.enqueueAction(action);   
	},
    
    enableDisableCreateButton: function (component, disabled) {
        var createButton = component.find("create-button-ci");
        console.log('createButton = ' + createButton);
        if (disabled == 'false') {
            console.log('Enable the button');
            //createButton.set("v.disabled",false);
            //$A.util.addClass(createButton, 'button-enabled-ci');
           	component.set("v.disableCreateButton", false);
        }
        else {
            console.log('Disable the button');
            //createButton.set("v.disabled",true);
            //$A.util.removeClass(createButton, 'button-enabled-ci');               
            component.set("v.disableCreateButton", true);
        }
	}
})