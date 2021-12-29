public class ContactAddrChangeOnAccAddrUpdateBL {
    
    public static void ContactAddrChangeOnAccAddrUpdate(List<Account> newRecords,Map<Id,Account> oldRecords){
       ID [] AccountIds = new ID []{}; 
        List<Contact>  contactsMailingTrueToBeUpdated = new List<Contact>();  
        List<Contact>  contactsMailingFalseToBeUpdated = new List<Contact>();  
        Map<Id,Account> newAccountRecords = new Map<Id,Account>();
        
        for(Account acc : newRecords){
            if(acc.ShippingStreet != oldRecords.get(acc.id).ShippingStreet || acc.ShippingCity != oldRecords.get(acc.id).ShippingCity
              || acc.ShippingState != oldRecords.get(acc.id).ShippingState || acc.ShippingPostalCode != oldRecords.get(acc.id).ShippingPostalCode
               || acc.ShippingStateCode != oldRecords.get(acc.id).ShippingStateCode 
               || acc.ShippingCountryCode != oldRecords.get(acc.id).ShippingCountryCode){
                   AccountIds.add(acc.id);
                   newAccountRecords.put(acc.id,acc);
                   
               }
        }
        
        if(AccountIds.size() > 0){
        
        Contact [] contactmailingtrue = [SELECT Id, AccountId, 
                                  OtherStreet, OtherCity, OtherPostalCode, OtherState, OtherCountry
                                  FROM Contact 
                                  WHERE Active__c = TRUE AND Mailing_Address_Same_As_Account_Address__c = TRUE
                                  AND AccountId IN : AccountIds];
            
        Contact [] contactmailingfalse = [SELECT Id, AccountId, 
                                  OtherStreet, OtherCity, OtherPostalCode, OtherState, OtherCountry
                                  FROM Contact 
                                  WHERE Active__c = TRUE AND Mailing_Address_Same_As_Account_Address__c = FALSE
                                  AND AccountId IN : AccountIds];
        
            
         for (Contact contac : contactmailingtrue){
             
                Account acct = newAccountRecords.get(contac.AccountId);
                                 
                contac.OtherStreet = acct.ShippingStreet;
                contac.OtherCity = acct.ShippingCity;
                contac.OtherPostalCode = acct.ShippingPostalCode;
                contac.OtherState = acct.ShippingState;
                contac.OtherCountry = acct.ShippingCountry;
                
                contactsMailingTrueToBeUpdated.add(contac);
              
           }  
            
            for(Contact cont : contactmailingfalse)  {
             if(string.isBlank(cont.OtherStreet) && string.isBlank(cont.OtherCity)
              && string.isBlank(cont.OtherCountry)){
                    Account acct = newAccountRecords.get(cont.AccountId);
                    
                    cont.OtherCity = acct.ShippingCity;
                    cont.OtherCountry = acct.ShippingCountry;
                    cont.OtherPostalCode = acct.ShippingPostalCode;
                    cont.OtherState = acct.ShippingState;
                    cont.OtherStreet = acct.ShippingStreet;
                    contactsMailingFalseToBeUpdated.add(cont);
                }
         }
            
            
            if(contactsMailingTrueToBeUpdated.size() > 0 || contactsMailingFalseToBeUpdated.size() > 0){
                try{
                	update contactsMailingTrueToBeUpdated;
                    update contactsMailingFalseToBeUpdated;
                    
            	}   catch(Exception ex){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                }
            
      		}
        }
    }
    
    
    public static void MarkAccountsAsRestrictedBasedonRestrictedCountries(List<Account> newRecords,Map<Id,Account> oldRecords){
        Map<String,String> restrictedCountries = new Map<String,String>();
        ID[] AccountId = new ID[]{};
        ID[] NonRestrictedAccountID = new ID[]{};
        
        List<Restricted_Countries__c> restrictedCountriesList = [SELECT Id,Country_code__c,Restricted_Country_Name__c,Name FROM Restricted_Countries__c];
        
        system.debug('restrictedCountriesList :'+ restrictedCountriesList);
        
        for(Restricted_Countries__c rstrcdCntries : restrictedCountriesList){
             restrictedCountries.put(string.valueOf(rstrcdCntries.Country_Code__c).split('-')[1],rstrcdCntries.Name);
        }
        List<Account> RMAccounts = new List<Account>();
        List<Account> RMAccountsNonRestricted = new List<Account>();
        for(Account accnt : newRecords){
            Account accntClone = accnt.clone (true,true,true,true);
            if(oldRecords.get(accntClone.id).domicile_country__c <> accntClone.domicile_country__c){
            if(restrictedCountries.containsKey(accntClone.domicile_country__c)){
                //AccountId.add(accnt.Id);
                //setting to cover the record for RM Movement in new RM Creation JIRA SALES-3692 
                if(oldRecords.get(accntClone.id).Restricted_Flag__c == false){//NonRestricted RM to Restricted RM
                    accntClone.Restricted_Flag__c = true;
                    RMAccounts.add(accntClone);
                }else{//Restricted RM to Restricted RM                    
                    accntClone.Previous_RG__c = 'NA';
                    RMAccounts.add(accntClone);
                }
            }
            else//Restricted RM to NonRestricted RM
            {
                //NonRestrictedAccountID.add(accnt.Id);
                //setting to cover the record for RM Movement in new RM Creation JIRA SALES-3692  
                if(oldRecords.get(accntClone.id).Restricted_Flag__c == true){
                    accntClone.Restricted_Flag__c = false;
                    accntClone.Previous_RG__c = 'NA';
                    RMAccountsNonRestricted.add(accntClone);
                }
            }
        }
        }
        
        system.debug('AccountId :'+ AccountId);
        
       //List<Account> RMAccounts = [SELECT ID,Name FROM ACCOUNT WHERE ID IN : AccountId and Restricted_Flag__c = false];
         
       //List<Account> RMAccountsNonRestricted = [SELECT ID,Name FROM ACCOUNT WHERE ID IN : NonRestrictedAccountID and Restricted_Flag__c = true];
        
        system.debug('RMAccounts :'+ RMAccounts);
                
        /*for(Account RMAccount : RMAccounts){            
             RMAccount.Restricted_Flag__c = true;                                    
        } 
        for(Account RMAccntNon : RMAccountsNonRestricted){             
            RMAccntNon.Restricted_Flag__c = false;
        }*/

       try{
             
       if(RMAccounts.size() >0)
        Update RMAccounts;
             
        }
        catch(exception ex){
              newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+':RMAccountsNonRestricted');
          }
        
          try{
       if(RMAccountsNonRestricted.size() > 0)
        Update RMAccountsNonRestricted;
             
        }
        catch(exception ex){
              newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+ ':RMAccountsNonRestricted');
          }
    }
    
    public static void PopulateBlankAddressFieldsForRMAccount(List<Account> newRecords){
        
       Map<string,string> countryCodeMap = new Map<string,string>();
       
        Schema.DescribeFieldResult fieldResultCountry = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> Countries = fieldResultCountry.getPicklistValues();
        for(Schema.PicklistEntry Country : Countries){
            countryCodeMap.put(country.getValue(),country.getLabel());
        }
        
        for(Account accts : newRecords){
            if(string.isBlank(accts.BillingStreet)){
                accts.BillingStreet = '**Not Entered**';
            }
            if(string.isBlank(accts.BillingCity)){
                accts.BillingCity = '**Not Entered**';
            }
            if(countryCodeMap.containsKey(accts.Domicile_Country__c) && string.isBlank(accts.BillingCountry)){
                accts.BillingCountry = countryCodeMap.get(accts.Domicile_Country__c);
            }
        }

    }
    
    public static void contactMailingAddrChangeOnAccOfficeAddrUpdate (List<Account> newRecords, Map<Id,Account> oldRecords){
        List<Contact> contactsToBeUpdated = new List<Contact>();
        Map<Id,Account> newAccountRecords = new Map<Id,Account>();
        
        for(Account accountObj : newRecords){
            if(accountObj != null){
                if((String.isNotEmpty(accountObj.BillingStreet) && !accountObj.BillingStreet.equals(oldRecords.get(accountObj.Id).BillingStreet)) ||
                   (String.isEmpty(accountObj.BillingStreet) && String.isNotEmpty(oldRecords.get(accountObj.Id).BillingStreet)) ||
                   (String.isNotEmpty(accountObj.BillingCity) && !accountObj.BillingCity.equals(oldRecords.get(accountObj.Id).BillingCity)) ||
                   (String.isEmpty(accountObj.BillingCity) && String.isNotEmpty(oldRecords.get(accountObj.Id).BillingCity)) ||
                   (String.isNotEmpty(accountObj.BillingPostalCode) && !accountObj.BillingPostalCode.equals(oldRecords.get(accountObj.Id).BillingPostalCode)) ||
                   (String.isEmpty(accountObj.BillingPostalCode) && String.isNotEmpty(oldRecords.get(accountObj.Id).BillingPostalCode)) ||
                   (String.isNotEmpty(accountObj.BillingState) && !accountObj.BillingState.equals(oldRecords.get(accountObj.Id).BillingState)) ||
                   (String.isEmpty(accountObj.BillingState) && String.isNotEmpty(oldRecords.get(accountObj.Id).BillingState)) ||
                   (String.isNotEmpty(accountObj.BillingCountry) && !accountObj.BillingCountry.equals(oldRecords.get(accountObj.Id).BillingCountry)) ||
                   (String.isEmpty(accountObj.BillingCountry) && String.isNotEmpty(oldRecords.get(accountObj.Id).BillingCountry)) )
                {
                       newAccountRecords.put(accountObj.Id, accountObj);
                }
            }
        }
        
        if(newAccountRecords.size() > 0){
           	Set<Id> accountIdSet = newAccountRecords.keySet();
            Contact [] contacts = [SELECT Id, AccountId, 
                                  MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry
                                  FROM Contact 
                                  WHERE Active__c = TRUE AND Mailing_Address_Same_As_Account_Address__c = TRUE
                                  	AND AccountId IN :accountIdSet
                                 ]; 
            
            for(Contact contactObj : contacts){
                Account accountObj = newAccountRecords.get(contactObj.AccountId);
                
                contactObj.MailingStreet = accountObj.BillingStreet;
                contactObj.MailingCity = accountObj.BillingCity;
                contactObj.MailingpostalCode = accountObj.BillingPostalCode;
                contactObj.MailingState = accountObj.BillingState;
                contactObj.MailingCountry = accountObj.BillingCountry;
                
                contactsToBeUpdated.add(contactObj);
            }
            
            if(contactsToBeUpdated.size() > 0){
                try
            	{
                	update contactsToBeUpdated;
            	}
                catch(Exception ex){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                }
            }
                
        }
    }
}