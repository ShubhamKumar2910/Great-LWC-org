({
	// Your renderer method overrides go here
    rerender : function(cmp, helper){
        this.superRerender();
        if(cmp.get("v.isHelperScriptLoaded") && cmp.get("v.needToRenderHelperLogic") && cmp.get("v.loggedInUserDetailsLoaded")) {
            try {
              	 helper.isUploadButtonSeen(cmp);
                var myPageRef = cmp.get("v.pageReference");
                var accountId = myPageRef.state.c__accountLookupId;
                if(!$A.util.isUndefinedOrNull(accountId))
                    cmp.set("v.accountLookupId",accountId);
                cmp.set("v.source", myPageRef.state.c__source);
                var today = new Date();
                cmp.set('v.CoverageStartDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
                console.log('Inside rerender ***');
                var myPageRef = cmp.get("v.pageReference");
                console.log(myPageRef);
                console.log(myPageRef.state.c__accountLookupId);
                //commented for JIRA SALES-3698
                //------------------helper.fetchNFPEType(cmp);
                //helper.fetchProductGroupDependantValues(cmp,'Coverage_Team_Member__c', 'Product_Group__c', 'Product2__c');
                //helper.fetchProductRegionSetValues(cmp);
                 helper.isCommentAccessible(cmp); 
                helper.isUserFISales(cmp);
                //helper.fetchCurrentUserSalesCodeId(cmp);
                cmp.set('v.isProductRegionsDisable',false);
                coverage_helper_util.setLoggedUserDetails(cmp);
            }
            catch(err) {
                console.log('Error during Helper renderer logic. Please find below:')   ;
                console.log(err);
            }
            
        }
        else{
            
            var myPageRef = cmp.get("v.pageReference");
            var accountId = myPageRef.state.c__accountLookupId;
            if(!$A.util.isUndefinedOrNull(accountId))
            {
                  
                if(accountId!='' && (cmp.get("v.accountLookupId")!=accountId))
                {
                    var accountLookup = cmp.find("lookup-accountAdd");
                    accountLookup.set("v.preSelectedIds",new Array(accountId));
                    console.log('ISSUE');
                    cmp.set("v.accountLookupId",accountId);
                    accountLookup.callPreSelect();                
                }
            }
            
        }
     },
    unrender: function () {
        this.superUnrender();
        // do custom unrendering here
    }
})