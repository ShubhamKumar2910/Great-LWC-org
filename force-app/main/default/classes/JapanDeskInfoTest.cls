@isTest
private class JapanDeskInfoTest {
    static void init(){
    }

    @testSetup
    static void setupTestData(){
        List<JapanDesk__c> desks = new List<JapanDesk__c>{
            // CombiTeam
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債'),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債'),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債2'),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='円債2'),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='外債'),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.CombiTeam, Japanese_Name__c='外債'),
            // DeskHead
            new JapanDesk__c(Name='Japan - FI - Desk Head - JIFS', Role_Level__c=JapanDeskInfo.DeskHead, Japanese_Name__c='GM1'),
            new JapanDesk__c(Name='Japan - FI - Desk Head - JFPS', Role_Level__c=JapanDeskInfo.DeskHead, Japanese_Name__c='GM3'),
            // Team
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='円金利営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=false, AutoOpptyForCoveringPeopleInDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='国内債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=false, AutoOpptyForCoveringPeopleInDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='外国債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=true, AutoOpptyForCoveringPeopleInDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS FID F&O (Japan)', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='外国債券営業課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=true, AutoOpptyForTeamAndCoveringPeopleInDesk__c=true, AutoOpptyForCoveringPeopleInDesk__c=true),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c=JapanDeskInfo.Team, Japanese_Name__c='SPM一課', AutoOpptyForPerson__c=true, AutoOpptyForTeam__c=false, AutoOpptyForTeamAndCoveringPeopleInDesk__c=false, AutoOpptyForCoveringPeopleInDesk__c=true)
        };
        insert desks;
    }
    
    static void loadTestData(){
    }

    @isTest 
    static void test(){
        JapanDesk__c desk;
        Set<ID> combiIds;
        ID combiId;
        Set<JapanDesk__c> desks;
        
        // init
        JapanDeskInfo.init();
        
        // getDeskByRoleName
        // - Not-exist case
        desk = JapanDeskInfo.getDeskByRoleName('Japan - FI - Sales - JIFS DUMMY DESK');
        System.assertEquals('Japan - FI - Sales - JIFS DUMMY DESK', desk.Name);
        System.assertEquals('DUMMY DESK', desk.Japanese_Name__c);
        System.assertEquals(false, desk.AutoOpptyForPerson__c);
        System.assertEquals(false, desk.AutoOpptyForTeam__c);
        System.assertEquals(false, desk.AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(false, desk.AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals(JapanDeskInfo.Team, desk.Role_Level__c);
        desk = JapanDeskInfo.getDeskByRoleName('Japan - FI - Team Head - JIFS DUMMY DESK');
        System.assertEquals(JapanDeskInfo.TeamHead, desk.Role_Level__c);
        desk = JapanDeskInfo.getDeskByRoleName('Japan - FI - Desk Head - JIFS DUMMY DESK');
        System.assertEquals(JapanDeskInfo.DeskHead, desk.Role_Level__c);
        desk = JapanDeskInfo.getDeskByRoleName('Japan - FI Sales DUMMY - Region Head');
        System.assertEquals(JapanDeskInfo.RegionHead, desk.Role_Level__c);

        // - Exist case
        desk = JapanDeskInfo.getDeskByRoleName('Japan - FI - Sales - JIFS International Products Sales');
        System.assertEquals('外国債券営業課', desk.Japanese_Name__c);
        System.assertEquals(true, desk.AutoOpptyForPerson__c);
        System.assertEquals(true, desk.AutoOpptyForTeam__c);
        System.assertEquals(true, desk.AutoOpptyForTeamAndCoveringPeopleInDesk__c);
        System.assertEquals(true, desk.AutoOpptyForCoveringPeopleInDesk__c);
        System.assertEquals(JapanDeskInfo.Team, desk.Role_Level__c);
        
        // getJpNameByRoleName
        System.assertEquals('円金利営業課', JapanDeskInfo.getJpNameByRoleName('Japan - FI - Sales - JIFS Yen Rates Sales'));
        
        // getCombiIdsByRoleName
        combiIds = JapanDeskInfo.getCombiIdsByRoleName('Japan - FI - Sales - JIFS Yen Rates Sales');
        System.assertEquals(2, combiIds.size());
        combiIds = JapanDeskInfo.getCombiIdsByRoleName('Japan - FI - Sales - JIFS FID F&O (Japan)');
        System.assertEquals(1, combiIds.size());
        
        for(ID i : combiIds){
            combiId = i;
            break;
        }
        
        // getCombiDesksById
        desks = JapanDeskInfo.getCombiDesksById(combiId);
        System.assertEquals(2, desks.size());
        
        // getCombiTopDeskById
        desk = JapanDeskInfo.getCombiTopDeskById(combiId);
        System.assertEquals('Japan - FI - Sales - JIFS International Products Sales', desk.Name);
        
        // getCombiNameById
        System.assertEquals('外債', JapanDeskInfo.getCombiNameById(combiId));
    }
}