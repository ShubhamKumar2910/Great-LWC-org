global class US_Monthly_Emails implements Database.Batchable<sObject>,Database.stateful {    
    global Set<String> supervisorreportees = new Set<String>();
    global Set<ID> supRept = new Set<ID>();
    global US_Monthly_Emails(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
         string query = 'SELECT Supervisor_Name__c,Supervisor_Role_Id__c,Supervisor_Role_Name__c,Supervisor_User_Id__c,Supervisor_Email_Address__c FROM Supervisors__c WHERE Supervisor_Role_Name__c LIKE \'%Team Head%\' OR Supervisor_Role_Name__c LIKE \'%Desk Head%\'';
        system.debug('Sam start here...');         
        return Database.getQueryLocator(query);
    }
    
    
    private string AddAllIndirectReportees(Set<ID> reporteeSup, ID CurrentReportee,Set<String> supervisorReportee, Integer counter, List<AggregateResult> cvgs, Set<ID> cvgUser){
        string body ='';
        if(CurrentReportee <> null){
        if(reporteeSup.contains(CurrentReportee)){
                        for(string rv : supervisorReportee){
                            string [] arr = rv.split('#');                              
                            if(arr[1] == CurrentReportee){     
                                if(cvgUser.contains(arr[0])){
                                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+arr[3] +' ['+ arr[2] + ']' +'<ul></td>';
                                    counter = 1;
                                    for(AggregateResult cvgData : cvgs){                        
                                        
                                        if(cvgData.get('userId') == arr[0]){
                                            
                                            if(counter==1){
                                                counter = counter + 1; 
                                                body +='<td>'  + cvgData.get('AccountName')  + '</td><td>' + date.valueOf(cvgData.get('cvgStartDate')).format() + '</td></tr>';
                                            }
                                            else
                                            {
                                                body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style=border-top:0;border-bottom:0></td><td>'  + cvgData.get('AccountName')   + '</td><td>' + date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                else
                                {
                                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+arr[3] +' ['+ arr[2] + ']' +'<ul></td><td align="left"></td><td></td></tr>';
                                }
                                
                             body+=  AddAllIndirectReportees(reporteeSup,arr[0],supervisorReportee,counter,cvgs,cvgUser);
                                
                            }
                        }
                    }
        }
        
        return body;
    }
    
    private Set<String> GetIndirectReportees(Set<ID> ReporteeUserId){
        
        if(ReporteeUserId.size() > 0){
            Set<ID> superviseId = new Set<ID>();
            Set<ID> reportees = new Set<ID>();
            List<Supervisors__c> reporteeSupervisor = [SELECT Supervisor_Name__c,Supervisor_Role_Id__c,Supervisor_Role_Name__c,Supervisor_User_Id__c,Supervisor_Email_Address__c FROM Supervisors__c
                                                       WHERE Supervisor_User_Id__c IN : ReporteeUserId];
            for(Supervisors__c rptsup : reporteeSupervisor){
                superviseId.add(rptsup.Supervisor_User_Id__c);
            }
            
            List<Reportees__c> reportee = [SELECT Reportee_Role_Id__c, Reportee_Role_Name__c ,Reportee_User_Id__c, Reportee_User_Name__c,Supervisor_Id__c,Reportee_Email__c
                                           FROM Reportees__c WHERE Supervisor_Id__c IN:superviseId Order by Reportee_Role_Name__c, Reportee_User_Name__c];
            
            for(Reportees__c rptee : reportee){
                if(!supRept.contains(rptee.Reportee_User_Id__c)){
                    supRept.add(rptee.Reportee_User_Id__c);
                    reportees.add(rptee.Reportee_User_Id__c);
                    supervisorreportees.add(rptee.Reportee_User_Id__c + '#'+ rptee.Supervisor_Id__c + '#' +rptee.Reportee_Role_Name__c + '#' + rptee.Reportee_User_Name__c) ;    
                }
            }
            GetIndirectReportees(reportees);
        }
        system.debug('supervisorreportees :'+ supervisorreportees);
        return supervisorreportees;
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        system.debug('Sam execute here...');
        
        Set<ID> supervisorUserId = new Set<ID>();
        Set<ID> UserId = new Set <ID>();
        Set<ID> cvgUser = new Set<ID>();
        Set<String> supervisorReportee = new Set<String>();
        Set<ID> reporteeSup = new Set<ID>();
        Map<string,String> suprepteedata = new Map<String,String>();
        List<GroupMember> excludedSupervisors = [SELECT UserOrGroupId from GroupMember where GroupID in (Select ID from Group where name ='Compliance Exclusion')];
        Set<ID> excludedIDs = new SET<ID>();        
        for(GroupMember grp : excludedSupervisors){
            excludedIds.add(grp.UserOrGroupId);
        }
        List<Supervisors__c> supervisors = (List<Supervisors__c>)scope;
        for(Supervisors__c supervisor : supervisors){
            
            supervisorUserId.add(supervisor.Supervisor_User_Id__c);
            UserId.add(supervisor.Supervisor_User_Id__c);
            
        }
        List<Reportees__c> reportees = new List<Reportees__c>();
        List<AggregateResult> cvgs = new List<AggregateResult>();
        
        reportees =  [SELECT Reportee_Role_Id__c, Reportee_Role_Name__c ,Reportee_User_Id__c, Reportee_User_Name__c,Supervisor_Id__c,Reportee_Email__c
                      FROM Reportees__c WHERE Supervisor_Id__c IN:supervisorUserId Order by Reportee_Role_Name__c, Reportee_User_Name__c];
        
        
        for(Reportees__c reportee : reportees){
            UserId.add(reportee.Reportee_User_Id__c);
        }
        
        supervisorReportee = GetIndirectReportees(UserId);
        
        system.debug('supervisorReportee :' + supervisorReportee); 
        
        if(supervisorReportee.size() > 0){        
            for(string rval : supervisorReportee) {
                string [] arr = rval.split('#');
                UserId.add(arr[0]);
                reporteeSup.add(arr[1]);
                
            }
        }
        
        system.debug('reporteeSup :' + reporteeSup); 
        
        cvgs = [SELECT Coverage_Start_Date__c cvgStartDate,RG_Account_Name__c AccountName,User_Id__c userId FROM Coverage__c WHERE User_Id__c IN : UserId
              group by Coverage_Start_Date__c,RG_Account_Name__c,User_Id__c  order by RG_Account_Name__c];
        
        for(AggregateResult cvgdt : cvgs){
            cvgUser.add((ID) cvgdt.get('userId'));
        }
        
        for(Supervisors__c supervisor : supervisors) {
            system.debug('supervisor : '+ supervisor);
            String [] toAddresses = new List<String>(); 
            Messaging.SingleEmailMessage  emailSalesHead = new Messaging.SingleEmailMessage();
            //EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
            //Name = 'Americas_Supervisor_Email']; 
            //emailSalesHead.Subject = 'Email: RG Coverage Information';  
            emailSalesHead.setSubject('MONTHLY REPORT : Account Coverage Information');
            
            List<Supervisors__c> supAtSameRole = [SELECT Supervisor_Name__c,Supervisor_Role_Id__c,Supervisor_Role_Name__c,Supervisor_User_Id__c,Supervisor_Email_Address__c,Manager__c FROM Supervisors__c
                                                WHERE Supervisor_Role_Id__c =: supervisor.Supervisor_Role_Id__c 
                                                 AND Manager__c =: supervisor.Supervisor_User_Id__c];
            
            
            
            String body = '<Table><tr><td><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 #A5A5A5><tr><td style=border:none;background:#CA2420;padding:0in 0in 0in 0in><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white>' + supervisor.Supervisor_Name__c  + '</td><td style=border:none;background:#CA2420;padding:0in 0in 0in 0in><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white>' + ' (' + supervisor.Supervisor_Role_Name__c + ')' + '</td><td style=border:none;background:#CA2420;></td></tr>';
            // String body = '<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b> '
            Integer counter = 1;
            for(AggregateResult cvgData : cvgs){
                if(cvgData.get('userId') == supervisor.Supervisor_User_Id__c)  { 
                    if(counter==1){
                        counter = counter +1;
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul><b>Coverage </b></ul></td><td align="left">'  + cvgData.get('AccountName')  + '</td><td>'  +  date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                    }
                    else
                    {
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style=border-top:0;border-bottom:0></td> <td align="left">'  + cvgData.get('AccountName')  + '</td><td>'  + date.valueOf(cvgData.get('cvgStartDate')).format() + '</td></tr>';  
                    }
                }
            }
            
            for(Supervisors__c supatsmeRole : supAtSameRole){
                counter = 1;
               for(AggregateResult cvgData : cvgs){
                if(cvgData.get('userId') == supatsmeRole.Supervisor_User_Id__c)  { 
                    if(counter==1){
                        counter = counter +1;
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+ supatsmeRole.Supervisor_Name__c + '</ul></td><td align="left">'  + cvgData.get('AccountName')  + '</td><td>'  + date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                    }
                    else
                    {
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style=border-top:0;border-bottom:0></td> <td align="left">'  + cvgData.get('AccountName')  + '</td><td>'  + date.valueOf(cvgData.get('cvgStartDate')).format() + '</td></tr>';  
                    }
                }
            } 
            }
            string currentRole;
            string prevRole;
            for(Reportees__c reportee : reportees){
                counter = 1;
                if(reportee.Supervisor_Id__c == supervisor.Supervisor_User_Id__c){
                    currentRole = reportee.Reportee_Role_Name__c;                    
                    if(currentRole <> prevRole){
                        counter = counter + 1;
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Direct Subordinate Role </b></td> <td style=border-bottom:0>&nbsp;&nbsp;</td><td style=border-bottom:0></td></tr>'; 
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b><ul>'+reportee.Reportee_Role_Name__c +'<ul></b></td> <td style=border-top:0;border-bottom:0></td><td style=border-top:0;border-bottom:0></td></tr>';                     
                    }
                    
                    if(cvgUser.contains(reportee.Reportee_User_Id__c)){
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+reportee.Reportee_User_Name__c +'<ul></td>';
                        counter = 1;
                        for(AggregateResult cvgData : cvgs){                        
                            
                            if(cvgData.get('userId') == reportee.Reportee_User_Id__c){
                                
                                if(counter==1){
                                    counter = counter + 1; 
                                    body +='<td>'  + cvgData.get('AccountName')  + '</td><td>' +  date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                                }
                                else
                                {
                                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style=border-top:0;border-bottom:0></td><td>'  + cvgData.get('AccountName')  + '</td><td>' + date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                                }
                            }
                            
                            
                        }
                    }
                    else
                    {
                        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+reportee.Reportee_User_Name__c +'<ul></td><td align="left"></td><td></td></tr>';
                    }
                    
                    if(reporteeSup.contains(reportee.Reportee_User_Id__c)){
                        for(string rv : supervisorReportee){
                            string [] arr = rv.split('#');                              
                            if(arr[1] == reportee.Reportee_User_Id__c){     
                                if(cvgUser.contains(arr[0])){
                                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+arr[3] +' ['+ arr[2] + ']' +'<ul></td>';
                                    counter = 1;
                                    for(AggregateResult cvgData : cvgs){                        
                                        
                                        if(cvgData.get('userId') == arr[0]){
                                            
                                            if(counter==1){
                                                counter = counter + 1; 
                                                body +='<td>'  + cvgData.get('AccountName')  + '</td><td>' + date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                                            }
                                            else
                                            {
                                                body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style=border-top:0;border-bottom:0></td><td>'  + cvgData.get('AccountName')   + '</td><td>' + date.valueOf(cvgData.get('cvgStartDate')).format()+ '</td></tr>';
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                else
                                {
                                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul>'+arr[3] +' ['+ arr[2] + ']' +'<ul></td><td align="left"></td><td></td></tr>';
                                }
                                
                              body+=AddAllIndirectReportees(reporteeSup,arr[0],supervisorReportee,counter,cvgs,cvgUser);
                                
                            }
                        }
                    }
                    
                    prevRole = reportee.Reportee_Role_Name__c;
                    
                    
                }
            }
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><ul><b>END OF REPORT<ul></td><td align="left"><b> END OF REPORT</b></td><td><b>END OF REPORT</b></td></tr>';
            //toAddresses.add('vipinkumar.pillai@nomura.com');
            toAddresses.add(supervisor.Supervisor_Email_Address__c);
            emailSalesHead.setHtmlBody(body);
            //emailSalesHead.HTML = true;
            emailSalesHead.setToAddresses(toAddresses);
            system.debug('before send email');
            Messaging.SendEmailResult [] mailResults;
            if(!excludedIds.contains(supervisor.Supervisor_User_Id__c)){
             mailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailSalesHead}); 
            }
            system.debug('after  send email :'+ mailResults);
            //}
        }
        
    }
    
    
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        
        
    }
    
    
    
    
}