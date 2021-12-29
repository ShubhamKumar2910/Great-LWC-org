trigger ActivateDeactivateContact on Contact (
  before insert, before update, after update, after insert) 
{
  /* /* SHIELD - START 
  User userObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];   
    
  for (Contact contact : Trigger.new) 
  {
    String encInactive = System.Label.InactiveEncryptedText;
    String unEncInactive = '(INACTIVE)';
      
    if(trigger.isUpdate && trigger.isBefore)
    {
      System.debug('is update');
    
      //Contact oldContact = trigger.oldMap.get(contact.ID);
      //if(contact.Active__c!=oldContact.Active__c){ 
      System.debug('active box changed');        
      System.debug('custom label text ' + System.Label.InactiveEncryptedText);
      
      if(!contact.Active__c)
      {  
        System.debug('has been deactivated');
        System.debug('15 inactive index  '+ contact.lastName.indexOf(encInactive));

        if(
            (contact.lastName.indexOf(unEncInactive)>=0)||
            (contact.LastName.indexOf(encInactive)>=0))
        {
          contact.lastName = contact.lastName.replace(encInactive, '');
          contact.lastName = contact.lastName.replace(unEncInactive, '');
          System.debug('21 last name ac ::' + contact.lastName);
        }

        System.debug(
          '24 inactive index 2 '+ contact.lastName.indexOf(unEncInactive));
        
        if(contact.lastName.indexOf(unEncInactive)<0)
        {
          contact.lastName = contact.lastName + unEncInactive;
          System.debug('27 last name inact ::' + contact.lastName);
        }

        if(contact.lastName.indexOf(encInactive)>0)
        {
          System.debug('30 encoded text present about to be replaced');
           
          contact.lastName = contact.lastName.replace(encInactive, unEncInactive);
          System.debug('32 last name inact ::' + contact.lastName);
        }
                    
        System.debug(
          '34 length of inactive last name :: ' + contact.LastName.length());
          
          contact.GRP_Access__c = False;
          contact.Markit_Hub__c = False;
      }
      else if(contact.Active__c)
      {
        System.debug('has been activated');
        System.debug('inactive index '+ contact.lastName.indexOf(unEncInactive));
        System.debug('encInactive index ' + contact.LastName.indexOf(encInactive));
        
        if(
            (contact.lastName.indexOf(unEncInactive)>=0)||
            (contact.LastName.indexOf(encInactive)>=0))
        {
          contact.lastName = contact.lastName.replace(unEncInactive, '');
          contact.lastName = contact.lastName.replace(encInactive, '');
          
          System.debug('last name ac ::' + contact.lastName);
        }
          
         contact.Inactive_Reason__c = '';
         contact.Other_Inactive_Reason__c = '';
      }
      //}
    }
         
    if(trigger.isInsert && Trigger.isBefore)
    {
      System.debug('is insert');
      
      // PeterUk - FOR CONSOLE MODE ONLY
      // **SET RG ACCOUNT BASED ON RM** 
      // this get set on page within Lightning
      if(contact.RG_Account__c == null &&
         !'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name) && !'sfadmin'.equalsIgnoreCase(userObj.Login_ID__c))
      {
          Account RMacc = [SELECT ParentId FROM Account WHERE Id =: contact.accountId];
          contact.RG_Account__c = RMacc.ParentId;
      }
      
      if(null!=contact.lastName&&contact.lastName.length()>0)
      {
        if(!contact.Active__c)
        {
          if(contact.lastName.indexOf(encInactive)>=0)
          {
            contact.lastName = contact.lastName.replace(encInactive, '');
            System.debug('last name ac ::' + contact.lastName);
          }
                    
          if(contact.lastName.indexOf(unEncInactive)<0)
          {
            contact.lastName =  contact.lastName + unEncInactive ;
            System.debug('last name inact ::' + contact.lastName);
          }
        }
        else if(contact.Active__c)
        {
          if(
              (contact.lastName.indexOf(unEncInactive)>=0)||
              (contact.LastName.indexOf(encInactive)>=0))
          {
            contact.lastName = contact.lastName.replace(unEncInactive, '');
            contact.lastName = contact.lastName.replace(encInactive, '');
            
            System.debug('last name ac ::' + contact.lastName);
          }
        } 
      }
        
        if(contact.Active__c){
            contact.Inactive_Reason__c = '';
            contact.Other_Inactive_Reason__c = '';
        } else {            
            if(!'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name) && !'sfadmin'.equalsIgnoreCase(userObj.Login_ID__c) ){                
                contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Active Contact').getRecordTypeId();
                contact.Active__c = True;
                contact.Inactive_Reason__c = '';
                contact.Other_Inactive_Reason__c = '';
            }
        }
        
        //ContactTriggerHandler.handleBeforeInsert(trigger.new);
    }   
         
  }
 
  SHIELD - END */ 

	if(trigger.isInsert && Trigger.isBefore) {
		ContactTriggerHandler.handleBeforeInsert(Trigger.new);
	}	
	
	if(Trigger.isAfter && Trigger.isInsert)	{
		ContactTriggerHandler.handleAfterInsert(Trigger.new, Trigger.oldMap);
	}
	
	if(Trigger.isBefore && Trigger.isUpdate) {
		ContactTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);  
	}
	
	if(Trigger.isAfter && Trigger.isUpdate) {
		ContactTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
	}
}