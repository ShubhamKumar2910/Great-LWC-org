public without sharing class LookupController 
{
    static String contactInput = '';
    public static Set<string> deskCodes = new Set<string>();
    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    //added parameter for JIRA SALES-2607
    @AuraEnabled
    public static LookupControllerResult[] lookup(String searchString, String sObjectAPIName, Boolean includeNomuraContact, Boolean allRecords, List < string > accountRecordType, Boolean uniqueSalesCode, Boolean inactiveSalesCode, Boolean isSplitSalesCode, Boolean withSharing
                                                 ,string baseString, String singleLookupJSON,String accountCompany,Boolean includeRGWithRMOnly,
                                                 Boolean filterDeskCode, Boolean includeInstinetContact, Boolean showCoveredAccountDetails,
                                                 String accountId) 
    {
        
        String searchQuery = '';
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        system.debug(sanitizedSearchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        List < LookupControllerResult > results = new List < LookupControllerResult > ();
        string CPID = 'CP12345';
        String INID = 'IN12345';
        String CPGID = 'CPG12345';
		String accountIdStart = '001';
        final String userId = UserInfo.getUserId();
        Boolean exceptPredefineObjects = false;        
        system.debug('withSharing: ' + withSharing);
		string query = '';
        //List<String> contactIds = new List<String>();
        //Boolean showNomuraEmployees = true;
        List<Id> contactListId = new List<Id>(); 
        String campaignId = '';
        String rgAccount = '';   
                                                     
        if(singleLookupJSON != null && String.isNotEmpty(singleLookupJSON)){
            ContactListFilter filterCondition  = (ContactListFilter) JSON.deserialize(singleLookupJSON, ContactListFilter.class); 
            system.debug('filterCondition: '+filterCondition);
         	if(singleLookupJSON != null && String.isNotEmpty(filterCondition.campaignId))
                campaignId = filterCondition.campaignId;
           	if(singleLookupJSON != null && String.isNotEmpty(filterCondition.rgAccount))
                rgAccount = filterCondition.rgAccount;
        }
        
		system.debug('baseString: '+baseString);
        system.debug('searchString: '+searchString);     
       	system.debug('sanitizedSearchString: '+sanitizedSearchString);
        system.debug('campaignId: '+campaignId);
        system.debug('rgAccount: ' + rgAccount);
        system.debug('accountId: ' + accountId);
        System.debug('showCoveredAccountDetails: ' + showCoveredAccountDetails);
        system.debug('singleLookupJSON: ' + singleLookupJSON);
        System.debug('---includeInstinetContact--' + includeInstinetContact);
        System.debug('---includeNomuraContact--' + includeNomuraContact);
        if (sObjectAPIName == 'User' )  
        {
            if(includeNomuraContact && includeInstinetContact){ // Users + Nomura Contacts + Instinet Contacts
                //Changed to base string. As Shield searches without escape character.                 
                searchQuery = 'FIND :searchString IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,IsActive,Email ORDER BY NAME ASC), CONTACT(id,name,Email,Active__c,Account.Parent.Name, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c WHERE RG_Account__r.RDM_Org_Id__c =:CPGID ) Limit 50';
            }
            else if(includeNomuraContact != true && includeInstinetContact != true){ //Only Users                
                searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,IsActive,Email ) Limit 50';
            }
            else if(includeNomuraContact || includeInstinetContact){ // Users + Nomura Contacts OR Instinet Contacts
                String searchByRDM = '';
                if(includeNomuraContact)
                    searchByRDM = CPID;
                else
                    searchByRDM = INID;
                System.debug('---searchByRDM--' + searchByRDM);
                if (sanitizedSearchString.contains('@')) {
                system.debug(sanitizedSearchString);
                //Changes for Shield. When users search with EmailID
                searchQuery = 'FIND :searchString IN EMAIL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,IsActive,Email ORDER BY NAME ASC), CONTACT(id,name,Email,Active__c, Account.Parent.Name, Account.RDM_Org_ID__c WHERE Account.RDM_Org_ID__c =:searchByRDM ) Limit 50';
                
                } else {
                    //Changed to base string. As Shield searches without escape character. 
                    searchQuery = 'FIND :searchString IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,IsActive,Email ORDER BY NAME ASC), CONTACT(id,name,Email,Active__c,Account.Parent.Name, Account.RDM_Org_ID__c WHERE Account.RDM_Org_ID__c =:searchByRDM ) Limit 50';
                }
            }
        }
        else if (sObjectAPIName == 'Contact') //Contacts with Name Field
        {
            //Changes for Shield. Removing OrderBy Clause from below queries. Sorting will be handled in LookupControllerResult class
            string contactEmail = '';
            string contactName = '';
            system.debug(sanitizedSearchString);
            if (sanitizedSearchString.contains('@')) {
                //Changes for Shield. When users search with EmailID
                    searchQuery += ' ) Limit 50';
                searchQuery = 'FIND \'' + sanitizedSearchString  + '\' IN EMAIL FIELDS RETURNING CONTACT(id,name,Email,Active__c,Account.Parent.Name, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c WHERE RG_Account__r.RDM_Org_Id__c !=  \'' + CPGID + '\' '; 
                                
                if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart))
                    searchQuery += ' AND Account.ParentId = \'' +  accountId + '\' ) Limit 50 ';
                else
                    searchQuery += ' ) Limit 50';
            } 
            else {
                //Changed to base string. As Shield searches without escape character.                
                if(accountCompany!=null && accountCompany!=''){                    
                    searchQuery = 'FIND \'' + sanitizedSearchString  + '\' IN NAME FIELDS RETURNING CONTACT(id,name,Email,Active__c,Account.Parent.Name, Account.RDM_Org_ID__c , RG_Account__r.RDM_Org_Id__c WHERE RG_Account__r.RDM_Org_Id__c != \'' + CPGID + '\' and (Account.Company_Type__c = \'Investor\' OR Account.Company_Type__c = \'Investor-Manager\' OR Account.Company_Type__c = \'Manager\' ) ';                	
                    if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart))
                        searchQuery += ' AND Account.ParentId = \'' +  accountId + '\' ) Limit 50 ';
                    else
                        searchQuery += ' ) Limit 50';
                }
                else
                {                                         
                    searchQuery = 'FIND \'' + sanitizedSearchString  + '\' IN NAME FIELDS RETURNING CONTACT(id,name,Email,Active__c,Account.Parent.Name, Account.RDM_Org_ID__c , RG_Account__r.RDM_Org_Id__c WHERE RG_Account__r.RDM_Org_Id__c != \'' + CPGID + '\' ';
                    if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart))
                        searchQuery += ' AND Account.ParentId = \'' +  accountId + '\' ) Limit 50 ';
                    else
                        searchQuery += ' ) Limit 50';
                }
                
            }
        }
        else if (sObjectAPIName == 'Ticker__c') 
        {
            searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,Issuer_Name__c WHERE name like \'%.%\' and Global_ESMP_Eq_ESMP__c = true)';

        }
        else if (sObjectAPIName == 'Account') //Contacts with Name Field
        {
            Set < string > typeset = new Set < string > ();
            For(string s: accountRecordType) {
                typeset.add(s.trim());
            }

             if (accountRecordType.size() > 0)
                searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,Active__c,RecordType.DeveloperName,ParentId,Parent.ParentId WHERE RecordType.DeveloperName in:typeset ORDER BY NAME ASC) ';
            else
                searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,Active__c,RecordType.DeveloperName,ParentId,Parent.ParentId ORDER BY NAME ASC) ';
            
            searchQuery = ((withSharing || showCoveredAccountDetails) ? (searchQuery + 'LIMIT 200 ') : (searchQuery + 'LIMIT 50 '));
            
            system.debug(System.LoggingLevel.WARN, searchQuery);

        } else if (sObjectAPIName == 'Sales_Team_for_Coverage__c') {            
            if(!isSplitSalesCode)
            {
                if(filterDeskCode)
                    searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN Name FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,Name,Coverage_ID__c,is_dummy__c,Is_Leaver__c ,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c WHERE Is_Split_Sales_Code__c = false and Company__c !=\'I\' ORDER BY NAME ASC) Limit 50';
                else
                    searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN Name FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,Name,Coverage_ID__c,is_dummy__c,Is_Leaver__c ,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c WHERE Is_Split_Sales_Code__c = false ORDER BY NAME ASC) Limit 50';
            }
            else
            {
                if(filterDeskCode)
                    searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN Name FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,Name,Coverage_ID__c,is_dummy__c,Is_Leaver__c,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Sales_Desk_Region__c,Company__c WHERE Company__c !=\'I\' ORDER BY NAME ASC) Limit 50';
                else
                    searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN Name FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,Name,Coverage_ID__c,is_dummy__c,Is_Leaver__c,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Sales_Desk_Region__c,Company__c ORDER BY NAME ASC) Limit 50';
                System.debug(searchQuery);
            }
        } else if (sObjectAPIName == 'Opportunity') {
            searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN Name FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,Name ' ;
            
            if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart))
                searchQuery += ' Where Account__c = \'' + accountId + '\' AND RecordType.DeveloperName NOT IN (\'Cross_Sell_Referral\', \'Inactive_Opportunity\') ORDER BY NAME ASC) Limit 50';
            else
                searchQuery += ' ORDER BY NAME ASC) Limit 50';

        }
        else if (sObjectAPIName == 'Sales_Team_User__c') {            
            query = 'select id,Sales_Team_for_Coverage__r.Is_Split_Sales_Code__c ,User__r.Status__c,User__c,User__r.Name from Sales_Team_User__c WHERE User__r.Name like \'%'+baseString+'%\' ORDER BY User__r.Name ASC';           
        }
        //CampaignMember--                                             
		else if(sObjectAPIName == 'CampaignMember'){       		
            //contactList = CommonTools.getContactDetailList(baseString, 'NAME', rgAccount, '', showNomuraEmployees);
            //Shield Changes-:
            searchQuery = 'FIND :baseString IN Name FIELDS RETURNING Contact(id,name,Email,Active__c,Account.Parent.Name, Account.RDM_Org_ID__c '
                			+ 'WHERE Active__c = true';
            // if(showNomuraEmployees == false)
            //     searchQuery = searchQuery + ' AND Account.RDM_ORG_ID__c <> \'CP12345\' ';
            
            if(String.isNotEmpty(rgAccount) && rgAccount.length() > 0)
                searchQuery = searchQuery + ' AND RG_Account__c = \'' + rgAccount + '\' ';
            
            searchQuery = searchQuery + ' ) LIMIT 475';
        }
		else {
            searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name ORDER BY NAME ASC) Limit 50';
        }
        Set < string > distinctNames = new Set < string > ();

        if(query!=''){
            if(sObjectAPIName == 'Sales_Team_User__c')
            {
                List<Sales_Team_User__c> solist1  = (List<Sales_Team_User__c>) Database.query(query);   
                for(Sales_Team_User__c teamObj: solist1){
                    If(allRecords) {
                        if (!distinctNames.contains(teamObj.User__r.Name)) {
                            system.debug('Status__c: '+teamObj.User__r.Status__c);
                            results.add(new LookupControllerResult(teamObj.User__r.Name, teamObj.User__c, '', '', '', '','', ''));
                            distinctNames.add(teamObj.User__r.Name);   
                        } 
                    }
                    else {
                        if (teamObj.User__r.Status__c==null) {
                            if (!distinctNames.contains(teamObj.User__r.Name)) {
                                results.add(new LookupControllerResult(teamObj.User__r.Name, teamObj.User__c, '', '', '', '', '', ''));
                                distinctNames.add(teamObj.User__r.Name);
                            }
                        }
                    }
                    
                }
            }        
            
        }
        else if (searchQuery != '') {
            system.debug('QUERY: ');
            system.debug(searchQuery);
            List < List < SObject >> searchList = new List < List < SObject >> ();
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            if (sObjectAPIName == 'Opportunity') {
                searchList = LookupUtil.getOpportunitiesOnAccess(searchQuery);
            } 
            else if (sObjectAPIName == 'Sales_Team_for_Coverage__c' && withSharing) {
                searchList = LookupUtil.getSalesPersonsOnAccess(searchQuery);
            }
            else if (sObjectAPIName == 'Contact' && withSharing){
                searchList = LookupUtil.getSearchResult(searchQuery);
            }
            else if (sObjectAPIName == 'Ticker__c'){
                searchList = LookupUtil.getSearchResult(searchQuery);
            }
            else if (sObjectAPIName == 'Account' && withSharing){
                List<List<SObject>> searchResultList = search.query(searchQuery);
                searchList = LookupUtil.getAccountSearchResult(searchResultList);
            } 
            /*else if(sObjectAPIName == 'Campaign'){
				campaignMemberList = Database.query(searchQuery);
            }*/
            else {
                searchList = search.query(searchQuery);
                System.debug('searchList--' + searchList);
            }

            
            for (List < SObject > solist: searchList) {
                boolean activefound = false;
                Set<string> leaverloginIdMap_nondummy = new Set<string>();
                Set<string> leaverloginIdMap_dummy = new Set<string>();
                Set<string> dummyloginIdMap = new Set<string>();
                Set<string> activeInactiveloginIdMap_nondummy = new Set<string>();   
                Set<string> activeInactiveloginIdMap_dummy = new Set<string>();  
                //section added for JIRA SALES-2607  ************
                Set<Id> setAccountId = new Set<Id>();
				List<Account> lstChildAccount = new List<Account>();
				Map<Id,List<Account>> mapAccountchild = new Map<Id, List<Account>>();
                Set<Id> coveredAccountIdSet = new Set<Id>();
                
                if(uniqueSalesCode && allRecords && (sObjectAPIName =='Sales_Team_for_Coverage__c')){
                    for (SObject temp: solist) {
                        Sales_Team_for_Coverage__c code = (Sales_Team_for_Coverage__c) temp;
                        if((code.Active__c || (!code.Active__c && !code.Is_Leaver__c))){
                            if(!code.Is_dummy__c && !activeInactiveloginIdMap_nondummy.contains(code.Sales_Code_Login_ID__c)){
                                results.add(new LookupControllerResult(code.Name, code.Id, '', code.Coverage_ID__c, code.Sales_Code_Login_ID__c, '', '', ''));
                                activeInactiveloginIdMap_nondummy.add(code.Sales_Code_Login_ID__c);
                            }
                            if(code.Is_dummy__c && !activeInactiveloginIdMap_dummy.contains(code.Sales_Code_Login_ID__c)){
                                results.add(new LookupControllerResult(code.Name, code.Id, '', code.Coverage_ID__c, code.Sales_Code_Login_ID__c, '', '', ''));
                                activeInactiveloginIdMap_dummy.add(code.Sales_Code_Login_ID__c);
                            }
                        }
                    }
                }
                
                //section added for JIRA SALES-2607  ************start
				if(sObjectAPIName =='Account' && includeRGWithRMOnly){
					//get the ids of the retrieved records
					for (SObject so: solist) {
					   setAccountId.add(so.Id);
					}
					//get the child of the retrieved records
					if(withSharing){
                        Map<Id,Account> accountRMMap = new Map<Id,Account>([Select Id, Name, ParentId from Account where ParentId IN : setAccountId]);
                        Set<Id> accountWithEditAccess = new Set<Id>();
                        accountWithEditAccess = RecordAccess.getRecordEditAccessDetails(accountRMMap.keySet(), TRUE);

                        for(Id accountRMId : accountRMMap.keySet()){
                            Account accountObj = accountRMMap.get(accountRMId);
                            if(accountWithEditAccess.contains(accountRMId)){
                                lstChildAccount.add(accountObj);
                            }
                        }
                    }
                    else {
                        lstChildAccount = [Select Id, Name, ParentId from Account where ParentId IN : setAccountId];
                    }
					
					//create map of the parent and child records
					for(Account acc: lstChildAccount){
					    if(mapAccountchild.containsKey(acc.ParentId)){
					       List<Account> lstAcc = mapAccountchild.get(acc.ParentId);
						   lstAcc.add(acc);
						   mapAccountchild.put(acc.ParentId, lstAcc);
					    }
					    else{
						   mapAccountchild.put(acc.ParentId, new List <Account>{acc});
					    }
					}
				}


                
                if(sObjectAPIName == 'Account' && showCoveredAccountDetails &&  accountRecordType[0] != null && accountRecordType[0] == 'RG_Account' && userId != null ){  
                    System.debug('---before results--' + results);
                    Set<Id> idSet = new Set<Id>();
                    

                    for (SObject so: solist) {
					   idSet.add(so.Id);
					}
                    if(idSet.size() > 0)
                        coveredAccountIdSet = LookupController.returnCoveredAccounts(idSet, userId);
               }


                //section added for JIRA SALES-2607  ************end
                for (SObject so: solist) {
                    system.debug(LoggingLevel.WARN, 'exceptPredefineObjects: ' + exceptPredefineObjects);
                    if (!exceptPredefineObjects) {
                        //-------------Shield Changes----------
                        //Added User and Contact object which are passed to LookupControllerResult class
                        if (so.getSObjectType() == User.sObjectType) {                            
                            User userObj = (User) so;
                            If(allRecords) {
                                results.add(new LookupControllerResult((String) so.get('Name'), so.Id, (String) so.get('Email'), '', '', '',userObj));
                            }
                            else {
                                if ((Boolean) so.get('IsActive') == true)
                                    results.add(new LookupControllerResult((String) so.get('Name'), so.Id, (String) so.get('Email'), '', '', '',userObj));
                            }
                            system.debug(LoggingLevel.WARN, 'User');
                        }

                        if (so.getSObjectType() == Contact.sObjectType) {
                            Contact conObj = (Contact) so;                                
                            If(allRecords) {
                                results.add(new LookupControllerResult(conObj.Name, conObj.Id, conObj.Email, '', '', conObj.Account.Parent.Name, conObj));
                            }
                            else {
                                if ((Boolean) so.get('Active__c') == true && String.isEmpty(campaignId))
                                    results.add(new LookupControllerResult(conObj.Name, conObj.Id, conObj.Email, '', '', conObj.Account.Parent.Name, conObj));
                                //For ContactList filter criteria
                                if(String.isNotEmpty(campaignId))
                                	contactListId.add(conObj.Id);                                
                            }                                  
                            system.debug(LoggingLevel.WARN, 'Contact');
                        }

                        if (so.getSObjectType() == Ticker__c.sObjectType) {
                            Ticker__c conObj = (Ticker__c) so;                                
                            results.add(new LookupControllerResult(conObj.Name, conObj.id, '','','', conObj.Issuer_Name__c,'',''));
                            system.debug(LoggingLevel.WARN, 'Ticker__c');
                        }
                        
                        if (so.getSObjectType() == Account.sObjectType) {
                            //sections added for JIRA SALES-2607
                             Account accObj = (Account) so;
							system.debug('includeRGWithRMOnly ***'+ includeRGWithRMOnly);
						    if(includeRGWithRMOnly){	
                                if(mapAccountchild.containsKey(so.Id)){							
									if(allRecords) {
										results.add(new LookupControllerResult(accObj.Name, accObj.Id, '', '', '', '', '', ''));
									}
									else {
										if ((Boolean) so.get('Active__c') == true)
											results.add(new LookupControllerResult(accObj.Name, accObj.Id, '', '', '', '', '', ''));
									}
								}
							}
							else {

                                if(showCoveredAccountDetails){
                                    if( coveredAccountIdSet!= null && coveredAccountIdSet.size() > 0 && coveredAccountIdSet.contains(so.Id))
                                        results.add(new LookupControllerResult(accObj.Name, accObj.Id, '', '', '', '', '', ''));
                                }                                
							    else{
                                    System.debug('----in else--');
                                    if(allRecords) {
                                            results.add(new LookupControllerResult(accObj.Name, accObj.Id, '', '', '', '', '', ''));
                                    }
                                    else {
                                        if ((Boolean) so.get('Active__c') == true)
                                            results.add(new LookupControllerResult(accObj.Name, accObj.Id, '', '', '', '', '', ''));
                                    }
                                }
							}	
                        }

                        if (so.getSObjectType() == Opportunity.sObjectType) {
                            Opportunity oppObj = (Opportunity) so;
                            results.add(new LookupControllerResult(oppObj.Name, oppObj.Id, '', '', '', '', '', ''));

                        }

                        if (so.getSObjectType() == Sales_Team_for_Coverage__c.sObjectType) {
                            system.debug('--Flag 2--');
                            Sales_Team_for_Coverage__c teamObj = (Sales_Team_for_Coverage__c) so;
                            If(allRecords) {
                                If(uniqueSalesCode) {
                                    system.debug('--Flag 3--');
                                     if(teamobj.is_dummy__c && teamObj.Is_Leaver__c && !activeInactiveloginIdMap_dummy.contains(teamObj.Sales_Code_Login_ID__c) && !leaverloginIdMap_dummy.contains(teamObj.Sales_Code_Login_ID__c))
                                    {
                                        system.debug('--Flag 4--');
                                        results.add(new LookupControllerResult(teamObj.Name + ' - Leaver', teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));
                                        leaverloginIdMap_dummy.add(teamObj.Sales_Code_Login_ID__c);
                                    }
                                    
                                    if(!teamobj.is_dummy__c && teamObj.Is_Leaver__c && !activeInactiveloginIdMap_nondummy.contains(teamObj.Sales_Code_Login_ID__c) && !leaverloginIdMap_nondummy.contains(teamObj.Sales_Code_Login_ID__c))
                                    {
                                        system.debug('--Flag 5--');
                                        results.add(new LookupControllerResult(teamObj.Name + ' - Leaver', teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));
                                        leaverloginIdMap_nondummy.add(teamObj.Sales_Code_Login_ID__c);
                                    }
                                    
                                    
                                }
                                else {
                                    system.debug('--Flag 6--');
                                    if (!teamObj.Is_Leaver__c)
                                        results.add(new LookupControllerResult(teamObj.Name + ' (' + teamObj.Coverage_ID__c + ') ' + teamObj.Sales_Team__c, teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));
                                    else
                                        results.add(new LookupControllerResult(teamObj.Name + ' (' + teamObj.Coverage_ID__c + ' - Leaver) ' + teamObj.Sales_Team__c, teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));

                                }

                            }
                            else {
                                system.debug('--Flag 7--');
                                if (inactiveSalesCode) {
                                    system.debug('--Flag 8--');
                                    if (!teamObj.Active__c && teamObj.Is_Leaver__c) {
                                        if (uniqueSalesCode) {
                                            if (!distinctNames.contains(teamObj.Sales_Code_Login_ID__c)) {
                                                system.debug('--Flag 9--');
                                                results.add(new LookupControllerResult(teamObj.Name + ' - Leaver', teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));
                                                distinctNames.add(teamObj.Sales_Code_Login_ID__c);
                                            }
                                        } else {
                                            system.debug('--Flag 10--');
                                            results.add(new LookupControllerResult(teamObj.Name + ' (' + teamObj.Coverage_ID__c + ' - Leaver) ' + teamObj.Sales_Team__c, teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));
                                        }
                                    }
                                } else {
                                    system.debug('--Flag 11--');
                                    if (teamObj.Active__c && !teamObj.is_Leaver__c) {
                                        if (uniqueSalesCode) {
                                            if (!distinctNames.contains(teamObj.Sales_Code_Login_ID__c)) {
                                                system.debug('--Flag 12--');
                                                results.add(new LookupControllerResult(teamObj.Name, teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', '', ''));
                                                distinctNames.add(teamObj.Sales_Code_Login_ID__c);
                                            }
                                        } else {
                                            system.debug('--Flag 13--');    
                                            results.add(new LookupControllerResult(teamObj.Name + ' (' + teamObj.Coverage_ID__c + ') ' + teamObj.Sales_Team__c, teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', teamObj.Sales_Desk_Region__c, teamObj.Company__c));
                                        }
                                    }
                                }
                            }

                        } 
                          else
                        {
                            if(sObjectAPIName =='Fund__c'){
                              results.add(new LookupControllerResult((String)so.get('Name'), so.Id,'','','', '', '', ''));
                            }
                        } 
                    } else {                        
                        results.add(new LookupControllerResult((String) so.get('Name'), so.Id, '', '', '', '', '', ''));
                        system.debug(LoggingLevel.WARN, 'ELSE'); 
                    }
                }
            }            
        }
                                                     
		//For ContactList filter criteria
        if(String.isNotEmpty(campaignId) && contactListId.size() > 0){  
            
            String contactIdString = CommonTools.formCommaSeparatedStringOfList(contactListId);
            String campaignQuery = 'Select ContactId, Contact.Name, Contact.Active__c, Contact.Account.Parent.Name, Contact.Account.RDM_Org_ID__c FROM CampaignMember WHERE CampaignId = \'' + campaignId +'\' AND ContactID IN ' + contactIdString ;
            List<CampaignMember> campaignMemberSearchList = Database.query(campaignQuery);
            for(CampaignMember campaignMemberObj : campaignMemberSearchList)
                    results.add(new LookupControllerResult(campaignMemberObj.Contact.Name, campaignMemberObj.Contact.Id, '', '', '', campaignMemberObj.Contact.Account.Parent.Name, '', ''));
            
        }               
       
        //Shield Changes. Sorting will only be called when Sobject passed will be Contact/ Sobject = User + includeNomuraContact = true
        if(sObjectAPIName == 'Contact' || includeNomuraContact ){            
			results.sort();                                   
        }

        System.debug('results---' + results);		
        return results;
    }

    //added parameter for JIRA SALES-2607
    @AuraEnabled
    public static LookupControllerResult[] recentlyViewed(String sObjectAPIName, Boolean includeNomuraContact, Boolean allRecords, List < string > accountRecordType, 
                                            Boolean includeRGWithRMOnly, Boolean includeInstinetContact, Boolean withSharing, Boolean showCoveredAccountDetails, String accountId) {
		String userId = UserInfo.getUserId();
        String accountIdStart = '001';
        System.debug('---showCoveredAccountDetails---' + showCoveredAccountDetails);
        System.debug('---2userI---' + userId);
        
        List < LookupControllerResult > results = new List < LookupControllerResult > ();
        // Boolean showCoveredAccountDetails = true;
        //String accountId = '0010p000003d1qRAAQ';
        
        // System.debug('---1showCoveredAccounts---' + showCoveredAccounts);
        // System.debug('---2userId---' + userId);
            
        Boolean isActiveOnes = true;
        if (allRecords) {
            isActiveOnes = false;
        } else {
            isActiveOnes = true;
        }
        
        system.debug(LoggingLevel.WARN, 'Is Active: ' + isActiveOnes);
        
        if(withSharing == null || withSharing == false){
            if (sObjectAPIName == 'User')  
            {
                if((includeNomuraContact && includeInstinetContact) || (includeNomuraContact || includeInstinetContact)){
                    // Users + Nomura Contacts + Instinet Contacts OR Users + any one
                    List <RecentlyViewed> RecentlyViewedList = [SELECT Id, Name, Type, LastViewedDate 
                                    FROM RecentlyViewed 
                                    WHERE Type in ('User', 'Contact') ORDER BY LastViewedDate Desc limit 50];
                    List<Id> RecentlyViewedIdList = new List<Id>(); 
                    for(RecentlyViewed oRcntVwd : RecentlyViewedList) {
                        RecentlyViewedIdList.add(oRcntVwd.Id);
                    }
                    Map<Id, User> UserByIdMap;
                    Map<Id, Contact> ContactByIdMap ;
                    String accountWhereClause = '';

                    if(includeNomuraContact && includeInstinetContact)
                        accountWhereClause = ' AND RG_Account__r.RDM_Org_Id__c = \'CPG12345\' ';        
                    else if(includeNomuraContact)
                        accountWhereClause = ' AND Account.RDM_Org_Id__c = \'CP12345\' ';
                    else if(includeInstinetContact)
                        accountWhereClause = ' AND Account.RDM_Org_Id__c = \'IN12345\' ';


                    if (!isActiveOnes) {
                        UserByIdMap = new Map < Id, User > ([SELECT Id, Email, IsActive FROM User WHERE Id IN :RecentlyViewedIdList]);                                        
                    }
                    else {
                        UserByIdMap = new Map <Id, User> ([SELECT Id, Email, IsActive FROM User 
                            WHERE Id IN :RecentlyViewedIdList AND IsActive = true]);                    
                    }
                    
                    String queryStr = 'SELECT Id, Email, Active__c, Account.Parent.Name FROM Contact '
                        + ' WHERE Id IN :RecentlyViewedIdList '
                        + accountWhereClause;
                    
                    if (isActiveOnes) 
                        queryStr += ' AND Active__c = true ';

                    ContactByIdMap = new Map<Id,Contact>((List<Contact>)Database.query(queryStr)) ;                

                    Integer countRcntVwd = 0;
                    for(RecentlyViewed oRcntVwd : RecentlyViewedList) {
                        User oUser = UserByIdMap.get(oRcntVwd.Id);
                        Contact oCont = ContactByIdMap.get(oRcntVwd.Id);
                        if(oUser!=null && String.isNotBlank(oUser.Email)) {
                            results.add(new LookupControllerResult(oRcntVwd.Name, oRcntVwd.Id, oUser.Email, '', '', '', '', ''));
                            ++countRcntVwd;
                        } else if(oCont!=null && String.isNotBlank(oCont.Email)) {
                            results.add(new LookupControllerResult(oRcntVwd.Name, oRcntVwd.Id, oCont.Email, '', '', oCont.Account.Parent.Name, '', ''));
                            ++countRcntVwd;
                        }
                        
                        if(countRcntVwd==5) {
                            break;
                        } 
                    }
                }
                else if(!(includeNomuraContact && includeInstinetContact)){ // Only Users
                    List<RecentlyViewed> RecentlyViewedList = [SELECT Id, Name, Type, LastViewedDate 
                    FROM RecentlyViewed 
                    WHERE Type =: sObjectAPIName ORDER BY LastViewedDate Desc limit 5];
                    List<Id> RecentlyViewedIdList = new List<Id>(); 
                    for (RecentlyViewed recent: RecentlyViewedList) {
                        RecentlyViewedIdList.add(recent.Id);
                    }
                    
                    Map<Id, User> UserMap = new Map<Id, User>();
                    if (!isActiveOnes) {
                        UserMap = new Map <Id, User> ([SELECT Id, Email FROM User where Id IN :RecentlyViewedIdList]);
                    }
                    else {
                        UserMap = new Map <Id, User> ([SELECT Id, Email FROM User WHERE Id IN :RecentlyViewedIdList AND IsActive = true]);
                    }

                    for (RecentlyViewed recent : RecentlyViewedList) {
                        User oUser = UserMap.get(recent.Id);
                        if(oUser!=null && String.isNotBlank(oUser.Email)) {
                            results.add(new LookupControllerResult(recent.Name, recent.Id, oUser.Email, '', '', '', '', ''));
                        } 
                    }
                }            
            }        
            else if (sObjectAPIName == 'Contact') //Contacts with Name Field
            {
                // not quering Map<Id , RecentlyViewed> in order to maintaing the order of returned result
                List<RecentlyViewed> RecentViewedList = [SELECT Id, Name, Type, LastViewedDate 
                                                        FROM RecentlyViewed 
                                                        WHERE Type = :sObjectAPIName ORDER BY LastViewedDate];
                List<Id> RecentlyViewedIddList = new List<Id>();
                String CPGID = 'CPG12345';
                for(RecentlyViewed oRcntViwd : RecentViewedList) {
                    RecentlyViewedIddList.add(oRcntViwd.Id);
                }
                if(!RecentViewedList.isEmpty()) {
                    // Not using the dynamic query n order to fetch the records in a Map instead of list
                    Map<Id, Contact> ContactByIdMap = new Map<Id, Contact>(); 
                    if(isActiveOnes) {
                        if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart)){
                            ContactByIdMap = new Map<Id, Contact>([SELECT Id, Name, Email, Account.Parent.Name 
                                                            FROM Contact 
                                                            WHERE Id IN :RecentlyViewedIddList AND Active__c = true AND RG_Account__r.RDM_Org_Id__c !=:CPGID AND Account.ParentId = :accountId LIMIT 100]);
                        }
                        else{
                            ContactByIdMap = new Map<Id, Contact>([SELECT Id, Name, Email, Account.Parent.Name 
                                                            FROM Contact 
                                                            WHERE Id IN :RecentlyViewedIddList AND Active__c = true AND RG_Account__r.RDM_Org_Id__c !=:CPGID LIMIT 100]);
                        }                                        
                    } else {
                        if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart)){
                            ContactByIdMap = new Map<Id, Contact>([SELECT Id, Name, Email, Account.Parent.Name 
                                                            FROM Contact 
                                                            WHERE Id IN :RecentlyViewedIddList AND RG_Account__r.RDM_Org_Id__c !=:CPGID AND Account.ParentId = :accountId LIMIT 100]);
                        }
                        else{
                            ContactByIdMap = new Map<Id, Contact>([SELECT Id, Name, Email, Account.Parent.Name 
                                                            FROM Contact 
                                                            WHERE Id IN :RecentlyViewedIddList AND RG_Account__r.RDM_Org_Id__c !=:CPGID LIMIT 100]);
                        }                    
                    }

                    if(!ContactByIdMap.isEmpty()) {
                        for(RecentlyViewed recent: RecentViewedList) {
                            Contact oCont = ContactByIdMap.get(recent.Id); 
                            if(oCont!=null && String.isNotBlank(oCont.Email)) {
                                results.add(new LookupControllerResult(oCont.Name, oCont.Id, oCOnt.Email, '', '', oCont.Account.Parent.Name, '', ''));
                                if(results.size() == 5) {
                                    break;
                                }
                            }
                        }	
                    }
                }
            } else if (sObjectAPIName == 'Account' && accountRecordType.size() > 0) //Contacts with Name Field
            {
                // The RecentlyViewed data is periodically truncated down to 200 records per object. so using a limiyt of 200
                System.debug('---showCoveredAccountDetails---' + showCoveredAccountDetails);
                System.debug('---userId---' + userId);
                
                Set<Id> recentIds = new Set<Id>();
                List < RecentlyViewed > recentlist = [SELECT Id, Name, Type, LastViewedDate 
                    FROM RecentlyViewed WHERE Type =: sObjectAPIName ORDER BY LastViewedDate Desc LIMIT :200];
                for (RecentlyViewed recent: recentlist) {
                    recentIds.add(recent.Id);
                }

                if(!includeRGWithRMOnly){
                    Map <Id, Account> mapAccount;
                    Set<Id> accountIdSet = new Set<Id>();
                    Set<Id> coveredAccountIdSet = new Set<Id>();
                    // not using dynamic query in order to avoid manually populating mapAccount. 
                    if(isActiveOnes) {
                        mapAccount = new Map <Id, Account>([SELECT Id, Name 
                            FROM Account 
                            WHERE Id IN :recentIds AND RecordType.DeveloperName IN :accountRecordType AND Active__c=true]);
                    } else {
                        mapAccount = new Map <Id, Account>([SELECT Id, Name 
                            FROM Account 
                            WHERE Id IN :recentIds AND RecordType.DeveloperName IN :accountRecordType]);
                    }

                    for (RecentlyViewed recent: recentlist) {
                        if (mapAccount.containsKey(recent.Id)) {
                            if(showCoveredAccountDetails){
                                accountIdSet.add(recent.Id);                            
                            }
                            else{
                                results.add(new LookupControllerResult(recent.Name, recent.Id, '', '', '', '', '', ''));
                                if(results.size()==5) {
                                    break;
                                }
                                System.debug('---results--' + results);
                            }
                        }
                    }

                    if(accountIdSet != null && accountIdSet.size() > 0)
                        coveredAccountIdSet = returnCoveredAccounts(accountIdSet, userId);

                    if( coveredAccountIdSet!= null && coveredAccountIdSet.size() > 0){
                        for(RecentlyViewed recent : recentlist) {
                            if(coveredAccountIdSet.contains(recent.Id)){
                                results.add(new LookupControllerResult(recent.Name, recent.Id, '', '', '', '', '', ''));
                            }
                            if(results.size()==5) {
                                break;
                            }
                            System.debug('---results--' + results);
                        }                
                    }
                }
                else{
                    // there is a scope to further improve this piece of code once we clearly understad what this code is exactly doing
                    // based on current understanding - it returns the recently viewed RG accounts with atleast one RM account
                    // So instead of creating a complex Map as below, we can re-write it in more optimised way. To-Do - post shield
                    //List<Account> lstChildAccount = [Select Id, Name, ParentId, RecordType.Name from Account where ParentId IN :recentIds];
                    Map<Id, List<Account>> mapAccountchild = new Map<Id, List<Account>>();
                    Set<Id> accountIdSet = new Set<Id>();
                    Set<Id> coveredAccountIdSet = new Set<Id>();

                    String query = 'SELECT Id, Name, ParentId, RecordType.Name, RecordType.DeveloperName FROM Account WHERE ParentId IN :recentIds AND Parent.RecordType.DeveloperName IN :accountRecordType ';
                    if(isActiveOnes) {
                        query+=' AND Active__c=true';
                    }
                    List<Account> lstChildAccount = (List<Account>)Database.query(query);
                    //create map of the parent and child records
                    for(Account acc: lstChildAccount){
                        if(mapAccountchild.containsKey(acc.ParentId)){
                            List<Account> lstAcc = mapAccountchild.get(acc.ParentId);
                            lstAcc.add(acc);
                            mapAccountchild.put(acc.ParentId, lstAcc);
                        }
                        else{
                            mapAccountchild.put(acc.ParentId, new List <Account>{acc});
                        }
                    }
                    //filter out RG without RM
                    for (RecentlyViewed recent: recentlist) {
                        if (mapAccountchild.containsKey(recent.Id)) {
                            if(showCoveredAccountDetails){
                                accountIdSet.add(recent.Id); 
                            }
                            else{
                                results.add(new LookupControllerResult(recent.Name, recent.Id, '', '', '', '', '', ''));
                                if(results.size()==5) {
                                    break;
                                }
                                System.debug('---results--' + results);
                            }
                            
                        }
                    }
                    if(accountIdSet != null && accountIdSet.size() > 0)
                        coveredAccountIdSet = returnCoveredAccounts(accountIdSet, userId);

                    if( coveredAccountIdSet!= null && coveredAccountIdSet.size() > 0){
                        for(RecentlyViewed recent : recentlist) {
                            if(coveredAccountIdSet.contains(recent.Id)){
                                results.add(new LookupControllerResult(recent.Name, recent.Id, '', '', '', '', '', ''));
                            }
                            if(results.size()==5) {
                                break;
                            }
                            System.debug('---results--' + results);
                        }                
                    }

                }
            } else if (sObjectAPIName == 'Sales_Team_for_Coverage__c') //Sales Person
            {
                Set<Id> recentIds = new Set<Id>();
                Map < Id, Sales_Team_for_Coverage__c > mapSalesPerson;
                List < RecentlyViewed > recentlist = [Select Id, Name, Type, LastViewedDate from RecentlyViewed where Type =: sObjectAPIName order by LastViewedDate Desc limit 5];
                for (RecentlyViewed recent: recentlist) {
                    //if (recent.Type == 'Sales_Team_for_Coverage__c') {
                        recentIds.add(recent.Id);
                    //}
                }
                
                if (!isActiveOnes) {
                    mapSalesPerson = new Map < Id, Sales_Team_for_Coverage__c > ([SELECT id, Name, Coverage_ID__c, Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Id IN :recentIds]);
                }
                else {
                    mapSalesPerson = new Map < Id, Sales_Team_for_Coverage__c > ([SELECT id, Name, Coverage_ID__c, Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Id IN :recentIds AND Active__c = true]);
                }
                
                for (RecentlyViewed recent: recentlist) {
                    if (recent.Type == 'Sales_Team_for_Coverage__c') {
                        if (mapSalesPerson.get(recent.Id) != null) {
                            results.add(new LookupControllerResult(mapSalesPerson.get(recent.Id).Name, recent.Id, '', mapSalesPerson.get(recent.Id).Coverage_ID__c, mapSalesPerson.get(recent.Id).Sales_Code_Login_ID__c, '', '', ''));
                        }
                    }
                }
                
            } else if (sObjectAPIName == 'Opportunity') {//Opportunity
                List <RecentlyViewed> recentlist =  LookupUtil.getRecentlyViewed(sObjectAPIName);
                List<Id> opportunityIdList = new List<String>();
                List<Opportunity> coveredOpportunityList = new List<Opportunity>();
                if(recentlist.size() > 0){
                    if(showCoveredAccountDetails && accountId != null && accountId.startsWith(accountIdStart)){
                        for(RecentlyViewed recent: recentlist)
                            opportunityIdList.add(recent.Id);
                        
                        if(opportunityIdList != null && opportunityIdList.size () > 0){
                            coveredOpportunityList = [SELECT Id, Name FROM Opportunity WHERE ID IN :opportunityIdList AND Account__c = :accountId AND RecordType.DeveloperName NOT IN ('Cross_Sell_Referral', 'Inactive_Opportunity')];
                        
                            if(coveredOpportunityList != null && coveredOpportunityList.size() > 0){
                                for(Opportunity oppObj : coveredOpportunityList)
                                    results.add(new LookupControllerResult(oppObj.Name, oppObj.Id, '','','','', '', ''));
                                System.debug('---results---' + results);
                            }
                        }
                    }
                    else{
                        for (RecentlyViewed recent: recentlist) {
                            results.add(new LookupControllerResult(recent.Name, recent.Id, '', '', '', '', '', ''));
                        }
                    }
                }
                
            }else {
                List < RecentlyViewed > recentlist = [Select Id, Name, Type, LastViewedDate from RecentlyViewed where Type =: sObjectAPIName order by LastViewedDate Desc limit 5];
                for (RecentlyViewed recent: recentlist) {
                    results.add(new LookupControllerResult(recent.Name, recent.Id, '', '', '', '', '', ''));
                }
            }
        }
        
        return results;
    }
    
    @AuraEnabled
    public static LookupControllerResult[] preSelectlookup(List < string > lookupids, String sObjectAPIName, Boolean uniqueSalesCode, Boolean allRecords) {
        List < LookupControllerResult > results = new List < LookupControllerResult > ();
        Set < string > typeset = new Set < string > ();
        Set<string> activeInactiveloginIdMap_nondummy = new Set<string>();   
        Set<string> activeInactiveloginIdMap_dummy = new Set<string>();
        Set<string> leaverloginIdMap_nondummy = new Set<string>();
        Set<string> leaverloginIdMap_dummy = new Set<string>();
               
        For(string s: lookupids) {
            typeset.add(s.trim());
        }
        System.debug('---lookupids--' + lookupids);
        System.debug('---typeset--' + typeset);
        String searchQuery = 'select id, Name from ' + sObjectAPIName + ' where Id in:typeset';
        if (sObjectAPIName == 'Sales_Team_for_Coverage__c') {
            
            Set<string> setLoginIds = new Set<string>();
            for(Sales_Team_for_Coverage__c code: CoverageDataWithoutSharingController.getSalesCodeDetails(lookupids))
            {
                if(!code.is_Dummy__c && code.Sales_Code_Login_ID__c!=null)
                    setLoginIds.add(code.Sales_Code_Login_ID__c);
            }
            
            Set<string> newSalesPersonIDS = new Set<string>();
            set<Id> userIds = CoverageDataWithoutSharingController.getUserIdsbyLoginId(setLoginIds);
            for(Sales_Team_User__c userData: CoverageDataWithoutSharingController.getSalesTeamUser(userIds))
            {
                newSalesPersonIDS.add(userData.Sales_Team_for_Coverage__c);
            }
            
            if(allRecords)
                searchQuery = 'select id, Name,Coverage_ID__c,Active__c,Is_Leaver__c,Is_dummy__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Sales_Desk_Region__c,Company__c from ' + sObjectAPIName + ' where Id in:newSalesPersonIDS and Is_Split_Sales_Code__c = false ORDER BY NAME ASC';
            else
                searchQuery = 'select id, Name,Coverage_ID__c,Active__c,Is_Leaver__c,Is_dummy__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Sales_Desk_Region__c,Company__c from ' + sObjectAPIName + ' where Id in:newSalesPersonIDS and Is_Split_Sales_Code__c = false and Active__c = true ORDER BY NAME ASC';
            List < sobject > sobjectList1 = Database.query(searchQuery);
            if(uniqueSalesCode && allRecords)
            {
                for (SObject temp: sobjectList1) {
                    Sales_Team_for_Coverage__c code = (Sales_Team_for_Coverage__c) temp;
                    if((code.Active__c || (!code.Active__c && !code.Is_Leaver__c))){
                        if(!code.Is_dummy__c && !activeInactiveloginIdMap_nondummy.contains(code.Sales_Code_Login_ID__c)){
                            results.add(new LookupControllerResult(code.Name, code.Id, '', code.Coverage_ID__c, code.Sales_Code_Login_ID__c, '', code.Sales_Desk_Region__c, code.Company__c));
                            activeInactiveloginIdMap_nondummy.add(code.Sales_Code_Login_ID__c);
                        }
                        if(code.Is_dummy__c && !activeInactiveloginIdMap_dummy.contains(code.Sales_Code_Login_ID__c)){
                            results.add(new LookupControllerResult(code.Name, code.Id, '', code.Coverage_ID__c, code.Sales_Code_Login_ID__c, '', code.Sales_Desk_Region__c, code.Company__c));
                            activeInactiveloginIdMap_dummy.add(code.Sales_Code_Login_ID__c);
                        }
                    }
                }
            }
            
            for (Sobject data: sobjectList1) {
                Sales_Team_for_Coverage__c teamObj = (Sales_Team_for_Coverage__c) data;
                If(uniqueSalesCode && allRecords) 
                {}
                else 
                {
                    if (!teamObj.Is_Leaver__c)
                        results.add(new LookupControllerResult(teamObj.Name + ' (' + teamObj.Coverage_ID__c + ') ' + teamObj.Sales_Team__c, teamObj.Id, '', teamObj.Coverage_ID__c, teamObj.Sales_Code_Login_ID__c, '', teamObj.Sales_Desk_Region__c, teamObj.Company__c));
                         
                }
                
                
                
                /*results.add(new LookupControllerResult(String.valueOf(data.get('Name')) + ' (' + String.valueOf(data.get('Coverage_ID__c')) + ') ' + String.valueOf(data.get('Sales_Team__c')), String.valueOf(data.get('Id')), '', String.valueOf(data.get('Coverage_ID__c')), String.valueOf(data.get('Sales_Code_Login_ID__c')), ''));*/
            }
            return results;
            
            
            
        } 
        if (sObjectAPIName == 'User') {
            List < sobject > sobjectList1 = Database.query('select id, Name from Contact where Id in:typeset');
            for (Sobject data: sobjectList1) {
                results.add(new LookupControllerResult(String.valueOf(data.get('Name')), String.valueOf(data.get('Id')), '', '', '', '', '', ''));
            }
        }

        if (sObjectAPIName == 'Ticker__c') {
            List < sobject > sobjectList1 = Database.query('select id,Name,Issuer_Name__c from Ticker__c where Name in:typeset');
            for (Sobject data: sobjectList1) {
                results.add(new LookupControllerResult(String.valueOf(data.get('Name')), String.valueOf(data.get('Id')), '', '', '', String.valueOf(data.get('Issuer_Name__c')), '', ''));
            }
            system.debug(results);
        }
        List < sobject > sobjectList = Database.query(searchQuery);
        for (Sobject data: sobjectList) {
            results.add(new LookupControllerResult(String.valueOf(data.get('Name')), String.valueOf(data.get('Id')), '', '', '', '', '', ''));
        }
        return results;
    }
	
    public static Set<Id> returnCoveredAccounts(Set<Id> accountIdSet, String userId) {
       
        Set<Id> coveredAccountSet = new Set<Id>();
         if(accountIdSet != null && accountIdSet.size() > 0 && userId != null){
            String accountIds = CommonTools.formCommaSeparatedStringOfId(accountIdSet);           
            String query = 'SELECT Id, AccountId, Account.Name, Account.ParentId, UserId, User.Name FROM AccountTeamMember '
                            + ' WHERE Account.ParentId IN ' + accountIds 
                            + ' AND UserId = :userId ';
            List<AccountTeamMember> accountTeamMemberList = Database.query(query);

            for(AccountTeamMember accountTeamMemberObj : accountTeamMemberList)
                coveredAccountSet.add(accountTeamMemberObj.Account.ParentId);            
         }
         System.debug('--------coveredAccountSet---' + coveredAccountSet);
         return coveredAccountSet;
    }
}