/**
* Trigger to adjust sharing on files related to Campaigns
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after delete) {
    String integrationUserId = null;
    
    // prepare to figure out which files are being deleted, if any
    /**Set<Id> deletedIdSet = new Set<Id>();
if (trigger.oldMap != null) {
for (Id oldId : trigger.oldMap.keySet()) {
deletedIdSet.add(oldId);
System.debug('* trigger ContentDocumentLinkTrigger adding ' + oldId + ' to deletedIdSet');
}
}**/
    
    /**
* Files being made visible to a Campaign should also be made visible to the Integration user
*/
    /*if (trigger.new != null) {
List<Id> congaCdlIdList = new List<Id>();
List<Id> congaEntityIdList = new List<Id>();
for (ContentDocumentLink cdl : trigger.new) {
deletedIdSet.remove(cdl.Id);
System.debug('* trigger ContentDocumentLinkTrigger removing new ' + cdl.Id + ' from deletedIdSet');
String docId = cdl.ContentDocumentId;
if (ContentDocumentLinkBL.isPublishedToCampaign(cdl)) {
if (integrationUserId == null) {
integrationUserId = ContentDocumentLinkBL.getIntegrationUserId();
}
if (!ContentDocumentLinkBL.isSharedWithUser(docId, integrationUserId)) {
ContentDocumentLinkBL.shareWithUser(docId, integrationUserId, 'V', 'AllUsers');
}
} else if (ContentDocumentLinkBL.isPublishedToCongaTemplate(cdl)) {
congaCdlIdList.add(cdl.Id);
congaEntityIdList.add(cdl.LinkedEntityId);
}
}

if (!congaCdlIdList.isEmpty()) {
ContentDocumentLinkBL.sendCongaTemplateUploadEmail(congaCdlIdList, congaEntityIdList);
}
}

/**
* Files being removed from visibility to a Campaign can also be hidden from the Integration user
*/
    /* Set<String> deletedIdsToRemoveFromUserSet = new Set<String>();
for (Id deletedId : deletedIdSet) {
ContentDocumentLink dcdl = trigger.oldMap.get(deletedId);
System.debug('* trigger ContentDocumentLinkTrigger deleting ContentDocumentLink Id=' + dcdl.Id 
+ ' sharing ContentDocumentId=' + dcdl.ContentDocumentId 
+ ' to LinkedEntityId=' + dcdl.LinkedEntityId);
if (ContentDocumentLinkBL.isPublishedToCampaign(dcdl)) {
if (integrationUserId == null) {
integrationUserId = ContentDocumentLinkBL.getIntegrationUserId();
}
System.debug('* trigger ALSO removing ' + dcdl.Id + ' from Integration user Id=' + integrationUserId);
deletedIdsToRemoveFromUserSet.add(dcdl.ContentDocumentId);
}
}
if (deletedIdsToRemoveFromUserSet.size() > 0) {
ContentDocumentLinkBL.removeFromUser(deletedIdsToRemoveFromUserSet, integrationUserId);
}*/
}