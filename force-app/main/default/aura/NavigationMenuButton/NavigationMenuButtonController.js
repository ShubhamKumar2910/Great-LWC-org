({
	onButtonClick : function(component, event, helper) {
        var button = component.find('homeAction');
        component.togglePopUp(button);
    },
    onMenuSelection : function(component, event, helper) {
        var myEvent = $A.get("e.c:NavigationBarEvent");
        var menuURLValue = event.getSource().get("v.value");
        myEvent.setParams({ "menuURL": menuURLValue});
        myEvent.fire();
        
    },
    toggleVisibility: function(component,event){
        var button = component.find('homeAction');
        window.setTimeout(function(){component.togglePopUp(button);},200);
    },
    handleSelection: function(component, event, helper) {
        var button = component.find('homeAction');
        var item = event.currentTarget;
        if (item && item.dataset) {
            var itemvalue = item.dataset.value;
            var itemindex = item.dataset.index;
            var myEvent = $A.get("e.c:NavigationMenuButtonEvent");
            myEvent.setParams({ "itemindex": itemindex});
            myEvent.setParams({ "itemvalue": itemvalue});
            myEvent.fire();
        }
    },
    togglePopUp: function(component,event){
        var params = event.getParam('arguments');
        if(params)
        {
            var buttonComponent = params.buttonObject;
            $A.util.toggleClass(buttonComponent, 'slds-is-open');
        }
    },
})