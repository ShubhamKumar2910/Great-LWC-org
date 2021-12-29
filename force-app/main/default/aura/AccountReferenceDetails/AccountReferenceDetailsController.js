({
	doInit: function(component, event, helper) {
    	//Fetch Details		
        helper.getAccountAccordionSectionDetails(component, function(){
            component.formAccordionSectionContent();
        });
    },
    
    formAccordionSectionContent: function(component, event, helper) {
         var accordionSectionList = component.get('v.accordionSections');
         var recordId = component.get('v.recordId');
         
         if(accordionSectionList != undefined && accordionSectionList != null && accordionSectionList.length > 0){
         
             for(var i=0; i<accordionSectionList.length; i++){
                 var childComponent = accordionSectionList[i].cmpName;
                 $A.createComponents([
                        ["lightning:accordionSection",
                          {
                              "name" : accordionSectionList[i].name,
                              "label" : accordionSectionList[i].label,
                              /*"title" : accordionSectionList[i].title,*/
                              "aura:id" : accordionSectionList[i].auraId,
                              "class" : 'sectionCls'
                          }
                        ],
                        [childComponent,
                         {
                             "childRecordId" : recordId
                         }]
                    ], 
                    function(components, status, errorMessage){
                        if (status === "SUCCESS") {
                            var targetComponent = component.find("acctAccordion")
                            var body = targetComponent.get("v.body");
                            
                            var lightningAccordionSection = components[0];
                            lightningAccordionSection.set("v.body",components[1]);
                            
                            body.push(lightningAccordionSection);
                            targetComponent.set("v.body",body);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
             }
             
             setTimeout($A.getCallback(
            	() => component.set("v.activeSectionName", accordionSectionList[0].name)
         	 ), 1000);	
         }
       
    }
})