global class SandboxPostRefresh implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        // Insert logic here to prepare the sandbox for use.
        Organization org = [SELECT IsSandbox  FROM Organization];
        Boolean isSandbox = org.IsSandbox;
        System.debug('isSandbox= ' + isSandbox);
        if( isSandbox && !Test.isRunningTest()){
            System.debug('this is a sandbox and its not running test,  run the code');
            //createUsers(context.sandboxName());
            updateCustomSettingsCtrl();
            recreateScheduleJobs();
        }else{
            System.debug('this is for test class or not sandbox, do nothing');
        }

    }

    //this method is  for recreating all scheduled jobs
    void recreateScheduleJobs(){
        System.debug('start recreateScheduleJobs');
        ApexScheduledJobPopulateRelatedToField sclass = new ApexScheduledJobPopulateRelatedToField();
        System.schedule('00 AM Populate Relate To Field Event', '0 0 00 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('01 AM Populate Relate To Field Event', '0 0 01 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('02 AM Populate Relate To Field Event', '0 0 02 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('03 AM Populate Relate To Field Event', '0 0 03 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('04 AM Populate Relate To Field Event', '0 0 04 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('05 AM Populate Relate To Field Event', '0 0 05 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('06 AM Populate Relate To Field Event', '0 0 06 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('07 AM Populate Relate To Field Event', '0 0 07 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('08 AM Populate Relate To Field Event', '0 0 08 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('09 AM Populate Relate To Field Event', '0 0 09 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('10 AM Populate Relate To Field Event', '0 0 10 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('11 AM Populate Relate To Field Event', '0 0 11 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('12 PM Populate Relate To Field Event', '0 0 12 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('13 PM Populate Relate To Field Event', '0 0 13 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('14 PM Populate Relate To Field Event', '0 0 14 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('15 PM Populate Relate To Field Event', '0 0 15 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('16 PM Populate Relate To Field Event', '0 0 16 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('17 PM Populate Relate To Field Event', '0 0 17 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('18 PM Populate Relate To Field Event', '0 0 18 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('19 PM Populate Relate To Field Event', '0 0 19 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('20 PM Populate Relate To Field Event', '0 0 20 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('21 PM Populate Relate To Field Event', '0 0 21 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('22 PM Populate Relate To Field Event', '0 0 22 ? * 1,2,3,4,5,6,7', sclass);
        System.schedule('23 PM Populate Relate To Field Event', '0 0 23 ? * 1,2,3,4,5,6,7', sclass);
        
        ApexSchedJobTaskPopulateRelatedToField stask = new ApexSchedJobTaskPopulateRelatedToField();
        System.schedule('00 AM Populate Task RelatedId', '0 0 00 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('01 AM Populate Task RelatedId', '0 0 01 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('02 AM Populate Task RelatedId', '0 0 02 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('03 AM Populate Task RelatedId', '0 0 03 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('04 AM Populate Task RelatedId', '0 0 04 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('05 AM Populate Task RelatedId', '0 0 05 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('06 AM Populate Task RelatedId', '0 0 06 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('07 AM Populate Task RelatedId', '0 0 07 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('08 AM Populate Task RelatedId', '0 0 08 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('09 AM Populate Task RelatedId', '0 0 09 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('10 AM Populate Task RelatedId', '0 0 10 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('11 AM Populate Task RelatedId', '0 0 11 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('12 PM Populate Task RelatedId', '0 0 12 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('13 PM Populate Task RelatedId', '0 0 13 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('14 PM Populate Task RelatedId', '0 0 14 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('15 PM Populate Task RelatedId', '0 0 15 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('16 PM Populate Task RelatedId', '0 0 16 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('17 PM Populate Task RelatedId', '0 0 17 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('18 PM Populate Task RelatedId', '0 0 18 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('19 PM Populate Task RelatedId', '0 0 19 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('20 PM Populate Task RelatedId', '0 0 20 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('21 PM Populate Task RelatedId', '0 0 21 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('22 PM Populate Task RelatedId', '0 0 22 ? * 1,2,3,4,5,6,7', stask);
        System.schedule('23 PM Populate Task RelatedId', '0 0 23 ? * 1,2,3,4,5,6,7', stask);
        
        
        System.schedule('AccountServiceRankCalculationScheduler', '0 0 16 ? * 1,2,3,4,5,6,7', new AccountServiceRankCalculationScheduler());
        System.schedule('CleanupStagingJob_Coverage', '0 0 02 ? * 1', new CleanupStagingJob_CoverageSchedulable());
        System.schedule('DailyRMFeedJob', '0 0 18 ? * 1,2,3,4,5,6,7', new DailyRMFeedSchedulableClass());
        System.schedule('DeactivateCoverageBatchJobSchedulable', '0 0 03 ? * 1', new DeactivateCoverageBatchJobSchedulable());
        System.schedule('PopulateRoleAndSubordinateBatchScheduler', '0 0 18 ? * 1,2,3,4,5,6,7', new PopulateRoleAndSubordinateBatchScheduler());
        System.schedule('ReplaceNomuraEmpWithUserBatchScheduler', '0 0 17 ? * 1,2,3,4,5,6', new ReplaceNomuraEmpWithUserBatchScheduler());
        System.schedule('Revenue Rank Calculation Job', '0 0 00 ? * 1,3,4,5,6,7', new RevenueRankCalculationScheduler());
        System.schedule('Update Analytic User Defaults', '0 0 00 ? * 2,3,4,5,6', new PopAnalyticUsrDefBatchScheduler());
        System.schedule('UpdateJapanOpptysBatchScheduler', '0 0 20 ? * 2,3,4,5,6', new UpdateJapanOpptysBatchScheduler());
        System.schedule('USComplianceCvgReport', '0 0 07 1 * ?', new USDeleteCoverageData());
        System.schedule('CallReportNotifyToSymphonyBatchJob', '0 0 * * * ?', new CallReportNotifyToSymphonyBatchScheduler());
        System.schedule('NotificationBatchJob', '0 0 * * * ?', new NotificationScheduler());
               
    }


    
    //this method is  for recreating all scheduled jobs
    void createUsers(String sandboxName){
        System.debug('start createUsers');
      /* Fill all mandatory fields */
      Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
      UserRole r = [SELECT Id From UserRole Where Name='Technology' limit 1];     

      List<User> users = new List<User>();  
      User user = new User();
      user.Email ='ahmad.kansouh@nomura.com';
      user.UserName = user.Email + '.'+ sandboxName;
      user.LastName = 'Kansouh';
      user.FirstName='Ahmad';
      user.Alias = 'kansouha';
      user.FederationIdentifier='kansouha';      
      user.UserRoleId=r.Id;
      user.ProfileId = p.Id;
      user.LocaleSidKey='en_US';
      user.LanguageLocaleKey='en_US';
      user.EmailEncodingKey = 'UTF-8';
      user.TimeZoneSidKey = 'GMT';
      user.IsActive=true;
      users.add(user);
      
      user = new User();
      user.Email ='faisal.salim@nomura.com';
      user.UserName = user.Email + '.'+ sandboxName;
      user.LastName = 'Salim';
      user.FirstName='Faisal';
      user.Alias = 'salimf';
      user.FederationIdentifier='salimf';      
      user.UserRoleId=r.Id;
      user.ProfileId = p.Id;
      user.LocaleSidKey='en_US';
      user.LanguageLocaleKey='en_US';
      user.EmailEncodingKey = 'UTF-8';
      user.TimeZoneSidKey = 'GMT';
      user.IsActive=true;
      users.add(user);

      try
     {
          insert users;  // insert the user record
      }
      catch(Exception e)
      {
         System.debug(e);
     
      }
    } //end of createusers


    void updateCustomSettingsCtrl(){
        System.debug('start updateCustomSettingsCtrl');
        // get Nomura Setting custom setting
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getOrgDefaults();
        nomuraSettings.Coverage_URL__c='http://uat-intranet.nomuranow.com/SFDS/grp/get/resendIdAndPasswordResult';
        nomuraSettings.GM_Scorecard_URL__c='http://tokws22167.japan.nom:81/Equities/Scorecard/GMReports/File?';
        nomuraSettings.GRP_Research_URL__c='http://uat-intranet.nomuranow.com/research/';
        nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c='salesforcedev@nomura.com';

        try
        {
            update nomuraSettings;
         }
         catch(Exception e)
         {
            System.debug(e);
        
         } 

    }

}