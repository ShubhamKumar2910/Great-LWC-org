({
    doInit: function(component, event, helper) {
        var nodeType = component.get("v.pos.nodeType");
        if(nodeType == "parent" || nodeType == "parent_end") {
            component.set("v.buttonClass", "slds-button slds-button--icon slds-m-right--x-small");
        } else {
            component.set("v.buttonClass", "slds-button slds-button--icon slds-m-right--x-small slds-is-disabled");
        }
        var currentNode = component.get("v.pos.currentNode");
        if(currentNode) {
            component.set("v.nameStyle", "font-weight: bold;")
        }
    },
 
    navigateToRecord : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": event.target.getAttribute('data-recordId'),
          "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    expandContractRow : function(component, event, helper) {
        var inlineAccountHierarchyRowEvent = $A.get("e.c:AccountHierarchyInlineRowEvent");
        var endState = "expanded";
        if (component.get("v.expandedFlag")) { endState = "collapsed"; }
        inlineAccountHierarchyRowEvent.setParams({ 
            "toggledNodeId" : component.get("v.pos.nodeId"),
            "endState" : endState
        });
        inlineAccountHierarchyRowEvent.fire();
    },
    
    handleInlineAccountHierarchyRowEvent : function(component,event,helper) {
        var toggledNodeId = event.getParam("toggledNodeId");
        var endState = event.getParam("endState");
        var toggledParentLevels = (component.get("v.pos.nodeId").match(/-/g).length - toggledNodeId.match(/-/g).length);
        
        //if this row is a descendent of the toggled row or the toggled row itself
		if (component.get("v.pos.nodeId").includes(toggledNodeId)) {
            //if the toggled row is the immediate parent of this row
            if (toggledParentLevels == 1) {
               //and if this sibling group state is expanded
                if (component.get("v.expandedSiblingGroup")) {
                    //then collapse this sibling group and hide these account details
                    component.set("v.expandedSiblingGroup", false);
                    component.set("v.expandedClass", "slds-is-collapsed");
                //but if this sibling group state is collapsed
                } else {
                    //then expand this sibling group and show these account details
                    component.set("v.expandedSiblingGroup", true);
                    component.set("v.expandedClass", "slds-is-expanded");
                }
            //but if the toggled row is a distant ancestor of this row
            } else if (toggledParentLevels > 1) {
                //and if the end state is collapsed
                if (endState == "collapsed") {
                    //then hide these account details
                    component.set("v.expandedClass", "slds-is-collapsed");
                //but if the end state is expanded
                } else if (endState == "expanded") {
                    //and if the sibling group state is expanded
                    if (component.get("v.expandedSiblingGroup")) {
                        //then show these account details
                        component.set("v.expandedClass", "slds-is-expanded");
                    //but if the sibling group state is collapsed
                    } else {
                        //then hide these account details
                        component.set("v.expandedClass", "slds-is-collapsed");
                    }
                }
            //otherwise, if the toggled row is this row, 
            } else if (component.get("v.pos.nodeId") == toggledNodeId) {
                //and if the chevron is currently expanded
                if (component.get("v.expandedFlag")) {
                    //then collapse the chevron
                    component.set("v.expandedFlag", false);
                //but if the chevron is  currently collapsed
                } else {
                    //then expand the chevron
                    component.set("v.expandedFlag", true);
                }
            }
        }
        
/*        
        //if this row is a descendent of the toggled row or the toggled row itself
		if (component.get("v.pos.nodeId").includes(toggledNodeId)) {
        	//change the account details state for this row
        	//if this row is not the toggled row
        	if(component.get("v.pos.nodeId") != toggledNodeId) {
                //if this row's account details are visible and the toggled row is any ancestor of this row (but not this row)
                if (component.get("v.expandedClass") == "slds-is-expanded") {
                    //then hide this row's account details
                    component.set("v.expandedClass", "slds-is-collapsed");
                //if this row's account details are hidden and the toggled row is this row's immediate parent
                } else if (component.get("v.expandedClass") == "slds-is-collapsed" && toggledParentLevels == 1) {
                    //then show this row's account details
                    component.set("v.expandedClass", "slds-is-expanded");
                //if this row's account details are hidden and the toggled row is a distant ancestor and this row's chevron is expanded and the end state is expanded
                } else if (component.get("v.expandedClass") == "slds-is-collapsed" && toggledParentLevels > 1 && component.get("v.expandedFlag") == true && endState == "expanded") {
                    //then show this row's account details
                    component.set("v.expandedClass", "slds-is-expanded");
                }
            }
        	//otherwise if this is the toggled row
        		//then don't change account details state -- no action

        	//change the chevron state for this row
        	//if this row is the toggled row or (the toggled row is the immediate parent and this node type is child)
            if (component.get("v.pos.nodeId") == toggledNodeId || (toggledParentLevels == 1 && component.get("v.pos.nodeType").includes("child"))) {
        		//and if this row's chevron is expanded
                if (component.get("v.expandedFlag") == true) {
        			//then collapse this row's chevron
        			component.set("v.expandedFlag", false);
                //but, if this row's chevron is collapsed
                } else { 
        			//then expand this row's chevron
        			component.set("v.expandedFlag", true);
                }
            }
        	//otherwise, if the toggled row is a distant ancestor of this row
        		//don't change chevron state
        
        }

        
        //if this row is any descendent of the toggled row
        if (component.get("v.pos.nodeId").includes(toggledNodeId)) {
			//and if this row's chevron is expanded
            if (component.get("v.expandedFlag")) {
                //then collapse this row's chevron
                component.set("v.expandedFlag", false);
                //and if this row is not the toggled row
                if(component.get("v.pos.nodeId") != toggledNodeId) {
                    //then also hide this row account details
	                component.set("v.expandedClass", "slds-is-collapsed");
                }
            //however, if this row is any descendent of the toggled row, but this row's chevron is collapsed
            } else {
                //then expand this row's chevron
                component.set("v.expandedFlag", true);
                //and if this row is not the toggled row
                if(component.get("v.pos.nodeId") != toggledNodeId) {
                    //then also show this row's account details
                    component.set("v.expandedClass", "slds-is-expanded");
                }
            }
        }
 */       
        
        
    }
})