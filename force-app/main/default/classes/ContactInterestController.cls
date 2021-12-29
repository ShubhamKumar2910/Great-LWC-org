public without sharing class ContactInterestController {
    
    @AuraEnabled
     public static Contact getContactDetails(Id contactId) {
           /* PageReference currentPage = ApexPages.currentPage();
            Map<String, String> params = currentPage.getParameters();
            system.debug('params = ' + params);
         	string retPage = ApexPages.currentPage().getParameters().get('retURL');
            system.debug('retURL = ' + retPage);
            string id = ApexPages.currentPage().getParameters().get('id');
            system.debug('id = ' + id);*/
        	Contact contact = [SELECT id, name FROM Contact WHERE Id=:contactId];
	        return contact;
     }
    
    @AuraEnabled
     public static List<Map<String, Object>> validate(Id contactId, String  marketListstr, String assetListstr, String sectorListstr,  string flags) {
	    system.debug(' contactId = ' + contactId);
            system.debug('market = ' + marketListstr);
            system.debug('asset = ' + assetListstr);
            system.debug('sector = ' + sectorListstr);
            system.debug('flags = ' + flags);
           List<Map<String, Object>> ciObjs = getCIObjs(contactId,  marketListstr,  assetListstr,  sectorListstr,  flags);
           validate1(ciObjs);
   	   ciObjs = formatResponseForValidateAction1(ciObjs);
           return ciObjs;
     } 
     
    @AuraEnabled
     public static List<Map<String, Object>> createCI(String  validRowsStr) {
	   system.debug(' validRowsStr = ' + validRowsStr);
           List<Map<String, Object>> ciObjs = getCIObjs(validRowsStr);
           create(ciObjs); 
	   ciObjs = formatResponseForCreateCIAction(ciObjs);
           return ciObjs;
     }  

    private static List<Map<String, Object>> formatResponseForCreateCIAction(List<Map<String, Object>> ciObjs) {
	for (Map<String, Object> ciMap: ciObjs) {
		Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
		ciMap.put('MARKET', ciMap.get('MARKET_TEXT'));
		ciMap.put('ASSET', ciMap.get('ASSET_TEXT'));
		ciMap.put('SECTOR', ciMap.get('SECTOR_TEXT'));	        
		if (ci.id != null) {
			ciMap.put('MESSAGE', 'Contact Interest added.');
            String hyperlink = System.URL.getSalesforceBaseUrl().toExternalForm() + '\\'+ ci.id;
			ciMap.put('HYPERLINK',  hyperlink);
			ciMap.put('RESULT', 'PASSED');
		}
		else {
			ciMap.put('MESSAGE', 'Failed to create!!');
            ciMap.put('HYPERLINK',  'javascript:void(0)');
			ciMap.put('RESULT', 'FAILED');
		}
        system.debug('HYPERLINK = ' + ciMap.get('HYPERLINK'));
		ciMap.remove('CI');
	  }
        return ciObjs;
    }     
     
    public static List<Map<String, Object>> formatResponseForValidateAction1(List<Map<String, Object>> ciObjs) {
	for (Map<String, Object> ciMap: ciObjs) {
		Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
		ciMap.put('MARKET', ciMap.get('MARKET_TEXT'));
		ciMap.put('ASSET', ciMap.get('ASSET_TEXT'));
		ciMap.put('SECTOR', ciMap.get('SECTOR_TEXT'));	        
		    if (ciMap.get('MESSAGE') == null){
		      ciMap.put('MESSAGE', 'No duplicates found.') ;
              ciMap.put('HYPERLINK',  'javascript:void(0)');
		      ciMap.put('RESULT', 'PASSED');  
		    }
		    else {
		      ciMap.put('RESULT', 'FAILED');  
              String hyperlink = System.URL.getSalesforceBaseUrl().toExternalForm() + '\\'+ ciMap.get('ID_DUP');
			  ciMap.put('HYPERLINK',  hyperlink);                
		    }
        system.debug('HYPERLINK = ' + ciMap.get('HYPERLINK'));
		ciMap.remove('CI');
	}
        return ciObjs;
    }
    
    private static void create(List<Map<String, Object>> ciObjs) {
	List<Contact_Interest__c> toBeInserted = new List<Contact_Interest__c>();
	for (Map<String, Object> ciMap: ciObjs) {
		Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
		toBeInserted.add(ci);
	}
	system.debug('to be inserted size = ' + toBeInserted.size());
	if (toBeInserted.size() > 0) {
	     Database.SaveResult[] results = Database.insert(toBeInserted, true);
	     doLogging(results);
	}
    }
    
    private static void doLogging(Database.SaveResult[] results) {
        for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Contact Interest. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = 'Failed for ' + '. Error status = ' +  err.getStatusCode() +
                            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
                        System.debug(errorMessage);                     
                    }
                }
            }   
    }      
    
    public static void validate1(List<Map<String, Object>> ciObjs){
        for (Map<String, Object> ciMap : ciObjs) {
	    Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
            String errorMessage = checkForDuplicates(ciMap);
            if (errorMessage != null) {
                System.debug('Duplicate found for ' + objDetails(ci) + ', error Message = ' + errorMessage);
            }
            else{
                System.debug('No duplicate found for ' + objDetails(ci));
            }
        }
    }
    
    private static String checkForDuplicates (Map<String, Object> ciMap) {
        String errorMessage = null;
		Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
        String soql = formSOQLToCheckDuplicates(ciMap);
        List<Contact_Interest__c> dupRecords = Database.query(soql);
	
        if (dupRecords != null && dupRecords.size() > 0) {
            System.debug('Duplicate record size = ' + dupRecords.size());
            for (Contact_Interest__c dup: dupRecords) {
                errorMessage = 'Duplicate record found for ' + dup.description__c + ' , id = ' + dup.id;
                System.debug(errorMessage);
            }
            Contact_Interest__c dupRecord = dupRecords[0];
            errorMessage = 'Duplicate record found for ' + dupRecord.description__c ;
            System.debug(errorMessage);
            ci.addError(errorMessage);
	    ciMap.put('MESSAGE', dupRecord.description__c);
		ciMap.put('MARKET_DUP', dupRecord.Market_lookup__r.Name);
		ciMap.put('ASSET_DUP', dupRecord.Asset_Lookup__r.Name);
		ciMap.put('SECTOR_DUP', dupRecord.Sector_Lookup__r.Name);	   
        ciMap.put('ID_DUP', dupRecord.id);
	    
        }
        return errorMessage;
    }
    
    private static void checkForDuplicates (Contact_Interest__c ci, Market__c market,  AssetClass__c asset, Sector__c sector) {
	String errorMessage = null;
        String soql = formSOQLToCheckDuplicates(ci,  market,  asset, sector);
        List<Contact_Interest__c> dupRecords = Database.query(soql);
	
        if (dupRecords != null && dupRecords.size() > 0) {
            System.debug('Duplicate record size = ' + dupRecords.size());
            for (Contact_Interest__c dup: dupRecords) {
                errorMessage = 'Duplicate record = + ' + dup.description__c + ' , id = ' + dup.id;
                System.debug(errorMessage);
            }
            Contact_Interest__c dupRecord = dupRecords[0];
            errorMessage = 'Duplicate record found for ' + dupRecord.description__c;
            ci.addError(errorMessage);
        }
    }    
    
    public static void validateForDuplicates(List <Contact_Interest__c> ciList) {
	Map<Id,Market__c> markets = getMarkets(ciList);
	Map<Id,AssetClass__c> assets = getAssets(ciList);
	Map<Id,Sector__c> sectors = getSectors(ciList);
	
		for (Contact_Interest__c ci: ciList) {
			checkForDuplicates(ci, markets.get(ci.Market_lookup__c), assets.get(ci.Asset_lookup__c), sectors.get(ci.Sector_lookup__c));
		}
        }

    private static Map<Id,Market__c>  getMarkets(List <Contact_Interest__c> ciList) {
		List<ID> marketIds = new List<Id>();
        Map<Id,Market__c> markets = new Map<Id,Market__c>();
		for (Contact_Interest__c ci: ciList) {
			marketIds.add(ci.Market_lookup__c);
		}
        for (Market__c  market : [select id, code__c, parent_codes__c, picklist__c from market__c where id in  :marketIds ]) {
            markets.put(market.id, market);
        }
		return markets;
        }
	
    private static Map<Id,AssetClass__c>  getAssets(List <Contact_Interest__c> ciList) {
		List<ID> assetIds = new List<Id>();
        Map<Id,AssetClass__c> assets = new Map<Id,AssetClass__c>();
		for (Contact_Interest__c ci: ciList) {
			assetIds.add(ci.Asset_lookup__c);
		}
        for (AssetClass__c  asset : [select id, code__c, parent_codes__c, picklist__c from AssetClass__c where id in  :assetIds ]) {
            assets.put(asset.id, asset);
        }
		return assets;
        }

    private static Map<Id,Sector__c>  getSectors(List <Contact_Interest__c> ciList) {
		List<ID> sectorsIds = new List<Id>();
        Map<Id,Sector__c> sectors = new Map<Id,Sector__c>();
		for (Contact_Interest__c ci: ciList) {
			sectorsIds.add(ci.Sector_lookup__c);
		}
        for (Sector__c  sector : [select id, code__c, parent_codes__c, picklist__c from Sector__c where id in  :sectorsIds ]) {
            sectors.put(sector.id, sector);
        }
		return sectors;
        }	
	
    private static String formSOQLToCheckDuplicates(Contact_Interest__c ci, Market__c market,  AssetClass__c asset, Sector__c sector) {
        String marketCodes = null;
        String assetCodes = null;
        String sectorCodes = null;
        String marketPickList = null;
        String assetPicklist = null;
        String sectorPickList = null;   
        
        ci.Market_Picklist__c = market.picklist__c;
        if (market.parent_codes__c != null){
            marketCodes = market.parent_codes__c + ':' + String.valueOf(market.code__c);
        }    
        else{
           marketCodes = String.valueOf(market.code__c);
        }  

        ci.Sectort_Picklist__c = sector.picklist__c;
        if (sector.parent_codes__c != null){
            sectorCodes = sector.parent_codes__c + ':' + String.valueOf(sector.code__c);
        }    
        else{
           sectorCodes = String.valueOf(sector.code__c);
        } 

        ci.Asset_Picklist__c = asset.picklist__c;
        if (asset.parent_codes__c != null){
            assetCodes = asset.parent_codes__c + ':' + String.valueOf(asset.code__c);
        }    
        else{
           assetCodes = String.valueOf(asset.code__c);
        }	
	
        String soql = 'select id, 	description__c, Market_lookup__r.Name, Asset_Lookup__r.Name,  Sector_Lookup__r.Name from Contact_Interest__c where contact__c = \'' + ci.Contact__c + '\' ';
        soql = appendClause(soql , marketCodes, false, 'Market_lookup__r.');
        soql = appendClause(soql , sectorCodes, true, 'Sector_Lookup__r.');
        soql = appendClause(soql , assetCodes, true, 'Asset_Lookup__r.');
        if (ci.id != null) {
			soql = soql + ' and id != \'' + ci.id + '\'';
    	}
        system.debug('soql = ' + soql);
        return soql;
        
    }

	
    private static String formSOQLToCheckDuplicates(Map<String, Object> ciMap ) {
	Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
        String soql = 'select id, 	description__c, Market_lookup__r.Name, Asset_Lookup__r.Name,  Sector_Lookup__r.Name from Contact_Interest__c where contact__c = \'' + ci.Contact__c + '\' ';
        soql = appendClause(soql , (String)ciMap.get('MARKET'), false, 'Market_lookup__r.');
		soql = appendClause(soql , (String)ciMap.get('SECTOR'), true, 'Sector_Lookup__r.');
		soql = appendClause(soql , (String)ciMap.get('ASSET'), true, 'Asset_Lookup__r.');
        system.debug('soql = ' + soql);
        return soql;
        
    }
    
    private static String appendClause (String soql , String allCodes, boolean isIDFieldTypeOfString, String entity) {
        List<Object> codes = getCodeList(allCodes);
	List<Object> parentDelimCodes = getParentDelimCodeList(allCodes);
        String downHeirarchyWhereClause = TreeListController.formdownHeirarchyWhereClause(codes, entity+'parent_codes__c');
        String upTheHeirarchyWhereClause = TreeListController.formUpTheHeirarchyWhereClause(parentDelimCodes, entity+'code__c', isIDFieldTypeOfString);	
		system.debug(' downHeirarchyWhereClause = ' + downHeirarchyWhereClause);
		system.debug(' upTheHeirarchyWhereClause = ' + upTheHeirarchyWhereClause);
		soql = soql + ' and (' + downHeirarchyWhereClause + ' or ' + upTheHeirarchyWhereClause + ' ) ' ;
        return soql;
    }
    
    private static String objDetails(Contact_Interest__c ci) {
        return 'name = ' + ci.name + ', id = ' + ci.id + 'contactName = ' + ci.Contact__c + ', sector = ' + ci.Sector_Lookup__c +
            ', Asset = ' + ci.Asset_Lookup__c + ' , market = ' + ci.Market_lookup__c;
        
    }
    
    private static List<Map<String, Object>> getCIObjs (Id contactId, String  marketListstr, String assetListstr, String sectorListstr, string flags) {
        List<Map<String, Object>> ciObjs = new List<Map<String, Object>>();
        List<Map<String, String>>  marketList = (List<Map<String, String>>)JSON.deserialize(marketListstr,List<Map<String, String>>.class);
        List<Map<String, String>>  assetList = (List<Map<String, String>>)JSON.deserialize(assetListstr,List<Map<String, String>>.class);
        List<Map<String, String>>  sectorList = (List<Map<String, String>>)JSON.deserialize(sectorListstr,List<Map<String, String>>.class);
        system.debug(marketList.size() );
        system.debug(assetList.size());
        system.debug(sectorList.size());
        for (integer i = 0 ; i < marketList.size() ; i ++) {
            
            for (integer j = 0 ; j < assetList.size() ; j ++) {
                for (integer k = 0 ; k < sectorList.size() ; k ++){
		    		Map<String, Object> ciMap = new Map<String, Object>();
		    		ciMap.put('CI',  new Contact_Interest__c());
                    updateFields(ciMap, contactId,  marketList[i],  assetList[j],  sectorList[k],  flags);
                    ciObjs.add(ciMap);
                }
            }
        }
        system.debug('No of ci created = ' + ciObjs.size());
        return ciObjs;
    }
    
    private static List<Map<String, Object>> getCIObjs (String  validRowsStr) {
        List<Map<String, Object>> ciObjs = new List<Map<String, Object>>();
        List<Map<String, String>>  validRows = (List<Map<String, String>>)JSON.deserialize(validRowsStr,List<Map<String, String>>.class);

        system.debug('valid rows size = ' + validRows.size() );
	for (Map<String, Object> row: validRows) {
		system.debug('valid row = ' + row);
		Map<String, Object> ciMap = new Map<String, Object>();
		ciMap.put('CI',  new Contact_Interest__c());
		updateFields(ciMap, row);
		ciObjs.add(ciMap);		
	}
        system.debug('No of ci created = ' + ciObjs.size());
        return ciObjs;
    }
    
    private static void updateFields(Map<String, Object> ciMap, Map<String, Object> row) {
	Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
        ci.Contact__c = (Id)row.get('Contact__c');
        Decimal marketCode = Decimal.valueOf((String)row.get('MARKET_CODE'));
        ci.Market_lookup__r = new Market__c(code__c=marketCode);
        ci.Sector_Lookup__r = new Sector__c(code__c=(String)row.get('SECTOR_CODE'));
        ci.Asset_Lookup__r = new AssetClass__c(code__c=(String)row.get('ASSET_CODE'));        
        ci.flags__c = (String)row.get('flags__c');
		ci.Market_Picklist__c=(String)row.get('MARKET_PICKLIST');
		ci.Sectort_Picklist__c=(String)row.get('SECTOR_PICKLIST');
		ci.Asset_Picklist__c=(String)row.get('ASSET_PICKLIST');
        ciMap.put('MARKET_TEXT', row.get('MARKET_TEXT'));
        ciMap.put('ASSET_TEXT', row.get('ASSET_TEXT'));
        ciMap.put('SECTOR_TEXT', row.get('SECTOR_TEXT'));	
        ciMap.put('SECTOR_PICKLIST', row.get('SECTOR_PICKLIST'));
        ciMap.put('MARKET_PICKLIST', row.get('MARKET_PICKLIST'));
        ciMap.put('ASSET_PICKLIST', row.get('ASSET_PICKLIST'));         
    }    
    
    private static void updateFields(Map<String, Object> ciMap, Id contactId, Map<String, String> market, Map<String, String> asset, Map<String, String> sector, string flags) {
    
	Contact_Interest__c ci = (Contact_Interest__c)ciMap.get('CI');
        ci.Contact__c = contactId;
        ci.Asset_Lookup__r = new AssetClass__c(code__c=getCode(asset.get('id')));
        Decimal marketCode = Decimal.valueOf(getCode(market.get('id')));
        ci.Market_lookup__r = new Market__c(code__c=marketCode);
        ci.Sector_Lookup__r = new Sector__c(code__c=getCode(sector.get('id')));
        ci.flags__c = flags.replace(',', ';');
        ciMap.put('MARKET', market.get('id'));
        ciMap.put('ASSET', asset.get('id'));
        ciMap.put('SECTOR', sector.get('id'));
        ciMap.put('MARKET_TEXT', market.get('text'));
        ciMap.put('ASSET_TEXT', asset.get('text'));
        ciMap.put('SECTOR_TEXT', sector.get('text'));	
        ciMap.put('MARKET_CODE', getCode(market.get('id')));
        ciMap.put('ASSET_CODE', getCode(asset.get('id')));
        ciMap.put('SECTOR_CODE', getCode(sector.get('id')));  
        ciMap.put('SECTOR_PICKLIST', sector.get('picklist__c'));
        ciMap.put('MARKET_PICKLIST', market.get('picklist__c'));
        ciMap.put('ASSET_PICKLIST', asset.get('picklist__c'));        
        ciMap.put('flags__c', flags.replace(',', ';'));   
        ciMap.put('Contact__c', contactId);
        system.debug('flags = ' + ci.flags__c);
    }
    
    private static String getCode(String allCodes) {
        String code = null;
        String [] codeList = allCodes.split(':');
        code = codeList[codeList.size() -1 ];
        return code;
    }   

    private static List<Object> getCodeList(String allCodes) {
        List<Object> codeList = new List<Object>();
        String [] codeArr = allCodes.split(':');
        codeList.add(codeArr[codeArr.size() -1 ]);
        return codeList;
    }      
    
    private static List<Object> getParentDelimCodeList(String allCodes) {
        List<Object> parentDelimCodes = new List<Object>();
        String [] codeArr = allCodes.split(':');
        
        for (integer i = 0; i < codeArr.size() ; i ++) {
            parentDelimCodes.add(codeArr[i]);
        }
        return parentDelimCodes;
    } 
    
    
    
    private static String[] getParentCodes(String allCodes) {
    	String[] parentCodes = null;
        String [] codeList = allCodes.split(':');
        
        parentCodes = new String[codeList.size() - 1];
        for (integer i = 0; i < codeList.size() -1; i ++) {
            parentCodes[i] = codeList[i];
        }
        return parentCodes;
    }    
}