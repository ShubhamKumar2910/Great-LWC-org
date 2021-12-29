@isTest
private class BatchUpdatingOpptysTargetIDsTest {
    private static String ForCombiTeam ='For Combination Team';
    private static String ForDesk ='For Desk';
    private static String ForTeam ='For Team';
    private static String ForCoveringPeopleInDesk ='For Covering People in Desk';
    private static String ForTeamAndCoveringPeople ='For Team + Covering People in Desk';
    private static String ForCombiTeamAndCoveringPeople ='For Combination Team + Covering People in Desk';
    
    private static List<Opportunity> opptys;
    private static List<JapanDesk__c> japanDesks;
    
    static void init(){
    }
    
    static void loadTestData(){
        opptys = [SELECT Id, Name, SystemAuto_Type__c, SystemAuto_Target_ID__c, LastModifiedDate FROM Opportunity ORDER BY Id];
        japanDesks = [SELECT Id, Name, Role_Level__c, Japanese_Name__c, IsForCoveringPeopleUnderRole__c, IsAutoOpportunityTrigger__c FROM JapanDesk__c ORDER BY Id];
    }
    
    @testSetup
    static void setupTestData(){
        UserRole deskHeadRole1 = [select Id, Name FROM UserRole where Name='Japan - FI - Desk Head - JFPS'];
        UserRole deskHeadRole2 = [select Id, Name from UserRole where Name='Japan - FI - Desk Head - JIFS'];
        UserRole teamMemberRole1 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Public Sector Instit Sales'];
        UserRole teamMemberRole2 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Fixed Income Sales'];
        UserRole teamMemberRole3 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Foreign Exchange Sales'];
        UserRole teamMemberRole4 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS International Products Sales'];
        UserRole teamMemberRole5 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)'];
		UserRole teamMemberRole6 = [select Id, Name from UserRole where Name='Japan - FI - Sales - JIFS Yen Rates Sales'];
        
        // User
       // User deskHead2 = [select Id, Name from User where UserRoleId=:deskHeadRole2.Id and IsActive=true limit 1];
//        User teamHead2 = [select Id, Name from User where UserRoleId=:teamHeadRole2.Id and IsActive=true limit 1];
        //User deskHead3 = [select Id, Name from User where UserRoleId=:deskHeadRole3.Id and IsActive=true limit 1]; // SALES-3115
        //User teamHead3 = [select Id, Name from User where UserRoleId=:teamHeadRole3.Id and IsActive=true limit 1]; // SALES-3115
    
        List<User> teamMembers = [select Id, Name from User where UserRoleId=:teamMemberRole1.Id and IsActive=true order by Id];
        
        // Acount
        RecordType art = [select Id from RecordType where Name = 'RM Account' and SobjectType = 'Account'];
        List<Account> accts = new List<Account>{
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 0', Local_Company_Name__c='顧客0', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street', ParentId = null),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 1', Local_Company_Name__c='顧客1', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 2', Local_Company_Name__c='顧客2', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 3', Local_Company_Name__c='顧客3', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=art.Id, Name='UpdateJapanOpptysBatchTest Account 4 - Inactive', Local_Company_Name__c='顧客4', Active__c=False,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street')
                
        };
        insert accts;
        
        RecordType gArt = [SELECT Id FROM RecordType WHERE Name = 'RG Account' and SobjectType = 'Account'];
        List<Account> gAccts = new List<Account>{
            new Account(RecordTypeId=gArt.Id, Name='UpdateJapanOpptysBatchTest RG Account 0', Local_Company_Name__c='顧客0 (G)', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street'),
            new Account(RecordTypeId=gArt.Id, Name='UpdateJapanOpptysBatchTest RG Account 1', Local_Company_Name__c='顧客0 (G)', Active__c=False,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street')
        };
        insert gAccts;
        
        accts[0].ParentId = gAccts[0].Id;
        accts[1].ParentId = gAccts[1].Id;
        update accts;
        
        
        List<JapanDesk__c> desks = new List<JapanDesk__c>{
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 0
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 3
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 11
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE), // 14
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE), // 21
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='GM3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='GM3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 24
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 25
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='円金利営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 26
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 27
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='金利デリバティブ営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), //28
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), //29
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='国内債券営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 30
            
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 31
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 34
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 41
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE), // 48
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='GM1＋GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='GM１/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='円債＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE)
        };
        insert desks;
        
        // Opportunity
        Date closeDate = Date.newInstance(2099, 12, 31);
        RecordType ort = [select Id from RecordType where Name = 'Automated' and SobjectType = 'Opportunity']; // SALES-3115
        List<Opportunity> opptys = new List<Opportunity>{
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 00', SystemAuto_Type__c='For Person', SystemAuto_Target_ID__c=teamMembers[0].Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id), // Out of Scope
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 01', SystemAuto_Type__c=ForDesk, SystemAuto_Target_ID__c=deskHeadRole1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 02', SystemAuto_Type__c=ForDesk, SystemAuto_Target_ID__c=deskHeadRole2.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 03', SystemAuto_Type__c=ForTeam, SystemAuto_Target_ID__c=teamMemberRole1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 04', SystemAuto_Type__c=ForTeam, SystemAuto_Target_ID__c=teamMemberRole2.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 05', SystemAuto_Type__c=ForTeam, SystemAuto_Target_ID__c=teamMemberRole3.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 06', SystemAuto_Type__c=ForTeam, SystemAuto_Target_ID__c=teamMemberRole4.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 07', SystemAuto_Type__c=ForTeam, SystemAuto_Target_ID__c=teamMemberRole5.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 08', SystemAuto_Type__c=ForTeam, SystemAuto_Target_ID__c=teamMemberRole6.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 09', SystemAuto_Type__c=ForCoveringPeopleInDesk, SystemAuto_Target_ID__c=deskHeadRole1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 10', SystemAuto_Type__c=ForCoveringPeopleInDesk, SystemAuto_Target_ID__c=deskHeadRole2.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 11', SystemAuto_Type__c=ForTeamAndCoveringPeople, SystemAuto_Target_ID__c=teamMemberRole1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 12', SystemAuto_Type__c=ForTeamAndCoveringPeople, SystemAuto_Target_ID__c=teamMemberRole2.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id), // Out of Scope
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 13', SystemAuto_Type__c=ForTeamAndCoveringPeople, SystemAuto_Target_ID__c=teamMemberRole3.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 14', SystemAuto_Type__c=ForTeamAndCoveringPeople, SystemAuto_Target_ID__c=teamMemberRole4.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 15', SystemAuto_Type__c=ForTeamAndCoveringPeople, SystemAuto_Target_ID__c=teamMemberRole5.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 16', SystemAuto_Type__c=ForTeamAndCoveringPeople, SystemAuto_Target_ID__c=teamMemberRole6.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),  // Out of Scope   
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 17', SystemAuto_Type__c=ForCombiTeamAndCoveringPeople, SystemAuto_Target_ID__c=desks[0].Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id),
            new Opportunity(AccountId=accts[0].Id, RecordTypeId=ort.Id, Name='Oppty - 18', SystemAuto_Type__c=ForCombiTeam, SystemAuto_Target_ID__c=desks[0].Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting', Account__c = gAccts[0].Id), // Out of Scope
            new Opportunity(AccountId=accts[2].Id, RecordTypeId=ort.Id, Name='Oppty - 19', SystemAuto_Type__c=ForDesk, SystemAuto_Target_ID__c=deskHeadRole1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting'), // RG Account is Inactive, Out of Scope
            new Opportunity(AccountId=accts[2].Id, RecordTypeId=ort.Id, Name='Oppty - 20', SystemAuto_Type__c=ForDesk, SystemAuto_Target_ID__c=deskHeadRole1.Id, CloseDate=closeDate, Active__c=true, StageName='Prospecting') // Account__c is empty, Out of Scope    
        };       
        insert opptys;
    }
    
    @isTest
    static void testLoadTestData(){
        loadTestData();
        System.assertequals(21, opptys.size());
        System.assertequals(160, japanDesks.size());
    }
    
    @isTest
    static void testBatchUpdatingOpptysTargetIDs(){
        loadTestData();
        
        Test.startTest();
        
        BatchUpdatingOpptysTargetIDs batch = new BatchUpdatingOpptysTargetIDs();
        ID batchprocessid = Database.executeBatch(batch);
        
        Test.stopTest();
        
        
        List<Opportunity> updatedOpptys = [SELECT Id, Name, SystemAuto_Type__c, SystemAuto_Target_ID__c, LastModifiedDate FROM Opportunity ORDER BY Id];
        List<JapanDesk__c> desks = [SELECT Id, Name, Role_Level__c, Japanese_Name__c, IsForCoveringPeopleUnderRole__c, IsAutoOpportunityTrigger__c FROM JapanDesk__c ORDER BY Id];
        
        
        // Oppty 00 - no update
        System.assertequals('For Person', updatedOpptys[0].SystemAuto_Type__c);
        
        // Oppty 01
        System.assertequals(ForCombiTeam, updatedOpptys[1].SystemAuto_Type__c);
        System.assertEquals(desks[11].Id, updatedOpptys[1].SystemAuto_Target_ID__c);
        
        // Oppty 02
        System.assertequals(ForCombiTeam, updatedOpptys[2].SystemAuto_Type__c);
        System.assertEquals(desks[3].Id, updatedOpptys[2].SystemAuto_Target_ID__c);
        
        // Oppty 03
        System.assertequals(ForCombiTeam, updatedOpptys[3].SystemAuto_Type__c);
        System.assertEquals(desks[29].Id, updatedOpptys[3].SystemAuto_Target_ID__c);
        
        // Oppty 04
        System.assertequals(ForCombiTeam, updatedOpptys[4].SystemAuto_Type__c);
        System.assertEquals(desks[30].Id, updatedOpptys[4].SystemAuto_Target_ID__c);
        
        // Oppty 09
        System.assertequals(ForCombiTeam, updatedOpptys[9].SystemAuto_Type__c);
        System.assertEquals(desks[21].Id, updatedOpptys[9].SystemAuto_Target_ID__c);
        
        // Oppty 11
        System.assertequals(ForCombiTeam, updatedOpptys[11].SystemAuto_Type__c);
        System.assertEquals(desks[48].Id, updatedOpptys[11].SystemAuto_Target_ID__c);
        
        // Oppty 17
        System.assertequals(ForCombiTeam, updatedOpptys[17].SystemAuto_Type__c);
        System.assertEquals(desks[34].Id, updatedOpptys[17].SystemAuto_Target_ID__c);
    }
    
    @isTest
    static void testInsertUpdateCombinationTeams(){
        // init - delete
        List<JapanDesk__c> desks = [SELECT Id, Name, Japanese_Name__c FROM JapanDesk__c WHERE Role_Level__c = 'Combination Team' AND Japanese_Name__c != '円債'];
        System.assertEquals(157, desks.size());
        delete desks;
        // init - update
        List<JapanDesk__c> yenDesks = [SELECT Id, Name, Japanese_Name__c FROM JapanDesk__c WHERE Role_Level__c = 'Combination Team' AND Japanese_Name__c = '円債'];
        System.assertequals(3, yenDesks.size());
        for(JapanDesk__c d : yenDesks){
            d.IsAutoOpportunityTrigger__c = false;
                }
        update yenDesks;
        
		
		DateTime now = DateTime.now();        
        BatchUpdatingOpptysTargetIDs batch = new BatchUpdatingOpptysTargetIDs();
        batch.insertUpdateCombinationTeam();
        
        List<JapanDesk__c> insertedDesks = [SELECT Id, Name, Japanese_Name__c, Role_Level__c FROM JapanDesk__c WHERE CreatedDate >=:now];
        List<JapanDesk__c> updatedDesks = [SELECT Id, Name, Japanese_Name__c, Role_Level__c, IsAutoOpportunityTrigger__c FROM JapanDesk__c WHERE CreatedDate <:now];
        
        System.assertEquals(171, insertedDesks.size());
        for(JapanDesk__c d : insertedDesks){
            System.assertEquals('Combination Team', d.Role_Level__c);
        }
        System.assertEquals(3, updatedDesks.size());
        for(JapanDesk__c d : updatedDesks){
            System.assertEquals('Combination Team', d.Role_Level__c);
            System.assertEquals(true, d.IsAutoOpportunityTrigger__c);
        }
      
    }
	
}