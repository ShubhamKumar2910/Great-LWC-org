({
    init : function(component, event, helper){
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

    var batchSize = $A.get("$Label.c.MiFID_II_Bulk_Update_Default_Batch_Size");
    console.log(batchSize);
    console.log(parseInt(batchSize));
    component.set('v.batchSize', parseInt(batchSize));
    component.set('v.maxBatchSize', parseInt(batchSize));   

    helper.initialistProductSubscriptions(component);

    },

    bulkUpdate : function(component, event, helper) {
    var emails = component.get("v.emailAddressInput");
    var errorMessage = component.find("errorMessage");
    if(emails.length > 0){
      helper.updateContacts(component);
     
    }       
    },

    

    reset : function(component, event){
        helper.resetForm(component);
    } , 

    successfulSection : function(component, event, helper) {
       var acc = component.find('articleOne');
            for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
    }, 

    errorSection : function(component, event, helper) {
       var acc = component.find('articleTwo');
            for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
    }, 

    retry :function(component, event, helper){
        helper.retryfailures(component);
    }, 

    handleRangeChange : function(component, event, helper){
      console.log(event.getParam("value"));
      var detail = component.set("v.batchSize", event.getParam("value"));
    }, 

    mifidScopeChanged :  function(component, event, helper){
      var scope = component.get("v.selectedScope");
      console.log(scope);
      if(scope == 'In Scope'){
        component.set("v.selectedSalesCommentary", 'Allowed');
        component.set("v.disabledSalesCommentary", false);
        component.set("v.disabledPortalUser", false);
        component.set("v.deactivateGRP", false);  
        component.set("v.disabledGRPAccess", false);
        component.set("v.disabledServiceType", false);
      }
      if(scope == 'No Change'){
        component.set("v.selectedSalesCommentary", '');
        component.set("v.disabledSalesCommentary", true);
        component.set("v.disabledPortalUser", true);
        component.set("v.disabledServiceType", true);
        component.set("v.selectedPortalUserStatus", 'No Change');
        component.set("v.deactivateGRP", false);  
        component.set("v.disabledGRPAccess", false);
      }
      if(scope == 'Out Of Scope'){
        
        component.set("v.disabledSalesCommentary", false);
        component.set("v.disabledPortalUser", false);
        component.set("v.selectedSalesCommentary", '--None--');
        component.set("v.selectedPortalUserStatus", 'Revoke Access');
        component.set("v.deactivateGRP", false);  
        component.set("v.disabledGRPAccess", false);  
        component.set("v.disabledServiceType", true); 
      }

    },

    serviceTypeChanged :  function(component, event, helper){},

    grpAccessChanged :  function(component, event, helper){},

    preferredLanguageChanged : function(component, event, helper){},

    regionChanged : function(component, event, helper){},
    
    investorTypeChanged : function(component, event, helper){},

    onSalesCommentaryChange : function(component, event, helper) {},

    //changes filter parameters
    handleSelectChangeEvent: function(component, event, helper) {
        var items = component.get("v.productsToAddItems");
        items = event.getParam("values");
        component.set("v.productsToAddItems", items);
    },

    //changes filter parameters
    handleSelectChangeEvent2: function(component, event, helper) {
        var items = component.get("v.productsToRemoveItems");
        items = event.getParam("values");
        component.set("v.productsToRemoveItems", items);
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

})