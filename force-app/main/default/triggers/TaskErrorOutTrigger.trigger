trigger TaskErrorOutTrigger on Task (before insert, before update) {
/*    
    System.debug('inside trigger TaskErrorOutTrigger');
    Set<String> whatIDs = new Set<String>();
    
    for (Task t : Trigger.new) {
        whatIDs.add(t.whatID);
    }
    
    List<Account> accts = [SELECT Id, RG_Account__c, RM_Account__c   FROM Account WHERE Id =: whatIDs];
    
    
    for (Task t : Trigger.new){
        if (!(t.Type.equals('Internal account review'))) {
            System.debug('not internal review');
            if (accts.size()>0) {
                if(accts[0].RM_Account__c){
                    if(String.isBlank(t.WhoId)){
                        System.debug('who id is blank');
                        t.addError('You are adding this Task to an Account so you must also select a Contact in the name field');
                    } 
                }else if(accts[0].RG_Account__c){
                    t.addError('Please relate this activity to an RM Account.');
                }else{
                    t.addError('Please relate this activity to an RM Account.'); 
                }
            }//account size > 0
        }//end of not internal account review
        else{ //from here is Internal account review
            if (accts.size()>0) {
                if(accts[0].RM_Account__c){
                    System.debug('is RM.....');
                    if(String.isBlank(t.WhoId)){
                        System.debug('who id is blank for RM');
                        t.addError('You are adding this Task to an Account so you must also select a Contact in the name field');
                    } 
                }else if(accts[0].RG_Account__c){
                    //ignore
                }else{
                    t.addError('Please relate this activity to an RM Account.');
                }
            }
        }//end of each Task
    } //end for Task in Trigger.New loop
*/
}