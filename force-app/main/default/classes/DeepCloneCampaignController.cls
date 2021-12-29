public with sharing class DeepCloneCampaignController {
    private ApexPages.StandardController stdCtrl;
    
    public DeepCloneCampaignController(ApexPages.StandardController std) {
       stdCtrl=std;
       Id cid = System.currentPageReference().getParameters().get('id');
        campId = cid;
        	System.debug('in deepclone controller ,get id from id parameter = ' + cid );
        	Campaign[] campgns=[SELECT Id, Name, ParentId, description,status, startdate, enddate, type, isActive
 				FROM Campaign
 				WHERE Id = :cid];
 			camp = campgns.size()>0 ? campgns[0] : new Campaign();
        System.debug('select the camp from database ,id = ' + camp.id + ' orig list =' + campgns);
        System.debug('campaign parent Id ;; ' + camp.ParentId);
    }
    
    public String campId {get; set;}
    
    public String campCloneName{get;set;}
    
    
     
    
    public Campaign camp{ get; set; }
	

    public void PassingParameter(){
        Id recordId = ApexPages.currentPage().getParameters().get('recordId');
        System.debug('PassingParameter Print--->'+recordId );
        contIdChosen = recordId;
         System.debug('PassingParameter campId  ' + camp.ParentId);
        System.debug('PassingParameter contIdChosen ' + contIdChosen);
        camp.ParentId = recordId;
        System.debug('PassingParameter campId After update ' + camp.ParentId);
        //account = [SELECT ID,Industry FROM Account WHERE id=:recordId ]; 
        //return null; 
    } 
            
    
    
    public ID contIdChosen {get; set;}
 
    
    public PageReference clonedeep() {
                
        Campaign campClone;
        
             
        	campClone = camp.clone();//campgns[0].clone(); 
            campClone.Description = camp.description;//campgns[0].description;
        	if(null == campCloneName){
            	campCloneName='Clone_'+camp.Name;
        	}
        
            campClone.Name = campCloneName;
            campClone.Status = camp.Status;//campgns[0].status;
            campClone.StartDate = camp.StartDate;// campgns[0].StartDate;
            campClone.EndDate = camp.EndDate;// campgns[0].EndDate;
            campClone.type = camp.type;//campgns[0].type;
            campClone.IsActive = camp.isActive;//campgns[0].IsActive; 
            //since list_id is  uniq field, shouldnt be duped
            //campClone.List_ID__c = campgns[0].List_ID__c + Datetime.now().gettime();
            campClone.List_ID__c ='';
            
        	System.debug('debug contIdChosen ' + contIdChosen );
            
        	
            campClone.ParentId = (null==contIdChosen)?camp.ParentId:contIdChosen;
            if(null==campClone.ParentId)
                campClone.ParentId = camp.Id;
            insert campClone;
         
        	system.debug('campClone id ' + campClone.id);
        	List<CampaignMember> CampaignMember = new List<CampaignMember>();
            
            Contact[] contacts = [SELECT Id, Name, Phone, Active__c FROM 
        							Contact 
    							WHERE 
        							Id IN (
            							Select contactid from campaignmember 
                                        where campaign.id  = :campid AND ContactId != null) and Active__c=true
								];


        	System.debug('no of contacts '+ contacts.size());
            if(contacts.size()>0){
        		for(Contact c : contacts){
                    if(c.Active__c){
            			System.Debug(c.name);
            			CampaignMember.add(new CampaignMember(       
                			ContactId = c.Id,
                			CampaignId = campClone.id,
                        	Status = 'Done'));   
                    }else{
                        System.debug('Contact is inactive and would not be added : ' + c.id);
                    }
        		}
        		insert CampaignMember;   
        	}
		//}		
        String ref;
        if(null!=campClone.id){
			ref = campClone.id;            
        }else{
            ref = campid;
        }
        PageReference reRend = new PageReference('/'+ref);
		reRend.setRedirect(true);
        return reRend;
    }
    
    public PageReference clonedeepCancel() {        
        PageReference reRend = new PageReference('/'+camp.Id);
		reRend.setRedirect(true);
        return reRend;
    }
	
}