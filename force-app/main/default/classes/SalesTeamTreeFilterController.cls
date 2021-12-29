global without sharing class SalesTeamTreeFilterController {
    static string ROOT_NODE='TEAMS';
    
    @AuraEnabled
    public static String searchSalesTeam(String searchStringForTree)
    {
        system.debug(searchStringForTree);
        string jsonString = '';
        List<Sales_Team_for_Coverage__c> mapLevel3_mapping = new List<Sales_Team_for_Coverage__c>();
        Map<string, List<Tree>> mapLevel3 = new Map<string, List<Tree>>();
        
        string query = 'select Sales_Desk_Division__c,Sales_Desk_Region__c,Desk_Name__c,Sales_Team__c  from Sales_Team_for_Coverage__c where Sales_Desk_Region__c like \'%'+searchStringForTree+'%\' or Desk_Name__c like \'%'+searchStringForTree+'%\' or Sales_Team__c like \'%'+searchStringForTree+'%\'';
        List<Sales_Team_for_Coverage__c> solist  = CoverageDataWithoutSharingController.getSalesTeamStructureSOQL(searchStringForTree,query);
        system.debug(solist); 
        
        
        
        //----------------------------------------------------- Level 4 (Team) -----------------------------------------------------------------------------
        Set<string> salesTeamSet = new Set<string>();
        for(Sales_Team_for_Coverage__c level4 : solist)
        {
            //Sales_Team_for_Coverage__c level4 = (Sales_Team_for_Coverage__c)so;
            if(level4.Sales_Desk_Division__c!=null && level4.Sales_Desk_Region__c!=null && level4.Desk_Name__c!=null && level4.Sales_Team__c!=null)
            {
                string ID = level4.Sales_Desk_Division__c.trim() + level4.Sales_Desk_Region__c.trim() + level4.Desk_Name__c.trim() + level4.Sales_Team__c.trim();
                ID= ID.replaceAll( '\\s+', '');
                string parentID = level4.Sales_Desk_Division__c.trim() + level4.Sales_Desk_Region__c.trim() + level4.Desk_Name__c.trim();
                parentID= parentID.replaceAll( '\\s+', '');
                string picklistValue = level4.Sales_Desk_Division__c.trim() + '-' + level4.Sales_Desk_Region__c.trim() + '-' + level4.Desk_Name__c.trim();
                string parentDelimCodes = level4.Sales_Desk_Division__c.trim() + ':' + level4.Sales_Desk_Region__c.trim() + ':' + level4.Desk_Name__c.trim();
                string teamKey = level4.Sales_Desk_Division__c.trim() + '-' + level4.Sales_Desk_Region__c.trim() + '-' + level4.Desk_Name__c.trim() + '-'+level4.Sales_Team__c.trim(); 
                if(!salesTeamSet.contains(level4.Sales_Team__c.replaceAll( '\\s+', '')))
                {
                    Tree node = new Tree();
                    node.text = level4.Sales_Team__c;
                    node.id = ID;
                    node.parentId = parentID;
                    node.picklist = picklistValue;
                    node.parentDelimCodes = parentDelimCodes;
                    node.fieldApi =	'Sales_Team__c';	
                    node.teamKey = teamKey;
                    node.deskKey = '';
                    if(mapLevel3.get(parentID) == null)
                    {
                        mapLevel3.put(parentId,new List<Tree>{node});
                    }
                    else
                    {
                        mapLevel3.get(parentID).add(node);
                    }
                    salesTeamSet.add(level4.Sales_Team__c.replaceAll( '\\s+', ''));
                }
                
            }
            
            mapLevel3_mapping.add(level4);
            
        }
        
        //----------------------------------------------------- Level 3 (Desk)-----------------------------------------------------------------------------
        
        List<Sales_Team_for_Coverage__c> mapLevel2_mapping = new List<Sales_Team_for_Coverage__c>();
        Map<string, List<Tree>> mapLevel2 = new Map<string, List<Tree>>();
        Set<string> DeskNameSet = new Set<string>();
        for(Sales_Team_for_Coverage__c level3: mapLevel3_mapping)
        {
            if(level3.Sales_Desk_Division__c!=null && level3.Sales_Desk_Region__c!=null && level3.Desk_Name__c!=null)
            {
                string ID = level3.Sales_Desk_Division__c.trim() + level3.Sales_Desk_Region__c.trim() + level3.Desk_Name__c.trim();
                ID= ID.replaceAll( '\\s+', '');
                string parentID = level3.Sales_Desk_Division__c.trim() + level3.Sales_Desk_Region__c.trim();
                parentID= parentID.replaceAll( '\\s+', '');
                string picklistValue = level3.Sales_Desk_Division__c.trim() + '-' + level3.Sales_Desk_Region__c.trim();
                string parentDelimCodes = level3.Sales_Desk_Division__c.trim() + ':' + level3.Sales_Desk_Region__c.trim();
                string deskKey = level3.Sales_Desk_Division__c.trim() + '-' + level3.Sales_Desk_Region__c.trim() + '-' + level3.Desk_Name__c.trim(); 
                
                if(!DeskNameSet.contains(level3.Desk_Name__c.replaceAll( '\\s+', '')))
                {
                    Tree node = new Tree();
                    node.text = level3.Desk_Name__c;
                    node.id = ID;
                    node.parentId = parentID;
                    node.picklist = picklistValue;
                    node.parentDelimCodes = parentDelimCodes;
                    node.fieldApi =	'Desk_Name__c';						
                    node.children = mapLevel3.get(ID);
                    node.deskKey = deskKey;
                    node.teamKey = '';
                    if(mapLevel2.get(parentID) == null)
                    {
                        mapLevel2.put(parentId,new List<Tree>{node});
                    }
                    else
                    {
                        mapLevel2.get(parentID).add(node);
                    } 
                    DeskNameSet.add(level3.Desk_Name__c.replaceAll( '\\s+', ''));
                }
            }
            mapLevel2_mapping.add(level3);
            
        }
        
        mapLevel3 = null;
        
        //----------------------------------------------------- Level 2 -----------------------------------------------------------------------------
        List<Sales_Team_for_Coverage__c> mapLevel1_mapping = new List<Sales_Team_for_Coverage__c>();
        Map<string, List<Tree>> mapLevel1 = new Map<string, List<Tree>>();
        Set<string> DeskRegionSet = new Set<string>();
        
        for(Sales_Team_for_Coverage__c level2: mapLevel2_mapping)
        {
            if(level2.Sales_Desk_Division__c!=null && level2.Sales_Desk_Region__c!=null)
            {
                string ID = level2.Sales_Desk_Division__c.trim() + level2.Sales_Desk_Region__c.trim();
                ID= ID.replaceAll( '\\s+', '');
                string parentID = level2.Sales_Desk_Division__c.trim();
                parentID= parentID.replaceAll( '\\s+', '');
                string picklistValue = level2.Sales_Desk_Division__c.trim();
                string parentDelimCodes = level2.Sales_Desk_Division__c.trim();
                
                if(!DeskRegionSet.contains(level2.Sales_Desk_Division__c.replaceAll( '\\s+', '')+level2.Sales_Desk_Region__c.replaceAll( '\\s+', '')))
                {
                    Tree node = new Tree();
                    node.text = level2.Sales_Desk_Region__c;
                    node.id = ID;
                    node.parentId = parentID;
                    node.picklist = picklistValue;
                    node.parentDelimCodes = parentDelimCodes;
                    node.children = mapLevel2.get(ID);
                    node.deskKey = '';
                    node.teamKey = '';
                    node.fieldApi =	'Sales_Desk_Region__c';						
                    
                    if(mapLevel1.get(parentID) == null)
                    {
                        mapLevel1.put(parentId,new List<Tree>{node});
                    }
                    else
                    {
                        mapLevel1.get(parentID).add(node);
                    }
                    DeskRegionSet.add(level2.Sales_Desk_Division__c.replaceAll( '\\s+', '')+level2.Sales_Desk_Region__c.replaceAll( '\\s+', ''));
                }
            }
            mapLevel1_mapping.add(level2);
        }
        
        //----------------------------------------------------- Level 1 -----------------------------------------------------------------------------
        Set<string> DivisionSet = new Set<string>();
        List<Tree> mainChilds = new List<Tree>();
        for(Sales_Team_for_Coverage__c level1: mapLevel1_mapping)
        {
            if(level1.Sales_Desk_Division__c!=null)
            {
                string ID = level1.Sales_Desk_Division__c.trim();
                ID= ID.replaceAll( '\\s+', '');
                if(!DivisionSet.contains(level1.Sales_Desk_Division__c.replaceAll( '\\s+', '')))
                {
                    Tree node = new Tree();
                    node.text = level1.Sales_Desk_Division__c;
                    node.id = ID;
                    node.parentId = 'SALESTEAM';
                    node.fieldApi =	'Sales_Desk_Division__c';						
                    node.children = mapLevel1.get(ID);
                    node.deskKey = '';
                    node.teamKey = '';
                    mainChilds.add(node);
                    DivisionSet.add(level1.Sales_Desk_Division__c.replaceAll( '\\s+', ''));
                }
            }
        }
        
        mapLevel3 = null;
        mapLevel2 = null;
        mapLevel1 = null;
        DeskNameSet = null;
        DeskRegionSet = null;
        DivisionSet=null;
        salesTeamSet = null;
        mapLevel1_mapping = null;
        mapLevel2_mapping = null;
        mapLevel3_mapping = null;
        //----------------------------------------------------- Level 0 - ROOT -----------------------------------------------------------------------------
        List<Tree> salesTeamTreeList = new List<Tree>();
        if(solist.size() > 0 && solist!=null)
        {
            Tree node = new Tree();
            node.text = ROOT_NODE;
            node.children = mainChilds;
            node.fieldApi =	'Sales_Team_for_Coverage__c';						
            salesTeamTreeList.add(node);
        }
        system.debug(JSON.serialize(salesTeamTreeList));
        jsonString = JSON.serialize(salesTeamTreeList);
        mainChilds = null;
        return jsonString;
        //return '[{"text":"SALES TEAM","picklist":null,"parentId":null,"parentDelimCodes":null,"parent":null,"id":"SALESTEAM","children":[{"text":"Fixed Income","picklist":null,"parentId":"SALESTEAM","parentDelimCodes":null,"parent":null,"id":"Fixed Income","children":[{"text":"Japan","picklist":"Fixed Income","parentId":"FixedIncome","parentDelimCodes":"Fixed Income","parent":null,"id":"Japan","children":[{"text":"JIFS","picklist":"Fixed Income-Japan","parentId":"FixedIncomeJapan","parentDelimCodes":"Fixed Income:Japan","parent":null,"id":"JIFS","children":[{"text":"JIFS","picklist":"Fixed Income-Japan-JIFS","parentId":"FixedIncomeJapanJIFS","parentDelimCodes":"Fixed Income:Japan:JIFS","parent":null,"id":"JIFS","children":null}]},{"text":"JIFS Macro Sales","picklist":"Fixed Income-Japan","parentId":"FixedIncomeJapan","parentDelimCodes":"Fixed Income:Japan","parent":null,"id":"JIFS Macro Sales","children":[{"text":"JIFS Macro Sales","picklist":"Fixed Income-Japan-JIFS Macro Sales","parentId":"FixedIncomeJapanJIFSMacroSales","parentDelimCodes":"Fixed Income:Japan:JIFS Macro Sales","parent":null,"id":"JIFS Macro Sales","children":null}]},{"text":"JIFS LDN Japan Risk (Japan)","picklist":"Fixed Income-Japan","parentId":"FixedIncomeJapan","parentDelimCodes":"Fixed Income:Japan","parent":null,"id":"JIFS LDN Japan Risk (Japan)","children":[{"text":"JIFS LDN Japan Risk (Japan)","picklist":"Fixed Income-Japan-JIFS LDN Japan Risk (Japan)","parentId":"FixedIncomeJapanJIFSLDNJapanRisk(Japan)","parentDelimCodes":"Fixed Income:Japan:JIFS LDN Japan Risk (Japan)","parent":null,"id":"JIFS LDN Japan Risk (Japan)","children":null}]},{"text":"JIFS Foreign Exchange Sales","picklist":"Fixed Income-Japan","parentId":"FixedIncomeJapan","parentDelimCodes":"Fixed Income:Japan","parent":null,"id":"JIFS Foreign Exchange Sales","children":[{"text":"JIFS Foreign Exchange Sales","picklist":"Fixed Income-Japan-JIFS Foreign Exchange Sales","parentId":"FixedIncomeJapanJIFSForeignExchangeSales","parentDelimCodes":"Fixed Income:Japan:JIFS Foreign Exchange Sales","parent":null,"id":"JIFS Foreign Exchange Sales","children":null}]},{"text":"JIFS Yen Derivative Sales","picklist":"Fixed Income-Japan","parentId":"FixedIncomeJapan","parentDelimCodes":"Fixed Income:Japan","parent":null,"id":"JIFS Yen Derivative Sales","children":[{"text":"JIFS Yen Derivative Sales","picklist":"Fixed Income-Japan-JIFS Yen Derivative Sales","parentId":"FixedIncomeJapanJIFSYenDerivativeSales","parentDelimCodes":"Fixed Income:Japan:JIFS Yen Derivative Sales","parent":null,"id":"JIFS Yen Derivative Sales","children":null}]},{"text":"JIFS Yen Rates Sales","picklist":"Fixed Income-Japan","parentId":"FixedIncomeJapan","parentDelimCodes":"Fixed Income:Japan","parent":null,"id":"JIFS Yen Rates Sales","children":[{"text":"JIFS Yen Rates Sales","picklist":"Fixed Income-Japan-JIFS Yen Rates Sales","parentId":"FixedIncomeJapanJIFSYenRatesSales","parentDelimCodes":"Fixed Income:Japan:JIFS Yen Rates Sales","parent":null,"id":"JIFS Yen Rates Sales","children":null}]}]}]}]}]'; 
    }
 	 global Class Tree implements GenericInterface{
        public Object text;
        public Object id;
        public Object parentId;
        public Object picklist;
        public string fieldApi;
        public String parentDelimCodes;
        public string teamKey;
        public string deskKey;
        public List<Tree> children;
        public TreeNode parent;
    }   
}