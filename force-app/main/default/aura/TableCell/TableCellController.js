({
    doInit : function( component, event, helper ) {
        //console.log('*********** IN CELL ******************');
        
        var row = component.get( 'v.row' );
      // console.log(row);
        
        var column = component.get( 'v.column' );
        
        //Setting column width
        var columnWidth = component.get('v.columnWidth');
        //console.log(columnWidth);
        var colIndex = component.get('v.colIdx');
        //console.log(colIndex);
        
        if(columnWidth.length > 0)
        {
            component.set('v.width',columnWidth[colIndex]);
        }
        
        if(!$A.util.isUndefinedOrNull(row))
        {
            if(!$A.util.isUndefinedOrNull(row.coverageData))
            {
                if(!$A.util.isUndefinedOrNull(row.coverageData.status))
                {
                    if(row.coverageData.status == 'Pending Approval')
                    {
                        component.set("v.backgroundcolor",'#d6d2ce');
                    }
                }
                 if(!$A.util.isUndefinedOrNull(row.coverageData.containsError))
                {
                    if(row.coverageData.containsError && row.coverageData.errorType == 'error')
                    {
                        component.set("v.color",'#fff');
                        component.set("v.backgroundcolor",'rgb(194, 57, 52)');
                    }
                    else if(row.coverageData.containsError && row.coverageData.errorType == 'warning')
                    {
                        component.set("v.color",'#fff');
                        component.set("v.backgroundcolor",'rgb(255, 183, 93)');
                    }
                }
            }
        }
       
        var wrapperRowPropertyToAccess = component.get('v.wrapperRowPropertyToAccess');
        
        var parseObject;
        if($A.util.isUndefinedOrNull( component.get('v.wrapperRowPropertyToAccess' )))
            parseObject = row;
        else
            parseObject = row[component.get('v.wrapperRowPropertyToAccess' )];
        
        // determine ui theme
        var uiTheme = helper.getUITheme();
        component.set( 'v.uiTheme', uiTheme );

        var mapLinkRecords = new Object();
        if(!$A.util.isUndefinedOrNull(component.get('v.TableColumnsLink' )))
        {
            var parts = component.get('v.TableColumnsLink' ).split(",");
            for (var i = 0; i < parts.length; i++) {
                var splits = parts[i].split(':');
                mapLinkRecords[splits[0]] = splits[1];
            }    
        }
        
        if(!$A.util.isUndefinedOrNull(mapLinkRecords[column]) && !$A.util.isUndefinedOrNull(parseObject))
        {
            var parsedLinkToRecord = helper.parseFieldValue( component, parseObject, mapLinkRecords[column] );
            
            if ( !$A.util.isUndefinedOrNull( parsedLinkToRecord ) ) {
                component.set( 'v.linkToRecord', ( uiTheme === 'Classic' ? '/' : '' ) + parsedLinkToRecord );
            } else {
                component.set( 'v.linkToRecord', ( uiTheme === 'Classic' ? '/' : '' ) + mapLinkRecords[column] );
            }
            
            if ( uiTheme === 'Classic' ) {
                component.set( 'v.classicLink', component.get( 'v.linkToRecord' ) );
            }
        }
        // the column's name might be a single property on the object
        // like 'Subject' or it might be a compound reference
        // like 'Who.Name' so we split the string into its parts
        // and try to traverse the object graph through the properties.
        //
        // if the row does not have the full property graph
        // then null is returned, otherwise the value at the end of the rainbow.
        
         if(!$A.util.isUndefinedOrNull(parseObject))
        component.set( 'v.value', helper.parseFieldValue( component, parseObject, column) );

        // set css class from column definition
        //component.set( 'v.class', column.get( 'v.valueClass' ) );

        var linkToURL = null;
        // if linking to a record we first check if the expression evaluates to a field on the row object
        // that holds the value to link to, otherwise will use the value as-is for linking
        if ( !$A.util.isUndefinedOrNull( linkToURL ) ) {

            var parsedLinkToURL = helper.parseFieldValue( component, parseObject, linkToURL );

            if ( !$A.util.isUndefinedOrNull( parsedLinkToURL ) ) {
                component.set( 'v.linkToURL', parsedLinkToURL );
            } else {
                component.set( 'v.linkToURL', linkToURL );
            }

            if ( uiTheme === 'Classic' ) {
                component.set( 'v.classicLink', component.get( 'v.linkToURL' ) );
            }

        }

    },

    /**
     * For Salesforce1 and Lightning themes, action handler
     * for navigating to record or arbitrary URL.
     */
    handleOnClick : function( component, event, helper ) {

        var linkToRecord = component.get( 'v.linkToRecord' );
        var linkToURL = component.get( 'v.linkToURL' );

        if ( !$A.util.isUndefinedOrNull( linkToRecord ) ) {
            helper.navigateToRecord( linkToRecord );
        } else if ( !$A.util.isUndefinedOrNull( linkToURL ) ) {
            helper.navigateToURL( linkToURL );
        } else {
            console.warn( 'Unexpected click event. No value for v.linkToRecord or v.linkToURL' );
            //console.log( event );
        }

    }
})