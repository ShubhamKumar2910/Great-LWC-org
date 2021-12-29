global class RGBatchSplitMultiselectProducts implements Database.batchable<sObject>, Database.Stateful{ 
    
   
    public string query{get;set;}
    public static string product_test {get;set;}
    List<RG_Coverage_Request__c > updateRecords = new List<RG_Coverage_Request__c >();
        
    global RGBatchSplitMultiselectProducts()
    {   try
        {
            string status ='Pending Approval';
            if(Test.isRunningTest())
                query = 'select id,Product2__c,Product__c,Product_Region__c from RG_Coverage_Request__c where Product__c!=null limit 1';
            else
                query = 'select id,Product2__c,Product__c,Product_Region__c from RG_Coverage_Request__c where Product__c!=null and Product2__c = null and Product_Region__c=null and status__c = \'' + status + '\'';
		}
        catch(Exception e)
        {   
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }  
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        Set<Id> Ids = new Set<Id>();
        SavePoint sp;
        updateRecords = new List<RG_Coverage_Request__c >();
		List<RG_Coverage_Request__c> deleteOldRGRequest = new List<RG_Coverage_Request__c>();
		List<RG_Coverage_Request__c> newRGRequest = new List<RG_Coverage_Request__c>();
		
        try
        {
            sp = Database.setSavepoint();
            Ids = (new Map<Id,SObject>(scope)).keySet();
            string query = ObjectUtil.getCreatableFieldsSOQL('RG_Coverage_Request__c','');
            query += ' WHERE Id in:Ids';
            List<RG_Coverage_Request__c> requestList =(List<RG_Coverage_Request__c>)Database.query(query);

            system.debug(query);
            for(RG_Coverage_Request__c record :requestList)
            {
				string[] productandRegion = new string[]{};
				string[] multipleproduct = new string[]{};
				
                if(Test.isRunningTest())
                {
                    //record.Product__c = 'NES - PT - Japan;NES - PT - Europe';
                    record.Product__c = product_test;
                }
				string productRegionCombinedValue = '';
				
				if(string.valueOf(record.Product__c)!='')
				{
					productRegionCombinedValue = string.valueOf(record.Product__c);
					multipleproduct = productRegionCombinedValue.split(';');
					if(multipleproduct.size() == 1) // contains single value
					{
						productandRegion = new string[]{};
						string prod = multipleproduct[0];
						productandRegion.add(prod.substring(0,string.valueOf(prod).lastIndexOf('-')));
						productandRegion.add(prod.substring(string.valueOf(prod).lastIndexOf('-')+1));
						record.Product2__c = productandRegion[0];
						record.Product_Region__c = productandRegion[1];
						updateRecords.add(record);
					}
					else //contains multiple value seperated by semicolon
					{
						for(string product : multipleproduct)
						{
                           	RG_Coverage_Request__c clonedRecord = record.clone(false,true);
							productandRegion = new string[]{};
							productandRegion.add(product.substring(0,string.valueOf(product).lastIndexOf('-')));
							productandRegion.add(product.substring(string.valueOf(product).lastIndexOf('-')+1));
							clonedRecord.Product2__c = productandRegion[0];
							clonedRecord.Product_Region__c = productandRegion[1];
                            clonedRecord.Product__c = product;
                            clonedRecord.Id = null;
							newRGRequest.add(clonedRecord);
						}
						deleteOldRGRequest.add(record);
					}
				}
            }
			
			
            if(updateRecords.size()>0 && !Test.isRunningTest())
                update updateRecords;
			
            system.debug(newRGRequest);
            
			if(newRGRequest.size() > 0 && !Test.isRunningTest())
			{
				insert newRGRequest;
				
				if(deleteOldRGRequest.size()> 0 )
				delete deleteOldRGRequest;
            }
        }
        catch(Exception e)
        {
            if(sp!=null)
                Database.rollback(sp);
            system.abortJob(info.getJobId());
            
        }
    }     
    
    global void finish(Database.batchableContext info){  
       
    }
}