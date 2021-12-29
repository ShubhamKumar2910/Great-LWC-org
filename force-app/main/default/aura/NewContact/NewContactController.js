({
	init : function(component, event, helper) {
		//helper.checkMifidPermissions(component);
		var america = [
            { value: "", label: "Please select" },
            { value: "Americas- Qualified Institutional Buyer", label: "Americas- Qualified Institutional Buyer" },
            { value: "Americas-Qualified User (other)", label: "Americas-Qualified User (other)" },
            { value: "Qualified User - Academic 大学等教育関係者", label: "Qualified User - Academic 大学等教育関係者" },
            { value: "Qualified User - Journalist Japan 日本メディア・ジャーナリスト", label: "Qualified User - Journalist Japan 日本メディア・ジャーナリスト" },
            { value: "Qualified User - Journalist Non-Japan 海外メディア・ジャーナリスト", label: "Qualified User - Journalist Non-Japan 海外メディア・ジャーナリスト" }
        ];

        var aej = [
            { value: "", label: "Please select" },
            { value: "NJA-Qualifed User", label: "NJA-Qualifed User" },
            { value: "NJA-Qualified Investor", label: "NJA-Qualified Investor" },
            { value: "Qualified User - Academic 大学等教育関係者", label: "Qualified User - Academic 大学等教育関係者" },
            { value: "Qualified User - Journalist Japan 日本メディア・ジャーナリスト", label: "Qualified User - Journalist Japan 日本メディア・ジャーナリスト" },
            { value: "Qualified User - Journalist Non-Japan 海外メディア・ジャーナリスト", label: "Qualified User - Journalist Non-Japan 海外メディア・ジャーナリスト" }
        ];

        var emea = [
            { value: "", label: "Please select" },
            { value: "EMEA-Qualified Investor", label: "EMEA-Qualified Investor" },
            { value: "EMEA-Qualified User", label: "EMEA-Qualified User" },
            { value: "Qualified User - Academic 大学等教育関係者", label: "Qualified User - Academic 大学等教育関係者" },
            { value: "Qualified User - Journalist Japan 日本メディア・ジャーナリスト", label: "Qualified User - Journalist Japan 日本メディア・ジャーナリスト" },
            { value: "Qualified User - Journalist Non-Japan 海外メディア・ジャーナリスト", label: "Qualified User - Journalist Non-Japan 海外メディア・ジャーナリスト" }
        ];

        var japan = [
            { value: "", label: "Please select" },
            { value: "JPN-General Investor (Non-Qualified User) 一般投資家 （GRPアクセス不可なので通常選びません）", label: "JPN-General Investor (Non-Qualified User) 一般投資家 （GRPアクセス不可なので通常選びません）" },
            { value: "JPN-Qualified Institutional Investor 適格機関投資家", label: "JPN-Qualified Institutional Investor 適格機関投資家" },
            { value: "JPN-Qualified User その他（政府機関等の特殊な場合のみ）", label: "JPN-Qualified User その他（政府機関等の特殊な場合のみ）"},
            { value: "JPN-Specified Investor 特定投資家", label: "JPN-Specified Investor 特定投資家"},
            { value: "Qualified User - Academic 大学等教育関係者", label: "Qualified User - Academic 大学等教育関係者" }
        ];
            
        component.set("v.AmericaInvestorOptions", america); 
        component.set("v.AEJInvestorOptions", aej);
        component.set("v.EMEAInvestorOptions", emea);
        component.set("v.JapanInvestorOptions", japan);
		//helper.initialistProductSubscriptions(component);
        //helper.checkForClone(component);
        
        helper.getComponentInitializationInfo(component, event, helper);
        //Added for JIRA SALES-3521
        helper.initialisePositionValues(component);
	},

	save : function(component, event, helper) {
        helper.showSpinner(component);
		helper.saveContact(component,event);
        helper.hideSpinner(component);
	},
    
    cancel : function(component, event, helper){
        var origin = component.get("v.origin");
        var originContactId = component.get("v.editContId");
        if($A.util.isEmpty(originContactId)) {
            originContactId = component.get("v.cloneFrom");
        }
        
        if($A.get("$Browser.formFactor") === "DESKTOP" && origin == 'ContactList'){
            component.find("navigationService").navigate({
                "type": "standard__navItemPage",
                "attributes": {
                    "apiName":"Contact_Lists" },
                "state": {}
            });    
        } else if(!$A.util.isEmpty(originContactId)){
            component.find("navigationService").navigate({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": originContactId,
                    "objectApiName": "Contact",
                    "actionName": "view" 
                },
                "state": {}
            }, true); 
        } else if($A.get("$Browser.formFactor") === "DESKTOP"){
                helper.navigateToHomepage(component);
        } else {
            component.find("navigationService").navigate({
                "type": "standard__navItemPage",
                "attributes": {
                    "apiName":"Home_Mobile" }
            }, true);
        }
    },

    OnReset : function(component,event,helper){
        console.log('On reset called lookup');
        helper.resetMiFIDIIDerivedFromRMAcc(component,event,helper);
        var combobox = component.find("addressCombobox");
        var podCombobox = component.find("podAddressCombobox");
        combobox.clear();
        podCombobox.clear();
        combobox.hideItems();
        podCombobox.hideItems();
        component.set('v.selectedAddress','');
        component.set('v.selectedPodAddress','');
        $A.util.addClass(combobox.find('lookup-pill'),'slds-hide');
        helper.resetMifidInScope(component);
       // helper.updateMifidInScope(component);
    },
    addressCleared : function(component,event,helper){
    	helper.resetMiFIDIIDerivedFromRMAcc(component,event,helper);
        if(component.get('v.relatedToAccount')!='')
        {
            component.set('v.selectedAddress','');
            component.find("addressCombobox").reinitialise();
              helper.resetMifidInScope(component);
           
        }
    },
    podAddressCleared : function(component,event,helper){
    	//helper.resetMiFIDIIDerivedFromRMAcc(component,event,helper);
        if(component.get('v.relatedToAccount')!='')
        {
            component.set('v.selectedPodAddress','');
            component.find("podAddressCombobox").reinitialise();
              //helper.resetMifidInScope(component);
           
        }
    },
    serviceTypeChanged :  function(component, event, helper){},

    grpAccessChanged :  function(component, event, helper){
        var flag = component.find("GRPAccess").get("v.checked");

        var mifidIIAdmin = component.get("v.showMifid");

        if(mifidIIAdmin == false && flag == true){
            helper.defaultSponsor(component);
        }
        if(flag == false){
            component.set("v.contact.Sponsor_Email_Text__c", "");
            component.set("v.contact.Sales_Sponsor__c", "");
        }

    },
    
    preferredLanguageChanged : function(component, event, helper){},

    regionChanged : function(component, event, helper){},
    
    investorTypeChanged : function(component, event, helper){},

    onSalesCommentaryChange : function(component, event, helper) {},

     addressChanged : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            console.log('values');
            console.log(event.getParam("values"));
            component.set('v.selectedAddress',event.getParam("values")[0]);
            console.log('data');
            console.log(event.getParam("data"));
            component.find("podAddressCombobox").reinitialise();
            helper.updateMifidInScope(component);
        }
        var selectedAddress = component.get("v.selectedAddress");
        console.log('selected Address :'+selectedAddress)
    },

    podAddressChanged : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            console.log('pod values');
            console.log(event.getParam("values"));
            component.set('v.selectedPodAddress',event.getParam("values")[0]);
            console.log('pod data');
            console.log(event.getParam("data"));
            //helper.updateMifidInScope(component);
        }
        var selectedPodAddress = component.get("v.selectedPodAddress");
        console.log('Selected Pod Address :' + selectedPodAddress)
    },

    
    contactAccountchanged : function(component, event, helper){
        
        var accountIds = event.getParam("values");
      
        if(event.getParam("values").length >= 1){
            var validationResult = [];
            var action = component.get("c.getAccountAddresses");
            action.setParams({
                    "accountId" : accountIds[0]
                });

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log(result);

                        var addresses = [];
                        for(var k in result){
                            var labelText = result[k].BillingCountry + ' ' + result[k].BillingStreet + ' ' + result[k].BillingCity;
                            addresses.push({label:labelText, value: result[k].Id});
                        }
                        
                        var array = [];

                        array.push(accountIds[0]);
                        component.set("v.relatedToAccount", accountIds[0]);
                        component.set("v.relatedToAccountSelected", array);
                        component.set("v.addressOptions", addresses);
                        component.find("addressCombobox").reinitialise();
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

    handleSelectChangeEvent : function(component, event, helper){
        if(event.getParam("values").length >= 1) {
            component.set("v.selectedSubscriptions",event.getParam("values"));
        } else {
            component.set("v.selectedSubscriptions",[]);
        } 
    },

    doApplySponsor:  function(component, event, helper) { 
        if(event.getParam("values").length == 1){
            component.set("v.selectedLookupId", event.getParam("values")[0]);
            helper.doApplySponsor(component);
        }
        else{
             component.find("lookup-contact").reset();
            var a = component.get('c.doInit');
            $A.enqueueAction(a);
        }
    },

    toggleShowHide : function(component, event, helper){
        helper.toggleShowHideClass(component, event, "localNames");
        helper.toggleShowHideClass(component, event, "openDescSecId");
        helper.toggleShowHideClass(component, event, "closeDescSecId");
    },
    
    closeErrorMessages : function(component, event, helper){
    	component.set("v.hasErrors", false);
    	component.set("v.errorMessages", null);
    },
    
    handleMiFIDIIToggle : function(component, event, helper) {
    	helper.cheackAndClearMiFIDIIFields(component, event, helper);
    },
    positionvalueChanged : function(component, event, helper) {
        console.log('event val'+ event.getSource().get('v.value'));
        console.log('event val'+ event.getParam("values"));
        if(event.getSource().get('v.value') != 'undefined'){
            var positionval = event.getSource().get('v.value');          
            console.log('position val :: ' + positionval);             
            component.set("v.contact.PositionPicklist__c", positionval);
        }else{
            component.set("v.contact.PositionPicklist__c", "");
        }
    },
})