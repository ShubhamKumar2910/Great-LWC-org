public with sharing class CoverageToolController {
    static string userRegion; 
    public static string isCommentAccessible = 'false';
    public static Boolean isEquityUser = false;
    
    @AuraEnabled 
    public static Boolean isUserRoleAEJResearch()
    {
        List<User> userdata = [select id, UserRole.Name,Profile.Name from User where Id =: UserInfo.getUserId() 
                         and ((UserRole.Name like 'AEJ%' or UserRole.Name in('Japan - EQ - Team Head - Corporate Access','Japan - EQ - Desk Head - Corporate Access','Japan - EQ - Sales - Corporate Access')) and   Profile.Name='Nomura - Research') limit 1]; 
        if(userdata.size()>0)
        {
            return true;
        }
        return false;
    }
    public static Set<Id> getUserRoleAEJResearchBySalesCodeOwnerId(Set<Id> salescodeOwnerIds)
    {
        Set<Id> salesCodeOwnerResearchMap = new Set<Id>();
        List<User> userdata = [select id, UserRole.Name,Profile.Name from User where Id  in:salescodeOwnerIds 
                         and (UserRole.Name like 'AEJ%' and  Profile.Name='Nomura - Research')];
        for(User u: userdata)
        {
            salesCodeOwnerResearchMap.add(u.id);
        }
        return salesCodeOwnerResearchMap;
    }
    
    @AuraEnabled 
    public  static string getCurrentUserSalesCode()
    {
        string salesCodeId = '';
        List<User> userdata = [select id, Login_Id__c from User where Id =: UserInfo.getUserId() limit 1];
        system.debug(userdata);
        if(userdata.size() == 1)
        {
            List<Sales_Team_for_Coverage__c> salescodedata = [select id,Sales_Desk_Region__c, Sales_Desk_Division__c,Coverage_ID__c,Sales_Code_Login_ID__c from Sales_Team_for_Coverage__c where Active__c = true and
                                                              Sales_Code_Login_ID__c =: userdata[0].Login_Id__c];
            system.debug(salescodedata);
            if(salescodedata.size()>=1)
            {
                salesCodeId = salescodedata[0].id;
                salesCodeId = salescodedata[0].id+'#'+salescodedata[0].Sales_Desk_Division__c+'#'+salescodedata[0].Sales_Desk_Region__c;
                return salesCodeId; 
            }
            
            
        }
        return salesCodeId;
    }
    
    @AuraEnabled
    public static List<CommonTools.MultiselectWrapper> getNFPEPicklistValues(){
        return CommonTools.getNFPEPicklistValues();
    }
     
    public static void setEquityUserFlagforGroupRevenues()
    {
        Set<Id> usersIdsInGroup= new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        List<GroupMember> groupMembers=[Select Id, group.type, UserOrGroupId From GroupMember where group.DeveloperName='Restrict_Coverage_Screen_Revenue_Access'];
        for(GroupMember gm : groupMembers)
        {
            if(string.valueOf(gm.UserOrGroupId).startsWithIgnoreCase(userType))
                usersIdsInGroup.add(gm.UserOrGroupId);
        }
        if(usersIdsInGroup.contains(UserInfo.getUserId()))
            isEquityUser = true;
        
    }
    
    @AuraEnabled
    public static String isCommentAccessible(){ //true:r = only read permission, //true:rw = read and write permission
        User callingUser = [SELECT Id,Region__c,UserRole.Name,Profile.Name FROM User WHERE Id = : UserInfo.getUserId()] ;  
        if(callingUser.UserRole.Name.toUpperCase().contains('- EQ -') || callingUser.UserRole.Name.toUpperCase().contains('- EQ SALES'))
            isEquityUser = true;
        
        if(callingUser.UserRole.Name.toUpperCase().contains('- FI -') || callingUser.UserRole.Name.toUpperCase().contains('- FI SALES'))
            isEquityUser = false;
        
        setEquityUserFlagforGroupRevenues();
        if(callingUser.Region__c!=null)
        { 
            if(callingUser.Region__c.toLowerCase() == 'japan' && callingUser.Profile.Name == 'Nomura - Business Management')
            {
                isCommentAccessible = 'true:rw';
                return isCommentAccessible; 
            }
            else if(callingUser.Region__c.toLowerCase() == 'japan' && callingUser.Profile.Name != 'Nomura - Business Management')
            {
                isCommentAccessible = 'true';
                return isCommentAccessible; 
            }
        }
        
      return 'false';
    }
    
    
    
    @AuraEnabled
    public static String isUploadButtonSeen(){
        List<Profile> profile = [SELECT Name FROM Profile WHERE Id=: UserInfo.getProfileId()];
        Set<string> accessProfiles = new Set<string>();
        boolean showButton = true;
        
        if(profile.size()== 1 && !isUserRoleAEJResearch() && profile[0].Name == 'Nomura - Research' )
            showButton = false;
        
        
        for(Profile_View_Access__c coverageProfiles: [SELECT Id, Profile_Name__c,hasBulkUploadAccess__c FROM Profile_View_Access__c]){
            if(coverageProfiles.Profile_Name__c!=null && coverageProfiles.hasBulkUploadAccess__c)
                accessProfiles.add(coverageProfiles.Profile_Name__c);
        }
        
        if(accessProfiles.contains(string.valueOf(profile[0].Name)) && showButton){
            return 'true';
        }
        else
        {
            return 'false';
        }
    }    
    @AuraEnabled
    public static CoverageToolResult getCoverageDataSearch( string[] clientIDS,string include,string[] clientType, 
                                                           string[] pGroups, string[] pRegions, string[] products,
                                                           string[] role, string[] salesPersonIDS, string isAndOR, string[] salesTeam,string level,Decimal softLimit,
                                                           Boolean isInit, Boolean allCoverages, string[] salesPersonUserLoginIds, string salesTeamTree,boolean isClone,
                                                           List<string> types,STRING startdate_clone
                                                          )
    {
        try
        {
            isCommentAccessible();
            system.debug('Started Processing At: ');
            system.debug(DateTime.now());
       		system.debug('Role: ');
            system.debug(role);
    		system.debug('types: '+types);
                system.debug('isClone: '+isClone);
            system.debug('salesPersonIDS: ');
            system.debug(salesPersonIDS);
            system.debug('allCoverages : '+allCoverages);
            system.debug('isInit : '+isInit);
            system.debug('salesPersonUserLoginIds: '+salesPersonUserLoginIds);
            //changed for 3646
            /*Block of code getting salescode Ids from SalesTeamUser for Joint SalesCode*/
            //Set<string> setLoginIds = new Set<string>();
            /*for(Sales_Team_for_Coverage__c code: CoverageDataWithoutSharingController.getSalesCodeDetails(salesPersonIDS))
            {
               
                if(!code.is_Dummy__c && code.Sales_Code_Login_ID__c!=null)
                //if(code.Sales_Code_Login_ID__c!=null) 
                    setLoginIds.add(code.Sales_Code_Login_ID__c);
            } */
           // system.debug('setLoginIds : '+ setLoginIds);
            //set<Id> userIds = CoverageDataWithoutSharingController.getUserIdsbyLoginId(salesPersonUserLoginIds);
            Set<string> newSalesPersonIDS = new Set<string>();
            Set<string> setLoginIds = new Set<string>();
            setLoginIds.addall(salesPersonUserLoginIds);
            system.debug('userIds : '+ setLoginIds); 
            for(Sales_Team_User__c userData: CoverageDataWithoutSharingController.getSalesTeamUser2(setLoginIds))
            {
                 newSalesPersonIDS.add(userData.Sales_Team_for_Coverage__c);
            }
            system.debug('newSalesPersonIDS : '+ newSalesPersonIDS);
            /****************************************************************************************************/
            
            
           if(allCoverages && isInit)
           {
                
                CoverageToolResult resultData = new CoverageToolResult();
                resultData.exceptionMsg = 'NoMessage';
                return resultData;
            }
            
            Boolean containsFilter = false;
            string userId = UserInfo.getUserId();
           
            Set<string> salesDivisions = new Set<string>();
            Set<string> salesRegions = new Set<string>();
            Set<string> salesDesks = new Set<string>();
            Set<string> salesTeams = new Set<string>();
            Set<string> fieldAPIs = new Set<string>();
            Set<string> teamKeys = new Set<string>();
            Set<string> deskKeys = new Set<string>();
            Set<string> root_team = new Set<string>();

            List<MultiselectTree> salesTeamTreeList = new List<MultiselectTree>();
            if(salesTeamTree!=null && salesTeamTree!='')
                salesTeamTreeList = (List<MultiselectTree>) JSON.deserialize(salesTeamTree, List<MultiselectTree>.class);
            if(salesTeamTreeList!=null){
                for(MultiselectTree team:salesTeamTreeList)
                {
                    system.debug(team);
                    if(team.text!=null){
                        if(team.fieldApi == 'Desk_Name__c')
                        {
                            if(team.text!='')
                                salesDesks.add(string.valueOf(team.text));
                            
                        }
                        if(team.fieldApi == 'Sales_Team__c')
                        {
                            if(team.text!='')
                                salesTeams.add(string.valueOf(team.text));
                        }
                        if(team.fieldApi == 'Sales_Desk_Region__c')
                        {
                            if(team.text!='')
                                salesRegions.add(string.valueOf(team.text));
                        }
                        
                        if(team.fieldApi == 'Sales_Desk_Division__c' && team.text!='')
                            salesDivisions.add(string.valueOf(team.text));
                        
                        fieldAPIs.add(string.valueOf(team.fieldApi));
                    }
                    if(team.teamKey!=null && team.teamKey!='')
                    {
                        teamKeys.add(team.teamKey);
                    }
                    if(team.deskKey!=null && team.deskKey!='')
                    {
                        deskKeys.add(team.deskKey);
                    }
                    
                    if(team.text!=null && team.text=='TEAMS')
                        root_team.add('TEAMS');
                }
            }
            
            system.debug('teamkeys:');
            system.debug(teamKeys);
            User callingUser = [SELECT Id,User_Profile_Name__c,Name, Region__c FROM User WHERE Id = : UserInfo.getUserId()] ;  
            if(callingUser.Region__c!=null)
                userRegion = callingUser.Region__c;
            
            if(newSalesPersonIDS.size()>0)
                salesPersonIDS.addAll(newSalesPersonIDS);
            system.debug('salesPersonIDS 2::'+salesPersonIDS);
            system.debug('1');
            if(salesTeam.size() > 0)
            {
                if(salesDivisions.size() > 0 || salesRegions.size() > 0 || root_team.size() > 0 )
                {
                    CoverageToolResult resultData = new CoverageToolResult();
                    resultData.exceptionMsg = 'Search results are more than allowed. Please refine your search criteria.';
                    resultData.csvString = CoverageToolDataController.csvString;
                    resultData.csvKeys = CoverageToolDataController.csvKeys;
                    resultData.doNotShowRevenueColumns = CoverageToolDataController.doNotShowRevenueColumns;
                    system.debug('3');
                    return resultData;
                }
            } 
            system.debug('2');
            /************* COMMON FILTERS *****************************/
            string customWhereClause = '';
             string entityCriteriaStandard = 'NFPE_Primary_Relationship_Coverage__c = false and NFPE_Primary_Product_Coverage__c = false and NFPE_Overseas_Authorised_Coverage__c = false)';
       
            
            String whereTypeClause = ' where (';
            Integer i = 1;
            for(string ctype: types){
                if(ctype.toLowerCase()!='standard'){
                    if(whereTypeClause == ' where (')
                        whereTypeClause += ctype.replace(' ','_')+'__c=true ';
                    else
                        whereTypeClause += ' or '+ctype.replace(' ','_')+'__c=true ';
                } 
                else if(i >= 1 && ctype.toLowerCase() == 'standard')
                {
                     if(whereTypeClause == ' where (')
                     {
                         whereTypeClause += ' and (';
                         if(types.size() == 1)
                         {
							whereTypeClause = whereTypeClause.replace( 'and (', '')  ;                           
                         }
                     }
                    else
                        whereTypeClause += ' or (';
                    whereTypeClause += ' '+ entityCriteriaStandard;
                }
                i++;
            }
            
            
            
            if(whereTypeClause!='' && types.size()>0)
            {
                boolean skip = false;
                if(types.size()==1 && types[0].toLowerCase()=='standard')
                    skip = true;
                if(!skip){
                    whereTypeClause = whereTypeClause + ') ';
                    customWhereClause = whereTypeClause;
                }
                else
                {
                    customWhereClause = whereTypeClause;
                }
            }
			
             system.debug(whereTypeClause);
           
            
            
            if(clientIDS.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Account__r.Parent.Id in:clientIDS';
                else
                    customWhereClause += ' and Account__r.Parent.Id in:clientIDS';
                
                containsFilter = true;
            }
            
            if(clientType.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Account__r.Parent.Sales_Client_Type__c in:clientType';
                else
                    customWhereClause += ' and Account__r.Parent.Sales_Client_Type__c in:clientType';
                
                containsFilter = true;
            }
            
            if(pGroups.size() > 0 && level == 'Product')
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product_Group__c in:pGroups';
                else
                    customWhereClause += ' and Product_Group__c in:pGroups';
                containsFilter = true;
            }
            
            if(pRegions.size() > 0 && level == 'Product')
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product_Region__c in:pRegions';
                else
                    customWhereClause += ' and Product_Region__c in:pRegions';
                containsFilter = true;
            }
            
            if(products.size() > 0 && level == 'Product')
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product2__c in:products';
                else
                    customWhereClause += ' and Product2__c in:products';
                containsFilter = true;
            }
            
            if(isClone)
            {
                List<string> salescode_company_to_exclude = CoverageUtil.salescode_company_to_exclude;		      
                List<string> productsaccessforInstinet = CoverageUtil.productsWithRegionsToIncludeForInstinet;
                
                if(customWhereClause == '')
                    customWhereClause += ' where (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) ';
                else
                    customWhereClause += ' and (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) ';
                containsFilter = true;
            }
                
            if(role.size() > 0 && !isClone)
            { 
                if(customWhereClause == '')
                    customWhereClause += ' where Team_Role__c in:role';
                else
                    customWhereClause += ' and Team_Role__c in:role';
                
                containsFilter = true;
            }
            
            if(salesPersonIDS.size() > 0 || salesTeam.size()>0)
            {
                if(customWhereClause.contains('where'))
                {  customWhereClause += ' and ';}
                else
                {customWhereClause += ' where ';}
                
                if(salesPersonIDS.size() == 0 && salesTeam.size()>0)
                {
                    if(salesDesks.size() > 0 && salesTeams.size() > 0)
                        customWhereClause += ' (Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys or Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys) ';
                    else if(salesDesks.size() > 0 && salesTeams.size() == 0)
                        customWhereClause += '  Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys ';
                    else if(salesDesks.size() == 0 && salesTeams.size() > 0)
                        customWhereClause += '  Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys ';
                    containsFilter = true;
                }
                else if(salesPersonIDS.size() > 0 && salesTeam.size() == 0)
                {   
                    if(customWhereClause.contains('where')){
                        customWhereClause +=' Sales_Team_for_Coverage__c in:salesPersonIDS';
                        containsFilter = true;
                    }
                    else
                    {
                        customWhereClause +=' Sales_Team_for_Coverage__c in:salesPersonIDS';
                        containsFilter = true;
                    }
                }
                else
                {
                    if(salesDesks.size() > 0 && salesTeams.size() > 0)
                        customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' (Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys or Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys)) ';
                    else if(salesDesks.size() > 0 && salesTeams.size() == 0)
                        customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys) ';
                    else if(salesDesks.size() == 0 && salesTeams.size() > 0)
                        customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys) ';
                    containsFilter = true;
                    
                }
                
            }
            
           
            List<CoverageDataWrapper> wrapperlist = new List<CoverageDataWrapper>();
            if(level == 'Client' && !isClone) //CLIENT
            {		
                    wrapperlist = CoverageToolDataController.getCoverage(clientIDS,include,clientType, 
                                                                                    pGroups, pRegions,  products,
                                                                                    role,  salesPersonIDS, isAndOR,  salesTeam,level,softLimit,
                                                                                    isInit, allCoverages,true,customWhereClause,salesDivisions,salesRegions,salesDesks,salesTeams,fieldAPIs,teamKeys,deskKeys,userRegion,types);
               
            }
            else if(level == 'Product' && !isClone)//PRODUCT
            {		
                    wrapperlist = CoverageToolDataController.getCoverage(clientIDS,include,clientType, 
                                                                                     pGroups, pRegions,  products,
                                                                                     role,  salesPersonIDS, isAndOR,  salesTeam,level,softLimit,
                                                                                     isInit, allCoverages,true,customWhereClause,salesDivisions,salesRegions,salesDesks,salesTeams,fieldAPIs,teamKeys,deskKeys,userRegion,types);
                    
            }
            else if(isClone && level == 'Client')
            {	
                List<CoverageDataWrapper> dataList = new List<CoverageDataWrapper>(); 
                dataList.addAll(CoverageToolDataController.getCoverage(clientIDS,include,clientType, 
                                                                       pGroups, pRegions,  products,
                                                                       null,  salesPersonIDS, isAndOR,  salesTeam,level,softLimit,
                                                                       isInit, allCoverages,true,customWhereClause,salesDivisions,salesRegions,salesDesks,salesTeams,fieldAPIs,teamKeys,deskKeys,userRegion,types));
                level = 'Product'; 
                dataList.addAll(CoverageToolDataController.getCoverage(clientIDS,include,clientType, 
                                                                                          pGroups, pRegions,  products,
                                                                                          null,  salesPersonIDS, isAndOR,  salesTeam,level,softLimit,
                                                                                          isInit, allCoverages,true,customWhereClause,salesDivisions,salesRegions,salesDesks,salesTeams,fieldAPIs,teamKeys,deskKeys,userRegion,types));
                
                Map<string,List<string>> csv_Keys = new Map<string,List<string>>();
                Set<string> Keys = new Set<string>();
                Map<string,CoverageDataWrapper> csv_Wrapper = new Map<string,CoverageDataWrapper>();
                for(CoverageDataWrapper wrapperCloned: dataList){
                    string productGroup = '';
                    string product = '';
                    string productRegion = '';
                    string rgOrgId = wrapperCloned.rgOrgID;
                    string role1 = wrapperCloned.role;
                    Date startDate =  wrapperCloned.startDate;
                    string key = rgOrgId+'#'+wrapperCloned.CoverageId;
                    if(wrapperCloned.product!=null && wrapperCloned.product!=''){
                        productGroup = wrapperCloned.productGroup;
                        product = wrapperCloned.product;
                        productRegion = wrapperCloned.productRegion;
                    }
                    system.debug(role);
                    if(role!=null && role.size()==1)
                    wrapperCloned.role = role[0];
                    string prodKey = key +'#'+productGroup+'#'+product+'#'+productRegion;
                    csv_Wrapper.put(prodKey,wrapperCloned);
                }
               
                if(csv_Wrapper.size()>0)
                {
                    dataList.clear();
                    for(CoverageDataWrapper cw:csv_Wrapper.values()){
                        Boolean remove = false;
                        if(cw.product!=null && cw.product!=''){
                            string key = cw.rgOrgId+'#'+cw.CoverageId+'###';
                            if(csv_Wrapper.keyset().contains(key)){
                            	csv_Wrapper.remove(key);    
                                remove = true;
                            }
                            
                        }
                    }
                }
                
                if(csv_Wrapper.size()>0)
                {
                    List<CoverageDataWrapper> rgList = new List<CoverageDataWrapper>();
                    List<CoverageDataWrapper> rmList = new List<CoverageDataWrapper>();
                    List<CoverageDataWrapper> nfpeList = new List<CoverageDataWrapper>();
                    List<CoverageDataWrapper> overallData = new List<CoverageDataWrapper>();
                    overallData = CoverageToolTrsferController.getProductLevelData(JSON.serialize(csv_Wrapper.values()), 'active', 'Client',true,false);
                    for(CoverageDataWrapper clonedata: overallData){
                        clonedata.accountName = clonedata.accountName.toUpperCase();
                        if(clonedata.coverageType!=null && clonedata.coverageType !='Standard' && clonedata.coverageType!='')
                        {nfpeList.add(clonedata);clonedata.rgOrgID = '';}
                        else if(clonedata.coverageType!=null && clonedata.coverageType =='Standard' && clonedata.rmRestricted!=null && clonedata.rmRestricted)
                        {	 rmList.add(clonedata); clonedata.rgOrgID = '';}
                        else
                        {rgList.add(clonedata);clonedata.rmOrgID = '';}
                        if(role!=null && role.size()==1)
                            clonedata.role = role[0];
                        IF(startdate_clone!=null && startdate_clone!='')
                            clonedata.startDate = date.valueOf(startdate_clone);
                    }
                    overallData.clear();
                    csv_Wrapper.clear();
                    if(rmList.size()>0)
                    wrapperList.addAll(rmList);
                    if(nfpeList.size()>0)
                    wrapperList.addAll(nfpeList);
                    if(rgList.size()>0)
                    wrapperList.addAll(rgList);
                    
                }
            }
            
            
            CoverageToolResult resultData = new CoverageToolResult();
            system.debug('softLimit: '+softLimit);
            system.debug('wrapperlist.size(): '+wrapperlist.size());
            
            if((wrapperlist.size()<=softLimit || softLimit == null) && wrapperlist.size()!=0)
            {
                resultData.dataBody = wrapperlist; 
                resultData.dataFooter = null;
                if(level == 'Client') //CLIENT
                {
                    resultData.YTDSummary = CoverageToolDataController.YTDSummary;
                    resultData.YTDBudgetSummary = CoverageToolDataController.YTDBudgetSummary;
                    resultData.WTDSummary = CoverageToolDataController.WTDSummary;
                    resultData.MTDSummary = CoverageToolDataController.MTDSummary;
                }
                resultData.userRegion = CoverageToolDataController.userRegion;
                resultData.csvString = CoverageToolDataController.csvString;
                resultData.csvKeys = CoverageToolDataController.csvKeys;
                resultData.doNotShowRevenueColumns = CoverageToolDataController.doNotShowRevenueColumns;
                
                return resultData;
            }
            else if(wrapperlist.size()>=softLimit && wrapperlist.size()!=0)
            {
                resultData.exceptionMsg = 'Search results are more than allowed. Please refine your search criteria.';
                resultData.csvString = CoverageToolDataController.csvString;
                resultData.csvKeys = CoverageToolDataController.csvKeys;
                resultData.doNotShowRevenueColumns = CoverageToolDataController.doNotShowRevenueColumns;
                return resultData;
            }
            else if(wrapperlist.size() == 0)
            {
                resultData.exceptionMsg = 'Coverage data not found. Please refine your search criteria.';
                resultData.csvString = CoverageToolDataController.csvString;
                resultData.csvKeys = CoverageToolDataController.csvKeys;
                resultData.doNotShowRevenueColumns = CoverageToolDataController.doNotShowRevenueColumns;
                return resultData;
            }
            
            //}
        }
        catch(Exception e)
        {
            system.debug(e);
            system.debug(e.getStackTraceString());
            CoverageToolResult resultData = new CoverageToolResult();
            resultData.exceptionMsg = e.getMessage()+e.getStackTraceString();
            resultData.csvString = CoverageToolDataController.csvString;
            resultData.csvKeys = CoverageToolDataController.csvKeys;
            resultData.doNotShowRevenueColumns = CoverageToolDataController.doNotShowRevenueColumns;
            return resultData;
        }
        
        
        return null;
    }
    
   
    @AuraEnabled 
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        return PicklistFieldController.getDependentOptionsImpl(objApiName, contrfieldApiName, depfieldApiName);
    }
    
    @AuraEnabled 
    public static List<string> getProductRegionsSetfromCoverageAccessObject()
    {
        Set<string> productRegionSet = new Set<string>();
        Schema.DescribeFieldResult fieldResult1 = Coverage_Access_Request__c.Product__c.getDescribe();
        for(Schema.Picklistentry pe:fieldResult1.getPicklistValues())
        {
            productRegionSet.add(pe.getvalue().toLowerCase());
            system.debug('Product Region Set: '+pe.getvalue().toLowerCase());
        }
        
        list<string> productRegionList = new list<string>();
        if(productRegionSet.size()>0)
            productRegionList.addAll(productRegionSet);
        return productRegionList;
    }
     
    @AuraEnabled
    public static List<CoverageDataWrapper> getSelectedAddCoverages(string[] clientIDS,string[] salesTeamCoverageIds, 
                                                                    string pGroup, string pRegion, string[] products,
                                                                    string role, boolean isAttested,string startdate,string comments, List<string> coverageTypes)
    {
        return CoverageToolDataController.getSelectedAddCoverages(clientIDS,salesTeamCoverageIds, pGroup, pRegion,  products, role, isAttested, startdate,comments,coverageTypes,null,null,null,'','ADD',null);
    }
    
    @AuraEnabled
    public static CoverageToolResult getExistingCoveragesExcludingSalesCode( string product, string productRegion,
                                                                            string productGroup, string salesCodeId, 
                                                                            string clientId, boolean isRM , boolean isRG,string salesteam,string coverageType,string subType
                                                                           ) 
    {
        
        List<CoverageDataWrapper> wrapperlist = CoverageToolDataController.getExistingCoveragesExcludingSalesCode(product, productRegion,
                                                                                                                  productGroup, salesCodeId, 
                                                                                                                  clientId, isRM , isRG,salesteam,coverageType,subType);
        setEquityUserFlagforGroupRevenues();
        if(wrapperlist.size()!=0)
        {
            CoverageToolResult resultData = new CoverageToolResult();
            resultData.dataBody = wrapperlist;
            resultData.dataFooter = null;
            resultData.userRegion = CoverageToolDataController.userRegion;
            resultData.doNotShowRevenueColumns = isEquityUser;
            return resultData;
        }
         return null;
    }
    
    @AuraEnabled
    public static BulkUploaderCoverageWrapper validateCoverageData (string jsonData){ 
        system.debug(jsonData);
         //added for JIRA 1588
        return CoverageBulkUploadController.processImportFromTool(jsonData,'CVGTOOL');
    }
    
    @AuraEnabled
    public static string submitCoverageData (List<Coverage_Temp__c> successList,List<RG_Coverage_Request__c> rgDeleteList,List<Coverage_Access_Request__c> rmDeleteList,Integer totalCount,string guid){
        return CoverageBulkUploadController.submitPartialData(successList,totalCount, guid);
    }
    
    
     @AuraEnabled 
    public static List<PicklistDataWrapper> getSourceOptionsImpl(string objApiName , string picklistfieldName){
        List<PicklistDataWrapper> datalist = new List<PicklistDataWrapper>();
        
        Map<String,String> sourceMap = PicklistFieldController.getSourceOptionsImpl(objApiName, picklistfieldName);
       
        if(sourceMap!=null)
        {
            PicklistDataWrapper obj = new PicklistDataWrapper();
            if(picklistfieldName!='Team_Role__c' && picklistfieldName!='Role__c' && picklistfieldName!='Product_Group__c' && picklistfieldName!='Product_Region__c' && picklistfieldName!='Type__c'){
                obj.id = 'None';
                obj.text = 'None';
                datalist.add(obj);
            }
            
            for(String key: sourceMap.keySet())
            {
                obj = new PicklistDataWrapper();
                boolean addToList = true;
                if(picklistfieldName=='Type__c' && sourceMap.get(key) == 'Cross Sell Referral')
                addToList = false;
                
                 system.debug(picklistfieldName);
                 system.debug(sourceMap.get(key));
                
                if(addToList){
                    obj.id = key;
                    obj.text = sourceMap.get(key);
                    datalist.add(obj);
                }
            }
        }
        return datalist;
    }
    
    @AuraEnabled 
    public static String getSourceOptionsJSON(string objApiName , string picklistfieldName){
        List<PicklistDataWrapper> datalist = new List<PicklistDataWrapper>();        
        datalist = getSourceOptionsImpl(objApiName , picklistfieldName);
        system.debug('JSON.serialize(datalist)');
        system.debug(JSON.serialize(datalist));
        return JSON.serialize(datalist);
    }
    
    @AuraEnabled 
    public static String getClientTypesJSON(string objApiName , string picklistfieldName){
        List<PicklistDataWrapper> datalist = new List<PicklistDataWrapper>();
        datalist = getDistinctClientType();
        return JSON.serialize(datalist);
    }
    
    @AuraEnabled
    public static List<PicklistDataWrapper> getDistinctClientType()
    {
        List<PicklistDataWrapper> datalist = new List<PicklistDataWrapper>();
        
        /*Set<String> uniqueTypes = new Set<String>();
        List<AggregateResult> accountList = [SELECT Sales_Client_Type__c FROM Account Where RecordType.Name = 'RG Account' and  Active__c = true Group by Sales_Client_Type__c limit 1000];
        for(AggregateResult record: accountList)
        {
            if(record.get('Sales_Client_Type__c')!=null && record.get('Sales_Client_Type__c')!='')
                uniqueTypes.add(string.valueOf(record.get('Sales_Client_Type__c')));
        }
        
        accountList = null;*/
        Map<String,String> picklistValues = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.Sales_Client_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry picklist : picklistEntry)
        {
            picklistValues.put(picklist.getValue(),picklist.getLabel());
        }

        PicklistDataWrapper obj = new PicklistDataWrapper();
        obj.id = 'None';
        obj.text = 'None';
        datalist.add(obj);
        
        for(String ctype: picklistValues.keySet())
        {
            if(String.isNotBlank(picklistValues.get(ctype))){
                obj = new PicklistDataWrapper();
                obj.id = ''+ctype;
                obj.text = ''+picklistValues.get(ctype);
                datalist.add(obj);
            }
        }
        
        system.debug(LoggingLevel.WARN,datalist);
        return datalist;
    }
    
    @AuraEnabled
    public static String getSalesPersonData()
    {
        List<PicklistDataWrapper> datalist = new List<PicklistDataWrapper>();
        
        Set<String> uniqueTypes = new Set<String>();
        List<Sales_Team_for_Coverage__c> coverageList = [select Id,Name,Coverage_ID__c from Sales_Team_for_Coverage__c ];
        for(Sales_Team_for_Coverage__c record: coverageList)
        {
            PicklistDataWrapper obj = new PicklistDataWrapper();
            obj.id = ''+record.Id;
            obj.text = ''+record.Name;
            datalist.add(obj);
        }    
        return JSON.serialize(datalist);
    }
    
}