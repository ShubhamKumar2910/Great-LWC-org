({
	init : function(component, event, helper) {
		helper.getProductSubscriptions(component);
		helper.isUserEligibleForBulkUpdate(component);
		helper.initialiseReportIdLinks(component);
		helper.initialiseAccountInformation(component); 
		helper.getNFPEDetails(component);
		helper.setShowCautionClientInfo(component);
	},  
	//function for SALES-3698
	openNFPEChampionReport : function(component, event, helper){
        helper.navigatetoNFPEChampion(component,event);
	},
	reInit : function(component, event, helper) {
		helper.initialiseAccountInformation(component);
		helper.setShowCautionClientInfo(component);
	},
	handleMenuSelect: function(component, event, helper){
		var selectedMenu = event.detail.menuItem.get("v.value");
		switch(selectedMenu){ 
			case "EntityDetail":
				helper.navigateToMifidIIDetail(component);	
				break;	
			case "MiFIDIIContactsWithSubs":
				helper.navigateToMifidContactsWithSubs(component, event);	
				break;	
			case "MiFIDIIContactsWithoutSubs":
				helper.navigateToMifidContactsWithoutSubs(component, event);	
				break;
			case "NonMiFIDIIContactsWithRestrProdENT":
				helper.navigateToNonMiFIDIIContactsWithRestrProdENT(component, event);	
				break;
			case "NonMiFIDIIContactsWithGRPAndProdENT":
				helper.navigateToNonMiFIDIIContactsWithGRPAndProdENT(component, event);	
				break;
			case "MiFIDIIBulkUpdate":
				helper.navigateToBulkUpdate(component, event);	
				break;
						
		}
	}

})