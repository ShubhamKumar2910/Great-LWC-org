({
    isUploadButtonSeen : function(component)
   {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.isUploadButtonSeen(component);
   },
   fetchCurrentUserSalesCodeId : function(component){
         if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.fetchCurrentUserSalesCodeId(component);
   },
   isUserFISales : function(component)
   {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.isUserFISales(component);
   },
   /*---------------------fetchNFPEType : function(component)
   {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.fetchNFPEType(component);
   },*/
   fetchProductGroupDependantValues: function(component,objName, controllerField, dependentField) {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.fetchProductGroupDependantValues(component,objName, controllerField, dependentField);
   },
   isCommentAccessible : function(component)
   {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.isCommentAccessible(component);
   },
   fetchDepValues: function(component, productRegions, productGrps) {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
       coverage_helper_util.fetchDepValues(component, productRegions, productGrps); 
   },
   createAddCoverages: function(component){
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
       coverage_helper_util.createAddCoverages(component);
   },
   viewExistingCoverage: function(component,product, productRegion,
                                       productGroup,salesCodeId, 
                                       clientId,isRM ,isRG,salesTeam,coverageType,subType){
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
       {
           coverage_helper_util.viewExistingCoverage(component,product, productRegion,
                                       productGroup,salesCodeId, 
                                                     clientId,isRM ,isRG,salesTeam,coverageType,subType);}
   },
   createBulkformat: function(component,tableAuraId,operation)
   {
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
       coverage_helper_util.createBulkformat(component,tableAuraId,operation);
   },
   fetchProductRegionSetValues: function(component){
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
       coverage_helper_util.fetchProductRegionSetValues(component);
   },
   fetchCurrentUserSalesCodeId: function(component){
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
           coverage_helper_util.fetchCurrentUserSalesCodeId(component);
   },
   sortData: function (cmp, fieldName, sortDirection) {
       var data = cmp.get("v.addCoverageData");
       var validationdata = cmp.get("v.validationCoverageData");
       var reverse = sortDirection !== 'asc';
       if(cmp.get("v.setWizardStep") == 'Select')
       {
           //sorts the rows based on the column header that's clicked
           data.sort(this.sortBy(fieldName, reverse));
           cmp.set("v.addCoverageData", data);
       }
       else {
           validationdata.sort(this.sortBy(fieldName, reverse));
           cmp.set("v.validationCoverageData", validationdata);
       }
   },
   sortBy: function (field, reverse, primer) {
       var key = primer ?
           function(x) {return primer(x[field])} :
       function(x) {return x[field]};
       //checks if the two rows should switch places
       reverse = !reverse ? 1 : -1;
       return function (a, b) {
           return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
       }
   },
   submitData: function(component,successlist,rgDeleteList,rmDeleteList,totalCount,guid){
       console.log('In submit');
       console.log(rgDeleteList);
       console.log(rmDeleteList);
       
       if(!$A.util.isUndefinedOrNull(coverage_helper_util))
       coverage_helper_util.submitData(component,successlist,rgDeleteList,rmDeleteList,totalCount,guid);
   },
   actionChange:function(cmp,coverage){
       var clientId='';
       var isRM =false;
       var isRG = false;
       var headerName = 'NA';
       console.log(coverage);
       if(coverage.clientRGId!='' && coverage.coverageType == 'Standard' && coverage.rmRestricted == false)
       {
           console.log('RG called');
           console.log('Team: '+coverage.team);
           cmp.set("v.addModalTitle", headerName);
           cmp.set("v.clientName",coverage.clientRG);
           cmp.set("v.teamName",coverage.team);
           var productDesc = '';
           if(!$A.util.isUndefinedOrNull(coverage.product)
             && !$A.util.isUndefinedOrNull(coverage.productRegion)
             && !$A.util.isUndefinedOrNull(coverage.productGroup))
           {
               if(coverage.product!='' && coverage.productRegion!='' && coverage.productGroup!='')
               {
                   productDesc = coverage.productGroup + '-' + coverage.product + '-' +coverage.productRegion
                   cmp.set("v.productDescription",productDesc);
               }
           }
           else
           {
                   cmp.set("v.productDescription","NA");
           }
           this.viewExistingCoverage(cmp,coverage.product, coverage.productRegion,
                                       coverage.productGroup,coverage.salesCodeID, 
                                    coverage.clientRGId,false ,true,coverage.team,coverage.coverageType,coverage.subType);
       }
       else if(coverage.clientRMId!='')
       {
           console.log('RM called');
           console.log('Team: '+coverage.team);
           cmp.set("v.addModalTitle", headerName);
           cmp.set("v.clientName",coverage.clientRM);
           cmp.set("v.teamName",coverage.team);
           var productDesc = '';
           if(!$A.util.isUndefinedOrNull(coverage.product)
              && !$A.util.isUndefinedOrNull(coverage.productRegion)
              && !$A.util.isUndefinedOrNull(coverage.productGroup))
           {
               if(coverage.product!='' && coverage.productRegion!='' && coverage.productGroup!='')
               {
                   productDesc = coverage.productGroup + '-' + coverage.product + '-' +coverage.productRegion
                   cmp.set("v.productDescription",productDesc);
               }
               
           }
           else
           {
                   cmp.set("v.productDescription","NA");
               
           }
           this.viewExistingCoverage(cmp,coverage.product, coverage.productRegion,
                                       coverage.productGroup,coverage.salesCodeID, 
                                    coverage.clientRMId,true ,false,coverage.team,coverage.coverageType,coverage.subType);
       }

   }
   
   
})