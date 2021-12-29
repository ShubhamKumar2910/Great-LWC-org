/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This is a controller class for lightning component c:AnnouncementConsole
**
**/ 
public without sharing class AnnouncementConsoleController {
    @AuraEnabled 
    public static String getGroupURL(String groupName) {
        System.debug('#### AnnouncementConsoleController::getGroupURL()');
        String groupURL;
        try{
        	List<CollaborationGroupMember> CollGrpMemList = [SELECT CollaborationGroupId 
        		FROM CollaborationGroupMember
        		WHERE MemberId = :UserInfo.getUserId() AND
        			CollaborationGroupId IN (SELECT Id FROM CollaborationGroup WHERE Name = :groupName)];
        	if(!CollGrpMemList.isEmpty()) {
        		groupURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+CollGrpMemList[0].CollaborationGroupId;
        	}
        }  catch(Exception ex) {
            System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		throw new AuraHandledException('Error in identifying Group Memberhip : '+ex.getMessage());
        }
        System.debug('Group URL : '+groupURL);
        return groupURL;
    }
}