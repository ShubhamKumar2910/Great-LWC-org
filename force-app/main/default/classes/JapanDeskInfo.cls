public class JapanDeskInfo {
    private static Map<String, JapanDesk__c> roleNameToDeskMap;
    private static Map<String, Set<ID>> combiRoleNameToIdsMap;
    private static Map<String, JapanDesk__c> combiNameToTopDeskMap;
    private static Map<String, Set<JapanDesk__c>> combiNameToDesksMap;
    private static Map<ID, Set<JapanDesk__c>> combiIdToDesksMap;
    private static Map<ID, JapanDesk__c> combiIdToTopDeskMap;
    private static Map<String, Set<ID>> combiRoleNameToIdsMapForTrigger; // SALES-3115
    public static final String Team = 'Team';
    public static final String TeamHead = 'Team Head';
    public static final String DeskHead = 'Desk Head';
    public static final String RegionHead = 'Region Head';
    public static final String CombiTeam = 'Combination Team';
    
    public static void init(){
        roleNameToDeskMap = new Map<String, JapanDesk__c>();
        combiRoleNameToIdsMap = new Map<String, Set<Id>>();
        combiNameToTopDeskMap = new Map<String, JapanDesk__c>();
        combiNameToDesksMap = new Map<String, Set<JapanDesk__c>>();
        combiIdToDesksMap = new Map<ID, Set<JapanDesk__c>>();
        combiIdToTopDeskMap = new Map<ID, JapanDesk__c>();
        combiRoleNameToIdsMapForTrigger = new Map<String, Set<Id>>(); // SALES-3115
        
        List<JapanDesk__c> desks = [SELECT Id, Name, Japanese_Name__c, Role_Level__c, AutoOpptyForPerson__c, AutoOpptyForTeam__c, AutoOpptyForCoveringPeopleInDesk__c, AutoOpptyForTeamAndCoveringPeopleInDesk__c, AutoOpptyForDesk__c, IsForCoveringPeopleUnderRole__c, IsAutoOpportunityTrigger__c FROM JapanDesk__c ORDER BY Id]; // SALES-3115
        for(JapanDesk__c desk : desks){
            if(desk.Role_Level__c == CombiTeam){
                // ** Combination Desk Infomation **
                
                // Get Representative Desk
                JapanDesk__c topDesk = combiNameToTopDeskMap.get(desk.Japanese_Name__c);
                if(topDesk == null){
                    topDesk = desk;
                    // Create Map between each Combination Desk Name (Japanese) to its Representative Desk
                    combiNameToTopDeskMap.put(topDesk.Japanese_Name__c, topDesk);
                    // Create Map between each Combination ID (which is ID of the representative desk) to its Representative Desk
                    combiIdToTopDeskMap.put(topDesk.Id, topDesk);
                }
                
                // Create Map between each Combination Desk Name (Japanese) to All of its Combination Desks (which have the same name)
                if(!combiNameToDesksMap.containsKey(desk.Japanese_Name__c)){
                    combiNameToDesksMap.put(desk.Japanese_Name__c, new Set<JapanDesk__c>());
                }
                combiNameToDesksMap.get(desk.Japanese_Name__c).add(desk);
                
                // Create Map between each Combination ID to All of its Combination Desks
                if(!combiIdToDesksMap.containsKey(topDesk.Id)){
                    combiIdToDesksMap.put(topDesk.Id, new Set<JapanDesk__c>());
                }
                combiIdToDesksMap.get(topDesk.Id).add(desk);
                
                // Create Map between each Role Name to All IDs of its Combination Desks
                if(!combiRoleNameToIdsMap.containsKey(desk.Name)){
                    combiRoleNameToIdsMap.put(desk.Name, new Set<Id>());
                }
                combiRoleNameToIdsMap.get(desk.Name).add(topDesk.Id);
                
                // SALES-3115 For trigger
                if(desk.IsAutoOpportunityTrigger__c == TRUE){
                    if(!combiRoleNameToIdsMapForTrigger.containsKey(desk.Name)){
                        combiRoleNameToIdsMapForTrigger.put(desk.Name, new Set<Id>());
                    }
                    combiRoleNameToIdsMapForTrigger.get(desk.Name).add(topDesk.Id);
                }
            }
            else{
                // ** Normal Desk Infomation **
                // Create Map between each Role Name to its Desk
                roleNameToDeskMap.put(desk.Name, desk);
            }
        }
    }
    
    // Get Desk
    public static JapanDesk__c getDeskByRoleName(String roleName){
        JapanDesk__c ret = roleNameToDeskMap.get(roleName);

        // Create default object if not exist
        if(ret == null){
            ret = new JapanDesk__c();
            ret.Name = roleName;
            ret.AutoOpptyForPerson__c = false;
            ret.AutoOpptyForTeam__c = false;
            ret.AutoOpptyForTeamAndCoveringPeopleInDesk__c = false;
            ret.AutoOpptyForCoveringPeopleInDesk__c = false;
        }

        // Set Japanese Name if null
        if(ret.Japanese_Name__c == null){
            ret.Japanese_Name__c = ret.Name.replaceAll('^[^-]+ - [^-]+ - [^-]+ - ', '').trim().replaceAll('^(JFMD|JFPS|JIFS)', '').trim();
        }

        // Set Role Level if null
        if(ret.Role_Level__c == null){
            if(ret.Name.contains('Team Head')){
                ret.Role_Level__c = TeamHead;
            }
            else if(ret.Name.contains('Desk Head')){
                ret.Role_Level__c = DeskHead;
            }
            else if(ret.Name.contains('Region Head')){
                ret.Role_Level__c = RegionHead;
            }
            else{
                ret.Role_Level__c = Team;
            }
        }
        return ret;
    }
    
    // Get Japanese Desk Name
    public static String getJpNameByRoleName(String roleName){
        return getDeskByRoleName(roleName).Japanese_Name__c;
    }
    
    // Get Combination Desks
    public static Set<JapanDesk__c> getCombiDesksById(ID combiId){
        Set<JapanDesk__c> ret = combiIdToDesksMap.get(combiId);
        return (ret != null) ? ret : new Set<JapanDesk__c>();
    }
    
    // Get Top Desk in Combination Desks
    public static JapanDesk__c getCombiTopDeskById(ID combiId){
        return combiIdToTopDeskMap.get(combiId);
    }
    
    // Get Japanese Desk Name of Combination Desks
    public static String getCombiNameById(ID combiId){
        JapanDesk__c desk = getCombiTopDeskById(combiId);
        return (desk != null) ? desk.Japanese_Name__c : '';
    }
    
    // Get IDs of Combination Desks
    public static Set<ID> getCombiIdsByRoleName(String roleName){
        Set<ID> ret = combiRoleNameToIdsMap.get(roleName);
        return (ret != null) ? ret : new Set<ID>();
    }
    
    // Get IDs of Combination Desks for trigger
    public static Set<ID> getCombiIDsByRoleNameForTrigger(String roleName){
        Set<ID> ret = combiRoleNameToIdsMapForTrigger.get(roleName);
        return (ret != null) ? ret : new Set<ID>();
    }
}