@isTest
public class UpdateJapanOpptysBatchTest {
    @testSetup
    static void setupTestData(){
        System.debug('setupTestData ** start **');
        
        // Role
        // SALES-3115
        Set<String> targetUserRoles = new Set<String>{
            'Japan - FI - Desk Head - JIFS',
            'Japan - FI - Team Head - JIFS Fixed Income Sales',
            'Japan - FI - Sales - JIFS Fixed Income Sales',
            'Japan - FI - Sales - JIFS Yen Rates Sales',
            'Japan - FI - Sales - JIFS International Products Sales',
            'Japan/AU - FI - Sales - JIFS Macro Sales',
            'Japan/AU - FI - Sales - JIFS AU Japan Risk (Japan)'
        };
        
        UserRole deskHeadRole2 = [select Id, Name from UserRole where Name='Japan - FI - Desk Head - JIFS'];
        UserRole teamHeadRole2 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS Fixed Income Sales'];      
        //UserRole teamHeadRole3 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS International Products Sales'];
        UserRole teamMemberRole2_1 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Fixed Income Sales'];
        UserRole teamMemberRole2_2 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Yen Rates Sales'];
        UserRole teamMemberRole2_3 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS International Products Sales'];
        UserRole teamMemberRole2_4 = [select Id, Name from UserRole where Name='Japan/AU - FI - Sales - JIFS Macro Sales'];
        UserRole teamMemberRole2_5 = [select Id, Name from UserRole where Name='Japan/AU - FI - Sales - JIFS AU Japan Risk (Japan)']; // To Be Ignored
        UserRole deskHeadRole3 = [select Id, Name from UserRole where Name='Japan - FI - Desk Head - JFPS']; // SALES-3115, GM3 Head
        UserRole teamHeadRole3 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Financial Instit Sales']; // SALES-3115, SPM1 Head
		UserRole teamMemberRole3_1 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Financial Instit Sales']; // SALES-3115, SPM1 
        UserRole teamMemberRole3_2 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Pension Funds Coverage']; // SALES-3115 SPM2
        UserRole teamMemberRole3_3 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Structured Products Marke']; // SALES-3115 SPM3
        
        UserRole teamHeadRole2_1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS Yen Rates Sales'];
        UserRole teamHeadRole3_1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS International Products Sales'];
        UserRole teamHeadRole4_1 = [select Id, Name from UserRole where Name='Japan/AU - FI - Team Head - JIFS Macro Sales'];
        UserRole teamHeadRole3_1_1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JFPS Financial Instit Sales']; // SALES-3115
        UserRole teamHeadRole3_2_1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JFPS Pension Funds Coverage']; // SALES-3115
        UserRole teamHeadRole3_3_1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JFPS Structured Products Marke']; // SALES-3115
        
        
        Profile p  = [SELECT Id From Profile WHERE Name='Nomura - Sales' limit 1];
        // User
        //User deskHead2 = [select Id, Name from User where UserRoleId=:deskHeadRole2.Id and IsActive=true limit 1];
        User deskHead2 = new User(LastName='deskHead2', firstName='deskHead2', UserRoleId=deskHeadRole2.Id, UserName='deskHead2@nnomura.com', Email='deskHead2@nnomura.com', isActive=TRUE, Alias = 'jpopty1', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        //User teamHead2 = [select Id, Name from User where UserRoleId=:teamHeadRole2.Id and IsActive=true limit 1];
        User teamHead2 = new User(LastName='teamHead2', firstName='teamHead2', UserRoleId=teamHeadRole2.Id, UserName='teamHead2@nnomura.com', Email='teamHead2@nnomura.com', isActive=TRUE, Alias = 'jpopty2', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        
        
        User teamMembers2_1_1 = new User(LastName='teamMembers2_1_1', firstName='teamMembers2_1_1', UserRoleId=teamMemberRole2_1.Id, UserName='teamMembers2_1_1@nnomura.com', Email='teamMembers2_1_1@nnomura.com', isActive=TRUE, Alias = 'jpopty3', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_1_2 = new User(LastName='teamMembers2_1_2', firstName='teamMembers2_1_2', UserRoleId=teamMemberRole2_1.Id, UserName='teamMembers2_1_2@nnomura.com', Email='teamMembers2_1_2@nnomura.com', isActive=TRUE, Alias = 'jpopty4', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_2_1 = new User(LastName='teamMembers2_2_1', firstName='teamMembers2_2_1', UserRoleId=teamMemberRole2_2.Id, UserName='teamMembers2_2_1@nnomura.com', Email='teamMembers2_2_1@nnomura.com', isActive=TRUE, Alias = 'jpopty5', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_2_2 = new User(LastName='teamMembers2_2_2', firstName='teamMembers2_2_2', UserRoleId=teamMemberRole2_2.Id, UserName='teamMembers2_2_2@nnomura.com', Email='teamMembers2_2_2@nnomura.com', isActive=TRUE, Alias = 'jpopty6', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_3_1 = new User(LastName='teamMembers2_3_1', firstName='teamMembers2_3_1', UserRoleId=teamMemberRole2_3.Id, UserName='teamMembers2_3_1@nnomura.com', Email='teamMembers2_3_1@nnomura.com', isActive=TRUE, Alias = 'jpopty7', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_3_2 = new User(LastName='teamMembers2_3_2', firstName='teamMembers2_3_2', UserRoleId=teamMemberRole2_3.Id, UserName='teamMembers2_3_2@nnomura.com', Email='teamMembers2_3_2@nnomura.com', isActive=TRUE, Alias = 'jpopty8', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_4_1 = new User(LastName='teamMembers2_4_1', firstName='teamMembers2_4_1', UserRoleId=teamMemberRole2_4.Id, UserName='teamMembers2_4_1@nnomura.com', Email='teamMembers2_4_1@nnomura.com', isActive=TRUE, Alias = 'jpopty9', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_4_2 = new User(LastName='teamMembers2_4_2', firstName='teamMembers2_4_2', UserRoleId=teamMemberRole2_4.Id, UserName='teamMembers2_4_2@nnomura.com', Email='teamMembers2_4_2@nnomura.com', isActive=TRUE, Alias = 'jpopty10', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_5_1 = new User(LastName='teamMembers2_5_1', firstName='teamMembers2_5_1', UserRoleId=teamMemberRole2_5.Id, UserName='teamMembers2_5_1@nnomura.com', Email='teamMembers2_5_1@nnomura.com', isActive=TRUE, Alias = 'jpopty11', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers2_5_2 = new User(LastName='teamMembers2_5_2', firstName='teamMembers2_5_2', UserRoleId=teamMemberRole2_5.Id, UserName='teamMembers2_5_2@nnomura.com', Email='teamMembers2_5_2@nnomura.com', isActive=TRUE, Alias = 'jpopty12', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers3_1_1 = new User(LastName='teamMembers3_1_1', firstName='teamMembers3_1_1', UserRoleId=teamMemberRole3_1.Id, UserName='teamMembers3_1_1@nnomura.com', Email='teamMembers3_1_1@nnomura.com', isActive=TRUE, Alias = 'jpopty13', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamMembers3_1_2 = new User(LastName='teamMembers3_1_2', firstName='teamMembers3_1_2', UserRoleId=teamMemberRole3_1.Id, UserName='teamMembers3_1_2@nnomura.com', Email='teamMembers3_1_2@nnomura.com', isActive=TRUE, Alias = 'jpopty14', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        
        User deskHead3 = new User(LastName='deskHead3', firstName='deskHead3', UserRoleId=deskHeadRole3.Id, UserName='deskHead3@nnomura.com', Email='deskHead3@nnomura.com', isActive=TRUE, Alias = 'jpopty15', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamHead2_1 = new User(LastName='teamHead2_1', firstName='teamHead2_1', UserRoleId=teamHeadRole2_1.Id, UserName='teamHead2_1@nnomura.com', Email='teamHead2_1@nnomura.com', isActive=TRUE, Alias = 'jpopty16', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamHead3_1 = new User(LastName='teamHead3_1', firstName='teamHead3_1', UserRoleId=teamHeadRole3_1.Id, UserName='teamHead3_1@nnomura.com', Email='teamHead3_1@nnomura.com', isActive=TRUE, Alias = 'jpopty17', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamHead4_1 = new User(LastName='teamHead4_1', firstName='teamHead4_1', UserRoleId=teamHeadRole4_1.Id, UserName='teamHead4_1@nnomura.com', Email='teamHead4_1@nnomura.com', isActive=TRUE, Alias = 'jpopty18', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamHead3_1_1 = new User(LastName='teamHead3_1_1', firstName='teamHead3_1_1', UserRoleId=teamHeadRole3_1_1.Id, UserName='teamHead3_1_1@nnomura.com', Email='teamHead3_1_1@nnomura.com', isActive=TRUE, Alias = 'jpopty19', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamHead3_2_1 = new User(LastName='teamHead3_2_1', firstName='teamHead3_2_1', UserRoleId=teamHeadRole3_2_1.Id, UserName='teamHead3_2_1@nnomura.com', Email='teamHead3_2_1@nnomura.com', isActive=TRUE, Alias = 'jpopty20', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User teamHead3_3_1 = new User(LastName='teamHead3_3_1', firstName='teamHead3_3_1', UserRoleId=teamHeadRole3_3_1.Id, UserName='teamHead3_3_1@nnomura.com', Email='teamHead3_3_1@nnomura.com', isActive=TRUE, Alias = 'jpopty21', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
        
        User teamMembers3_1_3 = new User(LastName='teamMembers3_1_3', firstName='teamMembers3_1_3', UserRoleId=teamMemberRole3_2.Id, UserName='teamMembers3_1_3@nnomura.com', Email='teamMembers3_1_3@nnomura.com', isActive=TRUE, Alias = 'jpopty22', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');
		User teamMembers3_1_4 = new User(LastName='teamMembers3_1_4', firstName='teamMembers3_1_4', UserRoleId=teamMemberRole3_3.Id, UserName='teamMembers3_1_4@nnomura.com', Email='teamMembers3_1_4@nnomura.com', isActive=TRUE, Alias = 'jpopty23', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles');

		List<User> users;
        System.runAs(new User(Id=UserInfo.getUserId())) {        
            users = new List<User>{
                deskHead2,
                teamHead2,
                teamMembers2_1_1,
                teamMembers2_1_2,
                teamMembers2_2_1,
                teamMembers2_2_2,
                teamMembers2_3_1,
                teamMembers2_3_2,
                teamMembers2_4_1,
                teamMembers2_4_2,
                teamMembers2_5_1,
                teamMembers2_5_2,
                teamMembers3_1_1,
                teamMembers3_1_2,
                teamHead2_1,
                teamHead3_1,
                teamHead4_1,
                teamHead3_1_1,
                teamHead3_2_1,
                teamHead3_3_1,
                teamMembers3_1_3,
                teamMembers3_1_4
            };
            insert users;
        }
   

        insert new Configuration__c(Name='UpdateJapanOpptysBatch', Param_Name__c='TeamsToBeIgnored', Parameter_Value__c='Japan - FI - Desk Head - JIFS:Japan/AU - FI - Sales - JIFS AU Japan Risk (Japan),Japan - FI - Desk Head - JIFS:Japan/AU - FI - Team Head - JIFS AU Japan Risk (Japan)');
     
        List<JapanDesk__c> desks = new List<JapanDesk__c>{
            // CombiTeam
            
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Commodities Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=true),
			
            // Originally For Team
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            
            // Originally For Team and Covering people
			new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),                
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Commodities Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            //new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
                
                
            // Originally For CombinationTeam    
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債', IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債', IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債', IsAutoOpportunityTrigger__c=true),
           
            
            // Originally For CombinationTeam + Covering People
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsAutoOpportunityTrigger__c=true),                
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Commodities Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            //new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            //new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債2'),
            //new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債2'),
            //new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債2'),
            
                
            // Originally For Deskhead    
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Commodities Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
                
            // SALES-3115 GM1 + GM3    
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Commodities Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='GM1 + GM3', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),
                
            // SALES-3115 Team + Covering people in GM1 + GM3
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=false, IsAutoOpportunityTrigger__c=true),                
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Commodities Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            //new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='国内債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=true, IsAutoOpportunityTrigger__c=false),    
                
            // TeamHead for Person
            new JapanDesk__c(Name='Japan - FI - Team Head  - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.TeamHead, Japanese_Name__c='円金利営業課', AutoOpptyForPerson__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.TeamHead, Japanese_Name__c='国内債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.TeamHead, Japanese_Name__c='為替営業課', AutoOpptyForPerson__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.TeamHead, Japanese_Name__c='外国債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true, IsAutoOpportunityTrigger__c=true),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.TeamHead, Japanese_Name__c='マクロセールス課', AutoOpptyForPerson__c=false, AutoOpptyForCoveringPeopleInDesk__c=false, AutoOpptyForDesk__c=false, IsAutoOpportunityTrigger__c=true),

            // Team    for Person
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='円金利営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='国内債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='為替営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=false, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='外国債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='先オプ', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=true, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='マクロセールス課', AutoOpptyForPerson__c=false, AutoOpptyForTeam__c=false, AutoOpptyForTeamAndCoveringPeopleInDesk__c=false, AutoOpptyForCoveringPeopleInDesk__c=false, AutoOpptyForDesk__c=false),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='SPM一課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=false, AutoOpptyForTeamAndCoveringPeopleInDesk__c=false, AutoOpptyForCoveringPeopleInDesk__c=true, AutoOpptyForDesk__c=true)

        };
        insert desks;

        // Acount
        RecordType art = [select Id from RecordType where Name = 'RM Account' and SobjectType = 'Account'];
        List<Account> accts = new List<Account>{
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 0', Local_Company_Name__c='顧客0', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 1', Local_Company_Name__c='顧客1', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 2', Local_Company_Name__c='顧客2', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 3', Local_Company_Name__c='顧客3', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 4 - Inactive', Local_Company_Name__c='顧客4', Active__c=False,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street')
                
        };
        insert accts;
        
        // SALES-3115
        RecordType gArt = [SELECT Id FROM RecordType WHERE Name = 'RG Account' and SobjectType = 'Account'];
        List<Account> gAccts = new List<Account>{
            new Account(RecordTypeId=gArt.Id, Name='UpdateJapanOpptysBatchTest Account 0 (G)', Local_Company_Name__c='顧客0(G)', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=gArt.Id, Name='UpdateJapanOpptysBatchTest Account 1 (G)', Local_Company_Name__c='顧客1(G)', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=gArt.Id, Name='UpdateJapanOpptysBatchTest Account 2 (G)', Local_Company_Name__c='顧客2(G)', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=gArt.Id, Name='UpdateJapanOpptysBatchTest Account 3 (G)', Local_Company_Name__c='顧客3(G)', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street')
        };
        insert gAccts;
        accts[0].ParentId = gAccts[0].Id;
        accts[1].ParentId = gAccts[1].Id;
        accts[2].ParentId = gAccts[2].Id;
        accts[3].ParentId = gAccts[3].Id;
        
        update accts; // This "update" is neccessary, if remove, a validation error will happens because Active__c will be false
        
        
        
            /* System.assert(teamMembers2_1.size() >= 2);
        System.assertNotEquals(0, teamMembers2_2.size());
        System.assertNotEquals(0, teamMembers2_3.size());
        System.assertNotEquals(0, teamMembers2_4.size());
        System.assertNotEquals(0, teamMembers2_5.size());*/
        User userToBeDisabled = teamMembers2_1_2;
        //System.assertNotEquals(null, userToBeDisabled);
        
        
        // AccountTeamMember
        List<AccountTeamMember> acctMembers = new List<AccountTeamMember>{
            new AccountTeamMember(AccountId=accts[0].Id, UserId=teamHead2.Id),
            new AccountTeamMember(AccountId=accts[1].Id, UserId=teamMembers2_1_1.Id),
            new AccountTeamMember(AccountId=accts[1].Id, UserId=teamMembers2_2_1.Id),
            new AccountTeamMember(AccountId=accts[1].Id, UserId=teamMembers2_3_1.Id),
            new AccountTeamMember(AccountId=accts[1].Id, UserId=teamMembers2_4_1.Id),
            new AccountTeamMember(AccountId=accts[1].Id, UserId=teamMembers2_5_1.Id), // To Be Ignored
            new AccountTeamMember(AccountId=accts[2].Id, UserId=teamMembers2_4_1.Id),
            new AccountTeamMember(AccountId=accts[3].Id, UserId=userToBeDisabled.Id),
            new AccountTeamMember(AccountId=accts[4].Id, UserId=teamMembers2_1_1.Id)
        };
        System.debug('AccountTeamMember: teamHead2=' + teamHead2.Name); // Iizuka as of 2019 Feb
        System.debug('AccountTeamMember: teamMembers2_1[0]=' + teamMembers2_1_1.Name); // Takahashi as of 2019 Feb
        System.debug('AccountTeamMember: teamMembers2_2[0]=' + teamMembers2_2_1.Name); // Suzuki as of 2019 Feb
        System.debug('AccountTeamMember: teamMembers2_3[0]=' + teamMembers2_3_1.Name); // Arai as of 2019 Feb
        System.debug('AccountTeamMember: teamMembers2_4[0]=' + teamMembers2_4_1.Name); // Steve as of 2019 Feb
        System.debug('AccountTeamMember: teamMembers2_5[0]=' + teamMembers2_5_1.Name); // Daniel as of 2019 Feb, To Be Ignored
        System.debug('AccountTeamMember: userToBeDisabled=' + userToBeDisabled.Name); // Hirai as of 2019 Feb

        insert acctMembers;
        
        // Opportunity
        Date closeDate = Date.newInstance(2099, 12, 31);
        RecordType ort = [select Id from RecordType where Name = 'Automated' and SobjectType = 'Opportunity']; // SALES-3115
        List<Opportunity> opptys = new List<Opportunity>{
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='顧客0 - PERSON - WITH EVENT', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamMembers2_1_1.Id, SystemAuto_Person_Role_ID__c=teamMemberRole2_3.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='顧客0 - PERSON - WITH EVENT-2', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamMembers2_2_1.Id, SystemAuto_Person_Role_ID__c=teamMemberRole2_2.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='顧客0 - PERSON - WITH NO ACTIVITIES', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamMembers2_3_1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[3].Id, RecordTypeId=ort.Id, Name='顧客3 - WITH EVENT', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=userToBeDisabled.Id, SystemAuto_Person_Role_ID__c=teamMemberRole2_1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[3].Id),
            new Opportunity(AccountId=accts[3].Id, RecordTypeId=ort.Id, Name='顧客3 - WITH TASK', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamMembers2_2_1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[3].Id),
            new Opportunity(AccountId=accts[3].Id, RecordTypeId=ort.Id, Name='顧客3 - WITH NO ACTIVITIES', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamMembers2_3_1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[3].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='顧客0 - PERSON', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamHead2.Id, SystemAuto_Person_Role_ID__c=teamMemberRole2_3.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            //new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='顧客0 - COVERING', SystemAuto_Type__c='For Covering People in Desk', SystemAuto_Target_ID__c=deskHeadRole2.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting')
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='顧客0 - COVERING', SystemAuto_Type__c='For Combination Team', SystemAuto_Target_ID__c=desks[0].Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id)
        };       
        insert opptys;
        
        System.assertEquals(8, opptys.size());
        for(Opportunity o : opptys){
            System.Debug('[Just After Insert]Opportunity Set : OpportunityId='+o.Id+', AccountId='+o.AccountId + ', Account.Id='+o.Account.Id + 'Account__c='+o.Account__c);
        }
        
        List<OpportunityTeamMember> opptyMembers = new List<OpportunityTeamMember>{
            new OpportunityTeamMember(OpportunityId=opptys[0].Id, UserId=teamMembers2_1_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[1].Id, UserId=teamMembers2_2_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[2].Id, UserId=teamMembers2_3_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[3].Id, UserId=userToBeDisabled.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[4].Id, UserId=teamMembers2_2_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[5].Id, UserId=teamMembers2_3_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[6].Id, UserId=teamHead2.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[7].Id, UserId=teamMembers2_1_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[7].Id, UserId=teamMembers2_2_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[7].Id, UserId=teamMembers2_3_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read'),
            new OpportunityTeamMember(OpportunityId=opptys[7].Id, UserId=teamMembers2_4_1.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read')
        };
        insert opptyMembers;
        
        RecordType ert = [select Id from RecordType where Name = 'Standard Event' and SobjectType = 'Event'];
        List<Event> events = new List<Event>{
            new Event(WhatId=opptys[0].Id, RecordTypeId=ert.Id, DurationInMinutes=0, ActivityDateTime=Date.today(), Subject='Call'),
            new Event(WhatId=opptys[1].Id, RecordTypeId=ert.Id, DurationInMinutes=0, ActivityDateTime=Date.today(), Subject='Call'),    
            new Event(WhatId=opptys[3].Id, RecordTypeId=ert.Id, DurationInMinutes=0, ActivityDateTime=Date.today(), Subject='Call'),
            new Event(WhatId=opptys[6].Id, RecordTypeId=ert.Id, DurationInMinutes=0, ActivityDateTime=Date.today(), Subject='Call')
        };
        insert events;
        
        // SALES-3115
        //List<Contact> contacts = [SELECT Id FROM Contact WHERE Active__c = true ORDER BY Id LIMIT 1];
        List<Contact> contacts = new List<Contact>{
            new Contact(AccountId=accts[0].Id, LastName='苗字', FirstName='名前', Salutation='Mr', Email='testcontact@testtest.testcom', Active__C = true)
        };
        insert contacts;
        System.debug('number of contacts : ' + contacts.size());
        
        /*
        List<Task> tasks = new List<Task>{
            new Task(WhatId=opptys[1].Id, ActivityDate=Date.today(), Subject='Task', WhoId=contacts[0].Id),
            new Task(WhatId=opptys[4].Id, ActivityDate=Date.today(), Subject='Task', WhoId=contacts[0].Id),
            new Task(WhatId=opptys[6].Id, ActivityDate=Date.today(), Subject='Task', WhoId=contacts[0].Id)
        };
        System.debug('---tasks--' + tasks);    
        insert tasks;
        */  
        opptys = [select Id, Name, Account.Name, Owner.LastName, CloseDate, Active__c, StageName, SystemAuto_Type__c, SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c, AccountId, Account.Id from Opportunity order by ID];
        System.assertEquals(8, opptys.size());
        for(Opportunity o : opptys){
            System.Debug('Opportunity Set : OpportunityId='+o.Id+', AccountId='+o.AccountId + ', Account.Id='+o.Account.Id);
        }
        System.debug('setupTestData ** end ** - MUST FINISH BEFORE setupTestData2');
    }

    @testSetup
    static void setupTestData2(){
        System.debug('setupTestData2 ** start ** - MUST RUN AFTER setupTestData');
        //UserRole teamMemberRole2_1 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Fixed Income Sales'];
        List<User> teamMembers2_1 = [select Id, Name from User where UserName = 'teamMembers2_1_2@nnomura.com'];

        User userToBeDisabled = teamMembers2_1[0];
        System.debug('setupTestData2 - userToBeDisabled.Name=' + userToBeDisabled.Name);
        userToBeDisabled.IsActive = false;
        update userToBeDisabled;
        System.debug('setupTestData2 ** end **');
    }

    static UserRole deskHeadRole;
    static UserRole deskHeadRole3; // SALES-3115
    static UserRole teamHeadRole1;
    static UserRole teamHeadRole2;
    static UserRole teamHeadRole3;
    static UserRole teamHeadRole4;
    static UserRole teamHeadRole3_1; // SALES-3115
    static UserRole teamHeadRole3_2; // SALES-3115
    static UserRole teamHeadRole3_3; // SALES-3115
    static UserRole teamMemberRole1;
    static UserRole teamMemberRole2;
    static UserRole teamMemberRole3;
    static UserRole teamMemberRole4;
    static UserRole teamMemberRole3_1; // SALES-3115
    static UserRole teamMemberRole3_2; // SALEs-3115
    static UserRole teamMemberRole3_3; // SALES-3115
    static List<User> deskHeads;
    static List<User> deskHeads3; // SALES-3115
    static List<User> teamHeads1;
    static List<User> teamHeads2;
    static List<User> teamHeads3;
    static List<User> teamHeads4;
    static List<User> teamHeads3_1; // SALES-3115
    static List<User> teamHeads3_2; // SALES-3115
    static List<User> teamheads3_3; // SALES-3115
    static List<User> teamMembers1;
    static List<User> teamMembers2;
    static List<User> teamMembers3;
    static List<User> teamMembers4;
    static List<User> teamMembers3_1; // SALES-3115
    static List<User> teamMembers3_2; // SALES-3115
    static List<User> teamMembers3_3; // SALES-3115
    static List<JapanDesk__c> combiTopDesks;

    static void loadTestData(){
        // Role
        deskHeadRole = [select Id, Name from UserRole where Name='Japan - FI - Desk Head - JIFS'];
        deskHeadRole3 = [select Id, Name from UserRole where Name='Japan - FI - Desk Head - JFPS']; // SALES-3115
        teamHeadRole1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS Fixed Income Sales'];
        teamHeadRole2 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS Yen Rates Sales'];
        teamHeadRole3 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JIFS International Products Sales'];
        teamHeadRole4 = [select Id, Name from UserRole where Name='Japan/AU - FI - Team Head - JIFS Macro Sales'];
        teamHeadRole3_1 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JFPS Financial Instit Sales']; // SALES-3115
        teamHeadRole3_2 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JFPS Pension Funds Coverage']; // SALES-3115
        teamHeadRole3_3 = [select Id, Name from UserRole where Name='Japan - FI - Team Head - JFPS Structured Products Marke']; // SALES-3115
        teamMemberRole1 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Fixed Income Sales'];
        teamMemberRole2 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Yen Rates Sales'];
        teamMemberRole3 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS International Products Sales'];
        teamMemberRole4 = [select Id, Name from UserRole where Name='Japan/AU - FI - Sales - JIFS Macro Sales'];
        teamMemberRole3_1 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Financial Instit Sales']; // SALES-3115
        teamMemberRole3_2= [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Pension Funds Coverage']; // SALES-3115
        teamMemberRole3_3 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JFPS Structured Products Marke']; // SALES-3115

        // User
        deskHeads = [select Id, Name, LastName, UserRoleId from User where UserName='deskHead2@nnomura.com'];
        deskHeads3 = [select Id, Name, LastName, UserRoleId from User where UserName='deskHead3@nnomura.com']; // SALES-3115
        teamHeads1 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead2@nnomura.com'];
        teamHeads2 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead2_1@nnomura.com'];
        teamHeads3 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead3_1@nnomura.com'];
        teamHeads4 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead4_1@nnomura.com'];
        teamHeads3_1 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead4_1@nnomura.com']; // SALES-3115
        teamHeads3_2 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead3_2_1@nnomura.com']; // SALES-3115
        teamHeads3_3 = [select Id, Name, LastName, UserRoleId from User where UserName='teamHead3_3_1@nnomura.com']; // SALES-3115
        //System.assertNotEquals(0, teamHeads1.size());
        //System.assertNotEquals(0, teamHeads2.size());
        //System.assertNotEquals(0, teamHeads3.size());
        //System.assertNotEquals(0, teamHeads4.size());
        teamMembers1 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers2_1_1@nnomura.com'];
        teamMembers2 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers2_2_1@nnomura.com'];
        teamMembers3 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers2_3_1@nnomura.com'];
        teamMembers4 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers2_4_1@nnomura.com'];
        teamMembers3_1 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers3_1_1@nnomura.com'];
        teamMembers3_2 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers3_1_3@nnomura.com'];
        teamMembers3_3 = [select Id, Name, LastName, UserRoleId from User where UserName='teamMembers3_1_4@nnomura.com'];
        /*System.assertNotEquals(0, teamMembers1.size());
        System.assertNotEquals(0, teamMembers2.size());
        System.assertNotEquals(0, teamMembers3.size());
        System.assertNotEquals(0, teamMembers4.size());*/
        
        /* SALES-3115 Comment out
        List<JapanDesk__c> desks = [select Id, Name, Role_Level__c from JapanDesk__c where Name='Japan - FI - Sales - JIFS Yen Rates Sales' and Role_Level__c='Combination Team'];
        //System.assertEquals(2, desks.size());
        combiTopDesk1 = desks[0];
        combiTopDesk2 = desks[1];*/
        
        // 0 : existing : CoveringPeopleInDesk
        // 1 : new : For Team
        // 2 : new : For Team and Covering People
        // 3 : new : For Combination Team (Yensai)
        // 4 : new : For Combination Team + Covering People (Yensai)
        // 5 : new : For Desk
        // 6 : new : GM1 + GM3
        // 7 : new : Team + covering people in GM1 + GM3
        combiTopDesks = [select Id, Name, Role_Level__c from JapanDesk__c where Name='Japan - FI - Sales - JIFS Fixed Income Sales' and Role_Level__c='Combination Team'];
        System.assertEquals(8, combiTopDesks.size());
    }
    
    @isTest
    static void testScheduler(){
        Test.startTest();
        
        loadTestData();

        UpdateJapanOpptysBatchScheduler scheduler = new UpdateJapanOpptysBatchScheduler();
        scheduler.execute(null);
        Test.stopTest();
    }

    @isTest
    static void testBatch1(){
        List<Opportunity> opptys;
		
        Test.startTest();
        
        loadTestData();

        //User disabledMember = [select Id, Name, IsActive from User where UserRoleId=:teamMemberRole1.Id and LastName='Imamura' order by Id];
		//System.debug('testBatch1 - disabledMember=' + disabledMember);
        
        opptys = [select Id, Name, Account.Name, Owner.LastName, CloseDate, Active__c, StageName, SystemAuto_Type__c, SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c from Opportunity order by ID];
        System.assertEquals(8, opptys.size());
        for(Opportunity o : opptys){
            System.debug('testBatch1: Opportunity'+o.Id + ' : ' + o.Name);
        }
       
        // start()
        UpdateJapanOpptysBatch batch = new UpdateJapanOpptysBatch();
        Iterable<Account> startResult = batch.start(null);
        
        Iterator<Account> iter = startResult.iterator();
        List<Account> accts = new List<Account>();
        while(iter.hasNext()){
            accts.add(iter.next());
        }
        System.assertEquals(4, accts.size());
        
        // execute()
        batch.execute(null, accts);
        opptys = [select Id, Name, Account.Name, Owner.LastName, CloseDate, Active__c, StageName, SystemAuto_Type__c, SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c from Opportunity order by ID];
        //System.assertEquals(4 + 25, opptys.size());
        
        Opportunity oppty;
        User usr;
        List<OpportunityTeamMember> opptyMembers;

        Integer offset = 0;

        // CASE 1:
        //   The oppty is already unneccesary because the sales was transferred (role was changed) and does not cover the client anymore
        //   but it's having an associated event
        // Expected Result:
        //   a) The oppty is not deleted
        //   b) "** OLD **" is added to the Oppty name
        //   c) The members are 
        //          the heads of the team to which the sales originally belonged
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId, User.UserRoleId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - PERSON - WITH EVENT ** OLD **', oppty.Name);
        //System.assertEquals(teamHeads3.size(), opptyMembers.size());
        System.Debug('Number of OpportunityTeamMembers : ' + opptyMembers.size());
        //System.assertEquals(teamHeadRole3.Id, opptyMembers[0].User.UserRoleId);
        
        // CASE 2:
        //   The oppty is already unneccesary because the sales does not cover the client anymore
        //   but it's having an associated event
        // Expected Result:
        //   a) The oppty is not deleted
        //   b) "** OLD **" is added to the Oppty name
        //   c) The member is only the sales person (it's not changed)
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - PERSON - WITH EVENT-2 ** OLD **', oppty.Name);
        //System.assertEquals(1, opptyMembers.size());
        //System.assertEquals(teamMembers2[0].Id, opptyMembers[0].UserId);
        
        // CASE 3:
        //   The oppty is already unneccesary because the sales was disabled (role was not changed)
        //   but it's having an associated event
        // Expected Result:
        //   a) The oppty is not deleted
        //   b) "** OLD **" is added to the Oppty name
        //   c) The members are 
        //          the heads of the team to which the sales belonged
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId, User.UserRoleId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客3 - WITH EVENT ** OLD **', oppty.Name);
        //System.assertEquals(teamHeads1.size(), opptyMembers.size());
        //System.assertEquals(teamHeadRole1.Id, opptyMembers[0].User.UserRoleId);
        
        /*
        // == THIS CASE IS NOT NEEDED ANYMORE ==
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        //System.assertEquals('顧客3 - WITH TASK ** OLD **', oppty.Name);
        //System.assertEquals(1, opptyMembers.size());
		*/
        usr = teamHeads1[0];

        // CASE 4:
        //   The oppty is already unneccesary because the sales was transferred (role was changed) and covers the same client
        //   and it's having an associated activity
        // Expected Result:
        //   a) The oppty is not deleted
        //   b) "** OLD **" is added to the Oppty name
        //   c) The members are 
        //          the heads of the team to which the sales originally belonged
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId, User.UserRoleId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - PERSON ** OLD **', oppty.Name);
        System.assertEquals('For Person', oppty.SystemAuto_Type__c);
        System.assertEquals(usr.Id, oppty.SystemAuto_Target_ID__c);
        //System.assertEquals(teamMemberRole3.Id, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamHeads3.size(), opptyMembers.size());
        //System.assertEquals(teamHeadRole3.Id, opptyMembers[0].User.UserRoleId);

        // CASE 5:
        //   The oppty exists but the oppty name & members are changed
        // Expected Result:
        //   a) The oppty is not deleted
        //   b) The name is corrected
        //   c) The members are 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId, Name from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - GM1内担当者', oppty.Name);
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        //System.assertEquals(deskHeadRole.Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamHeads1.size() + deskHeads.size(), opptyMembers.size()); // In this case a team head is the person covering the account
        
        
        //System.assertEquals(usr.Id, opptyMembers[0].UserId);

        // CASE 6:
        //   The oppty does not exist
        //     Type: For Person
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The member is only the sales person
        //   d) The common fields have expected values
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - ' + usr.LastName, oppty.Name);
        System.assertEquals('For Person', oppty.SystemAuto_Type__c);
        System.assertEquals(usr.Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(usr.UserRoleId, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(1, opptyMembers.size());
        //System.assertEquals(usr.Id, opptyMembers[0].UserId);

        System.assertEquals('UpdateJapanOpptysBatchTest Account 0', oppty.Account.Name);
        System.assertEquals('sfadmin', oppty.Owner.LastName);
        System.assertEquals(Date.newInstance(2099, 12, 31), oppty.CloseDate);
        System.assertEquals(true, oppty.Active__c);
        //System.assertEquals('Prospecting', oppty.StageName);
        
        // CASE 7:
        //   The oppty does not exist
        //     Type: Combination Team (Originally For Team)
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in the team and 
        //          the heads of the team
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客0 - 国内債券営業課', oppty.Name);
        System.assertEquals(combiTopDesks[1].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size(), opptyMembers.size());

        // CASE 8:
        //   The oppty does not exist
        //     Type: Combination Team (Originally For Team + Covering People in Desk)
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in the team and 
        //          the heads of the team and 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客0 - 国内債券営業課＋部内担当者', oppty.Name);
        System.assertEquals(combiTopDesks[2].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + 0 + deskHeads.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Combination Team
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in both of the teams and 
        //          the heads of both of the teams
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客0 - 円債', oppty.Name);
        System.assertEquals(combiTopDesks[3].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Combination Team + Covering People in Desk
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in both of the teams and 
        //          the heads of both of the teams and 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId, User.Name, User.UserRole.Name from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客0 - 円債＋部内担当者', oppty.Name);
        System.assertEquals(combiTopDesks[4].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        System.debug('Case Combination Team + Covering People. TeamMember1 : ' + teamMembers1.size() + ', teamHeads1 : ' + teamHeads1.size() + ', teamMembers2 : ' + teamMembers2.size() + ', teamHeads2 : ' + teamHeads2.size() + ', deskHeads : ' + deskHeads.size());
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size() + 0 + deskHeads.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Desk
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          all of the people in the desk
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - GM1', oppty.Name);
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals(combiTopDesks[5].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assert(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size() + teamMembers3.size() + teamHeads3.size() + teamMembers4.size() + teamHeads4.size() + deskHeads.size() <= opptyMembers.size());
		
        // SALES-3115, Cross Desk
        // CASE:
        //   The oppty does not exist
        //     Type: For Combination Team
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          all of the people in the desks
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - GM1 + GM3', oppty.Name);
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals(combiTopDesks[6].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assert(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size() + teamMembers3.size() + teamHeads3.size() + teamMembers4.size() + teamHeads4.size() + teamMembers3_1.size() + teamHeads3_1.size() + teamMembers3_2.size() + teamHeads3_2.size() + teamMembers3_3.size() + teamHeads3_3.size() + deskHeads.size() + deskHeads3.size() <= opptyMembers.size());
        
        // SALES-3115, Team + Cross Desk Coverage
        // CASE:
        //   The oppty does not exist
        //     Type: For Combination Team
        //     Sales person's role: Team head
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          all of the people in the desks
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('顧客0 - 国内債券営業課＋GM1/3内担当者', oppty.Name);
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals(combiTopDesks[7].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + 0 /* Number of coverage in teamMember3_1 */ + teamHeads3_1.size() + 0 /* Number of coverage in teamMember3_2 */ + 0 /* No team head for teamMember3_2 */ +  0 /* Number of coverage in teamMember3_3 */ + 0 /* No team head for teamMember3_3 */ + deskHeads.size() + deskHeads3.size(), opptyMembers.size());

        
        usr = teamMembers1[0];
        
        // CASE:
        //   The oppty does not exist
        //     Type: For Person
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The member is only the sales person
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Person', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - ' + usr.LastName, oppty.Name);
        System.assertEquals(usr.Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(usr.UserRoleId, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(1, opptyMembers.size());
        //System.assertEquals(usr.Id, opptyMembers[0].UserId);
		
        // CASE:
        //   The oppty does not exist
        //   One team is belonging to 2 combination teams
        //     Type: For Combination Team + Covering People in Desk
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is not deleted
        //   b) The name is corrected
        //   c) The members are 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - GM1内担当者', oppty.Name);
        System.assertEquals(combiTopDesks[0].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(4 + teamHeads1.size() + teamHeads2.size() + teamHeads3.size() + teamHeads4.size() + deskHeads.size(), opptyMembers.size());
        
        // CASE:
        //   The oppty does not exist
        //     Type: For Team
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in the team and 
        //          the heads of the team
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - 国内債券営業課', oppty.Name);
        System.assertEquals(combiTopDesks[1].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Team + Covering People in Desk
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in the team and 
        //          the heads of the team and 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - 国内債券営業課＋部内担当者', oppty.Name);
        System.assertEquals(combiTopDesks[2].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + 3 + teamHeads1.size() + teamHeads2.size() + teamHeads3.size() + teamHeads4.size() + deskHeads.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Combination Team
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in both of the teams and 
        //          the heads of both of the teams
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - 円債', oppty.Name);
        System.assertEquals(combiTopDesks[3].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Combination Team + Covering People in Desk
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in both of the teams and 
        //          the heads of both of the teams and 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - 円債＋部内担当者', oppty.Name);
        System.assertEquals(combiTopDesks[4].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size() + 2 + teamHeads3.size() + teamHeads4.size() + deskHeads.size(), opptyMembers.size());
		
        // SALES 3115 NO LONGER REQUIRED
        // CASE:
        //   The oppty does not exist
        //   One team is belonging to 2 combination teams
        //     Type: For Combination Team
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in both of the teams and 
        //          the heads of both of the teams
        //oppty = opptys[offset++];
        //opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        //System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        //System.assertEquals('顧客1 - 円債2', oppty.Name);
        //System.assertEquals(combiTopDesk2.Id, oppty.SystemAuto_Target_ID__c);
        //System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size(), opptyMembers.size());
		
        // SALES-3115 NO LONGER REQUIRED
        // CASE:
        //   The oppty does not exist
        //   One team is belonging to 2 combination teams
        //     Type: For Combination Team + Covering People in Desk
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          the members in both of the teams and 
        //          the heads of both of the teams and 
        //          the sales persons which covers the account in the desk and 
        //          the team heads of the sales persons
        //          the desk heads of the sales persons
        //oppty = opptys[offset++];
        //opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        //System.assertEquals('For Combination Team + Covering People in Desk', oppty.SystemAuto_Type__c);
        //System.assertEquals('顧客1 - 円債2＋部内担当者', oppty.Name);
        //System.assertEquals(combiTopDesk2.Id, oppty.SystemAuto_Target_ID__c);
        //System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assertEquals(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size() + 2 + teamHeads3.size() + teamHeads4.size() + deskHeads.size(), opptyMembers.size());

        // CASE:
        //   The oppty does not exist
        //     Type: For Desk
        //     Sales person's role: Team Member
        // Expected Result:
        //   a) The oppty is created
        //   b) The name is correct
        //   c) The members are 
        //          all of the people in the desk
        oppty = opptys[offset++];
        opptyMembers = [select Id, Opportunity.Name, UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.assertEquals('For Combination Team', oppty.SystemAuto_Type__c);
        System.assertEquals('顧客1 - GM1', oppty.Name);
        System.assertEquals(combiTopDesks[5].Id, oppty.SystemAuto_Target_ID__c);
        System.assertEquals(null, oppty.SystemAuto_Person_Role_ID__c);
        //System.assert(teamMembers1.size() + teamHeads1.size() + teamMembers2.size() + teamHeads2.size() + teamMembers3.size() + teamHeads3.size() + teamMembers4.size() + teamHeads4.size() + deskHeads.size() <= opptyMembers.size());
        
        Test.stopTest();

        // finish()
        batch.finish(null);
    }
    
    @isTest 
    static void testRunTwice(){
        Test.startTest();
        
        loadTestData();
        
        // start()
        UpdateJapanOpptysBatch batch = new UpdateJapanOpptysBatch();
        Iterable<Account> startResult = batch.start(null);
        Iterator<Account> iter = startResult.iterator();
        List<Account> accts = new List<Account>();
        while(iter.hasNext()){
            accts.add(iter.next());
        }
        //System.assertEquals(4, accts.size());
       
        List<Opportunity> opptys;

        // execute()
        batch.execute(null, accts);
        opptys = [select Id, Name, Account.Name, Owner.LastName, CloseDate, Active__c, StageName, SystemAuto_Type__c, SystemAuto_Target_ID__c from Opportunity order by ID];
        //System.assertEquals(4 + 25, opptys.size());

        // execute() - again
        batch.execute(null, accts);
        //opptys = [select Id, Name, Account.Name, Owner.LastName, CloseDate, Active__c, StageName, SystemAuto_Type__c, SystemAuto_Target_ID__c from Opportunity order by ID];
        //System.assertEquals(4 + 25, opptys.size());

        Test.stopTest();
    }
    
    @isTest 
    static void testTeamToBeIgnoredConfig(){
        Test.startTest();
        
        loadTestData();
        
        // start()
        UpdateJapanOpptysBatch batch = new UpdateJapanOpptysBatch();
        Iterable<Account> startResult = batch.start(null);
        Iterator<Account> iter = startResult.iterator();
        List<Account> accts = new List<Account>();
        while(iter.hasNext()){
            accts.add(iter.next());
        }
       
        // execute()
        batch.execute(null, accts);
        
        List<OpportunityTeamMember> opptyMembers = [SELECT Id, Opportunity.Name, User.Name, Name FROM OpportunityTeamMember WHERE User.UserRole.Name in ('Japan/AU - FI - Sales - JIFS AU Japan Risk (Japan)', 'Japan/AU - FI - Team Head - JIFS AU Japan Risk (Japan)')];
        //System.assertEquals(0, opptyMembers.size());

        Test.stopTest();
    }

    @isTest 
    static void testReleseScript(){
        // delete
        //System.assertNotEquals(0, [select count() from JapanDesk__c]);
        delete [select ID from JapanDesk__c];
        //System.assertEquals(0, [select count() from JapanDesk__c]);

        // insert
        insert new List<JapanDesk__c>{
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS LDN Japan Risk (Japan)' ,Japanese_Name__c='LDN Japan Risk' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Desk Head - JIFS' ,Japanese_Name__c='GM1' ,Role_Level__c='Desk Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales' ,Japanese_Name__c='国内債券営業課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS FID F&O (Japan)' ,Japanese_Name__c='先オプ' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Yen Rates Sales' ,Japanese_Name__c='円金利営業課' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales' ,Japanese_Name__c='円債' ,Role_Level__c='Combination Team' ,AutoOpptyForPerson__c=FALSE ,AutoOpptyForDesk__c=FALSE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Yen Derivative Sales' ,Japanese_Name__c='金利デリバティブ営業課' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales' ,Japanese_Name__c='円金利営業課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales' ,Japanese_Name__c='金利デリバティブ営業課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales' ,Japanese_Name__c='円債' ,Role_Level__c='Combination Team' ,AutoOpptyForPerson__c=FALSE ,AutoOpptyForDesk__c=FALSE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=FALSE),
            new JapanDesk__c(Name='Japan - FI Sales - Region Head' ,Japanese_Name__c='FI' ,Role_Level__c='Region Head' ,AutoOpptyForPerson__c=FALSE ,AutoOpptyForDesk__c=FALSE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)' ,Japanese_Name__c='LDN Japan Risk' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=TRUE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales' ,Japanese_Name__c='外国債券営業課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=TRUE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Public Sector Instit Sales' ,Japanese_Name__c='公共法人' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Foreign Exchange Sales' ,Japanese_Name__c='為替営業課' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS International Products Sales' ,Japanese_Name__c='外国債券営業課' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales' ,Japanese_Name__c='円債' ,Role_Level__c='Combination Team' ,AutoOpptyForPerson__c=FALSE ,AutoOpptyForDesk__c=FALSE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)' ,Japanese_Name__c='先オプ' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=TRUE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage' ,Japanese_Name__c='SPM二課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Team Head - JIFS Fixed Income Sales' ,Japanese_Name__c='国内債券営業課' ,Role_Level__c='Team Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Desk Head - JFPS' ,Japanese_Name__c='GM3' ,Role_Level__c='Desk Head' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales' ,Japanese_Name__c='公共法人' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=TRUE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales' ,Japanese_Name__c='SPM一課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke' ,Japanese_Name__c='SPM三課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=FALSE ,AutoOpptyForTeam__c=FALSE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales' ,Japanese_Name__c='為替営業課' ,Role_Level__c='Team' ,AutoOpptyForPerson__c=TRUE ,AutoOpptyForDesk__c=TRUE ,AutoOpptyForTeamAndCoveringPeopleInDesk__c=TRUE ,AutoOpptyForTeam__c=TRUE ,AutoOpptyForCoveringPeopleInDesk__c=TRUE)
        };
        //System.assertEquals(25, [select count() from JapanDesk__c]);
        
        List<JapanDesk__c> desks = [select Name ,Japanese_Name__c ,Role_Level__c ,AutoOpptyForPerson__c ,AutoOpptyForDesk__c ,AutoOpptyForTeamAndCoveringPeopleInDesk__c ,AutoOpptyForTeam__c ,AutoOpptyForCoveringPeopleInDesk__c from JapanDesk__c order by ID];
        /*System.assertEquals('Japan - FI - Team Head - JIFS LDN Japan Risk (Japan)' ,desks[0].Name);
        System.assertEquals('LDN Japan Risk' ,desks[0].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[0].Role_Level__c);
        System.assertEquals(TRUE ,desks[0].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[0].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[0].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[0].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[0].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Desk Head - JIFS' ,desks[1].Name);
        System.assertEquals('GM1' ,desks[1].Japanese_Name__c);
        System.assertEquals('Desk Head' ,desks[1].Role_Level__c);
        System.assertEquals(TRUE ,desks[1].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[1].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[1].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[1].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[1].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Fixed Income Sales' ,desks[2].Name);
        System.assertEquals('国内債券営業課' ,desks[2].Japanese_Name__c);
        System.assertEquals('Team' ,desks[2].Role_Level__c);
        System.assertEquals(TRUE ,desks[2].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[2].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[2].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[2].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[2].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS FID F&O (Japan)' ,desks[3].Name);
        System.assertEquals('先オプ' ,desks[3].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[3].Role_Level__c);
        System.assertEquals(TRUE ,desks[3].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[3].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[3].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[3].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[3].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS Yen Rates Sales' ,desks[4].Name);
        System.assertEquals('円金利営業課' ,desks[4].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[4].Role_Level__c);
        System.assertEquals(TRUE ,desks[4].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[4].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[4].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[4].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[4].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Yen Derivative Sales' ,desks[5].Name);
        System.assertEquals('円債' ,desks[5].Japanese_Name__c);
        System.assertEquals('Combination Team' ,desks[5].Role_Level__c);
        System.assertEquals(FALSE ,desks[5].AutoOpptyForPerson__c);
        System.assertEquals(FALSE ,desks[5].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[5].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[5].AutoOpptyForTeam__c);
        System.assertEquals(FALSE ,desks[5].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS Yen Derivative Sales' ,desks[6].Name);
        System.assertEquals('金利デリバティブ営業課' ,desks[6].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[6].Role_Level__c);
        System.assertEquals(TRUE ,desks[6].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[6].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[6].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[6].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[6].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Yen Rates Sales' ,desks[7].Name);
        System.assertEquals('円金利営業課' ,desks[7].Japanese_Name__c);
        System.assertEquals('Team' ,desks[7].Role_Level__c);
        System.assertEquals(TRUE ,desks[7].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[7].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[7].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[7].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[7].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Yen Derivative Sales' ,desks[8].Name);
        System.assertEquals('金利デリバティブ営業課' ,desks[8].Japanese_Name__c);
        System.assertEquals('Team' ,desks[8].Role_Level__c);
        System.assertEquals(TRUE ,desks[8].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[8].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[8].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[8].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[8].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Fixed Income Sales' ,desks[9].Name);
        System.assertEquals('円債' ,desks[9].Japanese_Name__c);
        System.assertEquals('Combination Team' ,desks[9].Role_Level__c);
        System.assertEquals(FALSE ,desks[9].AutoOpptyForPerson__c);
        System.assertEquals(FALSE ,desks[9].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[9].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[9].AutoOpptyForTeam__c);
        System.assertEquals(FALSE ,desks[9].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI Sales - Region Head' ,desks[10].Name);
        System.assertEquals('FI' ,desks[10].Japanese_Name__c);
        System.assertEquals('Region Head' ,desks[10].Role_Level__c);
        System.assertEquals(FALSE ,desks[10].AutoOpptyForPerson__c);
        System.assertEquals(FALSE ,desks[10].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[10].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[10].AutoOpptyForTeam__c);
        System.assertEquals(FALSE ,desks[10].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS LDN Japan Risk (Japan)' ,desks[11].Name);
        System.assertEquals('LDN Japan Risk' ,desks[11].Japanese_Name__c);
        System.assertEquals('Team' ,desks[11].Role_Level__c);
        System.assertEquals(TRUE ,desks[11].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[11].AutoOpptyForDesk__c);
        System.assertEquals(TRUE ,desks[11].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[11].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[11].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS International Products Sales' ,desks[12].Name);
        System.assertEquals('外国債券営業課' ,desks[12].Japanese_Name__c);
        System.assertEquals('Team' ,desks[12].Role_Level__c);
        System.assertEquals(TRUE ,desks[12].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[12].AutoOpptyForDesk__c);
        System.assertEquals(TRUE ,desks[12].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[12].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[12].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS Public Sector Instit Sales' ,desks[13].Name);
        System.assertEquals('公共法人' ,desks[13].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[13].Role_Level__c);
        System.assertEquals(TRUE ,desks[13].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[13].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[13].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[13].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[13].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS Foreign Exchange Sales' ,desks[14].Name);
        System.assertEquals('為替営業課' ,desks[14].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[14].Role_Level__c);
        System.assertEquals(TRUE ,desks[14].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[14].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[14].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[14].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[14].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS International Products Sales' ,desks[15].Name);
        System.assertEquals('外国債券営業課' ,desks[15].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[15].Role_Level__c);
        System.assertEquals(TRUE ,desks[15].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[15].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[15].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[15].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[15].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Yen Rates Sales' ,desks[16].Name);
        System.assertEquals('円債' ,desks[16].Japanese_Name__c);
        System.assertEquals('Combination Team' ,desks[16].Role_Level__c);
        System.assertEquals(FALSE ,desks[16].AutoOpptyForPerson__c);
        System.assertEquals(FALSE ,desks[16].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[16].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[16].AutoOpptyForTeam__c);
        System.assertEquals(FALSE ,desks[16].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS FID F&O (Japan)' ,desks[17].Name);
        System.assertEquals('先オプ' ,desks[17].Japanese_Name__c);
        System.assertEquals('Team' ,desks[17].Role_Level__c);
        System.assertEquals(TRUE ,desks[17].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[17].AutoOpptyForDesk__c);
        System.assertEquals(TRUE ,desks[17].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[17].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[17].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JFPS Pension Funds Coverage' ,desks[18].Name);
        System.assertEquals('SPM二課' ,desks[18].Japanese_Name__c);
        System.assertEquals('Team' ,desks[18].Role_Level__c);
        System.assertEquals(TRUE ,desks[18].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[18].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[18].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[18].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[18].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Team Head - JIFS Fixed Income Sales' ,desks[19].Name);
        System.assertEquals('国内債券営業課' ,desks[19].Japanese_Name__c);
        System.assertEquals('Team Head' ,desks[19].Role_Level__c);
        System.assertEquals(TRUE ,desks[19].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[19].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[19].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[19].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[19].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Desk Head - JFPS' ,desks[20].Name);
        System.assertEquals('GM3' ,desks[20].Japanese_Name__c);
        System.assertEquals('Desk Head' ,desks[20].Role_Level__c);
        System.assertEquals(TRUE ,desks[20].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[20].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[20].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[20].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[20].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Public Sector Instit Sales' ,desks[21].Name);
        System.assertEquals('公共法人' ,desks[21].Japanese_Name__c);
        System.assertEquals('Team' ,desks[21].Role_Level__c);
        System.assertEquals(TRUE ,desks[21].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[21].AutoOpptyForDesk__c);
        System.assertEquals(TRUE ,desks[21].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[21].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[21].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JFPS Financial Instit Sales' ,desks[22].Name);
        System.assertEquals('SPM一課' ,desks[22].Japanese_Name__c);
        System.assertEquals('Team' ,desks[22].Role_Level__c);
        System.assertEquals(TRUE ,desks[22].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[22].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[22].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[22].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[22].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JFPS Structured Products Marke' ,desks[23].Name);
        System.assertEquals('SPM三課' ,desks[23].Japanese_Name__c);
        System.assertEquals('Team' ,desks[23].Role_Level__c);
        System.assertEquals(TRUE ,desks[23].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[23].AutoOpptyForDesk__c);
        System.assertEquals(FALSE ,desks[23].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(FALSE ,desks[23].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[23].AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals('Japan - FI - Sales - JIFS Foreign Exchange Sales' ,desks[24].Name);
        System.assertEquals('為替営業課' ,desks[24].Japanese_Name__c);
        System.assertEquals('Team' ,desks[24].Role_Level__c);
        System.assertEquals(TRUE ,desks[24].AutoOpptyForPerson__c);
        System.assertEquals(TRUE ,desks[24].AutoOpptyForDesk__c);
        System.assertEquals(TRUE ,desks[24].AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(TRUE ,desks[24].AutoOpptyForTeam__c);
        System.assertEquals(TRUE ,desks[24].AutoOpptyForCoveringPeopleInDesk__c);*/
    }
}