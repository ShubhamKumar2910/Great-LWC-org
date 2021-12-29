/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for Bloomberg_Entity_Data__c object 
**                to implement business tasks, calculations and processes around this object.
**                And to Seperation of Concern
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public class BloombergEntityDataService {

    private static final Integer BBG_SUPPORTED_PARENT_HIERARCHY_DEPTH = 25;

    public static Map<String, Bloomberg_Entity_Data__c> getUltimateParentForChildEntities(List<String> BbgCompanyIdList) {
        System.debug('#### BloombergEntityDataService::getUltimateParentForChildEntities');
        Map<String, Bloomberg_Entity_Data__c> UltimateParentByChildBbgIdMap = new Map<String, Bloomberg_Entity_Data__c>();
        Integer hierarchyDepth = 0;
        try {
            if(BbgCompanyIdList!=null && !BbgCompanyIdList.isEmpty()) {
                Map<String, String> BbgParentIdByBbgChildIdMap = new Map<String, String>();
                Map<String, Bloomberg_Entity_Data__c> UltPrntByUltPrntBbgIdMap = new Map<String, Bloomberg_Entity_Data__c>();
                Set<String> RemainingBbgCompanyIdSet = new Set<String>(BbgCompanyIdList);
                while(!RemainingBbgCompanyIdSet.isEmpty() && hierarchyDepth < BBG_SUPPORTED_PARENT_HIERARCHY_DEPTH) {
                    List<Bloomberg_Entity_Data__c> BbgEntitydataList = [SELECT Id, Name, CNTRY_OF_DOMICILE__c,
                            ID_BB_PARENT_CO__c, LONG_COMP_NAME__c, LONG_PARENT_COMP_NAME__c, INDUSTRY_SECTOR__c, INDUSTRY_GROUP__c, INDUSTRY_SUBGROUP__c 
                        FROM Bloomberg_Entity_Data__c 
                        WHERE Name IN :RemainingBbgCompanyIdSet];
                    if(!BbgEntitydataList.isEmpty()) {
                        for(Bloomberg_Entity_Data__c oBbgEntitydata : BbgEntitydataList) {
                            //BbgParentIdByBbgChildIdMap.put(oBbgEntitydata.Name, oBbgEntitydata.ID_BB_PARENT_CO__c);
                            if(String.isBlank(oBbgEntitydata.ID_BB_PARENT_CO__c)) {
                                UltPrntByUltPrntBbgIdMap.put(oBbgEntitydata.Name, oBbgEntitydata);
                            } else {
                                BbgParentIdByBbgChildIdMap.put(oBbgEntitydata.Name, oBbgEntitydata.ID_BB_PARENT_CO__c);
                                RemainingBbgCompanyIdSet.add(oBbgEntitydata.ID_BB_PARENT_CO__c);
                            }
                            RemainingBbgCompanyIdSet.remove(oBbgEntitydata.Name);
                        }
                    } else {
                        break;
                    }
                } // end of while loop

                if(hierarchyDepth < BBG_SUPPORTED_PARENT_HIERARCHY_DEPTH) {
                    // by now we have found all the parent records
                    for(String bbgId : BbgCompanyIdList) {
                        String parentBbgId = BbgParentIdByBbgChildIdMap.get(bbgId);
                        String  prevParentBbgId = parentBbgId;
                        while(String.isNotBlank(parentBbgId)) {
                            prevParentBbgId = parentBbgId;
                            parentBbgId = BbgParentIdByBbgChildIdMap.get(parentBbgId);
                        }
                        if(String.isNotBlank(prevParentBbgId)) {
                            UltimateParentByChildBbgIdMap.put(bbgId, UltPrntByUltPrntBbgIdMap.get(prevParentBbgId));
                        }
                    }
                } // else { exception will be thrown after catch clause}
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new BloombergEntityDataServiceException('Error Occured in BloombergEntityDataService::getUltimateParentForChildEntities() : '+ex.getMessage());
        }

        if(hierarchyDepth >= BBG_SUPPORTED_PARENT_HIERARCHY_DEPTH) {
            throw new BloombergEntityDataServiceException('Error Occured in BloombergEntityDataService::getUltimateParentForChildEntities() : '+
                'Bllomberg Ultimate Parent not found after looking for '+BBG_SUPPORTED_PARENT_HIERARCHY_DEPTH+' depth');
        }

        return UltimateParentByChildBbgIdMap;
    }

    public static List<Bloomberg_Entity_Data__c> getUltimateParentMatchingName(String ultimateParentName) {
        System.debug('#### BloombergEntityDataService::getUltimateParentMatchingName');
        List<Bloomberg_Entity_Data__c> UltimateParentEntityList = new List<Bloomberg_Entity_Data__c>();
        try {
            ultimateParentName += '%';
            UltimateParentEntityList = [SELECT Id, Name, 
                            ID_BB_PARENT_CO__c, LONG_PARENT_COMP_NAME__c 
                        FROM Bloomberg_Entity_Data__c 
                        WHERE LONG_PARENT_COMP_NAME__c LIKE :ultimateParentName];
        } catch (Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new BloombergEntityDataServiceException('Error Occured in BloombergEntityDataService::getUltimateParentMatchingName() : '+ex.getMessage());
        }
        return UltimateParentEntityList;
    }

    public static List<Bloomberg_Entity_Data__c> findBBGEntities(String entityName, String entityLocation, 
            Boolean getUltimateParent, Integer limitRecs, Integer offset) {
        System.debug('#### BloombergEntityDataService::findLegalEntities');
        List<Bloomberg_Entity_Data__c> BbgLegalEntityList = new List<Bloomberg_Entity_Data__c>();
        //Map<String, Bloomberg_Entity_Data__c> BbgLegalEntityMap = new Map<String, Bloomberg_Entity_Data__c>();
        try {
            if(String.isNotBlank(entityName)) {
                entityName = entityName.trim();
                if(String.isNotBlank(entityName)) {
                    // First remove the trailing special characters from search string tokens, say for e.g. remov & from search string abc& but not from abc&d 
                    System.debug('entityName : b4 regx : '+entityName);
                    String regExp1 = '(&\\s{1,}|\\|\\s{1,}|!\\s{1,}|\\(\\s{1,}|\\)\\s{1,}|\\{\\s{1,}|\\}\\s{1,}|\\[\\s{1,}|\\]\\s{1,}|\\^\\s{1,}|"\\s{1,}|~\\s{1,}|\\*\\s{1,}|\\?\\s{1,}|:\\s{1,}|\\+\\s{1,}|\\-\\s{1,}|\\\\\\s{1,}|\'\\s{1,})';
                    entityName = entityName.replaceAll(regExp1, ' ');
                    System.debug('entityName : af regx : '+entityName);
                    
                    //Now escape the special characters & | ! ( ) { } [ ] ^ " ~ * ? : \ + -  except '
                    string regExp2 = '(&|\\||!|\\|\\(|\\)|\\{|\\}|\\[|\\]|\\^|"|~|\\*|\\?|:|\\+|\\-|\\\\|\')';
                    String escapedEntityName = entityName.replaceAll(regExp2, '\\\\$1');
                    System.debug('escapedEntityName : '+escapedEntityName);
                    
                    entityName = String.escapeSingleQuotes(entityName);
                    System.debug('escape colon : '+entityName);
                    
                    List<String> EscapedEntityNameTokList = escapedEntityName.split(' ');
                    String srchStr = EscapedEntityNameTokList[0]+'*';
                    for(Integer i=1; i<EscapedEntityNameTokList.size() &&  Limits.getLimitSoslQueries()>Limits.getSoslQueries(); ++i) {
                       srchStr += ' AND '+EscapedEntityNameTokList[i]+'*';
                    }
                    String bbgQuery = 'FIND {' + srchStr + '} IN ALL FIELDS RETURNING  Bloomberg_Entity_Data__c '+
                        '(Id, Name, LONG_COMP_NAME__c, CNTRY_OF_DOMICILE__c, INDUSTRY_SECTOR__c, INDUSTRY_GROUP__c, INDUSTRY_SUBGROUP__c  WHERE (';
                    Boolean addAND = false;
                    List<String> EntityNameTokList = entityName.split(' ');
                    for(String entityToken : EntityNameTokList) {
                        //entityToken = entityToken.replace('\\-', '-');
                        //entityToken = entityToken.replace('\\&','&');
                        bbgQuery += (addAND ? ' AND ':'') + 'LONG_COMP_NAME__c LIKE \'%'+entityToken+'%\' ';     
                        addAND = true;
                    }
                    bbgQuery += ') ';
                    bbgQuery += ' AND ID_BB_PARENT_CO__c '+(getUltimateParent ? '= null ' : '!= null ');
                    if(String.isNotBlank(entityLocation)) {
                        bbgQuery += 'AND CNTRY_OF_DOMICILE__c = :entityLocation ';
                    }
                    bbgQuery += 'ORDER BY LONG_COMP_NAME__c ASC LIMIT :limitRecs';
                    if(offset != null) {
                        bbgQuery += ' OFFSET :offset';
                    }
                    bbgQuery += ')';
                    System.debug('bbgQuery : '+bbgQuery);
                    List<List<Bloomberg_Entity_Data__c>> SearchList = (List<List<Bloomberg_Entity_Data__c>>)search.query(bbgQuery);
                    BbgLegalEntityList = SearchList[0];
                }
            }
        } catch (Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new BloombergEntityDataServiceException('Error Occured in BloombergEntityDataService::getLegalEntities() : '+ex.getMessage());
        }
        return BbgLegalEntityList;
    }

    public static List<Bloomberg_Entity_Data__c> searchFuzzyBBEntites(String entityName, String entityLocation, Integer offset, Integer limitSize){

        List<Bloomberg_Entity_Data__c> bloombergEntityList = new List<Bloomberg_Entity_Data__c>();
        Set<String> bbULTParentIDList = new Set<String>();

        final String isULTParentNVal = 'N';
        final String isULTParentYVal = 'Y';
        Integer counter = 0;
        
        if(String.isNotBlank(entityName)){
            String compNameWhereCondition = '';
            List<String> searchStrList = entityName.split(' ');
            String fuzzySrchStr = SearchUtil.getSoslSearchString(searchStrList, '');
            System.debug('--searchFuzzyBBEntites fuzzySrchStr--' + fuzzySrchStr);

            Boolean addOR = false;
            List<String> EntityNameTokList = fuzzySrchStr.split(' OR ');
            Integer wordCount = EntityNameTokList.size();  
            compNameWhereCondition += '( ';
            for(String entityToken : EntityNameTokList) {    
                System.debug('--entityToken--' + entityToken);
                // if(wordCount == 1){
                    
                // }
                entityToken = entityToken.removeEnd('*');
                compNameWhereCondition += (addOR ? ' OR ':'') + 'LONG_COMP_NAME__c LIKE \''+entityToken+'%\' ';    
                System.debug('--compNameWhereCondition--' + compNameWhereCondition);
                addOR = true;
                wordCount--;
            }
            compNameWhereCondition += ') ';

            String inFields = 'ALL';
            String objectString = 'Bloomberg_Entity_Data__c';
            String selectString = 'Id, Name, CNTRY_OF_DOMICILE__c, ID_BB_PARENT_CO__c, ID_BB_ULTIMATE_PARENT_CO__c, ' +
                                    ' INDUSTRY_SUBGROUP__c, LONG_PARENT_COMP_NAME__c, Source__c, IS_ULT_PARENT__c, LONG_ULT_PARENT_COMP_NAME__c, LONG_COMP_NAME__c, Status__c ';
            String whereString = compNameWhereCondition;
            Boolean isStartingWord = false;
            String sortBy = SortUtils.NAME_SEARCH_STRING_SORT; 
            Boolean performSort = false;
            

            if(String.isNotBlank(entityLocation)){
                whereString += ' AND CNTRY_OF_DOMICILE__c = \'' + entityLocation + '\' ';
            }
            

            List<SortUtils.SortWrapper> searchedResults = SearchUtil.getSObjectsBySOSL(entityName, inFields, objectString, selectString, whereString, isStartingWord, sortBy,performSort );
            System.debug('---searchedResults.size()--' + searchedResults.size());
            for(SortUtils.SortWrapper obj : searchedResults){
                //add counter using limit
                //System.debug('--- searchFuzzyBBEntites obj-' + obj);
                if(limitSize != null){
                    if(counter < limitSize){
                        bloombergEntityList.add(obj.oBloomberg_Entity_Data);     
                        counter++;
                    }
                }
                else
                    bloombergEntityList.add(obj.oBloomberg_Entity_Data);               
            }           
            
            if(bloombergEntityList !=null && bloombergEntityList.size() > 0){
                for(Bloomberg_Entity_Data__c obj : bloombergEntityList){
                    if(isULTParentNVal.equalsIgnoreCase(obj.IS_ULT_PARENT__c))
                        bbULTParentIDList.add(obj.ID_BB_ULTIMATE_PARENT_CO__c);                    
                }
                
                for(Bloomberg_Entity_Data__c obj : bloombergEntityList){
                    List<Bloomberg_Entity_Data__c> tempList = bloombergEntityList.clone();
                    if(bbULTParentIDList != null && isULTParentYVal.equalsIgnoreCase(obj.IS_ULT_PARENT__c) && bbULTParentIDList.contains(obj.Name)){
                        Integer removeIndex = tempList.indexOf(obj);
                        tempList.remove(removeIndex);
                    }
                    bloombergEntityList = tempList.clone();
                }                
            }

        }
        System.debug('--final bloombergEntityList.size--' + bloombergEntityList.size());
        return bloombergEntityList;
    }


    /*
     public static List<Bloomberg_Entity_Data__c> findLegalEntities(String entityName, String entityLocation, Integer limitRecs) {
        System.debug('#### BloombergEntityDataService::findLegalEntities');
        //List<Bloomberg_Entity_Data__c> BbgLegalEntityList = new List<Bloomberg_Entity_Data__c>();
        Map<String, Bloomberg_Entity_Data__c> BbgLegalEntityMap = new Map<String, Bloomberg_Entity_Data__c>();
        try {
            if(String.isNotBlank(entityName)) {
                entityName = entityName.trim();
                String bbgQuery;                
                List<List<Bloomberg_Entity_Data__c>> SearchList;
                if(String.isNotBlank(entityName)) {
                    bbgQuery = 'FIND {' + entityName + '*} IN ALL FIELDS RETURNING  Bloomberg_Entity_Data__c '+
                        '(Id, Name, LONG_COMP_NAME__c, CNTRY_OF_DOMICILE__c WHERE ';
                    bbgQuery += ' LONG_COMP_NAME__c LIKE \''+entityName+'%\' '; 
                    if(String.isNotBlank(entityLocation)) {
                        bbgQuery += ' AND CNTRY_OF_DOMICILE__c = :entityLocation ';
                    }
                    bbgQuery += ' ORDER BY LONG_COMP_NAME__c ASC Limit :limitRecs)';
                    System.debug('bbgQuery : '+bbgQuery);
                    SearchList = (List<List<Bloomberg_Entity_Data__c>>)search.query(bbgQuery);
                    for(Bloomberg_Entity_Data__c oBBGEntityData : SearchList[0]) {
                        BbgLegalEntityMap.put(oBBGEntityData.Id, oBBGEntityData);
                    }
                }

                List<String> EntityNameTokList = entityName.split(' ');
                for(Integer i=0; i<EntityNameTokList.size() &&  Limits.getLimitSoslQueries()>Limits.getSoslQueries(); ++i) {
                    String entityNameToken = EntityNameTokList[i];
                    bbgQuery = 'FIND {' + entityNameToken + '*} IN ALL FIELDS RETURNING  Bloomberg_Entity_Data__c '+
                        '(Id, Name, LONG_COMP_NAME__c, CNTRY_OF_DOMICILE__c WHERE ';
                    if(!BbgLegalEntityMap.isEmpty()) {
                        Set<String> BBGEntityIdSet = BbgLegalEntityMap.keySet();  
                        System.debug('BBGEntityIdSet : '+BBGEntityIdSet);
                        bbgQuery += ' Id NOT IN :BBGEntityIdSet AND '; 
                    }
                    bbgQuery += ' LONG_COMP_NAME__c LIKE \'%'+entityNameToken+'%\' '; 
                    if(String.isNotBlank(entityLocation)) {
                        bbgQuery += 'AND CNTRY_OF_DOMICILE__c = :entityLocation ';
                    }
                    bbgQuery += 'ORDER BY LONG_COMP_NAME__c ASC Limit :limitRecs)';
                    System.debug('bbgQuery : '+bbgQuery);
                    SearchList = (List<List<Bloomberg_Entity_Data__c>>)search.query(bbgQuery);
                    for(Bloomberg_Entity_Data__c oBBGEntityData : SearchList[0]) {
                        BbgLegalEntityMap.put(oBBGEntityData.Id, oBBGEntityData);
                    }
                }
                
            }
        } catch (Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new BloombergEntityDataServiceException('Error Occured in BloombergEntityDataService::getLegalEntities() : '+ex.getMessage());
        }
        return BbgLegalEntityMap.values();
    }
    */

    /*public static List<Bloomberg_Entity_Data__c> getLegalEntities(String entityName, String entityLocation, Integer limitRecs) {
        System.debug('#### BloombergEntityDataService::getLegalEntities');
        List<Bloomberg_Entity_Data__c> BbgLegalEntityList = new List<Bloomberg_Entity_Data__c>();
        try {
            if(String.isNotBlank(entityName)) {
                String bbgQuery = 'SELECT Id, Name, LONG_COMP_NAME__c, CNTRY_OF_DOMICILE__c '+
                        'FROM Bloomberg_Entity_Data__c '+
                        'WHERE LONG_COMP_NAME__c LIKE '+'\''+entityName+'%\''+' '; 
                if(String.isNotBlank(entityLocation)) {
                    bbgQuery += ' AND CNTRY_OF_DOMICILE__c = :entityLocation ';
                }
                bbgQuery += ' ORDER BY LONG_COMP_NAME__c ';
                bbgQuery += 'LIMIT :limitRecs';
                System.debug('bbgQuery : '+bbgQuery);
                BbgLegalEntityList = (List<Bloomberg_Entity_Data__c>) Database.query(bbgQuery);
            }
        } catch (Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new BloombergEntityDataServiceException('Error Occured in BloombergEntityDataService::getLegalEntities() : '+ex.getMessage());
        }
        return BbgLegalEntityList;
    }*/

    public class BloombergEntityDataServiceException extends Exception{}
}