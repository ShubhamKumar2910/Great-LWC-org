global without sharing class TreeListController {
        
    @AuraEnabled
    public static String getselectOptions(string sourceEntity, String idField, String textField, String parentIdsField) {
        system.debug('sourceEntity --->' + sourceEntity);
        String jsonData = null;
        String soql = 'select ' + idField + ', ' +  textField + ', ' +  parentIdsField + ' from ' + sourceEntity;
        List<Sobject> objs = Database.query(soql);
        TreeList treelist = new TreeList(objs,idField, textField, parentIdsField);
        system.debug('isEmpty  = ' + treelist.isEmpty());
        if (!treelist.isEmpty()) {
            system.debug('Size  = ' + treelist.getSize());  
            jsonData= JSON.serialize(treelist.getSortedData());
        }
        return jsonData;
    }
    @AuraEnabled
    public static String query(String searchStringForTree, String sourceEntity, String idField, String textField, String parentIdsField) {
        String jsonData = null;
        boolean isIDFieldTypeOfString = isIDFieldTypeOfStringFunc(sourceEntity, idField);
        system.debug('inside query searchString = ' + searchStringForTree + ', sourceEntity = ' + sourceEntity);
        if (searchStringForTree == null || searchStringForTree.trim() == '')
            return getselectOptions(sourceEntity, idField, textField, parentIdsField);
        
        List<Object> codes = new List<Object> ();
        List<Object>  parentCodes = new List<Object> ();
        getCodesOfSearchString(codes, parentCodes, searchStringForTree, sourceEntity, idField, textField, parentIdsField);
        List<Sobject> objs = queryDataFromForce(codes, parentCodes, sourceEntity, idField, textField, parentIdsField, isIDFieldTypeOfString);
        TreeList treelist = new TreeList(objs,idField, textField, parentIdsField);
        system.debug('isEmpty  = ' + treelist.isEmpty());
        if (!treelist.isEmpty()) {
            system.debug('Size  = ' + treelist.getSize());  
            jsonData= JSON.serialize(treelist.getSortedData());
        }
        system.debug('JSON DATA');
        system.debug(jsonData);
        return jsonData;
    } 
    
    private static boolean isIDFieldTypeOfStringFunc(String sourceEntity, String idField) {
        boolean isIDFieldTypeOfString = false;
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{sourceEntity});
        Schema.DisplayType FldType = descResult[0].fields.getMap().get(idField).getDescribe().getType();
        if (FldType == Schema.DisplayType.String ) {
            isIDFieldTypeOfString = true;
        }    
        return 	isIDFieldTypeOfString ;
    }
    
    private static void getCodesOfSearchString(List<Object>  codes, List<Object>  parentCodes, String searchString, String sourceEntity, String idField, String textField, String parentIdsField) {
        String paddedSearchString = '\'%' + searchString + '%\'';
        String soql = 'select ' + idField + ' , ' + textField + ' , ' + parentIdsField + ' from ' + sourceEntity + ' where ' + textField + ' like ' + paddedSearchString ;
        system.debug('soql = ' + soql);
        List<Sobject> sobjs = Database.query(soql);
        if (sobjs != null && sobjs.size() > 0) {
            for (Sobject obj: sobjs) {
                Object code = obj.get(idField);
                Object pcode = obj.get(parentIdsField);
                if (isValidStr(code)) {
                    codes.add(code);
                    parentCodes.add(String.valueof(code));
                }
                if (isValidStr(pcode)) {
                    parentCodes.add(pcode);
                }                
            }
        }
    }
    private static List<Sobject> queryDataFromForce(List<Object>  codes, List<Object>  parentCodes, String sourceEntity, String idField, String textField, String parentIdsField, boolean isIDFieldTypeOfString) {
        List<Sobject> sobjs = null;
        if (codes.size() <= 0 || parentCodes.size() <= 0)
            return sobjs;
        String soql = 'select ' + idField + ' , ' + textField + ' , ' + parentIdsField + ',picklist__c from ' + sourceEntity;
        String downHeirarchyWhereClause = formdownHeirarchyWhereClause(codes, parentIdsField);
        String upTheHeirarchyWhereClause = formUpTheHeirarchyWhereClause(parentCodes, idField, isIDFieldTypeOfString);
        if (downHeirarchyWhereClause != '' && upTheHeirarchyWhereClause != '') {
            soql = soql + ' where ' + downHeirarchyWhereClause + ' or ' + upTheHeirarchyWhereClause;
        }
        else if (downHeirarchyWhereClause != '') {
            soql = soql + ' where ' + downHeirarchyWhereClause ;
        }
        else if (upTheHeirarchyWhereClause !='') {
            soql = soql + ' where ' + upTheHeirarchyWhereClause;
        }
        system.debug('soql = ' + soql);
        return Database.query(soql);
    }    
    
    public static string formdownHeirarchyWhereClause(List<Object> codes, String parentIdsField) {
        String downHeirarchyWhereClause = '';
        //TODO
        for (Object code: codes) {
            if (downHeirarchyWhereClause != '')
                downHeirarchyWhereClause = downHeirarchyWhereClause + ' or ';
            String paddedCode = '\'%' + code + '%\'';
            downHeirarchyWhereClause = downHeirarchyWhereClause + ' ' + parentIdsField + ' like ' + paddedCode;
        }
        return downHeirarchyWhereClause;
    }
    
    public static string formUpTheHeirarchyWhereClause(List<Object> parentDelimCodes, String idField, boolean isIDFieldTypeOfString) {
        List<Object> parentCodes = new List<Object>();
        for (Object parentDelimCode: parentDelimCodes)  {
            String parentDelimCodeStr = (String) parentDelimCode;
            String [] pstrArr = parentDelimCodeStr.split(':');
            for (String pcode : pstrArr) {
                parentCodes.add(pcode);
            }
        }
        String upTheHeirarchyWhereClause = '';
        for (Object parentCode: parentCodes) {
            if (upTheHeirarchyWhereClause != '')
                upTheHeirarchyWhereClause = upTheHeirarchyWhereClause + ' , ';
            Object decoratedParentCode = null;
            if (isIDFieldTypeOfString)
                decoratedParentCode = '\'' + parentCode +  '\'';
            else
                decoratedParentCode = parentCode;
            upTheHeirarchyWhereClause = upTheHeirarchyWhereClause + decoratedParentCode;
        }
        if (upTheHeirarchyWhereClause != '') {
            upTheHeirarchyWhereClause = idField + ' in (' + upTheHeirarchyWhereClause + ')';
        }
        return upTheHeirarchyWhereClause ;
    }   
    
    private static boolean isValidStr(Object obj) {
        boolean isValidStr = false;
        if (obj != null && String.valueOf(obj).trim() != '')
            isValidStr = true;
        
        return isValidStr;
    }
    
   
}