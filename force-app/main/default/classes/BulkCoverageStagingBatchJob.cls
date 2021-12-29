global class BulkCoverageStagingBatchJob implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts{

    global String guid = '';

    public BulkCoverageStagingBatchJob (){        
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get('Bulk_Coverage_Staging__c').getDescribe().fields.getMap().keySet());

        guid = GUIDGenerator.NewGuid();
        
        System.debug('guid: '+guid);
        String query = 'SELECT '+String.join(fields, ',')+' FROM Bulk_Coverage_Staging__c Where CreatedById = \'' + UserInfo.getUserId() + '\'';
        System.debug('Query: '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Bulk_Coverage_Staging__c> bulkCoverageStaging){
        System.debug('bulkCoverageStaging size in execute: '+bulkCoverageStaging.size());
        List<Bulk_Coverage_Staging__c> bcsl = bulkCoverageStaging;
        Set<Coverage_Temp__c> cts = new Set<Coverage_Temp__c>();// Valid coverage to be inserted
        Set<Coverage_Temp__c> ctdel = new Set<Coverage_Temp__c>(); // Coverage existing for deletion
        Map<String, Coverage_Temp__c> ctsrm = new Map<String, Coverage_Temp__c>(); // Duplicate coverage in request objects
        Map<String, Coverage_Temp__c> ctstm = new Map<String, Coverage_Temp__c>(); // Duplicate coverage in coverage team member objects
        Set<Coverage_Temp__c> ctd = new Set<Coverage_Temp__c>(); // Duplicate coverage to be mailed
        Map<String, String> requestToApprovedKeyMap = new Map<String, String>();
        Map<String, String> approvedToRequestKeyMap = new Map<String, String>();

        for(Bulk_Coverage_Staging__c bcs : bcsl){
            Coverage_Temp__c ct = new Coverage_Temp__c();
            //ct.GUID__C = ;
            ct.ACCOUNTID__C = bcs.RG_Account__c != null ? bcs.RG_Account__c : bcs.RM_Account__c != null ? bcs.RM_Account__c : bcs.POD_Account__c;
            ct.ACTION__C = bcs.Action__c;
            ct.CLIENTKEY__C = bcs.RM_POD_RDM_Org_Id__c;
            ct.CLIENTRGKEY__C = bcs.RG_RDM_Org_Id__c;
            ct.COUNTRY__C = bcs.RM_Country__c;
            ct.FROMDATE__C = bcs.Date__c;
            ct.GROUP_BY__C = bcs.Group_By__c;
            ct.IS_DUMMY__C = bcs.IS_Dummy__c;
            ct.IS_POD_COVERAGE_ERROR__C = bcs.IS_POD_Coverage_Error__c;
            ct.ISATTESTED__C = bcs.Attest__c;
            ct.ISRG__C = bcs.IS_RG__c;
            ct.ISRM__C = bcs.IS_RM__c;
            ct.MANAGERID__C = bcs.Manager__c;
            ct.PARENTROLEID__C = bcs.User_Parent_Role__c;
            ct.PRODUCTGROUP__C = bcs.Product_Group__c;
            ct.PRODUCTNAME__C = bcs.Product__c;
            ct.PRODUCTREGION__C = bcs.Product_Region__c;
            ct.ROLE__C = bcs.Role__c;
            ct.ROLEID__C = bcs.User_Parent_Role__c;
            ct.SALESCODE__C = bcs.Sales_Code__c;
            ct.SALESDESKDIVISION__C = bcs.Sales_Desk_Division__c;
            ct.SALESDESKREGION__C = bcs.Sales_Desk_Region__c;
            ct.SALESTEAMCOVERAGEID__C = bcs.Sales_Team_for_Coverage__c;
            ct.SOURCE__C = bcs.Source__c;
            ct.TEAMMEMBERID__C = bcs.User__c;
            ct.TYPE__C = bcs.Type__c;
        
            ctsrm.put(bcs.Coverage_Request_Unique_Id__c, ct);
            ctstm.put(bcs.Coverage_Unique_Id__c, ct);
            requestToApprovedKeyMap.put(bcs.Coverage_Request_Unique_Id__c, bcs.Coverage_Unique_Id__c);
            approvedToRequestKeyMap.put(bcs.Coverage_Unique_Id__c, bcs.Coverage_Request_Unique_Id__c);
        }

        for(RG_Coverage_Request__c r : [Select Id, UniqueID__c, UniqueID_wop__c From RG_Coverage_Request__c Where (UniqueID__c in :ctsrm.keyset() Or UniqueID_wop__c in :ctsrm.keyset()) And Status__c = 'Pending Approval']){
            if(ctsrm.get(r.UniqueID__c) != null){
                ctd.add(ctsrm.get(r.UniqueID__c)); // Add to duplicate list before removing 
                ctsrm.remove(r.UniqueID__c);
                ctstm.remove(requestToApprovedKeyMap.get(r.UniqueID__c));
            }
            if(ctsrm.get(r.UniqueID_wop__c) != null){
                ctd.add(ctsrm.get(r.UniqueID_wop__c)); // Add to duplicate list before removing 
                ctsrm.remove(r.UniqueID_wop__c);
                ctstm.remove(requestToApprovedKeyMap.get(r.UniqueID_wop__c));
            }
        }

        for(Coverage_Access_Request__c r : [Select Id, UniqueID__c, UniqueID_wop__c, ParentUniqueID__c, ParentUniqueID_wop__c, Group_By__c From Coverage_Access_Request__c Where (UniqueID__c in :ctsrm.keyset() Or UniqueID_wop__c in :ctsrm.keyset() Or ParentUniqueID__c in :ctsrm.keyset() Or ParentUniqueID_wop__c in :ctsrm.keyset()) And Status__c = 'Pending Approval']){
            if(ctsrm.get(r.UniqueID__c) != null){ 
                ctd.add(ctsrm.get(r.UniqueID__c)); // Add to duplicate list before removing 
                ctsrm.remove(r.UniqueID__c);
                ctstm.remove(requestToApprovedKeyMap.get(r.UniqueID__c));
            }
        
            if(ctsrm.get(r.UniqueID_wop__c) != null){
                ctd.add(ctsrm.get(r.UniqueID_wop__c)); // Add to duplicate list before removing 
                ctsrm.remove(r.UniqueID_wop__c);
                ctstm.remove(requestToApprovedKeyMap.get(r.UniqueID_wop__c));
            }
            
            if(r.Group_By__c != 'POD'){
                if(ctsrm.get(r.ParentUniqueID_wop__c) != null){
                    ctd.add(ctsrm.get(r.ParentUniqueID_wop__c)); // Add to duplicate list before removing 
                    ctsrm.remove(r.ParentUniqueID_wop__c);
                    ctstm.remove(requestToApprovedKeyMap.get(r.ParentUniqueID_wop__c));
                }
            }
        }

        for(Coverage_Team_Member__c r : [Select Id, UniqueID__c, UniqueId_wop__c, Parent_Key__c, Parent_Key_wop__c, Group_By__c,Team_Role__c From Coverage_Team_Member__c Where (UniqueId__c in :ctstm.keyset() Or UniqueId_wop__c in :ctstm.keyset() Or Parent_Key__c in :ctstm.keyset() Or Parent_Key_wop__c in :ctstm.keyset()) And RecordType.DeveloperName = 'Active_Coverage']){
            if(ctstm.get(r.UniqueID__c) != null && ((Coverage_Temp__c)ctstm.get(r.UniqueID__c)).Action__c != 'delete'){
                ctd.add(ctstm.get(r.UniqueID__c)); // Add to duplicate list before removing 
                ctstm.remove(r.UniqueID__c);
                ctsrm.remove(approvedToRequestKeyMap.get(r.UniqueID__c));
            } else if (ctstm.get(r.UniqueID__c) != null && ((Coverage_Temp__c)ctstm.get(r.UniqueID__c)).Action__c == 'delete' && 
                        ((Coverage_Temp__c)ctstm.get(r.UniqueID__c)).ROLE__C == r.Team_Role__c){
                ctdel.add(ctstm.get(r.UniqueID__c));
            }
            
            if(ctstm.get(r.UniqueId_wop__c) != null && ((Coverage_Temp__c)ctstm.get(r.UniqueId_wop__c)).Action__c != 'delete'){
                ctd.add(ctstm.get(r.UniqueId_wop__c)); // Add to duplicate list before removing 
                ctstm.remove(r.UniqueId_wop__c);
                ctsrm.remove(approvedToRequestKeyMap.get(r.UniqueId_wop__c));
            }
            
            if(r.Group_By__c != 'POD'){	 	
                if(ctstm.get(r.Parent_Key_wop__c) != null && ((Coverage_Temp__c)ctstm.get(r.Parent_Key_wop__c)).Action__c != 'delete'){
                    ctd.add(ctstm.get(r.Parent_Key_wop__c)); // Add to duplicate list before removing 
                    ctstm.remove(r.Parent_Key_wop__c);
                    ctsrm.remove(approvedToRequestKeyMap.get(r.Parent_Key_wop__c));
                }
                
                if (ctstm.get(r.Parent_Key__c) != null && ((Coverage_Temp__c)ctstm.get(r.Parent_Key__c)).Action__c == 'delete' && 
                        ((Coverage_Temp__c)ctstm.get(r.Parent_Key__c)).ROLE__C == r.Team_Role__c){
                    ctdel.add(ctstm.get(r.Parent_Key__c));
                }
            }
        }

        system.debug('ctsrm: '+ctsrm.values().size());
        system.debug('ctstm: '+ctstm.values().size());
        cts.addAll(ctsrm.values()); // Add valid coverage gauged after pending request checks
        cts.addAll(ctstm.values()); // Add valid coverage gauged after approved request checks
        system.debug('ctd: '+ctd.size());
        for(Coverage_Temp__c ct: cts){
            if(ct.Action__c == 'delete' && !ctdel.contains(ct)){       
                ctd.add(ct);
                cts.remove(ct);
            }
        }

        string header = 'RG_Account__r.RDM_Org_ID__c,RM_POD_Account__r.RDM_Org_ID__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Product_Group_Region__c,Product__c,Role__c,Action__c,Date__c,Attest__c\n';
        string finalstr = header; 
        if(ctd !=null && ctd.size()>0){
            system.debug('ctd: '+ctd.size());
            for(Coverage_Temp__c ct: ctd)
            {
                string recordString = (ct.CLIENTRGKEY__C==null? '': ct.CLIENTRGKEY__C)+','+(ct.CLIENTKEY__C==null? '': ct.CLIENTKEY__C)+','+ct.SALESCODE__C+','+(ct.PRODUCTGROUP__C==null? '': ct.PRODUCTGROUP__C+'#'+ct.PRODUCTREGION__C)+','+(ct.PRODUCTNAME__C==null? '': ct.PRODUCTNAME__C)+','+ct.ROLE__C+','+ct.ACTION__C+','+ct.FROMDATE__C+','+ct.ISATTESTED__C+'\n';
                finalstr = finalstr +recordString;
            }
            
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalstr);
            string csvname='Duplicate_Coverage.csv';
            csvAttc.setContentType('text/csv');
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            csvAttc.setInline(false);
            
            MailUtility.sendMailWithAttachment(new String[]{UserInfo.getUserEmail()}, new String[]{}, 'Duplicate coverage add Or Non existing coverage delete attempted', 'Please verify the data being uploaded', new List<Messaging.EmailFileAttachment>{csvAttc});
        }

        system.debug('cts: '+cts.size());
        if(cts.size() > 0){
            List<Coverage_Temp__c> ctl = new List<Coverage_Temp__c>(cts);
            for(Coverage_Temp__c ct : ctl){
                ct.GUID__C = guid;
                system.debug('guid: '+ guid);
                system.debug('Valid ====== CLIENTKEY__C : '+ ct.CLIENTKEY__C + ' CLIENTRGKEY__C : ' + ct.CLIENTRGKEY__C+ ' SALESCODE__C : ' + ct.SALESCODE__C + ' PRODUCTNAME__C : ' + ct.PRODUCTNAME__C + ' PRODUCTREGION__C : ' + ct.PRODUCTREGION__C);        
            }
            insert ctl;
        }
    }

    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new ProcessStagingCoverages(guid), 1);
    }
}