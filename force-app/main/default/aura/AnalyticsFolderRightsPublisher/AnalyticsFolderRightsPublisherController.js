(
    {
    doInit : function(component, event, helper) {
        var context = {apiVersion: "46.0"};
        var method = 'listFolders';
        var methodParameters = {
            'pageSize' : 200};
        var sdk = component.find("sdk");
        var folders = [];
        console.log("invoking sdk method listFolders with sdk "+ sdk);
        sdk.invokeMethod(context, method, methodParameters,
            $A.getCallback(function (err, data) {
                console.log("In callback for sdk");
                if (err !== null) {
                    //DO THIS IF THE METHOD FAILS
                    console.error("SDK error", err);
                } else {
                    //DO THIS IF THE METHOD SUCCEEDS
                    var payload = JSON.parse(JSON.stringify(data.folders));
                    for (var i = 0; i < payload.length; i++) {
                        folders[i]= payload[i].name;
                    }
                    var pubsub = component.find('pubsub');
                    console.log("type of for folders " + typeof folders);
                    pubsub.fireEvent('waveFolderSearchEvent', folders);
                }
                console.log("after checking data and err object");
            }));
     },  
});