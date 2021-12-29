global without sharing class CoverageBulkUploadUtility {
    
    public static Set<string> csvRGIds;
    public static Set<string> csvRGIdsDelete;
    public static Set<string> csvRMIds;
    public static Set<string> csvSalesCodes;
	public static Set<string> csvSalesCodes_Delete;
    public static Set<string> csvRMSalesCodes;
    public static Set<Id> teamCoverageIds;
    public static Set<string> action;
    public static Set<string> Roles;
    public static Set<string> productGroup;
    public static Set<string> productRegion;
    public static Set<string> productName;
    public static Set<string> productRegionSet;
    public static Map<string,string> rgMap;
    public static Map<string,string> rgMapDelete;
    public static Map<string,Boolean> rgMapAccStatus;
    public static Map<string,string> rgMapAccName;
    public static Map<string,string> rmMapAccName;
    public static Map<string,string> rmMapBillingCode;
    public static Map<string,Boolean> rmMapAccStatus;
    public static Map<string,Boolean> rmMapAccRestricted;
    public static Map<string,Id> rmMap;
    public static Map<string,Account> rmMapBySalesCode;
    public static Map<string,Sales_Team_for_Coverage__c> mapSalesCodeByTeamCoverageId; 
    public static Set<Id> salesCodeOwnerIds;
    public static Map<String,List<Coverage_Team_Member__c>> coverageMap;
    public static Map<String,String> FunctionAccess;
    public static boolean isCoverageTool = false;
    
    
    global static string accessByProfile(string profileName){
        
        Map<String,String> FunctionAccess = new Map<String,String>();
        FunctionAccess.put('Nomura - Sales', '$Label.c.Label_My_Coverage_Group_Level#$Label.c.Label_All_Coverage_Group_Level#$Label.c.Label_All_Coverage_Group_Level');
        FunctionAccess.put('Nomura - Sales Desk Heads', 'MyCoverage#AllCoverage#PendingRequests');
        FunctionAccess.put('Nomura - Business Management', 'MyCoverage#AllCoverage#PendingApprovals#BulkCoverage');
        FunctionAccess.put('Nomura - Business Management', 'MyCoverage#AllCoverage#PendingApprovals#BulkCoverage');
        FunctionAccess.put('Nomura - Assistant','MyCoverage#AllCoverage#BulkCoverage');
        FunctionAccess.put('Nomura - Structuring','MyCoverage#AllCoverage#PendingRequests');
        FunctionAccess.put('Instinet - Sales','MyCoverage#AllCoverage#PendingRequests');
        FunctionAccess.put('Instinet - Business Management','MyCoverage#AllCoverage#PendingApprovals#BulkCoverage');
        
        return FunctionAccess.get(profileName);
          
    }
    
   
	
    public CoverageBulkUploadUtility()
    {
        rmMapBySalesCode = new Map<string,Account>();
        
    }
    global static void storeRGMap(Set<string> rgIds) 
    {
        rgMap = new Map<string,string>();
        rgMapAccStatus = new Map<string,Boolean>();
        rgMapAccName = new Map<string,string>();
        for(Account acc : [select Id, Name,RDM_Org_ID__c, Active__c from Account where RDM_Org_ID__c in: rgIds])
        {
            rgMap.put(acc.RDM_Org_ID__c,acc.Id);
            rgMapAccStatus.put(acc.RDM_Org_ID__c,acc.Active__c);
            rgMapAccName.put(acc.RDM_Org_ID__c,acc.Name);
        }
    }
    
    /*global static void storeRGMapDelete(Set<string> rgIds) 
    {
        rgMapDelete = new Map<string,string>();
        for(Account acc : [select Id, RDM_Org_ID__c, Active__c from Account where RDM_Org_ID__c in: rgIds])
        {
            rgMapDelete.put(acc.RDM_Org_ID__c,acc.Id);
        }
    }*/
    
    global static void storeRMMap(Set<string> rmIds) 
    {
        rmMap = new Map<string,Id>();
        rmMapAccStatus = new Map<string,Boolean>();
        rmMapAccName = new Map<string,string>();
        rmMapBillingCode = new Map<string,string>();
        rmMapAccRestricted = new Map<string,Boolean>();
        for(Account acc : [select Id,Name,Domicile_country__c,RDM_Org_ID__c,Parent.RDM_Org_ID__c,BillingCountryCode,Restricted_Flag__c,BillingCountry,Closing_Date__c,Active__c from Account where RDM_Org_ID__c in: rmIds])
        {
            CoverageBulkUploadController.rmrgmap.put(acc.RDM_Org_ID__c,acc.Parent.RDM_Org_ID__c);
            rmMap.put(acc.RDM_Org_ID__c,acc.Id);
            rmMapAccStatus.put(acc.RDM_Org_ID__c,acc.Active__c);
            rmMapAccName.put(acc.RDM_Org_ID__c,acc.Name);
            if(acc.Domicile_country__c!=null)
            rmMapBillingCode.put(acc.RDM_Org_ID__c,acc.Domicile_country__c);
            rmMapAccRestricted.put(acc.RDM_Org_ID__c,acc.Restricted_Flag__c);
         }
    }
    global static void getSalesTeamCoverageMap(Set<string> salesCodes)
    {
        teamCoverageIds = new Set<Id>();
        mapSalesCodeByTeamCoverageId = new Map<string, Sales_Team_for_Coverage__c>();
        salesCodeOwnerIds = new Set<Id>();
        mapSalesCodeByTeamCoverageId = CoverageRequestUtility.fetchSalesCodeMapUsingSalesCodeSet(salesCodes,false); 
        for(Sales_Team_for_Coverage__c tm:mapSalesCodeByTeamCoverageId.values())
        {
            if(tm.Coverage_ID__c!=null){
                mapSalesCodeByTeamCoverageId.put(tm.Coverage_ID__c,tm);   
                teamCoverageIds.add(tm.Id);
                salesCodeOwnerIds.add(tm.OwnerId);
            }
        }
    }
    global static void getRoles()
    {
        Roles = new Set<string>();
        Schema.DescribeFieldResult rgfieldResult = Coverage_Team_Member__c.Team_Role__c.getDescribe();
        for(Schema.Picklistentry pe:rgfieldResult.getPicklistValues())
        {
            roles.add(pe.getvalue().toLowerCase());
        }
    }
    global static void getAction()
    {
        action = new Set<string>();
        Schema.DescribeFieldResult rgfieldResult = RG_Coverage_Request__c.Type_of_Coverage__c.getDescribe();
        for(Schema.Picklistentry pe1:rgfieldResult.getPicklistValues())
        {
            action.add(pe1.getvalue().toLowerCase());
        }
    }
    global static void getProductGroup()
    {
        productGroup = new Set<string>();
        Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Product_Group__c.getDescribe();
        for(Schema.Picklistentry pe:fieldResult.getPicklistValues())
        {
            productGroup.add(pe.getvalue().toLowerCase());
        }
    }
    global static void getProductRegion()
    {
        productRegion = new Set<string>();
        Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Product_Region__c.getDescribe();
        for(Schema.Picklistentry pe:fieldResult.getPicklistValues())
        {
            productRegion.add(pe.getvalue().toLowerCase());
        }
    }
    global static void getProductName()
    {
        productName = new Set<string>();
        Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Product2__c.getDescribe();
        for(Schema.Picklistentry pe:fieldResult.getPicklistValues())
        {
            productName.add(pe.getvalue().toLowerCase());
        }
    }
    global static void getProductRegionSet()
    {
        productRegionSet = new Set<string>();
        Schema.DescribeFieldResult fieldResult = Coverage_Access_Request__c.Product__c.getDescribe();
        for(Schema.Picklistentry pe:fieldResult.getPicklistValues())
        {
            productRegionSet.add(pe.getvalue().toLowerCase());
        }
    }
    /*
* Send Error Log
*/
    public void emailLog(String subject, string body, string csvFile, string logType, string salesforceTechMessage,Set<string> approverIds)
    {
        Boolean isSandbox = runningInASandbox();
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        String subjectText = '';
        
        
        if(approverIds!=null)
        {
            if(approverIds.size()>0)
            {
                Map<Id,User> userMap = new Map<Id,User>([select id, Name,HomePageLink__c from User where Id in:approverIds]);

                system.debug('Approver IDS: '+approverIds);
                for(string userId: approverIds)
                {
                    Messaging.SingleEmailMessage userEmail = new Messaging.SingleEmailMessage();
                    if(isSandbox)
                    {
                        if(isCoverageTool)
                            subjectText = '[Sandbox - '+getInstanceName()+']: Coverage Submitted : '+'Your Approval needed for Coverage Requests';
                        else
                            subjectText = '[Sandbox - '+getInstanceName()+']: Coverage Bulk Upload : '+'Your Approval needed for Coverage Requests';
                    }
                    else
                    {
                        if(isCoverageTool)
                        subjectText = 'Coverage Submitted : '+'Your Approval needed for Coverage Requests'; 
                        else
                        subjectText = 'Coverage Bulk Upload : '+'Your Approval needed for Coverage Requests';     
                    }
                    userEmail.setSubject(subjectText);
                    string bodytext = 'Hi '+ userMap.get(userId).Name +',<br/><br/>' +
                                      UserInfo.getName()+' has just submitted a Coverage Access Request using Bulk Upload feature.<br/><br/>' +
                        			  'Please approve or reject this request by using the link below:<br/>'+userMap.get(userId).HomePageLink__c+'<br/><br/>Thank You.';
                    userEmail.setHtmlBody(bodytext);
                    userEmail.setToAddresses(new String[]{userId}); //To
                    userEmail.setOrgWideEmailAddressId(owea.get(0).Id);
                    userEmail.setReplyTo(owea.get(0).Address);
                    Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{userEmail});
                    displayEmailStatus(sendEmailResults,'Owner Emails');
                }
                
            }
        }
        else
        {
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); //User
            Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage(); //Sales Tech
            
            //defining Subject
            if(isSandbox)
            {
                if(isCoverageTool)
                    subjectText = '[Sandbox - '+getInstanceName()+']: Coverage Submitted : '+subject;
                else
                    subjectText = '[Sandbox - '+getInstanceName()+']: Coverage Bulk Upload : '+subject;
            }
            else
            {
                 if(isCoverageTool)
                     subjectText = 'Coverage Submitted : '+subject; 
                else
                    subjectText = 'Coverage Bulk Upload : '+subject; 
            }
            //defining To's
            if((subject=='ERRORS' || subject == 'ERROR') && logType == 'User') //Validation email - User
            {
                
                mail1.setToAddresses(new String[]{UserInfo.getUserEmail()}); //To
                mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                mail1.setReplyTo(owea.get(0).Address);
                mail1.setSubject(subjectText);
                if(csvFile!=null && subject == 'ERRORS')
                {
                    mail1.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,'Coverage')}); 
                }
                mail1.setPlainTextBody(body);
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
                displayEmailStatus(sendEmailResults,'User');
            }
            else if(subject=='FAILURE') //Failure
            {
                system.debug('body: '+body);
                if(salesforceTechMessage!=null)      
                {   
                    mail1.setToAddresses(new String[]{UserInfo.getUserEmail()});
                    mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail1.setReplyTo(owea.get(0).Address);
                    mail1.setSubject(subjectText);
                    mail1.setPlainTextBody(body);
                    
                    mail2.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail2.setReplyTo(owea.get(0).Address);
                    mail2.setToAddresses(new String[]{owea.get(0).Address}); //To Sales Tech  
                    mail2.setSubject(subjectText+'<'+UserInfo.getUserName()+'>');
                    mail2.setPlainTextBody(salesforceTechMessage);
                    
                    if(csvFile!=null && subject == 'FAILURE')
                    {
                        mail1.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,'Coverage')}); 
                        mail2.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,'Coverage')}); 
                    }
                    Messaging.sendEmailResult[] sendEmailResults1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
                    Messaging.sendEmailResult[] sendEmailResults2 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail2});
                    displayEmailStatus(sendEmailResults1,'User');
                    displayEmailStatus(sendEmailResults2,'Salesforce Tech');
                }
                else
                {
                    mail1.setToAddresses(new String[]{UserInfo.getUserEmail()});
                    mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail1.setReplyTo(owea.get(0).Address);
                    mail1.setSubject(subjectText);
                    mail1.setPlainTextBody(body);
                    Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
                    displayEmailStatus(sendEmailResults,'User');
                }
            }
            else //Success
            {
                mail1.setToAddresses(new String[]{UserInfo.getUserEmail()}); //To
                mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                mail1.setReplyTo(owea.get(0).Address);
                mail1.setSubject(subjectText);
                mail1.setPlainTextBody('Regards,\nSalesforce Tech');
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
                displayEmailStatus(sendEmailResults,'User');
            }
        }
       
        
       
        
        
    }
    public void displayEmailStatus(Messaging.SendEmailResult[] sendEmailResults,string logtype)
    {
        for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
            if(sendEmailResult.isSuccess()){
                system.debug(logtype+': Email Successfully sent.'); 
            }
        }
    }
    public Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    public Messaging.EmailFileAttachment getAttachmentContent(string csvFile,string ObjectName)
    {
        Messaging.EmailFileAttachment errorattachment = new Messaging.EmailFileAttachment();
        Blob errorcsv = Blob.valueOf(csvFile);
        errorattachment.setFileName(ObjectName+'-Error.csv');
        errorattachment.setBody(errorcsv);        
        return errorattachment;
    }
    public String getInstanceName() {
        return [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
    }
}