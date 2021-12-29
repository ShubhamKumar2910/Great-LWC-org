@isTest
private class CoverageTeamMemberBLTest {
  static testMethod void TestCreateDeleteAccountTeamMember() {
    list<user> user = UtilityTesting.CreateUsers(3);
      
      Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
      salescvgTeam.Coverage_ID__c = '1234';
      salescvgTeam.Name = 'Newuser';
      salescvgTeam.Sales_Team__c = 'Test Team';  
      salescvgTeam.Active__c = TRUE;
      
      insert salescvgTeam;
      
      /* Insert Sales_Team_User__c */
      Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
	  salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
	  salesTeamUserObj.User__c = user[1].Id;
      
      insert salesTeamUserObj;
      
    system.runas(user[0]){
      
      Account acct = UtilityTesting.CreateAccount();
      
      Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
      revRollup.RM__c= acct.id;
      insert revRollup;
      
      list<Coverage_Team_Member__c> covgTeamList = new  list<Coverage_Team_Member__c>();
      
      Coverage_Team_Member__c covgTeamMember = new Coverage_Team_Member__c();
      covgTeamMember.account__c = acct.id;
      covgTeamMember.team_member__c = user[1].id;
      covgTeamMember.Sales_Team_for_Coverage__c = salescvgTeam.id; 
      covgTeamList.add(covgTeamMember);    
     
      
      insert covgTeamList;          
      
      //delete covgTeamList;
        
      //delete salescvgTeam;
    
    }
  }
  
  static testMethod void TestCreateDeleteRevenureRollupShares() {
    list<user> user = UtilityTesting.CreateUsers(3);
    system.runas(user[0]){
        
     Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
     salescvgTeam.Coverage_ID__c = '1234';
     salescvgTeam.Name = 'Newuser';
     salescvgTeam.Sales_Team__c = 'Test Team';  
     salescvgTeam.Active__c = TRUE;
      
     insert salescvgTeam;
        
      /* Insert Sales_Team_User__c */
      Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
	  salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
	  salesTeamUserObj.User__c = user[1].Id;   
        
      insert salesTeamUserObj;  
      
      Account acct = UtilityTesting.CreateAccount();
      
      Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
      revRollup.RM__c= acct.id;
      insert revRollup;
      
      list<Coverage_Team_Member__c> covgTeamList = new  list<Coverage_Team_Member__c>();
      
      Coverage_Team_Member__c covgTeamMember = new Coverage_Team_Member__c();
      covgTeamMember.account__c = acct.id;
      covgTeamMember.team_member__c = user[1].id;
      covgTeamMember.Sales_Team_for_Coverage__c = salescvgTeam.id;
      covgTeamList.add(covgTeamMember);    
     
      
      insert covgTeamList; 
        
      Coverage_Team_Member__c covgTeamMember1 = new Coverage_Team_Member__c();
      covgTeamMember1.account__c = acct.id;
      covgTeamMember1.team_member__c = user[1].id;
      covgTeamMember1.Sales_Team_for_Coverage__c = salescvgTeam.id;  
      covgTeamMember1.Product_Group__c = 'Equity';
      covgTeamMember1.Product2__c  = 'FUTURES';
      covgTeamMember1.Product_Region__c = 'USA';
      covgTeamMember1.UniqueId__c = 'RM1234#1234#Adlees#Equity#FUTURES-USA#TRUE' ; 
      covgTeamMember1.Called_From__c = 'Y';  
        
      insert covgTeamMember1;
        
        
      Coverage_Team_Member__c covgTeamMember2 = new Coverage_Team_Member__c();
      covgTeamMember2.account__c = acct.id;
      covgTeamMember2.team_member__c = user[1].id;
      covgTeamMember2.Sales_Team_for_Coverage__c = salescvgTeam.id;  
      covgTeamMember2.Product_Group__c = 'Equity';
      covgTeamMember2.Product2__c  = 'CONTENT';
      covgTeamMember2.Product_Region__c = 'USA';
      covgTeamMember2.Called_From__c = 'Y'; 
      covgTeamMember2.End_Date__c = Date.newInstance(2016, 10, 12);
      covgTeamMember2.UniqueId__c = 'RM1234#1234#Adlees#Equity#CONTENT-USA#TRUE' ; 
      covgTeamMember2.Called_From__c = 'Y';  
        
      insert covgTeamMember2;
        
    /*  Coverage_Team_Member__c covgTeamMember3 = new Coverage_Team_Member__c();
      covgTeamMember3.account__c = acct.id;
      covgTeamMember3.team_member__c = user[1].id;
      covgTeamMember3.Sales_Team_for_Coverage__c = salescvgTeam.id;  
      covgTeamMember3.Product_Group__c = 'Equity';
      covgTeamMember3.Product2__c  = 'FUTURES';
      covgTeamMember3.Product_Region__c = 'USA';
      covgTeamMember3.Called_From__c = 'Y'; 
      covgTeamMember3.End_Date__c = Date.newInstance(2016, 10, 12);
      covgTeamMember3.UniqueId__c = 'RM1234#1234#Adlees#Equity#FUTURES-USA#TRUE' ; 
        
      insert covgTeamMember3; */
      
      //delete covgTeamList;
        
     // delete salescvgTeam;
    
    
    }
  }
  
  
  static testMethod void TestUdpateTeamMembers() {
    list<user> user = UtilityTesting.CreateUsers(3);
    system.runas(user[0]){
      
      Account acct = UtilityTesting.CreateAccount();
      
      Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
      revRollup.RM__c= acct.id;
      insert revRollup;
        
      Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
      salescvgTeam.Coverage_ID__c = '1234';
      salescvgTeam.Name = 'Newuser';
      salescvgTeam.Sales_Team__c = 'Test Team';  
      salescvgTeam.Active__c = TRUE;
      
      insert salescvgTeam;
        
      /* Insert Sales_Team_User__c */
      Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
	  salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
	  salesTeamUserObj.User__c = user[1].Id;
             
	  insert salesTeamUserObj;
        
      list<Coverage_Team_Member__c> covgTeamList = new  list<Coverage_Team_Member__c>();
      
      Coverage_Team_Member__c covgTeamMember = new Coverage_Team_Member__c();
      covgTeamMember.account__c = acct.id;
      covgTeamMember.team_member__c = user[1].id;
      covgTeamMember.Sales_Team_for_Coverage__c = salescvgTeam.id;
      covgTeamList.add(covgTeamMember);    
      insert covgTeamList;  
      
      Coverage_Team_Member__c covgTeamMember1 = [select id,account_access__c,team_role__c,Sales_Team_for_Coverage__c from Coverage_Team_Member__c where id in: covgTeamList];
      covgTeamMember1.account_access__c = 'Read/Write';
      covgTeamMember1.team_role__c='test';
      //covgTeamMember1.Sales_Team_for_Coverage__c = salescvgTeam.id;
    /*  covgTeamMember1.Product_Group__c = 'Equity';
      covgTeamMember1.Product2__c  = 'FUTURES';
      covgTeamMember1.Product_Region__c = 'USA';
      covgTeamMember1.Called_From__c = 'Y';*/  
      update covgTeamMember1;
        
     // delete salescvgTeam;
     covgTeamMember1.End_Date__c = Date.today();
	 update covgTeamMember1;        
    }
  }
  
 
}