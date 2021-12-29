({
	init: function (component, event, helper) {
    component.set('v.tableColumns', [
                {label: 'Account', fieldName: 'accountURL', type: 'url', typeAttributes:
                    { label: {fieldName: 'accountName' }
                    },
                },
                {label: 'Mifid II In Scope', type: 'text', cellAttributes:
                    { iconName: { fieldName: 'mifidInScopeIcon' }, iconPosition: 'right' }},
                {label: 'Product Subscriptions', fieldName: 'subscriptions', type: 'text'},
                {label: $A.get("$Label.c.Desk_Commentary_Label"), fieldName: 'deskCommentary', type: 'text'}
            ]);
       
       	helper.initialiseAccountInformation(component);
    },
    getSelectedName: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            alert("You selected: " + selectedRows[i].accountName);
        }
    },

    navigateBackToAccount : function(component){
    	var accountId = component.get("v.parentAccountId");
    	var navEvt = $A.get("e.force:navigateToSObject");
	    navEvt.setParams({
	      "recordId": accountId
	    });
	    navEvt.fire();
    }
})