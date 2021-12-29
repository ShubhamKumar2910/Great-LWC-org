@isTest
private class RevenueBLTest {
  static testMethod void TestCreateRevenueShareRecords() {
    list<user> user = UtilityTesting.CreateUsers(3);
    system.runas(user[0]){
       Account acct = UtilityTesting.CreateAccount();     
       
       List<Group> gpList = new List<group>();
       
       group gp = new group();
       gp.name='test';
       gp.developername='test_group';
       gpList.add(gp);
       
       gp = new group();
       gp.name = 'test1';
       gp.developername = 'test_group_1';
       gpList.add(gp);
       
       insert gpList;
             
       revenue__c rev = new revenue__c();
       rev.rm__c = acct.id;
       rev.group__c = 'test';
        rev.Sales_Id__c='TEST';
        rev.Salesperson__c = 'TEST/TEST';
       insert rev;
       
       revenue__c revToUpdate = new revenue__c();
       revToUpdate.id = rev.id;
       revToUpdate.group__c = 'test1';
       update revToUpdate;
       
        //persona update
       Analytic_Revenue_Persona_Link__c persona = new Analytic_Revenue_Persona_Link__c();
       persona.SMS_Sales_Id__c='TEST';
        persona.SMS_Salesperson__c = 'TEST/TEST';
        insert persona;
        Id personaId = persona.id;
        System.debug('New Persona id = ' + personaId);
        //update revenue
        rev.Salesperson__c='TEST/TEST/TEST';
        System.debug('Updating revenue with new salesperson name');
        update rev;
        List<Analytic_Revenue_Persona_Link__c> personas = [SELECT id, SMS_Salesperson__c from Analytic_Revenue_Persona_Link__c where Id=:personaId];
        if (personas.size()>0) {
	        Analytic_Revenue_Persona_Link__c newPersona = personas[0];
    	    System.assert(newPersona.SMS_Salesperson__c == 'TEST/TEST/TEST');
        } else {
            System.debug('No test personas found!');
        }
        rev.Salesperson__c='LEAVER';
        update rev;
        personas = [SELECT id, SMS_Salesperson__c from Analytic_Revenue_Persona_Link__c where Id=:personaId];
        if (personas.size()>0) {
	        Analytic_Revenue_Persona_Link__c newPersona = personas[0];
    	    System.assert(newPersona.SMS_Salesperson__c == 'TEST/TEST/TEST');
        } else {
            System.debug('No test personas found for leaver test');
        }
        rev.Salesperson__c='hello test';
        update rev;
        personas = [SELECT id, SMS_Salesperson__c from Analytic_Revenue_Persona_Link__c where Id=:personaId];
        if (personas.size()>0) {
	        Analytic_Revenue_Persona_Link__c newPersona = personas[0];
    	    System.assert(newPersona.SMS_Salesperson__c == 'hello test');
        } else {
            System.debug('No test personas found for leaver reversion test');
        }
        //inactive test
        persona.Is_Active__c = false;
        persona.SMS_Salesperson__c = 'hello test';
        update persona;
        rev.Salesperson__c='inactive test';
        update rev;
        personas = [SELECT id, SMS_Salesperson__c from Analytic_Revenue_Persona_Link__c where Id=:personaId];
        if (personas.size()>0) {
	        Analytic_Revenue_Persona_Link__c newPersona = personas[0];
    	    System.assert(newPersona.SMS_Salesperson__c == 'hello test');
        } else {
            System.debug('No test personas found for inactive test');
        }
       delete rev;
        
     }
   }
 }