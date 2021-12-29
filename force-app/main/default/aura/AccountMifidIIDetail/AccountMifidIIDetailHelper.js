({
	initialiseAccountInformation : function(component){
        var validationResult = [];
        var test = component.get("v.parentAccountId");
        var action = component.get("c.getAccountSubscriptions");
        console.log('TEST: '+ test);
        action.setParams({
            "parentAccountId" :  component.get("v.parentAccountId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {                   
                    var result =  response.getReturnValue();
                    console.log(result);

                    var resultArray = [];

                    for(var k in result){
                        var a = {
                            id: result[k].rmAccount.Id,
                            accountURL : '/' + result[k].rmAccount.Id,
                            accountName: result[k].rmAccount.Name,
                            mifidIIInScope: result[k].rmAccount.MiFIDII_in_Scope__c,
                            subscriptions: result[k].productSubscriptions,
                            deskCommentary: result[k].deskCommentary 
                        }

                        if(a.mifidIIInScope == true){
                            a.mifidInScopeIcon = 'standard:task2';
                        }else{
                            a.mifidInScopeIcon = '';
                        }

                        resultArray.push(a);

                        component.set("v.ParentAccountName", result[k].rmAccount.Parent.Name);
                    }


                    component.set("v.accountData", resultArray);
                }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                            validationResult.push({
                                message :  errors[0].message
                            });
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
            
    }
})