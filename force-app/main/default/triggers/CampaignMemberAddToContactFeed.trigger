trigger CampaignMemberAddToContactFeed on CampaignMember (after insert, after update) {
/*
     for (CampaignMember cm : Trigger.new) {
         system.debug(cm + '---------AddTask---------' + CM.Campaign);
         FeedItem post = new FeedItem();
         post.parentId = cm.contactId;
         Campaign camp = [select Name from Campaign WHERE ID=: cm.CampaignId];
         post.body = cm.FirstName + ' ' + cm.lastName + ' was added to campaign ' + camp.name;
         System.debug(post.body);
         insert post;         
    }
*/    
}