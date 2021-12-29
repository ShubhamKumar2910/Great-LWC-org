global class BatchUpdatingOpptysTargetIDs implements Database.Batchable<sObject> {
    
    public String Query {get; set;}
    public List<Opportunity> UpdateOpptyRecords{get; set;}
    public Map<String, Id> deskMap{get; set;} 
    public Map<String, String> opptysKeyToJapanDeskMap{get; set;}
    
    String ForCombiTeam ='For Combination Team';
    String ForDesk ='For Desk';
    String ForTeam ='For Team';
    String ForCoveringPeopleInDesk ='For Covering People in Desk';
    String ForTeamAndCoveringPeople ='For Team + Covering People in Desk';
    String ForCombiTeamAndCoveringPeople ='For Combination Team + Covering People in Desk';
    
    global BatchUpdatingOpptysTargetIDs(){
        Query = 'SELECT Id, Name, SystemAuto_Type__c, SystemAuto_Target_ID__c FROM Opportunity WHERE Account.Active__c = true AND Account__r.Active__c = true AND SystemAuto_Type__c NOT IN (\'For Person\', \'For Combination Team\', \'\') AND RecordType.Name = \'Automated\' AND RecordType.SobjectType = \'Opportunity\' Order By Id';
		
        deskMap = new Map<String, ID>();        
        List<JapanDesk__c> desks = [SELECT Japanese_Name__c, Id FROM JapanDesk__c WHERE Role_Level__c = 'Combination Team' AND IsAutoOpportunityTrigger__c = true ORDER BY Id];
        for(JapanDesk__c desk : desks){
            if(!deskMap.containsKey(desk.Japanese_Name__c)){
                deskMap.put(desk.Japanese_Name__c, desk.Id);
                System.Debug('Key : ' + desk.Japanese_Name__c + ' and Value : ' + deskMap.get(desk.Japanese_Name__c));
            }
        }
        
        opptysKeyToJapanDeskMap = new Map<String, String>{
            	createKey(ForDesk, '00E28000000e02eEAA') => 'GM3', // Japan - FI - Desk Head - JFPS
				createKey(ForDesk, '00E28000000e02fEAA') => 'GM1', // Japan - FI - Desk Head - JIFS
                createKey(ForTeam, '00E28000000e02rEAA') => '公共法人', // Japan - FI - Sales - JIFS Public Sector Instit Sales
                createKey(ForTeam, '00E28000000e02yEAA') => '国内債券営業課',
                createKey(ForTeam, '00E28000000e02zEAA') => '為替営業課', // Japan - FI - Sales - JIFS Foreign Exchange Sales
                createKey(ForTeam, '00E28000000e030EAA') => '外国債券営業課', // Japan - FI - Sales - JIFS International Products Sales
                createKey(ForTeam, '00E28000000e031EAA') => 'LDN Japan Risk', // Japan - FI - Sales - JIFS LDN Japan Risk (Japan)
                createKey(ForTeam, '00E28000000e034EAA') => '円金利営業課',
                createKey(ForCoveringPeopleInDesk, '00E28000000e02eEAA') => 'GM3内担当者', // Japan - FI - Desk Head - JFPS
                createKey(ForCoveringPeopleInDesk, '00E28000000e02fEAA') => 'GM1内担当者', // Japan - FI - Desk Head - JIFS
                createKey(ForTeamAndCoveringPeople, '00E28000000e02rEAA') => '公共法人＋部内担当者', // Japan - FI - Sales - JIFS Public Sector Instit Sales
        		createKey(ForTeamAndCoveringPeople, '00E28000000e02zEAA') => '為替営業課＋部内担当者', // Japan - FI - Sales - JIFS Foreign Exchange Sales
                createKey(ForTeamAndCoveringPeople, '00E28000000e030EAA') => '外国債券営業課＋部内担当者', // Japan - FI - Sales - JIFS International Products Sales
                createKey(ForTeamAndCoveringPeople, '00E28000000e031EAA') => 'LDN Japan Risk＋部内担当者', // Japan - FI - Sales - JIFS LDN Japan Risk (Japan)
                createKey(ForCombiTeamAndCoveringPeople, deskMap.get('円債')) => '円債＋部内担当者'
                    };
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        SavePoint sp;
		UpdateOpptyRecords = new List<Opportunity>();
            for(sObject s : scope){
                Opportunity o = (Opportunity)s;
                System.debug('Opportunity Id:' + o.Id);
                System.debug('Opportunity Name:' + o.Name);
                System.debug('Opportunity SystemAuto_Type__c: '+ o.SystemAuto_Type__c);
                System.debug('Opportunity SystemAuto_Target_ID__c: '+ o.SystemAuto_Target_ID__c);
                
                if(opptysKeyToJapanDeskMap.containsKey(createKey(o))){
                    System.Debug(o.Name + ' will be updated. SystemAuto_Type__c => ' + ForCombiTeam + ', SystemAuto_Target_ID__c => ' + deskMap.get(opptysKeyToJapanDeskMap.get(createKey(o))));
                    o.SystemAuto_Target_ID__c = deskMap.get(opptysKeyToJapanDeskMap.get(createKey(o)));
                    o.SystemAuto_Type__c = ForCombiTeam;
                    System.Debug(o.Name + 'is in update list. SystemAuto_Type__c = ' + o.SystemAuto_Type__c + ', SystemAuto_Target_ID__c = ' + o.SystemAuto_Target_ID__c);
                    UpdateOpptyRecords.add(o);
                }
                else{
                    System.Debug('Opportunity out of scope. Id: ' + o.Id + ', Name : ' + o.Name);
                }
            }
            if(UpdateOpptyRecords.size()>0){
                System.debug(UpdateOpptyRecords.size() + ' Opptys will be updated.');
                update UpdateOpptyRecords;
            }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    private String createKey(String SystemAuto_Type, String SystemAuto_Target_ID){
        return SystemAuto_Type + SystemAuto_Target_ID;
    }
    
    private String createKey(Opportunity o){
        return createKey(o.SystemAuto_Type__c, o.SystemAuto_Target_ID__c);
    }
    
    public void insertUpdateCombinationTeam(){
        List<JapanDesk__c> desks = new List<JapanDesk__c>{
           
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan/AU - FI - Sales - JIFS Macro Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='GM1', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='GM3', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM1内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='GM3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='GM3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='GM3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='為替営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='円金利営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='金利デリバティブ営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='国内債券営業課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='SPM一課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='SPM三課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='円債＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='LDN Japan Risk＋部内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='公共法人＋部内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
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
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Public Sector Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Fixed Income Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Foreign Exchange Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Derivative Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS Yen Rates Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Financial Instit Sales', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Pension Funds Coverage', Role_Level__c='Combination Team', Japanese_Name__c='外国債券営業課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
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
            new JapanDesk__c(Name='Japan - FI - Sales - JFPS Structured Products Marke', Role_Level__c='Combination Team', Japanese_Name__c='SPM二課＋GM1/3内担当者', IsForCoveringPeopleUnderRole__c=TRUE, IsAutoOpportunityTrigger__c=FALSE),
                
            /* SALES-3377 */
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS International Products Sales', Role_Level__c='Combination Team', Japanese_Name__c='外債全拠点', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
            new JapanDesk__c(Name='Japan - FI - Sales - JIFS LDN Japan Risk (Japan)', Role_Level__c='Combination Team', Japanese_Name__c='外債全拠点', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
			new JapanDesk__c(Name='AEJ - FI - Sales - JPN Singapore', Role_Level__c='Combination Team', Japanese_Name__c='外債全拠点', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE),
			new JapanDesk__c(Name='Americas - FI - Sales - CB & Japan Sales', Role_Level__c='Combination Team', Japanese_Name__c='外債全拠点', IsForCoveringPeopleUnderRole__c=FALSE, IsAutoOpportunityTrigger__c=TRUE)
                
        };
        insert desks;
        
        List<JapanDesk__c> yenDesks = [SELECT Id, Name, Japanese_Name__c, Role_Level__c, AutoOpptyForPerson__c, IsAutoOpportunityTrigger__c, IsForCoveringPeopleUnderRole__c FROM JapanDesk__c  WHERE Japanese_Name__c = '円債'];
        System.Debug('Size of yen desks : ' + yenDesks.size());
		for(JapanDesk__c d : yenDesks){
			System.Debug(d.IsAutoOpportunityTrigger__c);
    		d.IsAutoOpportunityTrigger__c = true;
		}
		update yenDesks;
    }
}