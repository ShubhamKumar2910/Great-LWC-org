({
    rerender : function(cmp, helper){ 
        this.superRerender();
        
        if(cmp.get("v.isHelperTreeScriptLoaded") && cmp.get("v.nTRTreeHelperLogic")) {
            try {
                
                // Define query callback function
                var queryCallBackFunction = $A.getCallback(function queryDataFromServer(comp, succ, searchString) {
                    cmp.set('v.searchText',searchString);
                    helper.query(comp, succ, searchString);
                });    
                
                var placeHolder = cmp.get("v.placeHolder");
                
                // active/call select2 plugin function after load jQuery and select2 plugin successfully    
                var treePickListId = '#'+cmp.get('v.parentID')+'_team_treePickList';
                $(treePickListId).select2({
                    minimumInputLength : 2,
                    //quietMillis : 400,
                    placeholder: placeHolder,
                    multiple : true,
                    width : "100%",
                    ajax: {
                        url : function(term) {
                            return term;
                        },
                        transport: function (params) {
                            queryCallBackFunction(cmp, params.success, params.url);
                        },
                        results : function(data, page) {
                            return {
                                results : data
                                
                            };
                        }
                    }
                }).on("change", 
                      function(e) {
                          var selectedValues = e.val;
                          var selectedObjects = $(treePickListId).select2("data");
                          try{
                              // Fire value change event
                              var compEvent = cmp.getEvent("treeChange");
                              console.log(compEvent);
                              compEvent.setParams({ "values": selectedValues });
                              console.log(selectedValues);
                              console.log(selectedObjects);
                              compEvent.setParams({ "objects": selectedObjects });
                              compEvent.fire();
                          }
                          catch(error)
                          {
                              console.log(error);
                          }
                          
                      }
                     );  
                
                cmp.set("v.nTRTreeHelperLogic",false); // this will not fire rerender again
            }
            catch(err) {
                console.log('Error during Multiselect Tree renderer logic. Please find below:')   ;
                console.log(err);
            }
            
        }
        
    },
    unrender: function () {
        /*this.superUnrender();
        console.log('unrenderer multiselect tree');
        $("#team_treePickList").unload();
        cmp.set("v.needToRenderHelperLogic",false); // this will not fire rerender again
        cmp.set("v.isHelperScriptLoaded",false);*/
        // do custom unrendering here
    }
    
})