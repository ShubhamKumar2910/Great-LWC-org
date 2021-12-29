public WITHOUT SHARING class CoverageMembersController {
    
    public CoverageMembersController( ){
        
    }
    @AuraEnabled
    public static List<CommonTools.MultiselectWrapper> getNFPEPicklistValues(){
        return CommonTools.getNFPEPicklistValues();
    }
    
     @AuraEnabled
    public static string getVisibilityCriteria(){
        return CoverageToolController.isCommentAccessible();
    }
    
    @AuraEnabled
    public static List<cvgCsvClassMember> getCoverageCsvData 
        (String AccountId,List<string> regions, List<string> products,List<string> entities)
    {
        if(regions.contains('Asia'))
            regions.add('aej');
        if(regions.contains('USA'))
            regions.add('americas');
        if(regions.contains('Europe'))
            regions.add('emea');
        List<cvgCsvClassMember> cvgMembers = new List<cvgCsvClassMember>();
        Set<Id> salesCodeOwnerId = new Set<Id>();
        Set<Id> researchsalesCodeOwnerId = new Set<Id>();
        string isCommentVisible = CoverageToolController.isCommentAccessible();
        string entityCriteriaStandard = 'NFPE_Primary_Relationship_Coverage__c = false and NFPE_Primary_Product_Coverage__c = false and NFPE_Overseas_Authorised_Coverage__c = false)';
        
        
        List<AggregateResult> cvgMembs = new List<AggregateResult>();
        List<IBD_Coverage__c> ibdCoverages = new List<IBD_Coverage__c>();
        
        string query = '';
        string groupby = '';
        string entitycriteria = '';
        
        Integer i = 1;
        for(string entity: entities){
            if(entity.toLowerCase() != 'standard'){
                if(entitycriteria=='')
                {
                    entitycriteria = ' AND ';
                    if(entities.size()>=1)
                        entitycriteria += ' (';
                    entitycriteria += entity.replace(' ','_') +'__c=true ';
                }
                
                else
                {
                    entitycriteria += ' OR ' + entity.replace(' ','_') +'__c = true';  
                    
                } 
            }
            else if(i >= 1 && entity.toLowerCase() == 'standard')
            {
                if(entitycriteria=='')
                    entitycriteria += ' and (';
                else
                    entitycriteria += ' or (';
                entitycriteria += ' '+ entityCriteriaStandard;
            }
            
            i++;
        }
        
        if(entitycriteria!='')
            entitycriteria +=')';
        
        system.debug(entitycriteria);
        if(entities.size() == 1 && entities[0] == 'standard')
            entitycriteria = entitycriteria.removeEnd(')');

        Account result = [SELECT RecordType.DeveloperName from Account Where Id =: AccountId];

        groupby = ' group by Account__r.ParentId, Sales_Team_for_Coverage__r.Name,Sales_Team_for_Coverage__r.Desk_Name__c,Sales_Team_for_Coverage__r.Coverage_ID__c, '+
                'Team_Role__c,Product__c,Product_Region__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c  order by Sales_Team_for_Coverage__r.Name';
        
        if(result.RecordType.DeveloperName == 'POD_Account' || result.RecordType.DeveloperName == 'RM_Account') {
            query = 'SELECT MIN(Account__r.RDM_Org_ID__c) RMORGID,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1 ,Sales_Team_for_Coverage__r.Name Name,Sales_Team_for_Coverage__r.Desk_Name__c SalesDesk,MIN(Sales_Team_for_Coverage__r.OwnerId) SalesCodeOwnerId,Sales_Team_for_Coverage__r.Coverage_ID__c salesCode, '+
            'MIN(Sales_Desk_Region__c) salesDeskRegion,MIN(Start_Date__c) startDate,MAX(Comment__c) comments,Team_Role__c Role,Product__c Product,Product_Region__c ProductRegion,Sales_Team_for_Coverage__r.Sales_Desk_Division__c Division FROM Coverage_Team_Member__c '+
            'WHERE Account__r.Id =: AccountId AND RecordType.Name  = \'Active Coverage\' AND Sales_Team_for_Coverage__r.Active__c = true ';
        }
            
        else {
            query = 'SELECT MIN(Account__r.RDM_Org_ID__c) RMORGID,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1 ,Sales_Team_for_Coverage__r.Name Name,Sales_Team_for_Coverage__r.Desk_Name__c SalesDesk,MIN(Sales_Team_for_Coverage__r.OwnerId) SalesCodeOwnerId,Sales_Team_for_Coverage__r.Coverage_ID__c salesCode, '+
            'MIN(Sales_Desk_Region__c) salesDeskRegion,MIN(Start_Date__c) startDate,MAX(Comment__c) comments,Team_Role__c Role,Product__c Product,Product_Region__c ProductRegion,Sales_Team_for_Coverage__r.Sales_Desk_Division__c Division FROM Coverage_Team_Member__c '+
            'WHERE Account__r.ParentId =: AccountId AND RecordType.Name  = \'Active Coverage\' AND Sales_Team_for_Coverage__r.Active__c = true ';
        }
        
        if(regions.size()>=1 && products.size()>=1){
            query += 'AND Product_Region__c in :regions AND Product__c in :products ';        
        }
        else if(regions.size()==0 && products.size()>=1){
            query += 'AND Product__c in:products ';
            
        }
        else if(regions.size()>=1 && products.size()==0){
            query += 'AND Product_Region__c in:regions ';
        }
        else{
            
            ibdCoverages = [SELECT Coverage_Member__r.Name ,Comment__c ,Coverage_Type__c, Region__c 
                            FROM IBD_Coverage__c WHERE Account__c =: AccountId];
        }
        
        
         if(entitycriteria!='')
        {
            query += entitycriteria;
            query += groupby;
        }
        else
        {
            if(entities.size()<=1 && entities.contains('Standard') || entitycriteria != '')
            {
                query += ' AND NFPE_Primary_Relationship_Coverage__c = false and NFPE_Primary_Product_Coverage__c = false and NFPE_Overseas_Authorised_Coverage__c = false ';
                query += groupby;
            }
            else
                query += groupby;
        }
        

        cvgMembs = (List<AggregateResult>) database.query(query);
        
        
        for(AggregateResult cvg : cvgMembs){
            salesCodeOwnerId.add(string.valueOf(cvg.get('SalesCodeOwnerId')));
        }
        if(salesCodeOwnerId.size()>0)
        {
          researchsalesCodeOwnerId = CoverageToolController.getUserRoleAEJResearchBySalesCodeOwnerId(salesCodeOwnerId); 
        } 
        
        
        Set<string> coverageType_key = new Set<string>();
        Map<string,cvgCsvClassMember> nfpeMap = new  Map<string,cvgCsvClassMember>();
        Map<string,string> rgPrimaryKey  = new Map<string,string>();
        Map<string,List<string>> nfpeKey = new Map<string,List<string>>();
        for(AggregateResult cvg : cvgMembs){
            if(!researchsalesCodeOwnerId.contains(string.valueOf(cvg.get('SalesCodeOwnerId'))))
            {
                if(cvg.get('Product')!=null)
                system.debug('csv Product: '+string.valueOf(cvg.get('Product')));
                             
                Boolean nfpe = false;
                Boolean nfpe_subtype1 = false;
                Boolean nfpe_subtype2 = false;
				Boolean nfpe_subtype3 = false;
                Boolean nfpe1 = false;
                string uniqueKey = '';
                
                if(CoverageUtil.FLAG_NFPE_SUBTYPE1!=null && CoverageUtil.FLAG_NFPE_SUBTYPE1!=''){
                    if(cvg.get('nfpetype1')!=null){
                        if(Boolean.valueOf(cvg.get('nfpetype1'))){
                            nfpe_subtype1 = true;
                        }
                    }
                }
                
                if(CoverageUtil.FLAG_NFPE_SUBTYPE2!=null && CoverageUtil.FLAG_NFPE_SUBTYPE2!=''){
                    if(cvg.get('nfpetype2')!=null){
                        if(Boolean.valueOf(cvg.get('nfpetype2'))){
                            nfpe_subtype2 = true;
                        }
                    }
                }
				
				if(CoverageUtil.FLAG_NFPE_SUBTYPE3!=null && CoverageUtil.FLAG_NFPE_SUBTYPE3!=''){
                    if(cvg.get('nfpetype3')!=null){
                        if(Boolean.valueOf(cvg.get('nfpetype3'))){
                            nfpe_subtype3 = true;
                        }
                    }
                }
                
                if(CoverageUtil.FLAG_NFPE1!=null && CoverageUtil.FLAG_NFPE1!=''){
                    if(cvg.get('nfpe1')!=null){
                        if(Boolean.valueOf(cvg.get('nfpe1'))){
                            nfpe1 = true;
                        }
                    }
                }
                
                if(cvg.get('uniqueKey')!=null)
                {
                    uniqueKey = string.valueOf(cvg.get('uniqueKey'));
                    uniqueKey = uniqueKey.trim().replace(string.valueOf(cvg.get('RMORGID')), string.valueOf(cvg.get('RGORGID')));
                }
                
                string[] key = uniqueKey.split('#');
                string modifiedKey = '';
                
                if(key.size() == 4)
                    modifiedKey = key[0]+'#'+key[1]+'#'+key[2];
                else
                    modifiedKey = key[0]+'#'+key[1]+'#'+key[2]+'#'+key[3]+'#'+ key[4];
                
                
                if(nfpe_subtype1 || nfpe1 || nfpe_subtype2 || nfpe_subtype3)
                {
                    if(nfpeKey.get(modifiedKey)==null && nfpe_subtype1)
                        nfpeKey.put(modifiedKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1});
                    else if(nfpeKey.get(modifiedKey)!=null && nfpe_subtype1)
                    {
                        if(!nfpeKey.get(modifiedKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE1_1))
                            nfpeKey.get(modifiedKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1_1);
                    }
                    
                    
                    if(nfpeKey.get(modifiedKey)==null && nfpe_subtype2)
                        nfpeKey.put(modifiedKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2});
                    else  if(nfpeKey.get(modifiedKey)!=null && nfpe_subtype2){
                        if(!nfpeKey.get(modifiedKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE2))
                            nfpeKey.get(modifiedKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE2);
                    }
					
					if(nfpeKey.get(modifiedKey)==null && nfpe_subtype3)
                        nfpeKey.put(modifiedKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
                    else  if(nfpeKey.get(modifiedKey)!=null && nfpe_subtype3){
                        if(!nfpeKey.get(modifiedKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE3_1))
                            nfpeKey.get(modifiedKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3_1);
                    }
					
                    
                    if(nfpeKey.get(modifiedKey)==null && nfpe1){
                        nfpeKey.put(modifiedKey,new List<string>{CoverageUtil.FLAG_NFPE1});
                    }
                    else if(nfpeKey.get(modifiedKey)!=null && nfpe1){
                        if(!nfpeKey.get(modifiedKey).contains(CoverageUtil.FLAG_NFPE1))
                            nfpeKey.get(modifiedKey).add(CoverageUtil.FLAG_NFPE1);
                    }
                    
                }
                
                cvgCsvClassMember cvgMem = new cvgCsvClassMember();
                cvgMem.Name = string.valueOf(cvg.get('Name'));
                cvgMem.SalesDesk = string.valueOf(cvg.get('SalesDesk'));
                cvgMem.SalesCode =  string.valueOf(cvg.get('salesCode'));
                cvgMem.SalesDeskRegion = String.valueOf(cvg.get('salesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(cvg.get('startDate'));
                cvgMem.Comment = string.valueOf(cvg.get('comments'));
                cvgMem.Role = String.valueOf(cvg.get('Role'));
                cvgMem.Product = String.valueOf(cvg.get('Product'));
                cvgMem.Region = String.valueOf(cvg.get('ProductRegion'));
                cvgMem.Division = String.valueOf(cvg.get('Division'));
                nfpeMap.put(modifiedKey,cvgMem);
            }
            
        }
        
        system.debug(nfpeKey);
        
        for(string key: nfpeKey.Keyset()){
            system.debug('Key: '+key);
            string s = '';
            for(string type1: nfpeKey.get(key)){
                if(s==''){
                    s = type1;
                }
                else
                {
                    s += ', '+type1;
                }
            }
            string[] key1 = key.split('#');
            string flag1	 = '';
            if(key1.size() == 4 || key1.size() == 2 ||key1.size() == 3 )
            {
                if(key1.size() == 2)
                flag1 = key1[0]+'#'+key1[1];
                else if(key1.size() > 2)
                   flag1 = key1[0]+'#'+key1[1] +'#'+key1[2]; 
            }
            else if(key1.size() >= 5){
                flag1 = key1[0]+'#'+key1[1]+'#'+key1[2]+'#'+key1[3]+'#'+ key1[4];
            }
                
            system.debug(flag1);
            
            if(nfpeMap.get(flag1)!=null)
            {
                //commented for JIRA SALES 3698
                ////////////////////////////nfpeMap.get(flag1).Type = s.toUpperCase();
            }
        }
         
        if(nfpeMap.size()>0){
            cvgMembers.addAll(nfpeMap.values());
        }
        
        for(IBD_Coverage__c ibd : ibdCoverages){
             cvgCsvClassMember cvgMem = new cvgCsvClassMember();
                cvgMem.Name = string.valueOf(ibd.Coverage_Member__r.Name);
            if(isCommentVisible.toLowerCase() == 'true:rw' || isCommentVisible.toLowerCase() == 'true'){
                cvgMem.Comment = string.valueOf(ibd.Comment__c);
            }
            else
            {
                cvgMem.Comment = '';
            }
               cvgMem.SalesDesk = string.valueOf(ibd.Coverage_Type__c);
                cvgMem.SalesDeskRegion = String.valueOf(ibd.Region__c); 
            cvgMem.Division = 'IBD';
                cvgMembers.add(cvgMem);
        }
        
    return cvgMembers;
        
    }
    
    @AuraEnabled
    public static List<CommonTools.MultiselectWrapper> getSourceOptionsJSON(string objApiName , string picklistfieldName){
        List<PicklistDataWrapper> datalist = new List<PicklistDataWrapper>(); 
        List<CommonTools.MultiselectWrapper> picklistValues = new List<CommonTools.MultiselectWrapper>();
        datalist = CoverageToolController.getSourceOptionsImpl(objApiName , picklistfieldName);
        for(PicklistDataWrapper p: datalist){
            CommonTools.MultiselectWrapper wp = new CommonTools.MultiselectWrapper();
            wp.label = p.text;
            wp.value = p.id;
            wp.selected = false;
            picklistValues.add(wp);
        }
        return picklistValues;
    }
    
    @AuraEnabled
    public static List<cvgClassMember> getCoverageData (String AccountId,
                                                        List<string> regions, 
                                                        List<string> products,
                                                        List<string> entities)
    {
        system.debug(regions);
        system.debug(products);
        system.debug(entities);
        
        
        if(regions.contains('Asia'))
            regions.add('aej');
        if(regions.contains('USA'))
            regions.add('americas');
        if(regions.contains('Europe'))
            regions.add('emea');
        
         Set<Id> salesCodeOwnerId = new Set<Id>();
        Set<Id> researchsalesCodeOwnerId = new Set<Id>();
        List<cvgClassMember> cvgMembers = new List<cvgClassMember>();
        string isCommentVisible = CoverageToolController.isCommentAccessible();
        List<AggregateResult> cvgAggResults = new List<AggregateResult>();
        List<IBD_Coverage__c> ibdCoverages = new List<IBD_Coverage__c>();
        string query = '';
        string groupby = '';
        string entitycriteria = '';
        string entityCriteriaStandard = 'NFPE_Primary_Relationship_Coverage__c = false and NFPE_Primary_Product_Coverage__c = false and NFPE_Overseas_Authorised_Coverage__c = false)';
        Integer i = 1;
        for(string entity: entities){
            if(entity.toLowerCase() != 'standard'){
                if(entitycriteria=='')
                {
                    entitycriteria = ' AND ';
                    if(entities.size()>=1)
                        entitycriteria += ' (';
                    entitycriteria += entity.replace(' ','_') +'__c=true ';
                }
                
                else
                {
                    entitycriteria += ' OR ' + entity.replace(' ','_') +'__c = true';  
                   
                } 
                
            }
            else if(i >= 1 && entity.toLowerCase() == 'standard')
            {
                if(entitycriteria=='')
                    entitycriteria += ' and (';
                else
                    entitycriteria += ' or (';
                entitycriteria += ' '+ entityCriteriaStandard;
            }
            
            i++;
        }
        
        
        
        if(entitycriteria!='')
             entitycriteria +=')';
        
        if(entities.size() == 1 && entities[0] == 'standard')
        entitycriteria = entitycriteria.removeEnd(')');

        Account result = [SELECT RecordType.DeveloperName from Account Where Id =: AccountId];

        groupby = 'group by Account__r.ParentId, Sales_Team_for_Coverage__r.Desk_Name__c, Sales_Team_for_Coverage__r.Coverage_ID__c, '+
                'Sales_Team_for_Coverage__r.Name,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c Order by Sales_Team_for_Coverage__r.Desk_Name__c, Sales_Team_for_Coverage__r.Coverage_ID__c, '+
                'Sales_Team_for_Coverage__r.Name,Sales_Team_for_Coverage__r.Sales_Desk_Division__c';

        if(result.RecordType.DeveloperName == 'POD_Account' || result.RecordType.DeveloperName == 'RM_Account') {
            query = 'SELECT MIN(Account__r.RDM_Org_ID__c) RMORGID,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MIN(uniqueid__c) uniqueKey,Account__r.ParentId rg_id, NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,Sales_Team_for_Coverage__r.Name Name, Sales_Team_for_Coverage__r.Desk_Name__c SalesDesk, '+
            'Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) '+ 
            'SalesDeskRegion,MIN(Sales_Team_for_Coverage__r.OwnerId) SalesCodeOwnerId,min(Start_Date__c) CoverageStartDate, MIN(Team_Role__c) CoverageRole, MAX(Comment__c) Comments,Sales_Team_for_Coverage__r.Sales_Desk_Division__c Division FROM Coverage_Team_Member__c '+ 
            'WHERE Account__r.Id =: AccountId AND RecordType.Name  = \'Active Coverage\' '+
            'AND Sales_Team_for_Coverage__r.Active__c = true ';
        }
            
        else {
            query = 'SELECT MIN(Account__r.RDM_Org_ID__c) RMORGID,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MIN(uniqueid__c) uniqueKey,Account__r.ParentId rg_id, NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,Sales_Team_for_Coverage__r.Name Name, Sales_Team_for_Coverage__r.Desk_Name__c SalesDesk, '+
            'Sales_Team_for_Coverage__r.Coverage_ID__c SalesCode,MIN(Sales_Desk_Region__c) '+ 
            'SalesDeskRegion,MIN(Sales_Team_for_Coverage__r.OwnerId) SalesCodeOwnerId,min(Start_Date__c) CoverageStartDate, MIN(Team_Role__c) CoverageRole, MAX(Comment__c) Comments,Sales_Team_for_Coverage__r.Sales_Desk_Division__c Division FROM Coverage_Team_Member__c '+ 
            'WHERE Account__r.ParentId =: AccountId AND RecordType.Name  = \'Active Coverage\' '+
            'AND Sales_Team_for_Coverage__r.Active__c = true '; 
        }
                         
        if(regions.size()>=1 && products.size()>=1){
            system.debug('1');
            query += 'AND Product_Region__c in :regions AND Product__c in :products ';    
            
        }
        else if(regions.size()==0 && products.size()>=1){
            system.debug('2');
            query += 'AND Product__c in:products ';
            
        }
        else if(regions.size()>=1 && products.size()==0){
            system.debug('3');
            query += 'AND Product_Region__c in:regions ';
            
        }
        else{
            system.debug('4');
            
            ibdCoverages = [SELECT Coverage_Member__r.Name ,Comment__c ,Coverage_Type__c, Region__c 
                            FROM IBD_Coverage__c WHERE Account__c =: AccountId];
        }
        
        
        if(entitycriteria!='')
        {
            query += entitycriteria;
            query += groupby;
            system.debug(entitycriteria);
        }
        else
        {
            query += groupby;
        }
        
        
        cvgAggResults = (List<AggregateResult>) database.query(query);
        
        for(AggregateResult cvg : cvgAggResults){
            salesCodeOwnerId.add(string.valueOf(cvg.get('SalesCodeOwnerId')));
        }
        
        if(salesCodeOwnerId.size()>0)
        {
            researchsalesCodeOwnerId = CoverageToolController.getUserRoleAEJResearchBySalesCodeOwnerId(salesCodeOwnerId); 
        }
        
        //key = RG + CoverageType OR RG + SubType
        Set<string> coverageType_key = new Set<string>();
        Map<string,cvgClassMember> nfpeMap = new  Map<string,cvgClassMember>();
        Map<string,string> rgPrimaryKey  = new Map<string,string>();
        Map<string,List<string>> nfpeKey = new Map<string,List<string>>();
        for(AggregateResult aggr : cvgAggResults){
            if(!researchsalesCodeOwnerId.contains(string.valueOf(aggr.get('SalesCodeOwnerId'))))
            {
                Boolean nfpe = false;
                Boolean nfpe_subtype1 = false;
                Boolean nfpe_subtype2 = false;
				Boolean nfpe_subtype3 = false;
                Boolean nfpe1 = false;
                string uniqueKey = '';
                
                if(CoverageUtil.FLAG_NFPE_SUBTYPE1!=null && CoverageUtil.FLAG_NFPE_SUBTYPE1!=''){
                    if(aggr.get('nfpetype1')!=null){
                        if(Boolean.valueOf(aggr.get('nfpetype1'))){
                            nfpe_subtype1 = true;
                        }
                    }
                }
                
                if(CoverageUtil.FLAG_NFPE_SUBTYPE2!=null && CoverageUtil.FLAG_NFPE_SUBTYPE2!=''){
                    if(aggr.get('nfpetype2')!=null){
                        if(Boolean.valueOf(aggr.get('nfpetype2'))){
                            nfpe_subtype2 = true;
                        }
                    }
                }
				
				if(CoverageUtil.FLAG_NFPE_SUBTYPE3!=null && CoverageUtil.FLAG_NFPE_SUBTYPE3!=''){
                    if(aggr.get('nfpetype3')!=null){
                        if(Boolean.valueOf(aggr.get('nfpetype3'))){
                            nfpe_subtype3 = true;
                        }
                    }
                }
                
                if(CoverageUtil.FLAG_NFPE1!=null && CoverageUtil.FLAG_NFPE1!=''){
                    if(aggr.get('nfpe1')!=null){
                        if(Boolean.valueOf(aggr.get('nfpe1'))){
                            nfpe1 = true;
                        }
                    }
                }
                
                if(aggr.get('uniqueKey')!=null)
                {
                    uniqueKey = string.valueOf(aggr.get('uniqueKey'));
                    uniqueKey = uniqueKey.trim().replace(string.valueOf(aggr.get('RMORGID')), string.valueOf(aggr.get('RGORGID')));
                }
                
                string[] key = uniqueKey.split('#');
                string flag = key[0]+key[1]+key[2];
                
                
                if(nfpe_subtype1 || nfpe1 || nfpe_subtype2 || nfpe_subtype3 )
                {
                    if(nfpeKey.get(uniqueKey)==null && nfpe_subtype1)
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1});
                    else if(nfpeKey.get(uniqueKey)!=null && nfpe_subtype1)
                    {
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE1_1))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1_1);
                    }
                    
                    
                    if(nfpeKey.get(uniqueKey)==null && nfpe_subtype2)
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2});
                    else  if(nfpeKey.get(uniqueKey)!=null && nfpe_subtype2){
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE2))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE2);
                    }
					 if(nfpeKey.get(uniqueKey)==null && nfpe_subtype3)
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
                    else  if(nfpeKey.get(uniqueKey)!=null && nfpe_subtype3){
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE3_1))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3_1);
                    }
                    
                    if(nfpeKey.get(uniqueKey)==null && nfpe1){
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE1});
                    }
                    else if(nfpeKey.get(uniqueKey)!=null && nfpe1){
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE1))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE1);
                    }
                    
                }
                
                cvgClassMember cvgMem = new cvgClassMember();
                cvgMem.Name = string.valueOf(aggr.get('Name'));
                cvgMem.SalesDesk = string.valueOf(aggr.get('SalesDesk'));
                cvgMem.SalesCode =  string.valueOf(aggr.get('SalesCode'));
                cvgMem.SalesDeskRegion = String.valueOf(aggr.get('SalesDeskRegion'));
                cvgMem.CoverageStartDate = Date.valueOf(aggr.get('CoverageStartDate'));
                cvgMem.Comment = string.valueOf(aggr.get('Comments'));
                cvgMem.Division = string.valueOf(aggr.get('Division'));
                cvgMem.CoverageRole = String.valueOf(aggr.get('CoverageRole'));
                nfpeMap.put(flag,cvgMem);
            }
        }
        
        for(string key: nfpeKey.Keyset()){
            string s = '';
            for(string type1: nfpeKey.get(key)){
                if(s==''){
                    s = type1;
                }
                else
                {
                    s += ', '+type1;
                }
            }
            string[] key1 = key.split('#');
            string flag1	 = '';
            flag1 = key1[0]+key1[1]+key1[2];
            
            if(nfpeMap.get(flag1)!=null)
            {
                //commented for JIRA 3698
                /////////////////////////nfpeMap.get(flag1).Type = s.toUpperCase();
            }
        }
        
        if(nfpeMap.size()>0){
            cvgMembers.addAll(nfpeMap.values());
        }
        for(IBD_Coverage__c ibd : ibdCoverages){
             cvgClassMember cvgMem = new cvgClassMember();
             //cvgMem.KeyId =  string.valueOf(ibd.Coverage_Member__r.Name)+string.valueOf(ibd.Coverage_Type__c)+ String.valueOf(ibd.Region__c);
                cvgMem.Name = string.valueOf(ibd.Coverage_Member__r.Name);
            if(isCommentVisible.toLowerCase() == 'true:rw' || isCommentVisible.toLowerCase() == 'true'){
                cvgMem.Comment = string.valueOf(ibd.Comment__c);
            }
            else
            {
                cvgMem.Comment = '';
            }
                cvgMem.SalesDesk = string.valueOf(ibd.Coverage_Type__c);
                cvgMem.SalesDeskRegion = String.valueOf(ibd.Region__c); 
                cvgMem.Division = 'IBD';
                cvgMem.CoverageRole = '';
                cvgMembers.add(cvgMem);
        }
        system.debug('cvgMembers: '+cvgMembers.size());
    return cvgMembers;
        
    }
    
}