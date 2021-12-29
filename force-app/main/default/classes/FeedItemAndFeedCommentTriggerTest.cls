@isTest
public class FeedItemAndFeedCommentTriggerTest {

   
    @isTest
    public static void testFeedItemAndFeedCommentTrigger(){
        FeedItem actualFeedItemObj;
        FeedComment actualFeedCommentObj;
        User integrationUserObj;

        //Insert Nomura - Sales User
        Profile nomuraSalesProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];

        User nomuraSalesUserObj = new User();
        nomuraSalesUserObj.Login_ID__c = 'testtmpX';
        nomuraSalesUserObj.Alias = 'testtmpX';
        nomuraSalesUserObj.LastName = 'TestTemp_LN';
        nomuraSalesUserObj.FirstName = 'TestTemp_FN';
        nomuraSalesUserObj.Email = 'TestTempX@testOrg.com';
        nomuraSalesUserObj.UserName = 'TestTempX_NomuraSales@testOrg.com';
        nomuraSalesUserObj.ProfileId = nomuraSalesProfile.Id;
        nomuraSalesUserObj.EmailEncodingKey = 'UTF-8';
        nomuraSalesUserObj.LanguageLocaleKey = 'en_US';
        nomuraSalesUserObj.LocaleSidKey = 'en_US';
        nomuraSalesUserObj.TimeZoneSidKey = 'America/Los_Angeles';
        nomuraSalesUserObj.Region__c = 'Americas';

        insert nomuraSalesUserObj;

        List<User> userList = [SELECT Id, Name, Login_Id__c FROM User WHERE Profile.Name = 'Nomura - Integration' AND Login_Id__c = 'sfadmin' AND IsActive = TRUE];

        if(userList != null && !userList.isEmpty()){
            integrationUserObj = userList.get(0);
        }
        
        
        System.runas(integrationUserObj){
            //Insert FeedItem and FeedComment
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.Body='Test_1';
            feedItemObj.ParentId=integrationUserObj.id;
            insert feedItemObj;

            FeedComment feedCommentObj = new FeedComment();
            feedCommentObj.CommentBody='Test_Comment_1';
            feedCommentObj.FeedItemId=feedItemObj.Id;        
            insert feedCommentObj; 

            //Update FeedItem and FeedComment 
            feedItemObj.Body='Test_2';   
            update feedItemObj;     
            
            feedCommentObj.CommentBody='Test_Comment_2';
            update feedCommentObj;

            //Delete FeedItem and FeedComment
            delete feedCommentObj;
            delete feedItemObj;   
           

            actualFeedItemObj = new FeedItem();
            actualFeedItemObj.Body='Test_3';
            actualFeedItemObj.ParentId=integrationUserObj.id;
            insert actualFeedItemObj;

            actualFeedCommentObj = new FeedComment();
            actualFeedCommentObj.CommentBody='Test_Comment_3';
            actualFeedCommentObj.FeedItemId=actualFeedItemObj.Id;        
            insert actualFeedCommentObj; 

        }

        System.runas(nomuraSalesUserObj){
            //Insert FeedItem
            try {
                FeedItem feedItemObj = new FeedItem();
                feedItemObj.Body='Test_1';
                feedItemObj.ParentId=nomuraSalesUserObj.id;
                insert feedItemObj;
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Chatter is not supported.'));
            }

            //Update FeedItem
            try {
                actualFeedItemObj.Body='Test_4';
                update actualFeedItemObj;
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Chatter is not supported.'));
            }

            //Delete FeedItem
            try {
                delete actualFeedItemObj;
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Chatter is not supported.'));
            }

            //Insert FeedComment
            try {
                FeedComment feedCommentObj = new FeedComment();
                feedCommentObj.CommentBody='Test_Comment_1';
                feedCommentObj.FeedItemId=actualFeedItemObj.Id;        
                insert feedCommentObj; 
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Chatter is not supported.'));
            }

            //Update FeedComment
            try {
                actualFeedCommentObj.CommentBody='Test_Comment_4';
                update actualFeedCommentObj;
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Chatter is not supported.'));
            }

            //Delete FeedComment
            try {
                delete actualFeedCommentObj;
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Chatter is not supported.'));
            }
        }
        

    }
}