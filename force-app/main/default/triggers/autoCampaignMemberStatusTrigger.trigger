//SAM when you work on this trigger please 
// --add custom labels 
// --make it available for Japanese locale 
// --and do it only for mass email
// -- this is for Campaign/Menage Members/Add Member/ Add with Status drop down list
// -- Default Value is Sent and Responded
// -- if we want to change it , enable this trigger
trigger autoCampaignMemberStatusTrigger on Campaign (after insert, after update) {
    //System.debug('Inside autoCampaignMemberStatusTrigger');
    //AutoCmpgnMembrStatusTrgHndlr.OnAfterInsertAndUpdate(trigger.New);
}