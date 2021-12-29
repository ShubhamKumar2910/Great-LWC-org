({
    wrapperDataLoad : function(component) {
       /* var wrapperMethod =  component.get('v.wrapperMethod');
        var wrapperParams =  component.get('v.wrapperParams');
        console.log('Wrapper Params: '+wrapperParams);
        console.log('Wrapper Method: '+wrapperMethod);
        if(!$A.util.isUndefinedOrNull(wrapperMethod) && !$A.util.isUndefinedOrNull(component.get("v.columnWidth")))
        {
            component.showSpinner();
            this.callWrapperAction(
                component,
                'c.'+wrapperMethod,
                wrapperParams,
                function( result ) {
                    console.log('Table Result: '+result);
                    if(result!=null)
                    {
                        component.set('v.pageNumber',0);
                        var columnName;
                        var resultdata = result;
                        var wrapperlist = component.get('v.wrapperList');
                        wrapperlist = resultdata.dataBody;
                        
                        if(!$A.util.isUndefinedOrNull(component.get('v.sortColumnName')))
                        {
                            columnName = component.get('v.sortColumnName');
                        }
                        
                        if(!$A.util.isUndefinedOrNull(columnName))
                        {
                            var currentOrder = false;
                            if(component.get('v.sortDirection') == 'asc')
                                currentOrder = true;
                            else
                                currentOrder = false;
                            wrapperlist.sort(function(a,b) {
                                var recordA = a[component.get("v.wrapperProperty")];
                                var recordB = b[component.get("v.wrapperProperty")];
                                var t1 = recordA[columnName] == recordB[columnName], t2 = recordA[columnName] < recordB[columnName];
                                return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
                            });
                        }
                        component.set('v.wrapperList',wrapperlist);
                        console.log('Wrapper List Size: '+component.get('v.wrapperList').length);
                        component.OnNext(false); 
                        component.showTable();
                    }
                   
                }
            );   
            
        } */
    },
    getNextPage : function( component) {
		var pageNumber = component.get( 'v.pageNumber' );
        var pageSize = component.get( 'v.pageSize' );
        pageNumber++;

        component.set( 'v.pageNumber', pageNumber );
        component.set( 'v.pageSize', pageSize );
        
        if(!$A.util.isUndefinedOrNull( component.get("v.query")))
        {
            if(component.get("v.showCheck"))
            {
                if(component.find("selectCheckBox").get("v.value")==true)
                    component.callSOQLAction(true);
                else
                    component.callSOQLAction(false);
            }
            else
            {
                component.callSOQLAction(false);
            }
        }
        else
        {
            
        }
    },
    callSOQLAction : function( component, actionName, params, successCallback, failureCallback ) {
        var action = component.get( actionName );
        if ( params ) {
            action.setParams( params );
        }
        action.setCallback( this, function( response ) {
            if ( component.isValid() && response.getState() === 'SUCCESS' ) {
                
                var splitstring = component.get( 'v.query' ).substr(6);
                var fromIndex = splitstring.indexOf("from");
                 if(fromIndex!=-1)
                     splitstring = splitstring.substr(0,fromIndex);
                 splitstring = splitstring.trim();
                 
                var parsedColumns = new Array();
                var querycolumns = splitstring.split(",");
                for(var i = 0; i < querycolumns.length; i++)
                    parsedColumns.push(querycolumns[i].trim());
                component.set('v.columnAPIs', parsedColumns);
                
                var result = response.getReturnValue();
                var datalist = component.get('v.dataList');
                datalist = datalist.concat(result.dataBody);
                component.set( 'v.dataList', datalist );
                
                //this.getNext(component,false); 
                
                var footerData = result.dataFooter;
                
                
                if(component.get("v.showCheck"))
                {
                    if(component.find("selectCheckBox").get("v.value")==true)
                        component.selectIDs();
                }   
                component.showTable();
                
            } else {
                
                console.error( 'Error calling action "' + actionName + '" with state: ' + response.getState() );
                
                if ( failureCallback ) {
                    failureCallback( response.getError(), response.getState() );
                } else {
                    this.logActionErrors( component, response.getError() );
                }
                component.hideTable();
                
            }
            
        });
        $A.enqueueAction( action );   
    },
    callSOQLSort : function( component, actionName, params, successCallback, failureCallback ) {
        var action = component.get( actionName );
        if ( params ) {
            action.setParams( params );
        }
        action.setCallback( this, function( response ) {
            if ( component.isValid() && response.getState() === 'SUCCESS' ) {
                
                var splitstring = component.get( 'v.query' ).substr(6);
                var fromIndex = splitstring.indexOf("from");
                 if(fromIndex!=-1)
                     splitstring = splitstring.substr(0,fromIndex);
                 splitstring = splitstring.trim();
                 
                var parsedColumns = new Array();
                var querycolumns = splitstring.split(",");
                for(var i = 0; i < querycolumns.length; i++)
                    parsedColumns.push(querycolumns[i].trim());
                component.set('v.columnAPIs', parsedColumns);
                
                var result = response.getReturnValue();
                var footerData = result.dataFooter;
                component.set('v.dataList', result.dataBody);
                
                
                if(component.get("v.showCheck"))
                {
                    if(component.find("selectCheckBox").get("v.value")==true)
                        component.selectIDs();
                }   
            } else {
                
                console.error( 'Error calling action "' + actionName + '" with state: ' + response.getState() );
                
                if ( failureCallback ) {
                    failureCallback( response.getError(), response.getState() );
                } else {
                    this.logActionErrors( component, response.getError() );
                }
            }
        });
        $A.enqueueAction( action );   
    },
    logActionErrors : function( component, errors ) {
        if ( errors ) {
            for ( var index in errors ) {
                console.error( 'Error: ' + errors[index].message );
            }
        } else {
            console.error( 'Unknown error' );
        }
        component.hideTable();
    },
    getNext : function(component,isSort) {
        var requestedList=new Array();
        var startNumber = 0;
        var wrapperList = component.get('v.wrapperList');
        var size = wrapperList.length;
        
        var index = component.get("v.pageNumber");
        
        var setPageSize = component.get("v.pageSize");
        
        
        
         if(index <= wrapperList.length)
        {
            if(size <= (index + setPageSize))
            {
                startNumber = index;
                index = size;
            }
            else
            {
                index = (index + setPageSize);
                startNumber = (index - setPageSize);
            }
            
            component.set("v.pageNumber",index);
            
             
            for(var start = startNumber; start < index; start++)
            {
                if(component.get("v.showCheck"))
                {
                    if(component.find("selectCheckBox").get("v.value")==true)
                    {
                        wrapperList[start].isChecked = true;
                    }
                }
               
                
                requestedList.push(wrapperList[start]);
            }
        }
            if(requestedList.length>=1)
            {
                var dataList = component.get('v.dataList');
                if(!isSort)
                {
                    if (dataList.length == 0)
                    {
                        dataList = requestedList;   
                        component.set( 'v.dataList', dataList);
                    }
                    else
                    {
                        dataList = dataList.concat(requestedList);   
                        component.set( 'v.dataList', dataList);
                    }
                }
                else
                {
                    component.set( 'v.dataList', requestedList);
                }   
                
            }
          // component.hideSpinner();
    },
    getScrollNext : function(component,isSort,pDiv,scrollpoint) {
        var requestedList=new Array();
        var startNumber = 0;
        var wrapperList = component.get('v.wrapperList');
        var size = wrapperList.length;
        
        var index = component.get("v.pageNumber");
        
        var setPageSize = component.get("v.pageSize");
        
        
        
         if(index <= wrapperList.length)
        {
            if(size <= (index + setPageSize))
            {
                startNumber = index;
                index = size;
            }
            else
            {
                index = (index + setPageSize);
                startNumber = (index - setPageSize);
            }
            
            component.set("v.pageNumber",index);
            
             
            for(var start = startNumber; start < index; start++)
            {
                if(component.get("v.showCheck"))
                {
                    if(component.find("selectCheckBox").get("v.value")==true)
                    {
                        wrapperList[start].isChecked = true;
                    }
                }
               
                
                requestedList.push(wrapperList[start]);
            }
        }
            if(requestedList.length>=1)
            {
                var dataList = component.get('v.dataList');
                if(!isSort)
                {
                    if (dataList.length == 0)
                    {
                        dataList = requestedList;   
                        component.set( 'v.dataList', dataList);
                    }
                    else
                    {
                        dataList = dataList.concat(requestedList);   
                        component.set( 'v.dataList', dataList);
                    }
                }
                else
                {
                    component.set( 'v.dataList', requestedList);
                }   
                
                pDiv.scrollTop = scrollpoint;
            }
           component.hideSpinner();
    },
    callWrapperAction : function( component, event ) {
        var wrapperparams = event.getParam('arguments');
        var successCallback;
        var failureCallback;
        if (wrapperparams) {
            successCallback = wrapperparams.successCallback;
            failureCallback = wrapperparams.failureCallback;
        }
        
        var wrapperMethod =  component.get('v.wrapperMethod');
        var params =  component.get('v.wrapperParams');
        
        var action = component.get( 'c.'+wrapperMethod );
        if ( params ) {
            action.setParams( params );
        }
        action.setCallback( this, function( response ) {
            
            if ( component.isValid() && response.getState() === 'SUCCESS' ) {
                if ( successCallback ) {
                    successCallback( response.getReturnValue() );
                }
                
            } else {
                
                console.error( 'Error calling action with state: ' + response.getState() );
                if ( successCallback ) {
                    successCallback( response.getReturnValue() , response.getError());
                }
                component.hideTable();
                
            }
           
        });
        
        $A.enqueueAction( action );
        
    }
    
})