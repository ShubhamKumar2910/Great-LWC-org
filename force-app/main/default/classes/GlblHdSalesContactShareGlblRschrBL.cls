public class GlblHdSalesContactShareGlblRschrBL {
    public static void ShareContactWithGlobalHeadResearchAccount(List<Contact> newRecords,Map<Id,Contact> oldRecords){
      /*   List<ContactShare> sharesToCreate = new List<ContactShare>();
        ID []  ContactId = new ID []{};
        ID []  ContactOwnerId = new ID []{}; 
        ID [] ContactWithSalesOwners = new ID[] {}; 
                
        Map <ID,String> GroupNamesBasedOnBillingCountry = new Map <ID,String> (); 
            


    for (Contact contact : newRecords) {
        ContactId.add(contact.id);
        ContactOwnerId.add(contact.ownerId);
    }  
        
        system.debug('newRecords :'+ newRecords);
     
          
       
        
         
       // Contact[] cont =[Select name, Account.Name,Account.Restricted_Flag__c,OwnerId from contact where id in: ContactId
                   // AND Account.Restricted_Flag__c = false And OwnerId IN (SELECT Id FROM User WHERE Id=: ContactOwnerId AND USerRoleId IN :subordinateRolesToGMSales)];
       
        Contact[] contNonRestricted =[Select name, Account.Name,Account.Restricted_Flag__c,OwnerId,Account.BillingCountry from contact where id in: ContactId
                    AND Account.Restricted_Flag__c = false];
        
         Contact[] contRestricted =[Select name, Account.Name,Account.Restricted_Flag__c,OwnerId,Account.BillingCountry from contact where id in: ContactId
                    AND Account.Restricted_Flag__c = true];
        
        for(Contact contacts : contRestricted ){
            GroupNamesBasedOnBillingCountry.put(contacts.AccountId,'Research_'+ contacts.Account.BillingCountry);  
        }
        
        List<Group> ResearchGroupsBasedonCountry = [select id, name from Group where Name IN: GroupNamesBasedOnBillingCountry.values()];
         List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE NAME Like '%Research_Group%'];
       
       
        
                
        List<ContactShare> conshare = [SELECT Id,ContactId,UserorGroupId FROM ContactShare WHERE ContactId IN : contNonRestricted
                                      AND UserOrGroupId IN : ResearchGroups ];
        Map<String,String> existingContactShares = new Map<string,string>();
        for(ContactShare csh :conshare ){
            string contactShareKey = String.valueOf(csh.ContactId) + string.valueOf(csh.UserOrGroupId);
            existingContactShares.put(contactShareKey,contactShareKey);
        }
        
           for(Group grp:ResearchGroups){
                for(Contact cont :contNonRestricted ){ 
                    system.debug('grp.name :'+ string.valueOf(grp.name));
                    string grpContactKey = string.valueOf(cont.id) +  string.valueOf(grp.Id);
                    
                    if(!existingContactShares.containsKey(grpContactKey)){
                       ContactShare cs = new ContactShare();
                       cs.ContactAccessLevel = 'Edit';
                       cs.ContactId = cont.Id;                     
                       cs.UserOrGroupId =  grp.id;                   
                       sharesToCreate.add(cs);  
                    } 
               
                    
                 }
            }
        
        ContactShare [] contactSharesToDelete = [select id from ContactShare where contactId in:contRestricted];
        
            if(contactSharesToDelete.size() > 0){
                try {                    
                    Database.delete(contactSharesToDelete,false);
                }
                catch(exception ex){
              newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
          }
            }        
        
        
         for(Group grp:ResearchGroups){
                for(Contact cont :contRestricted ){                    
                    if(string.valueOf(grp.name).contains(cont.Account.BillingCountry)){
                    ContactShare cs = new ContactShare();
                    cs.ContactAccessLevel = 'Edit';
                    cs.ContactId = cont.Id;                     
                    cs.UserOrGroupId =  grp.id;                   
                    sharesToCreate.add(cs);
                    }                    
                   
                 }
            }
        
         if (!sharesToCreate.isEmpty())
              try{
                Database.insert(sharesToCreate,false);
              }
        catch(exception ex){
           newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
        } */
        
        
    } 
}