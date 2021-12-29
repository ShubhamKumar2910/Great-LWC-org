/**
 * This class contains utility methods for creating accounts and coverage
 *
 */
@isTest
public class TestRevenueKPIDataFactory {
	private static RecordType rmRecordType = null;
	private static RecordType rgRecordType = null;
	
	private static RecordType getRmRecordType() {
		if (null == rmRecordType) {
			rmRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
		}
	 	return rmRecordType;
	}

	private static RecordType getRgRecordType() {
		if (null == rgRecordType) {
			rgRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
		} 
			
	 	return rgRecordType;
	}
	
	public static List<Account> createAccountsWithRg(Integer numberRmsToCreate, Account parentRg) {
        List<Account> accounts = new List<Account>();
        for (integer x=0; x<numberRmsToCreate; x++ ) {
        	String orgId = getRandomAccountName('RM');
        	Account rm = createAccount(getRandomAccountName('RMTEST'), orgId, parentRg);
        	accounts.add(rm);
        }
        return accounts;
		
	}
    
    public static Account createRgAccount(String accountName) {
    	return createAccount(getRandomAccountName(accountName), getRandomAccountName('RG'), null);
    }
    
    private static Account createAccount(String accountName, String accountId, Account rgAccount) {
        Account account = new Account(Name=accountName,RDM_Org_ID__c=accountId);
    	account.billingStreet = 'Test';
    	account.billingCity='Test';
    	account.billingCountry='United States';
    	RecordType recordType;
    	if (null!=rgAccount) {
    		account.parentId = rgAccount.Id;
    		recordType = getRmRecordType();
    	} else {
    		recordType = getRgRecordType();
    	}
    	account.recordTypeId = recordType.Id;
        try {
        	Account[] accountList = new List<Account>();
        	accountList.add(account);
			Database.SaveResult[] srList = Database.insert(accountList, false);
			Database.SaveResult sr = srList[0];
			if (sr.isSuccess()) {
				account.id = sr.getId();
			} else {
				DmlException dmlException = new DmlException();
				Database.Error error = sr.getErrors()[0];
				dmlException.setMessage(error.getMessage());
				throw dmlException;
			}
        } catch (DmlException e) {
        	System.debug(logginglevel.ERROR, 'TestRevenueKPIDataFactory. Error creating rg account. Message: '+e.getMessage());
        	throw e;
        }
        return account;
    }
    
    public static Sales_Team_For_Coverage__c getSalesTeam (String name, String teamName, String teamId, String ownerId) {
		Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
		salescvgTeam.Name = name;
        salescvgTeam.Sales_Team__c = teamName;
		salescvgTeam.Coverage_ID__c = teamId;
        salescvgTeam.OwnerId = ownerId;
	    insert salescvgTeam;
    	return salescvgTeam;
    }
    
    public static List<Sales_Team_For_Coverage__c> getSalesTeams (Integer numberOfSalesCodes, List<User> userList) {
		List<Sales_Team_For_Coverage__c> salesTeamforCoverageList = new List<Sales_Team_For_Coverage__c>();
        for(Integer x=0; x<numberOfSalesCodes; x++){
            Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
			salescvgTeam.Name = userList.get(x) != null ? userList.get(x).Name : ('Test' + String.valueOf(x));
			salescvgTeam.Coverage_ID__c = String.valueOf(x);
            salescvgTeam.Sales_Team__c = 'Test' + String.valueOf(x);
            
            salesTeamforCoverageList.add(salescvgTeam);
	    }
        
        insert salesTeamforCoverageList;
        return salesTeamforCoverageList;
    }
    
    public static Sales_Team_User__c getSalesTeamUser (Id userId, Id salesTeamForCoverageId) {
		Sales_Team_User__c salesTeamUser = new  Sales_Team_User__c();
		salesTeamUser.User__c = userId;
		salesTeamUser.Sales_Team_for_Coverage__c = salesTeamForCoverageId;
	    insert salesTeamUser;
    	return salesTeamUser;
    }
    
    public static List<Sales_Team_User__c> getSalesTeamUsers (Map<Id,Id> userSalesCodeMap) {
		List<Sales_Team_User__c> salesTeamUserList = new List<Sales_Team_User__c>();
        
        for(Id userId : userSalesCodeMap.keySet()){
            Sales_Team_User__c salesTeamUser = new  Sales_Team_User__c();
			salesTeamUser.User__c = userId;
			salesTeamUser.Sales_Team_for_Coverage__c = userSalesCodeMap.get(userId);
            salesTeamUserList.add(salesTeamUser);
        }
        
        insert salesTeamUserList;
        return salesTeamUserList;
    }
    
    public static Revenue_KPI__c createKPI(Account rg, User owner) {
    	Revenue_KPI__c kpi = new Revenue_KPI__c();
    	kpi.RG__c = rg.id;
    	kpi.RevenueKey__c = getRandomAccountName('xxxx');
    	kpi.ReportKey__c='Test';
    	kpi.RG_Id__c = rg.RDM_Org_ID__c;
        kpi.ownerId = owner.id;
    	insert kpi;
    	return kpi;
    }

    public static List<Revenue_KPI__c> createKPIsForAccount(Account rg, User owner, Integer numberOfKpis) {
        List<Revenue_KPI__c> kpis = new List<Revenue_KPI__c>();
        for (Integer x=0; x<numberOfKpis; x++ ) {
            Revenue_KPI__c kpi = new Revenue_KPI__c();
            kpi.RG__c = rg.id;
            kpi.RevenueKey__c = getRandomAccountName('xxxx'+x);
            kpi.ReportKey__c='Test'+x;
            kpi.RG_Id__c = rg.RDM_Org_ID__c;
            kpi.ownerId = owner.id;
            kpis.add(kpi);
        }
    	insert kpis;
    	return kpis;
    }
    
    public static List<Revenue_KPI__c> createKPIs(List<Account> rg, User owner) {
        system.debug('createKPIs. owner id ' + owner);
    	List<Revenue_KPI__c>kpis = new List<Revenue_KPI__c>();
    	for (Account account: rg) {
	    	Revenue_KPI__c kpi = new Revenue_KPI__c();
    		kpi.RG__c = account.id;
    		kpi.RevenueKey__c = getRandomAccountName('xxxx');
    		kpi.ReportKey__c='Test';
    		kpi.RG_Id__c = account.RDM_Org_ID__c;
    		kpi.ownerId = owner.id;
    		kpis.add(kpi);
    	}
    	insert kpis;
    	return kpis;
    }
    
    static private String getRandomAccountName(String prefix) {
    	Integer rand = Math.round(Math.random()*1000000);
    	return prefix + rand.format();
    }
    
    public static User createKPIOwner() {
		Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
		User kpiOwner = new User( Alias = 'kpiOwner',
                        Email ='newUserKPIOwner@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'newUserKPIOwner',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='newUserKPIOwner@testorg.com',
                        ProfileId=p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles'
                        );
        insert kpiOwner;
        System.debug('Init. owner id ' + kpiOwner.Id);
        return kpiOwner;
	}
    
    public static Map<Id, List<Revenue_KPI__share>> getKpiShares(Id ownerId, List<Revenue_KPI__c> kpis) {
    	Map<Id, List<Revenue_KPI__share>> shareMap = new Map<Id, List<Revenue_KPI__share>>();
    	List<Id> kpiIds = new List<Id>();
    	for (Revenue_KPI__c kpi: kpis) {
    		kpiIds.add(kpi.id);
    	}
    	
    	list<Revenue_KPI__share> kpiShares = [Select ParentId, UserOrGroupId from Revenue_KPI__share Where UserOrGroupId!=null and UserOrGroupId!=: ownerId and ParentId in : kpiIds limit 20];
    	for (Revenue_KPI__share share: kpiShares) {
    		List<Revenue_KPI__share> shares = shareMap.get(share.ParentId)!=null? shareMap.get(share.ParentId): new list<Revenue_KPI__share>();
    		shares.add(share);
    		shareMap.put(share.ParentId, shares);
    	}
    	return shareMap;
    }
    
    public static Map<Id,Id> getUserSalesCodeMap(List<User> users, List<Sales_Team_for_Coverage__c> salesTeamForCoverageList){
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
         for(Integer x=0; x<users.size(); x++){
            User userObj = users.get(x);
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = salesTeamforCoverageList.get(x);
            if(userObj != null && salesTeamForCoverageObj != null){
                userSalesCodeMap.put(userObj.Id, salesTeamForCoverageObj.Id);
            }
        }
        
        return userSalesCodeMap;
    }



}