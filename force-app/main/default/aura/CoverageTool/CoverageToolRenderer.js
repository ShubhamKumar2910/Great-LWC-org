({
    rerender : function(cmp, helper){
        this.superRerender();
        
        if(cmp.get("v.isHelperScriptLoaded") && cmp.get("v.needToRenderHelperLogic")) {
            try {
                /*helper.fetchProductGroupDependantValues(cmp,'Coverage_Team_Member__c', 'Product_Group__c', 'Product2__c');
                console.log(cmp.logTime('Product Dependant Values fetched completed'));
                helper.fetchProductRegionSetValues(cmp);
                console.log(cmp.logTime('Product Regions Set fetched completed'));*/
                helper.isUploadButtonSeen(cmp);
                helper.isCommentAccessible(cmp); 
                helper.isUserFISales(cmp);
                //helper.fetchCurrentUserSalesCodeId(cmp);
                //changes for JIRA SALES-3698
                //////////////helper.fetchNFPEType(cmp);
                cmp.set('v.isLoadInit',true);
               cmp.set("v.needToRenderHelperLogic",false); // this will not fire rerender again
            }
            catch(err) {
                console.log('Error during Helper renderer logic. Please find below:')   ;
                console.log(err);
            }
        }
        
        
        if(cmp.get("v.istoggleScriptLoaded") && cmp.get("v.needToRenderToggleLogic")) {
            try {
                $('.toggle').toggles({
                    drag: true, // allow dragging the toggle between positions
                    click: true, // allow clicking on the toggle
                    text: {
                        on: 'Account', // text for the ON position
                        off: 'Product' // and off
                    },
                    on: true, // is the toggle ON on init
                    animate: 250, // animation time (ms)
                    easing: 'swing', // animation transition easing function
                    checkbox: null, // the checkbox to toggle (for use in forms)
                    clicker: null, // element that can be clicked on to toggle. removes binding from the toggle itself (use nesting)
                    width: 80, // width used if not set in css
                    height: 30, // height if not set in css
                    type: 'select' // if this is set to 'select' then the select style toggle will be used
                });
                
                // Getting notified of changes, and the new state:
                $('.toggle').on('toggle', function(e, active) {
                    if (active) {
                        console.log('Section Account active.');
                        cmp.set("v.level",'Client');
                        cmp.set("v.coverageData", [{}]);
                        cmp.set("v.coverageColumns", [{}]); 
                        cmp.hideProductFilters();
                        cmp.hideDatatable();
                        cmp.doProductFilterReset();
                        /*cmp.set("v.showYTDBudgetStats",false);*/
                        cmp.set("v.buttonDisabled",true);
                        cmp.set("v.totalRecords",0);
                        console.log("isLoadInit in rerenderer IF : ",cmp.get('v.isLoadInit'));
                        if(!cmp.get('v.isLoadInit'))
                        {
                            cmp.refreshData();
                            cmp.set('v.maxHeight',"350");
                        }
                    } else {
                        console.log('Section Product active');
                        cmp.set("v.level",'Product');
                        cmp.set("v.coverageData", [{}]);
                        cmp.set("v.coverageColumns", [{}]); 
                        cmp.showProductFilters();
                        cmp.hideDatatable();
                        cmp.doProductFilterReset();
                        /*cmp.set("v.showYTDBudgetStats",false);*/
                        cmp.set("v.buttonDisabled",true);
                        cmp.set("v.totalRecords",0);
                        cmp.set('v.maxHeight',"283");
                        console.log("isLoadInit in rerenderer ELSE : ",cmp.get('v.isLoadInit'));
                        if(!cmp.get('v.isLoadInit'))
                        {
                            cmp.refreshData();
                        }
                    }
                    
                });

                $(".toggleView").toggles({
                    drag: true, // allow dragging the toggle between positions
                    click: true, // allow clicking on the toggle
                    text: {
                        on: "My Team", // text for the ON position
                        off: "Global" // and off
                    },
                    on: !cmp.get('v.withoutSharing') == true ? true : false, // is the toggle ON on init
                    animate: 250, // animation time (ms)
                    easing: "swing", // animation transition easing function
                    checkbox: null, // the checkbox to toggle (for use in forms)
                    clicker: null, // element that can be clicked on to toggle. removes binding from the toggle itself (use nesting)
                    width: 80, // width used if not set in css
                    height: 30, // height if not set in css
                    type: "select" // if this is set to 'select' then the select style toggle will be used
                });

                // Getting notified of changes, and the new state:
                $(".toggleView").on("toggle", function (e, active) {
                    if (active) {
                        console.log("Section My View .");
                        cmp.set("v.withoutSharing", false);
                        cmp.set("v.parentID", "mycoverage");
                        cmp.set("v.coverageData", [{}]);
                        cmp.set("v.coverageColumns", [{}]); 
                        cmp.hideDatatable();
                        cmp.set("v.buttonDisabled", true);
                        cmp.set("v.totalRecords", 0);
                        console.log("isLoadInit in rerenderer IF : ", cmp.get('v.isLoadInit'));
                        if (!cmp.get('v.isLoadInit')) {
                            cmp.refreshData();
                        }

                    } else {
                        console.log("Section Global View");
                        cmp.set("v.withoutSharing", true);
                        cmp.set("v.parentID", "mycoverage");
                        cmp.set("v.coverageData", [{}]);
                        cmp.set("v.coverageColumns", [{}]); 
                        cmp.hideDatatable();
                        cmp.set("v.buttonDisabled", true);
                        cmp.set("v.totalRecords", 0);
                        console.log("isLoadInit in rerenderer ELSE : ", cmp.get('v.isLoadInit'));
                        if (!cmp.get('v.isLoadInit')) {
                            cmp.refreshData();
                        }
                    }
                });
                cmp.set("v.needToRenderToggleLogic",false); // this will not fire rerender again
                
            }
            catch(err) {
                console.log('Error during toggle renderer logic. Please find below:')   ;
                console.log(err);
            }
        }
    },
    afterRender: function(component, helper) {
        this.superAfterRender();
    }
})