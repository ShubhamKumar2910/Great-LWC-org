({
    rerender : function(cmp, helper){
        this.superRerender();
        /*console.log("START RERENDER : ",cmp.get("v.needToRenderToggleLogic"));
        if(cmp.get("v.isHelperScriptLoaded") && cmp.get("v.needToRenderHelperLogic")) {
            try {
                //helper.isUploadButtonSeen(cmp);
                //helper.isCommentAccessible(cmp); 
                cmp.set('v.isLoadInit',false);
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
                        on: 'Request', // text for the ON position
                        off: 'Coverage' // and off
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
                        //cmp.set("v.level",'Client');
                        cmp.set("v.coverageData", [{}]);
                        cmp.set("v.coverageColumns", [{}]);
                        cmp.set("v.recType", Request);
                        //cmp.hideProductFilters();
                        console.log("HIDE TABLE 1");
                        //cmp.hideDataTable();
                        var dataTableDiv = cmp.find("dataTableDiv");
        				$A.util.addClass(dataTableDiv, "slds-hide");
        				$A.util.removeClass(dataTableDiv,'slds-show');
                        
                        //cmp.doProductFilterReset();
                        //cmp.set("v.buttonDisabled",true);
                        cmp.set("v.totalRecords",0);
                        console.log("isLoadInit in rerenderer IF : ",cmp.get('v.isLoadInit'));
                        if(!cmp.get('v.isLoadInit'))
                        {
                            console.log("CALL 1 -> refreshData");
                            cmp.refreshData();
                            cmp.set('v.maxHeight',"350");
                        }
                    } else {
                        console.log('Section Product active');
                        //cmp.set("v.level",'Product');
                        cmp.set("v.coverageData", [{}]);
                        cmp.set("v.coverageColumns", [{}]);
                        cmp.set("v.recType", "Coverage");
                        //cmp.showProductFilters();
                        console.log("HIDE TABLE 2");
                        //cmp.hideDataTable();
                        var dataTableDiv = cmp.find("dataTableDiv");
        				$A.util.addClass(dataTableDiv, "slds-hide");
        				$A.util.removeClass(dataTableDiv,'slds-show');
                        //cmp.doProductFilterReset();
                        //cmp.set("v.buttonDisabled",true);
                        //cmp.set("v.totalRecords",0);
                        //cmp.set('v.maxHeight',"283");
                        console.log("isLoadInit in rerenderer ELSE : ",cmp.get('v.isLoadInit'));
                        if(!cmp.get('v.isLoadInit'))
                        {
                            console.log("CALL 2 -> refreshData");
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
            console.log("STOP RERENDER : ",cmp.get("v.needToRenderToggleLogic"));
        }*/
    },
    afterRender: function(component, helper) {
        this.superAfterRender();
    }
})