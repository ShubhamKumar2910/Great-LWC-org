public without sharing class AccountMiFIDIIPanelController {

	@AuraEnabled
    public static Account getAccountInformation(Id accountId){
        Account a = new Account();

        a = [SELECT Id, Name, RecordType.DeveloperName, MiFIDII_in_Scope__c, 
                Caution_Client__c, Caution_Client_Info__c, CautionClientInputDate__c,
                Parent.Caution_Client__c, Parent.Caution_Client_Info__c, Parent.CautionClientInputDate__c
             FROM Account
             WHERE Id = :accountId];

        
        return a;
    }

    @AuraEnabled
    public static Map<String, String> getAccountReportInformation(Id accountId){
        Map<String, String> resultMap = new Map<String,String>();

        List<Report> reports = [SELECT Id, Name, DeveloperName, FolderName
                                FROM Report
                                WHERE FolderName IN ('Nomura MiFID-II For Research','Nomura Non-MiFID-II For Research', 'Nomura NFPE Reports')];

        if(reports.size() > 0){ 
                for(Report r : reports){
                    resultMap.put(r.DeveloperName, r.Id);
                }
        }
        
        return resultMap;
    }



    @AuraEnabled
    public static Boolean getUserEligibilityForBulkUpdate(){
        Boolean userEligible = false;

        List<PermissionSet> ps = [SELECT Id, Name 
                                  From PermissionSet 
                                  Where Name = 'Singletrack_Administrator'
                                  Limit 1];

        if(ps.size() > 0){
            List<PermissionSetAssignment> psa = [SELECT Id, PermissionSetId
                                                 FROM PermissionSetAssignment
                                                 WHERE AssigneeId = : UserInfo.getUserId()
                                                 AND PermissionSetId = :ps[0].Id
                                                 Limit 1];
            if(psa.size() > 0){
                userEligible = true;
            }
        }
        
        
        return userEligible;
    }

	@AuraEnabled
	public static String getAccountProductSubscriptions(Id accountId){
		String accountProducts = '';

		Set<String> accountProductsSet = new Set<String>();

        for(Contact c : 
            [
                SELECT tolabel(MiFID_II_Product_Subscriptions__c)
                FROM Contact
                WHERE 
                (
                    AccountId =: accountId
                    Or
                    Account.Parent.Id =: accountId
                )
                AND Active__c = true
                AND MiFID_II_Product_Subscriptions__c != null
                AND MiFIDII_in_Scope__c = TRUE
            ]
        )
        {
            List<String> contProds = c.MiFID_II_Product_Subscriptions__c.split(';');   
            accountProductsSet.addAll(contProds);        
        } 
       
        if(accountProductsSet.size() > 0)
        {
            accountProducts = String.ValueOf(accountProductsSet);
            accountProducts = accountProducts.replace('{', '');
            accountProducts = accountProducts.replace('}', '');
            accountProducts = accountProducts.replace(',', ';');
        }

        return accountProducts;
	}
    //changed for JIRA SALES-3698
    /*@AuraEnabled
	public static String getAccountNFPEDetails(Id accountId){
		String accountChampions = '';		
        Boolean isNFPE = FALSE;
        
        Id activeCoverageRecordType = CommonTools.getRecordTypeId('Coverage_Team_Member__c','Active Coverage');
        
		List<Account> accounts = [Select Id From Account Where Account.Parent.Id =: accountId And NFPE__c = true Limit 1];
        if(accounts.size() > 0)
        {
            isNFPE = TRUE;
        }
        
        List<String> srms = new List<String>();
        for(AggregateResult c : [SELECT Sales_Team_for_Coverage__r.Name name FROM Coverage_Team_Member__c Where RecordTypeId =: activeCoverageRecordType And RG_Account__r.Id =: accountId And NFPE_Primary_Relationship_Coverage__c = true And Team_Role__c = 'Primary' Group By Sales_Team_for_Coverage__r.Name Order By Sales_Team_for_Coverage__r.Name]){
             system.debug(c.get('name'));
             srms.add((string)c.get('name'));
         }
        accountChampions = String.join(srms, '; ');
        
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeBooleanField('isNFPE', isNFPE);
        gen.writeStringField('accountChampions', accountChampions);
        gen.writeEndObject();
        String  accountNFPEDetails = gen.getAsString();

        return accountNFPEDetails;
	}*/
    @AuraEnabled
	public static String getAccountNFPEDetails(Id accountId){
		String accountChampions = '';		
        Boolean isNFPE = FALSE;
        String nfpeType = CoverageUtil.FLAG_NFPE_SUBTYPE1_1;
        
        Id activeSalesChampionRecordType = CommonTools.getRecordTypeIdUsingDeveloperName('Sales_Champion__c','NFPE_Champion');
        
		List<Account> accounts = [Select Id From Account Where Account.Parent.Id =: accountId And NFPE__c = true Limit 1];
        if(accounts.size() > 0)
        {
            isNFPE = TRUE;
        }
        
        List<String> srms = new List<String>();
        /* Directly RecordType.DeveloperName can be used in this scenario */
		for(Sales_Champion__c champ: [Select Sales_Champion__r.name  from Sales_Champion__c where RecordtypeId =: activeSalesChampionRecordType and Account__r.ParentId =: accountId and Champion_Type__c =: nfpeType])
        {
            system.debug(champ.Sales_Champion__r.name);
            srms.add(champ.Sales_Champion__r.name);
        }
        accountChampions = String.join(srms, '; ');
        
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeBooleanField('isNFPE', isNFPE);
        gen.writeStringField('accountChampions', accountChampions);
        gen.writeEndObject();
        String  accountNFPEDetails = gen.getAsString();

        return accountNFPEDetails;
	}
    
    @AuraEnabled
    public static Boolean isUserOnCoverageForAccount(Id accountId)
    {
        Set<String> ignoreCoverageProfiles = new Set<String>{
            'System Administrator',
            'Nomura - Production Services',
            'Nomura - Business Management'
        };

        Profile userProfileName = [SELECT Name From Profile WHERE Id =: userinfo.getProfileId()];
        if(ignoreCoverageProfiles.contains(userProfileName.name))
        {
            return true;
        }
        else{
            return CoverageUtil.isUserOnCoverageForAccount(accountId);
        } 
    }
}