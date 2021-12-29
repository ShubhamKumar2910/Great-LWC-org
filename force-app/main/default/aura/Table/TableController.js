({
    
    // To ensure Translation labels are preloaded
    /* Coverage - Main Screen
    * $Label.c.CVGTOOL_ACCOUNT_NAME
    * $Label.c.CVGTOOL_TEAM
    * $Label.c.CVGTOOL_SALESPERSON
    * $Label.c.CVGTOOL_YTD_USD
    * $Label.c.CVGTOOL_BUDGET_USD
    * $Label.c.CVGTOOL_WTD_USD
    * $Label.c.CVGTOOL_MTD_USD
    * $Label.c.CVGTOOL_YTD_YEN
    * $Label.c.CVGTOOL_BUDGET_YEN
    * $Label.c.CVGTOOL_WTD_YEN
    * $Label.c.CVGTOOL_MTD_YEN
    * $Label.c.CVGTOOL_START_DATE
    * $Label.c.CVGTOOL_STATUS
    * $Label.c.CVGTOOL_PRODUCT
    * $Label.c.CVGTOOL_PRODUCT_REGION
    * $Label.c.CVGTOOL_ROLE
    * $Label.c.CVGTOOL_CANCEL
    * $Label.c.CVGTOOL_VALIDATE
    * $Label.c.CVGTOOL_PREVIOUS
    * $Label.c.CVGTOOL_SAVE
    * $Label.c.CVGTOOL_APPLY
    * $Label.c.CVGTOOL_CLEAR
	* $Label.c.CVGTOOL_REGION
	* $Label.c.CVGTOOL_DESK
    * $Label.c.Coverage_Validation_Status
    * $Label.c.CVGTOOL_NEW_ROLE
    * $Label.c.CVGTOOL_NEW_START_DATE
    * $Label.c.CVGTOOL_END_DATE
    * $Label.c.CVGTOOL_LABEL_TRANSFER_TO
    * $Label.c.CVGTOOL_LABEL_TRANSFER_DATE
    * $Label.c.CVGTOOL_TRANSFER_FROM
    * $Label.c.CVGTOOL_START_DATE
    * $Label.c.CVGTOOL_LABEL_START_DATE    
    */

    callWrapperAction : function(component,event,helper){
      helper.callWrapperAction(component,event);  
    },
    
    calculateWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        //to get the position from the left for storing the position from where user started to drag
        var mouseStart=event.clientX; 
        component.set("v.mouseStart",mouseStart);
        component.set("v.oldWidth",parObj.offsetWidth);
    },    
    setNewWidth : function(component, event, helper) {
        var childObj = event.target;
        var parObj = childObj.parentNode;
        var childDivObj;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        childDivObj = parObj.childNodes[0];
        var mouseStart = component.get("v.mouseStart");
        var oldWidth = component.get("v.oldWidth");
        //To calculate the new width of the column
        var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
        parObj.style.width = newWidth+'px';//assign new width to column
        childDivObj.style.width = newWidth+'px';//assign new width to column
    },
    scriptsLoaded : function(component, event, helper) {
        //component.set("v.isJqueryLoaded",true);
        //component.set("v.needToProcessReRenderLogic",true);
                
	},
    doInit : function(component, event, helper) {
        var tableColumns = component.get("v.columnLabels");
        var tableColumnNew = '';
        component.hideTable();
                
        //put comment
        for(var i=0;i<tableColumns.length;i++)
        {
            var ab = $A.getReference("$Label.c."+tableColumns[i].trim());
            component.set("v.tempLabelAttr", ab);
            
            if(component.get("v.tempLabelAttr").indexOf('$Label.c')==-1 && component.get("v.tempLabelAttr")!='')
            {
                tableColumns[i] = component.get("v.tempLabelAttr");
            }
        }
        component.set("v.columnLabels",tableColumns);
        
        var isWrapper = component.get("v.isWrapper");
        var isSOQL = false;
        var query = component.get("v.query");
        if ($A.util.isUndefinedOrNull( component.get("v.query")))
        { 
            isSOQL = false;
        }
        else
        {
            isSOQL = true;
            isWrapper = false;
        }
        
        if(isSOQL)
        {
            component.callSOQLAction(false);
        }
        
        if(isWrapper)
        {
            helper.wrapperDataLoad( component);
        }
        
        
    },
    actionDetails: function(component, event, helper){
        var item = event.currentTarget;
        var selectedRecord;
        if (item && item.dataset) {
            var datalist = component.get("v.dataList");
            var selectedIndex = item.dataset.index;
            var compEvent = component.getEvent("actionChange");
            compEvent.setParams({ "actionRecord": datalist[selectedIndex] });
            compEvent.fire();
        }    
        
    },
    checkboxSelect: function(component, event, helper) {
        var checkboxes = component.find("entity-ids");
        var datalist = component.get("v.dataList");
        var ids=''; 
        if(Array.isArray(checkboxes))
        {
            for (var i = 0; i < checkboxes.length; i++)
            {
                if(checkboxes[i].get("v.value")==true)
                {
                    var status = '';
                    if(!$A.util.isUndefinedOrNull(datalist[i].coverageData))
                    {
                        if(!$A.util.isUndefinedOrNull(datalist[i].coverageData.status))
                            status = datalist[i].coverageData.status;
                        else
                        {	
                            datalist[i].isChecked = false;
                         }
                    }
                    if(status!='')
                    {
                         datalist[i].isChecked = false;
                    }
                    else
                    {
                        datalist[i].isChecked = true;
                        if(ids === '')
                            ids = checkboxes[i].get("v.text");
                        else
                            ids = ids+','+checkboxes[i].get("v.text"); 
                    }
                   
                }
                else
                {
                    component.find("selectCheckBox").set("v.value",false);
                    datalist[i].isChecked = false;
                }
            }         
        }
        else
        {
            if(checkboxes.get("v.value")==true)
            {
                ids = checkboxes.get("v.text");
                var status = '';
                if(!$A.util.isUndefinedOrNull(datalist[0].coverageData))
                {
                    if(!$A.util.isUndefinedOrNull(datalist[0].coverageData.status))
                    status = datalist[0].coverageData.status;
                    else
                    {datalist[0].isChecked = false;
                     ids = '';  }
                }
                if(status!='')
                {
                    datalist[0].isChecked = false;
                    ids = '';
                }
                else
                {datalist[0].isChecked = true;}
                    
            }
            else
            {
                ids = '';
                component.find("selectCheckBox").set("v.value",false);
                datalist[0].isChecked = false;
            }
        }
        component.set("v.selectedIDs",ids);  
    },
    selectAll: function(component, event, helper) {
        var checkAll = component.find("entity-ids");
        
            
        if(component.find("selectCheckBox").get("v.value")==true)
        {
            if(Array.isArray(checkAll))
            {
                for (var i = 0; i < checkAll.length; i++)
                {
                    checkAll[i].set("v.value",true);
                }
            }
            else
            {
                checkAll.set("v.value",true);
            }
            component.selectIDs();
        }
        else
        {  
            if(Array.isArray(checkAll))
            {
                for (var i = 0; i < checkAll.length; i++){
                    checkAll[i].set("v.value",false);
                } 
            }
            else
            {
                checkAll.set("v.value",false);
            }
             component.selectIDs();
        }  
    },
    callSOQLAction : function(component, event, helper){
         var params = event.getParam('arguments');
        if(params)
        {
            var isSelected = params.isSelected;
            helper.callSOQLAction(
                    component,
                    'c.getSOQLData',
                    {
                        'page' : component.get( 'v.pageNumber'),
                        'pageSize' : component.get( 'v.pageSize'),
                        'sortCol' : component.get( 'v.sortColumnName' ),
                        'sortDir' : component.get( 'v.sortDirection' ),
                        'query' : component.get( 'v.query' ),
                        'isSelected' : isSelected
                    }
            );
        }
    },
    CallSOQLSortEvent : function(component, event, helper){
        var currentOrder = false;
        var sortDirection = component.get( 'v.sortDirection' );
        if ( sortDirection === 'asc' ) {
            sortDirection = 'desc';
            currentOrder = false;
        } else {
            sortDirection = 'asc';
            currentOrder = true;
        }
        
        
        var columnName = '';
        var jIndex;
        var item = event.currentTarget;
        if (item && item.dataset) {
            columnName = item.dataset.value;
            jIndex = item.dataset.index;
        }
        else
        {
            if(!$A.util.isUndefinedOrNull(component.get('v.sortColumnName')))
            {
                columnName = component.get('v.sortColumnName');
            }
        }
       
        var pageSize = component.get( 'v.pageSize');
        var query = component.get( 'v.query' );
        var isSelected = false;
        
        if(!$A.util.isUndefinedOrNull( component.get("v.query")))
        {
            if(component.get("v.showCheck"))
            {
                if(component.find("selectCheckBox").get("v.value")==true)
                    isSelected = true;
                else
                    isSelected = false;
            }
            else
            {
                isSelected = false;
            }
            
            component.set( 'v.sortDirection',sortDirection );
            component.set( 'v.sortColumnName', columnName);
            component.set( 'v.pageNumber',1);
            helper.callSOQLSort(
                component,
                'c.getSOQLData',
                {
                    'page' : component.get( 'v.pageNumber'),
                    'pageSize' : pageSize,
                    'sortCol' : columnName,
                    'sortDir' : sortDirection,
                    'query' : query,
                    'isSelected' : isSelected
                }
            );
        }
        else if(component.get("v.isWrapper"))
        {
            //1. sort wrapper
            var wrapperlist = component.get('v.wrapperList');
            wrapperlist.sort(function(a,b) {
                var recordA = a[component.get("v.wrapperProperty")];
                var recordB = b[component.get("v.wrapperProperty")];
                var t1 = recordA[columnName] == recordB[columnName], t2 = recordA[columnName] < recordB[columnName];
                return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
            });
            component.set('v.wrapperList',wrapperlist);
            
            //2. onnext
            component.set('v.pageNumber',0);
            component.OnNext(true);
            
            component.set( 'v.sortDirection',sortDirection );
            component.set( 'v.sortColumnName', columnName);
        }
        
    },
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    OnNext : function(component,event,helper) {
         var isSort;
        var params = event.getParam('arguments');
        if(params)
        {
            isSort = params.isSortable;
        }
        helper.getNext(component,isSort);
    },
    OnPrev : function(component,event,helper) {
        helper.getPrevious(component);
    },
    showTable : function(component,event) {
        var cmpTarget = component.find('tableSection');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideTable : function(component,event) {
        var cmpTarget = component.find('tableSection');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
   
})