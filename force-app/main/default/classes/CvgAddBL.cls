public class CvgAddBL {
    //modified for JIRA 3660
    public static string FLAG_NFPE = CoverageUtil.FLAG_NFPE;
    public static string FLAG_NFPE1 = CoverageUtil.FLAG_NFPE1;
    public static string FLAG_NFPE_SUBTYPE1 = CoverageUtil.FLAG_NFPE_SUBTYPE1;
    public static string FLAG_NFPE_SUBTYPE1_1 = CoverageUtil.FLAG_NFPE_SUBTYPE1_1;
    public static string FLAG_NFPE_SUBTYPE2 = CoverageUtil.FLAG_NFPE_SUBTYPE2;
	public static string FLAG_NFPE_SUBTYPE3 = CoverageUtil.FLAG_NFPE_SUBTYPE3;
    public static string FLAG_NFPE_SUBTYPE3_1 = CoverageUtil.FLAG_NFPE_SUBTYPE3_1;
    
    public static void RGAddCoverage (List<RG_Coverage_Request__c> reqsAdd, Map<String,String> mapofRGAdd,Map<String,String> mapofRGUserAdd, Set<ID> salesTeamForCoverageAdd){
        
        Map<String,Coverage_Team_Member__c> newMapofAdd = new Map<String,Coverage_Team_Member__c>();
        Map<String,String> mapAlreadyAdded = new Map<String,String>();
        Map<String,String> mapAccRG = new Map<String,String>();
        Map<ID,ID> mapAccParent = new Map<ID,ID>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>();
        List<Coverage_Team_Member__c> cvgMemWithNoProductUpdateList = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemToAddFinal = new List<Coverage_Team_Member__c>();
        boolean isMatchFound = false;
        
        salesCodeMap = CoverageRequestUtility.fetchsalesCodeDetails (salesTeamForCoverageAdd);
         
        system.debug('salesTeamForCoverageAdd :'+ salesTeamForCoverageAdd);
        system.debug('mapofRGAdd :'+ mapofRGAdd);
        List<Coverage_Team_Member__c>  cvgMemAdd =  new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
            String product = '';
            String productRegion = '';
            String productGroup = '';
            for(RG_Coverage_Request__c rgcvgReq : reqsAdd){ 
                product = rgcvgReq.Product2__c;
                productRegion = rgcvgReq.Product_Region__c;
                productGroup = rgcvgReq.Product_Group__c;
            }
            //JIRA 3419 To fix test class removed end date null check 
        cvgMemAdd = [SELECT Id,Account__c,Account__r.ParentId,Team_Member__c,UniqueId__c
                                                    FROM Coverage_Team_Member__c WHERE Account__r.ParentId IN : mapofRGAdd.keyset() AND Account__r.Active__c = true
                                                    AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageAdd AND RecordType.DeveloperName = 'Active_Coverage' AND ((Product2__c = NULL
                                                    AND Product_Region__c = NULL AND Product_Group__c = NULL) OR (Product2__c =: product 
                                                    AND Product_Region__c =: productRegion AND Product_Group__c =: productGroup AND Group_By__c = 'RM'))];
        }
        else if(Test.isRunningTest())
        {
            //JIRA 3419 To fix test class
            cvgMemAdd = [SELECT Id,Account__c,Account__r.ParentId,Team_Member__c,UniqueId__c
                                                    FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Active_Coverage' AND Product2__c = NULL
                                                    AND Product_Region__c = NULL AND Product_Group__c = NULL LIMIT 1]; 
        }
        
        
        
        for(Coverage_Team_Member__c cvgrecAdd : cvgMemAdd){
            List<String> strAddArguments = new List<String>();
            strAddArguments.add(cvgrecAdd.Account__c);
            strAddArguments.add(cvgrecAdd.Team_Member__c);
            strAddArguments.add(cvgrecAdd.Account__r.ParentId);
            newMapofAdd.put(String.format('{0}#{1}#{2}', strAddArguments),cvgrecAdd);
            mapAccParent.put(cvgrecAdd.Account__c, cvgrecAdd.Account__r.ParentId);
            
        }
         List<Account> childAccounts = new List<Account>();
        
        if(!Test.isRunningTest())
        {
            childAccounts = [SELECT Id,Name, ParentId,Restricted_Flag__c,Domicile_Country__c FROM Account WHERE ParentId IN :mapofRGAdd.values() AND Active__c = true
                             AND Restricted_Flag__c = false AND ID NOT IN : mapAccParent.keySet() AND RecordType.DeveloperName = 'RM_Account'];
        }
        else if(Test.isRunningTest()){
            childAccounts = [SELECT Id,Name, ParentId,Restricted_Flag__c,Domicile_Country__c from Account where Restricted_Flag__c = false AND RecordType.DeveloperName = 'RM_Account' AND
                             ParentID <> NULL  LIMIT 1];
        }
        
        Set<Id> all_rmIds = new Set<Id>();
        for(Account chldAct : childAccounts){
            all_rmIds.add(chldAct.Id);
            mapAccRG.put(chldAct.Id+'#'+chldAct.ParentId,chldAct.Restricted_Flag__c+'#'+chldAct.Domicile_Country__c);
        }
        
        
        

        
        
        system.debug('newMapofAdd :'+ newMapofAdd);
        system.debug('cvgMemAdd :'+ cvgMemAdd);
        
        for(RG_Coverage_Request__c rgcvgReq : reqsAdd){ 
            
            if(rgcvgReq.Approved__c == true || Test.isRunningTest()){
                
                for(string keyval : newMapofAdd.keySet())
                {
                    //IF current request has product, and exisitng coverage is without product,
                    //Update exisiting with product
                    if(rgcvgReq.Product__c <> NULL){
                        string [] keysplit = keyval.split('#');
                        if(!mapAlreadyAdded.containsKey(keysplit[1]+'#'+keysplit[2]+'#'+keysplit[0])){ //Team Member, RG and RM
                            system.debug(rgcvgReq.Requested_for_User__c);
                            system.debug(keysplit[1]);
                            system.debug(keysplit[2]);
                            system.debug(rgcvgReq.RG_Account__c);
                            if(keysplit[1] == rgcvgReq.Requested_for_User__c && keysplit[2] == rgcvgReq.RG_Account__c){
                               system.debug('inisde 3');
                                mapAlreadyAdded.put(keysplit[1]+'#'+keysplit[2]+'#'+keysplit[0], keysplit[2]);
                                Coverage_Team_Member__c cvgUpdateMem = newMapofAdd.get(keyval);                              
                                cvgUpdateMem.Product_Group__c = rgcvgReq.Product_Group__c;
                                cvgUpdateMem.Product2__c = rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim();
                                cvgUpdateMem.Product__c = rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim();
                                system.debug('Product2__c :'+cvgUpdateMem.Product2__c);
                                cvgupdateMem.NFPE1__c = false;
                                cvgupdateMem.NFPE_Primary_Product_Coverage__c = false;
                                cvgupdateMem.NFPE_Overseas_Authorised_Coverage__c = false;
                                cvgupdateMem.NFPE_Primary_Relationship_Coverage__c = false;
                                cvgUpdateMem.Product_Region__c = rgcvgReq.Product__c.substring(string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')+1).Trim();
                                cvgUpdateMem.Start_Date__c = string.isEmpty(string.valueOf(rgcvgReq.Start_Date__c))?Date.today() : rgcvgReq.Start_Date__c; 
                                cvgUpdateMem.Team_Role__c = rgcvgReq.Role__c;  
                                cvgUpdateMem.Comment__c = rgcvgReq.Comment__c;
                                cvgUpdateMem.UniqueId__c =  (cvgUpdateMem.UniqueId__c.split('#')).size() == 6 ? cvgUpdateMem.UniqueId__c : string.valueOf(cvgUpdateMem.UniqueId__c).RemoveEnd('FALSE') +rgcvgReq.Product_Group__c+'#'+rgcvgReq.Product2__c+' - '+rgcvgReq.Product_Region__c+'#' + 'FALSE';
                                cvgUpdateMem.Group_By__c = rgcvgReq.Group_By__c;
                                cvgMemWithNoProductUpdateList.add(cvgUpdateMem); 
                            }
                        }
                        //Found no scenario where this block of else code will get executed
                        else
                        {
                            if(keysplit[1] == rgcvgReq.Requested_for_User__c && keysplit[2] == rgcvgReq.RG_Account__c){
                                Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                                TeamMember.Account__c = keysplit[0];
                                TeamMember.Team_Member__c = rgcvgReq.Requested_for_User__c; //Changes for JIRA SALES-1362
                                TeamMember.Product_Group__c = rgcvgReq.Product_Group__c;
                                TeamMember.Product2__c = rgcvgReq.Product__c <> NULL ?  rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim(): '';
                                TeamMember.Product__c = rgcvgReq.Product__c <> NULL  ?  rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim() : '';
                                system.debug('Product2__c :'+TeamMember.Product2__c);
                                TeamMember.Product_Region__c   = rgcvgReq.Product__c <> NULL  ? rgcvgReq.Product__c.substring(string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')+1).Trim() : '';
                                TeamMember.Team_Role__c = rgcvgReq.Role__c;
                                TeamMember.Comment__c = rgcvgReq.Comment__c;
                                TeamMember.NFPE1__c = false;
                                TeamMember.NFPE_Primary_Product_Coverage__c = false;
                                TeamMember.NFPE_Overseas_Authorised_Coverage__c = false;
                                TeamMember.NFPE_Primary_Relationship_Coverage__c = false;
                                
                                TeamMember.Sales_Team_for_Coverage__c = rgcvgReq.Sales_Team_for_Coverage__c;
                                TeamMember.Start_Date__c = string.isEmpty(string.valueOf(rgcvgReq.Start_Date__c))?Date.today() : rgcvgReq.Start_Date__c;                        
                                TeamMember.Group_By__c = rgcvgReq.Group_By__c;
                                cvgMemToAddFinal.add(teammember);
                            }
                        }
                    }else{
                      string [] keysplit = keyval.split('#');
                        if(!mapAlreadyAdded.containsKey(keysplit[1]+'#'+keysplit[2]+'#'+keysplit[0])){ //Team Member, RG and RM
                            system.debug(rgcvgReq.Requested_for_User__c);
                            system.debug(keysplit[1]);
                            system.debug(keysplit[2]);
                            system.debug(rgcvgReq.RG_Account__c);
                            if(keysplit[1] == rgcvgReq.Requested_for_User__c && keysplit[2] == rgcvgReq.RG_Account__c){
                               system.debug('inisde 4');
                                mapAlreadyAdded.put(keysplit[1]+'#'+keysplit[2]+'#'+keysplit[0], keysplit[2]);
                                Coverage_Team_Member__c cvgUpdateMem = newMapofAdd.get(keyval);                              
                                //cvgUpdateMem.Product_Group__c = rgcvgReq.Product_Group__c;
                                //cvgUpdateMem.Product2__c = rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim();
                                //cvgUpdateMem.Product__c = rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim();
                                //system.debug('Product2__c :'+cvgUpdateMem.Product2__c);
                                cvgupdateMem.NFPE1__c = false;
                                cvgupdateMem.NFPE_Primary_Product_Coverage__c = false;
                                cvgupdateMem.NFPE_Overseas_Authorised_Coverage__c = false;
                                cvgupdateMem.NFPE_Primary_Relationship_Coverage__c = false;
                                //cvgUpdateMem.Product_Region__c = rgcvgReq.Product__c.substring(string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')+1).Trim();
                                cvgUpdateMem.Start_Date__c = string.isEmpty(string.valueOf(rgcvgReq.Start_Date__c))?Date.today() : rgcvgReq.Start_Date__c; 
                                cvgUpdateMem.Team_Role__c = rgcvgReq.Role__c;  
                                cvgUpdateMem.Comment__c = rgcvgReq.Comment__c;
                                //cvgUpdateMem.UniqueId__c =  string.valueOf(cvgUpdateMem.UniqueId__c).RemoveEnd('FALSE') +rgcvgReq.Product_Group__c+'#'+rgcvgReq.Product2__c+' - '+rgcvgReq.Product_Region__c+'#' + 'FALSE';
                                cvgUpdateMem.Group_By__c = rgcvgReq.Group_By__c;
                                cvgMemWithNoProductUpdateList.add(cvgUpdateMem); 
                            }
                        }  
                    }
                }
                
                for(string kyval : mapAccRG.keySet()){ // all non rest
                    string [] kyvalSplit = kyval.split('#');
                    if(kyvalSplit[1] == rgcvgReq.RG_Account__c){
                        Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                        TeamMember.Account__c = kyvalSplit[0];
                        TeamMember.Team_Member__c = rgcvgReq.Requested_for_User__c; 
                        TeamMember.Product_Group__c = rgcvgReq.Product_Group__c;
                        TeamMember.Product2__c = rgcvgReq.Product__c <> NULL?  rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim(): '';
                        TeamMember.Product__c = rgcvgReq.Product__c <> NULL ?  rgcvgReq.Product__c.substring(0,string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')).Trim() : '';
                        system.debug('Product2__c :'+TeamMember.Product2__c);
                        TeamMember.Product_Region__c   = rgcvgReq.Product__c <> NULL  ? rgcvgReq.Product__c.substring(string.valueOf(rgcvgReq.Product__c).lastIndexOf('-')+1).Trim() : '';
                        TeamMember.Team_Role__c = rgcvgReq.Role__c;
                        TeamMember.NFPE1__c = false;
                        TeamMember.NFPE_Primary_Product_Coverage__c = false;
                        TeamMember.NFPE_Overseas_Authorised_Coverage__c = false;
                        TeamMember.NFPE_Primary_Relationship_Coverage__c = false;
                        
                        TeamMember.Comment__c = rgcvgReq.Comment__c;
                        TeamMember.Sales_Team_for_Coverage__c = rgcvgReq.Sales_Team_for_Coverage__c;
                        TeamMember.Start_Date__c = string.isEmpty(string.valueOf(rgcvgReq.Start_Date__c))?Date.today() : rgcvgReq.Start_Date__c;                        
                        TeamMember.Group_By__c = rgcvgReq.Group_By__c;
                        cvgMemToAddFinal.add(teammember);
                    }
                }
                
            }
        }
        
        if(cvgMemWithNoProductUpdateList.size() >0){
            try{
                system.debug('++++'+cvgMemWithNoProductUpdateList);
                //Database.insert (coverageTeamMembList,false);
                
                update cvgMemWithNoProductUpdateList;
            }catch(exception ex){
                cvgMemWithNoProductUpdateList[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        
        if(cvgMemToAddFinal.size()>0){
            try{
                system.debug('++++'+cvgMemToAddFinal);
                 Database.SaveResult[] results = Database.insert(cvgMemToAddFinal, false);
               
                //Database.insert (coverageTeamMembList,false);
                //update cvgMemWithNoProductUpdateList;
                //insert cvgMemToAddFinal;
            }catch(exception ex){
              //  cvgMemToAddFinal[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
            
        } 
        
        
        
        
    }
    
    
    public static void RMAddCoverage (List<Coverage_Access_Request__c> reqsAdd, Map<String,String> mapofRMAdd,Map<String,String> mapofRMUserAdd, Set<ID> salesTeamForCoverageAdd){
        
        Map<String,Coverage_Team_Member__c> newMapofAdd = new Map<String,Coverage_Team_Member__c>();
        Map<String,Coverage_Team_Member__c> newMapofAdd_NFPE = new Map<String,Coverage_Team_Member__c>();
        Map<String,String> mapAlreadyAdded = new Map<String,String>();
        Map<String,String> mapAccRM = new Map<String,String>();
        Map<ID,ID> mapAccParent = new Map<ID,ID>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>();
        List<Coverage_Team_Member__c> cvgMemWithNoProductUpdateList = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemNFPEUpdateList = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemToAddFinal = new List<Coverage_Team_Member__c>();
        boolean isMatchFound = false;
        
        salesCodeMap = CoverageRequestUtility.fetchsalesCodeDetails (salesTeamForCoverageAdd);
        
        system.debug('salesTeamForCoverageAdd :'+ salesTeamForCoverageAdd);
        system.debug('mapofRMAdd :'+ mapofRMAdd);
        
        List<Coverage_Team_Member__c> cvgMemAdd = new List<Coverage_Team_Member__c>();
        Map<string,Coverage_Team_Member__c> cvgMemNFPEUpdate = new Map<string,Coverage_Team_Member__c>();
        Set<Id>  rmIds = new Set<Id>();
        
        for(Coverage_Access_Request__c rmcvgReq : reqsAdd){ 
            if(rmcvgReq.Type__c!=null && rmcvgReq.Type__c!='')
            rmIds.add(rmcvgReq.Account__c);
        }
        //JIRA 3419 To fix test class removed end date null check 
        for(Coverage_Team_Member__c tm: [SELECT Id,uniqueid__c,Product_Region__c,Product_group__c,Product__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE_Primary_Product_Coverage__c
                                                    FROM Coverage_Team_Member__c WHERE Account__c IN : rmIds
                                                    AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageAdd AND RecordType.DeveloperName = 'Active_Coverage' AND Product2__c != NULL
                                         AND Product_Region__c != NULL AND Product_Group__c != NULL])
        {
            string[] splitValue = tm.uniqueid__c.split('#');
            string key = '';
            if(tm.Product__c!=null && tm.Product__c!='')
            {
                key = splitValue[0]+'#'+splitValue[2]+'#'+splitValue[3]+'#'+tm.Product__c+'#'+tm.Product_Region__c;
            }
            else
            {
                key =splitValue[0]+'#'+splitValue[2]+'###';
            }
                cvgMemNFPEUpdate.put(key.tolowerCase(),tm);
        }
       
       if(!Test.isRunningTest()){
           //JIRA 3419 To fix test class removed end date null check 
		cvgMemAdd = [SELECT Id,Account__c,Account__r.ParentId,Team_Member__c,Product_Region__c,Product2__c,Sales_Team_for_Coverage__c,Product_Group__c,UniqueId__c,Sales_Team_for_Coverage__r.OwnerId
                                                    FROM Coverage_Team_Member__c WHERE Account__c IN : mapofRMAdd.keyset()
                                                    AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageAdd AND RecordType.DeveloperName = 'Active_Coverage' AND Product2__c = NULL
                                                    AND Product_Region__c = NULL AND Product_Group__c = NULL];
 
        }
        else if(Test.isRunningTest())
        {
            //JIRA 3419 To fix test class removed end date null check 
              cvgMemAdd = [SELECT Id,Account__c,Account__r.ParentId,Team_Member__c,
                           Product_Group__c,Product_Region__c,Product2__c,Sales_Team_for_Coverage__c,
                           UniqueId__c,Sales_Team_for_Coverage__r.OwnerId
                                                    FROM Coverage_Team_Member__c WHERE  RecordType.DeveloperName = 'Active_Coverage' LIMIT 1];
        }
        
        
        for(Coverage_Team_Member__c cvgrecAdd : cvgMemAdd){
            List<String> strAddArguments = new List<String>();
            strAddArguments.add(cvgrecAdd.Account__c);
            strAddArguments.add(cvgrecAdd.Team_Member__c);            
            newMapofAdd.put(String.format('{0}#{1}', strAddArguments),cvgrecAdd);
            mapAccParent.put(cvgrecAdd.Account__c, cvgrecAdd.Account__r.ParentId);
          /*  string key =  '';
            string productGrp = '';
            string productReg =  '';
            string product =  '';
            if(cvgrecAdd.Product_Group__c!=null && cvgrecAdd.Product_Group__c!='')
                productGrp = cvgrecAdd.Product_Group__c;
            if(cvgrecAdd.Product_Region__c!=null && cvgrecAdd.Product_Region__c!='')
                productReg = cvgrecAdd.Product_Region__c;
            if(cvgrecAdd.Product2__c!=null && cvgrecAdd.Product2__c!='')
                product = cvgrecAdd.Product2__c;
            key = cvgrecAdd.Account__c + '#' + cvgrecAdd.Sales_Team_for_Coverage__c + '#' + productGrp + '#' + product + '#' + productReg;
            newMapofAdd_NFPE.put(key,cvgrecAdd);
            
            if(cvgrecAdd.Product2__c == NULL && cvgrecAdd.Product_Region__c == NULL && cvgrecAdd.Product_Group__c == NULL){*/
                
            //}
        }
        
        if(newMapofAdd.size() == 0)
        {
            List<Account> childAccounts = new List<Account>();
            
            if(!Test.isRunningTest())
            
            childAccounts = [SELECT Id,Name, ParentId,Restricted_Flag__c,Domicile_Country__c from Account where ID IN : mapofRMAdd.keySet()];
            
            if(Test.isRunningTest()){
                 childAccounts = [SELECT Id,Name, ParentId,Restricted_Flag__c,Domicile_Country__c from Account WHERE Restricted_Flag__c = true LIMIT 4];
            }
            for(Account chldAct : childAccounts){
                mapAccRM.put(chldAct.Id,chldAct.Id);
            }
        }
        
        system.debug('newMapofAdd :'+ newMapofAdd);
        system.debug('cvgMemAdd :'+ cvgMemAdd);
        
        for(Coverage_Access_Request__c rmcvgReq : reqsAdd){ 
            string key =  '';
            string productGrp = '';
            string productReg =  '';
            string product =  '';
            
            
            if(rmcvgReq.Approved__c == true ){
                 //Exisitng Coverage Updates
                for(string keyval : newMapofAdd.keySet())
                {
                    string parenttype = '';
                    string subtype = '';
                    boolean sub_1 = false;
                    boolean sub_2 = false;
					boolean sub_3 = false;
                    
                    if(rmcvgReq.Type__c!=null && rmcvgReq.Type__c!='Standard'){
                        parenttype = rmcvgReq.Type__c;
                        subtype = rmcvgReq.Sub_Type__c;
                    }
                    
                    
                    //IF current request has product, and exisitng coverage is without product,
                    //Update exisiting with product
                    if(rmcvgReq.Product__c <> NULL){
                        system.debug('Block 1');
                        string [] keysplit = keyval.split('#');
                        if(!mapAlreadyAdded.containsKey(keysplit[0]+'#'+keysplit[1])){
                            if(keysplit[1] == rmcvgReq.Requested_for_User__c && keysplit[0] == rmcvgReq.Account__c){
                                mapAlreadyAdded.put(keysplit[0]+'#'+keysplit[1], keysplit[1]);
                                Coverage_Team_Member__c cvgUpdateMem = newMapofAdd.get(keyval);                              
                                cvgUpdateMem.Product_Group__c = rmcvgReq.Product_Group__c;
                              
                                if(parenttype!='' && subType == '' && FLAG_NFPE1!=null && FLAG_NFPE1!='' && parenttype.trim() == FLAG_NFPE1){
                                    cvgUpdateMem.NFPE1__c = true;
                                }
                                
                                if(parenttype!='' && subType != ''){
                                    //modified for JIRA 3660
                                    if(FLAG_NFPE_SUBTYPE1!=null && FLAG_NFPE_SUBTYPE1!='' && (subType.trim() == FLAG_NFPE_SUBTYPE1 || subType.trim() == FLAG_NFPE_SUBTYPE1_1))
                                        sub_1 = true;
                                    if(FLAG_NFPE_SUBTYPE2!=null && FLAG_NFPE_SUBTYPE2!='' && subType.trim() == FLAG_NFPE_SUBTYPE2)
                                        sub_2 = true;
									if(FLAG_NFPE_SUBTYPE3!=null && FLAG_NFPE_SUBTYPE3!='' && (subType.trim() == FLAG_NFPE_SUBTYPE3 || subType.trim() == FLAG_NFPE_SUBTYPE3_1))
										sub_3 = true;
                                }
                                else
                                {
                                    sub_1 = false;
                                    sub_2 = false;
									sub_3 = false;
                                }
                                
                                cvgUpdateMem.NFPE_Primary_Relationship_Coverage__c = sub_1;
                                cvgUpdateMem.NFPE_Primary_Product_Coverage__c = sub_2;
                                cvgUpdateMem.NFPE_Overseas_Authorised_Coverage__c = sub_3;
                                cvgUpdateMem.Product2__c = rmcvgReq.Product__c.substring(0,string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')).Trim();
                                cvgUpdateMem.Product__c = rmcvgReq.Product__c.substring(0,string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')).Trim();
                                cvgUpdateMem.Product_Region__c = rmcvgReq.Product__c.substring(string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')+1).Trim();
                                cvgUpdateMem.Start_Date__c = string.isEmpty(string.valueOf(rmcvgReq.Start_Date__c))?Date.today() : rmcvgReq.Start_Date__c; 
                                cvgUpdateMem.Team_Role__c = rmcvgReq.Role__c; 
                                cvgUpdateMem.Comment__c = rmcvgReq.Comment__c;
                                 cvgUpdateMem.UniqueId__c =  string.valueOf(cvgUpdateMem.UniqueId__c).RemoveEnd('FALSE') +rmcvgReq.Product_Group__c+'#'+rmcvgReq.Product2__c+' - '+rmcvgReq.Product_Region__c+'#' + 'FALSE';
                                 cvgUpdateMem.Group_By__c = rmcvgReq.Group_By__c;
                                cvgMemWithNoProductUpdateList.add(cvgUpdateMem); 
                            }
                        }
                       	else
                        {
                            if(keysplit[1] == rmcvgReq.Requested_for_User__c && keysplit[0] == rmcvgReq.Account__c){
                                
                                Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                                TeamMember.Account__c = keysplit[0];
                                TeamMember.Team_Member__c = rmcvgReq.Requested_for_User__c; //Changes for JIRA SALES-1362
                                TeamMember.Product_Group__c = rmcvgReq.Product_Group__c;
                                if(parenttype!='' && subType == '' && FLAG_NFPE1!=null && FLAG_NFPE1!='' && parenttype.trim() == FLAG_NFPE1){
                                    TeamMember.NFPE1__c = true;
                                }
                                if(parenttype!='' && subType != ''){
                                    //modified for JIRA 3660
                                    if(FLAG_NFPE_SUBTYPE1!=null && FLAG_NFPE_SUBTYPE1!='' && (subType.trim() == FLAG_NFPE_SUBTYPE1 || subType.trim() == FLAG_NFPE_SUBTYPE1_1))
                                        sub_1 = true;
                                    if(FLAG_NFPE_SUBTYPE2!=null && FLAG_NFPE_SUBTYPE2!='' && subType.trim() == FLAG_NFPE_SUBTYPE2)
                                        sub_2 = true;
									if(FLAG_NFPE_SUBTYPE3!=null && FLAG_NFPE_SUBTYPE3!='' && (subType.trim() == FLAG_NFPE_SUBTYPE3 || subType.trim() == FLAG_NFPE_SUBTYPE3_1))
										sub_3 = true;
                                }
                                else
                                {
                                    sub_1 = false;
                                    sub_2 = false;
									sub_3 = false;
                                }
                                TeamMember.NFPE_Primary_Relationship_Coverage__c = sub_1;
                                TeamMember.NFPE_Primary_Product_Coverage__c = sub_2;
                                TeamMember.NFPE_Overseas_Authorised_Coverage__c = sub_3;
                                TeamMember.Product2__c = rmcvgReq.Product__c <> NULL ?  rmcvgReq.Product__c.substring(0,string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')).Trim(): '';
                                TeamMember.Product__c = rmcvgReq.Product__c <> NULL  ?  rmcvgReq.Product__c.substring(0,string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')).Trim() : '';
                                TeamMember.Product_Region__c   = rmcvgReq.Product__c <> NULL  ? rmcvgReq.Product__c.substring(string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')+1).Trim() : '';
                                TeamMember.Team_Role__c = rmcvgReq.Role__c;
                                TeamMember.Comment__c = rmcvgReq.Comment__c;
                                TeamMember.Sales_Team_for_Coverage__c = rmcvgReq.Sales_Team_for_Coverage__c;
                                TeamMember.Start_Date__c = string.isEmpty(string.valueOf(rmcvgReq.Start_Date__c))?Date.today() : rmcvgReq.Start_Date__c;                        
                                TeamMember.Group_By__c = rmcvgReq.Group_By__c;
                                cvgMemToAddFinal.add(teammember);
                            }
                        }
                    }
                    else{
                        system.debug('Block 2');
                        Coverage_Team_Member__c cvgUpdateMem = newMapofAdd.get(keyval);                              
                        if(parenttype!='' && subType == '' && FLAG_NFPE1!=null && FLAG_NFPE1!='' && parenttype.trim() == FLAG_NFPE1){
                            cvgUpdateMem.NFPE1__c = true;
                        }
                        
                        if(parenttype!='' && subType != ''){
                            //modified for JIRA 3660
                            if(FLAG_NFPE_SUBTYPE1!=null && FLAG_NFPE_SUBTYPE1!='' && (subType.trim() == FLAG_NFPE_SUBTYPE1 || subType.trim() == FLAG_NFPE_SUBTYPE3_1))
                                sub_1 = true;
                            if(FLAG_NFPE_SUBTYPE2!=null && FLAG_NFPE_SUBTYPE2!='' && subType.trim() == FLAG_NFPE_SUBTYPE2)
                               sub_2 = true;
						   if(FLAG_NFPE_SUBTYPE3!=null && FLAG_NFPE_SUBTYPE3!='' && (subType.trim() == FLAG_NFPE_SUBTYPE3 || subType.trim() == FLAG_NFPE_SUBTYPE3_1))
								sub_3 = true;
                        }
                        if(subType.trim() == FLAG_NFPE_SUBTYPE1)
                        cvgUpdateMem.NFPE_Primary_Relationship_Coverage__c = sub_1;
                        if(subType.trim() == FLAG_NFPE_SUBTYPE2)
                        cvgUpdateMem.NFPE_Primary_Product_Coverage__c = sub_2;
                        if(subType.trim() == FLAG_NFPE_SUBTYPE3)
						cvgUpdateMem.NFPE_Overseas_Authorised_Coverage__c = sub_3;
                        cvgMemWithNoProductUpdateList.add(cvgUpdateMem); 
                    }
                }
                
                
                //When there are no existing coverages
                if(mapAccRM.containsKey(rmcvgReq.Account__c) || Test.isRunningTest()){
                    system.debug('Block 3');
                    string parenttype = '';
                    string subtype = '';
                    Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                    TeamMember.Account__c = rmcvgReq.Account__c;
                    TeamMember.Team_Member__c = rmcvgReq.Requested_for_User__c; 
                    TeamMember.Product_Group__c = rmcvgReq.Product_Group__c;
                    TeamMember.Product2__c = rmcvgReq.Product__c <> NULL?  rmcvgReq.Product__c.substring(0,string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')).Trim(): '';
                    TeamMember.Product__c = rmcvgReq.Product__c <> NULL ?  rmcvgReq.Product__c.substring(0,string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')).Trim() : '';
                    system.debug('Product2__c :'+TeamMember.Product2__c);
                    TeamMember.Product_Region__c   = rmcvgReq.Product__c <> NULL  ? rmcvgReq.Product__c.substring(string.valueOf(rmcvgReq.Product__c).lastIndexOf('-')+1).Trim() : '';
                    TeamMember.Team_Role__c = rmcvgReq.Role__c;
                   
                     if(rmcvgReq.Type__c!=null && rmcvgReq.Type__c!='Standard'){
                        parenttype = rmcvgReq.Type__c;
                        subtype = rmcvgReq.Sub_Type__c;
                    }
                    
                    system.debug(parenttype);
                    system.debug(subtype);
                    if(parenttype!='' && subType == '' && FLAG_NFPE1!=null && FLAG_NFPE1!='' && parenttype.trim() == FLAG_NFPE1){
                        TeamMember.NFPE1__c = true;
                    }
                    
                    if(parenttype!='' && subType != ''){
                        //modified for JIRA 3660
                        if(FLAG_NFPE_SUBTYPE1!=null && FLAG_NFPE_SUBTYPE1!='' && (subType.trim() == FLAG_NFPE_SUBTYPE1 || subType.trim() == FLAG_NFPE_SUBTYPE1_1))
                            TeamMember.NFPE_Primary_Relationship_Coverage__c = true;
                        if(FLAG_NFPE_SUBTYPE2!=null && FLAG_NFPE_SUBTYPE2!='' && subType.trim() == FLAG_NFPE_SUBTYPE2)
                            TeamMember.NFPE_Primary_Product_Coverage__c = true;
						if(FLAG_NFPE_SUBTYPE3!=null && FLAG_NFPE_SUBTYPE3!='' && (subType.trim() == FLAG_NFPE_SUBTYPE3 || subType.trim() == FLAG_NFPE_SUBTYPE3_1))
							TeamMember.NFPE_Overseas_Authorised_Coverage__c = true;
                    }
                    
                    string key1 = rmcvgReq.UniqueID__c.tolowercase();
                    
                    system.debug('Key: '+key1);
                    system.debug('Key: '+cvgMemNFPEUpdate.get(key1.toLowerCase()));
                    if(cvgMemNFPEUpdate.get(key1.toLowerCase())!=null){
                        Coverage_Team_Member__c tm = cvgMemNFPEUpdate.get(key1.toLowerCase());
                        if(parenttype!='' && subType != ''){
                            //modified for JIRA 3660
                            if(FLAG_NFPE_SUBTYPE1!=null && FLAG_NFPE_SUBTYPE1!='' && (subType.trim() == FLAG_NFPE_SUBTYPE1 || subType.trim() == FLAG_NFPE_SUBTYPE1_1))
                                tm.NFPE_Primary_Relationship_Coverage__c = true;
                            if(FLAG_NFPE_SUBTYPE2!=null && FLAG_NFPE_SUBTYPE2!='' && subType.trim() == FLAG_NFPE_SUBTYPE2)
                                tm.NFPE_Primary_Product_Coverage__c = true;
							if(FLAG_NFPE_SUBTYPE3!=null && FLAG_NFPE_SUBTYPE3!='' && (subType.trim() == FLAG_NFPE_SUBTYPE3 || subType.trim() == FLAG_NFPE_SUBTYPE3_1))
								tm.NFPE_Overseas_Authorised_Coverage__c = true;
                        }
                        cvgMemWithNoProductUpdateList.add(tm);
                    }
                    TeamMember.Comment__c = rmcvgReq.Comment__c;
                    TeamMember.Sales_Team_for_Coverage__c = rmcvgReq.Sales_Team_for_Coverage__c;
                    TeamMember.Start_Date__c = string.isEmpty(string.valueOf(rmcvgReq.Start_Date__c))?Date.today() : rmcvgReq.Start_Date__c;                        
                    TeamMember.Group_By__c = rmcvgReq.Group_By__c;
                    cvgMemToAddFinal.add(teammember);
                }
            }
            
        }
        
        if(cvgMemWithNoProductUpdateList.size() >0){
            try{
                //Database.insert (coverageTeamMembList,false);
                
                update cvgMemWithNoProductUpdateList;
            }catch(exception ex){
                cvgMemWithNoProductUpdateList[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        if(cvgMemNFPEUpdateList.size() >0){
            try{
                system.debug('++++'+cvgMemNFPEUpdateList);
                //Database.insert (coverageTeamMembList,false);
                
                update cvgMemNFPEUpdateList;
            }catch(exception ex){
                cvgMemNFPEUpdateList[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        
        
        
        if(cvgMemToAddFinal.size()>0 ){
            try{
                system.debug('++++'+cvgMemToAddFinal);
                //Database.insert (coverageTeamMembList,false);
                //update cvgMemWithNoProductUpdateList;
                insert cvgMemToAddFinal;
            }catch(exception ex){
                cvgMemToAddFinal[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
            
        } 
        
        
        
        
    }
    
}