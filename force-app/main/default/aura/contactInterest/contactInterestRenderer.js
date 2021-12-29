({
	rerender : function(component, helper){
        this.superRerender();
        if(component.get("v.isHelperScriptLoaded") && component.get("v.needToRenderHelperLogic")) {
            try {
                $("#flagsMultiSelect").select2({
            multiple : true,
            width : "100%",
            placeholder: "Please select",
            data : [
                    {
                      id: 'wont participate in deals with mkt cap < US$2bn',
                      text: 'won\'t participate in deals with mkt cap < US$2bn'
                    },
				   {
                      id: 'wont participate in deals with mkt cap < US$10bn',
                      text: 'won\'t participate in deals with mkt cap < US$10bn'
                    },
					  {
                      id: 'wont participate in deals with mkt cap < US$20bn',
                      text: 'won\'t participate in deals with mkt cap < US$20bn'
                    },
            ]
          }); 
                var rec = component.get("v.recordId");
            console.log('Record ID = ' + rec);
            helper.getContactDetails(component) ;
            helper.enableDisableCreateButton(component, "true");
            component.set("v.needToRenderHelperLogic",false);
            }
             catch(err) {
                console.log('Error during Helper renderer logic. Please find below:')   ;
                console.log(err);
            }
        }
    },
      unrender: function () {
        this.superUnrender();
        // do custom unrendering here
    }
})