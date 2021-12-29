public with sharing class CallReportControllerExtension {
  
  
public static String getDefaultCoveredAccountOppoData(String accountId){
      String opportunityId = '';
      String userId = UserInfo.getUserId();
      if(accountId != null){
          List<Opportunity> opportunityList = [Select Id FROM Opportunity WHERE Account__c = :accountId AND RecordType.DeveloperName NOT IN ('Cross_Sell_Referral', 'Inactive_Opportunity') ];
          List<Event> eventList = [SELECT Id, OwnerId, WhatId FROM Event 
                                WHERE OwnerId = :userId AND WhatId IN :opportunityList 
                                Order By CreatedDate DESC LIMIT 1];
        for(Event eventObj : eventList){
            opportunityId = eventObj.WhatId;
        }
      }
      return opportunityId;
    }
}