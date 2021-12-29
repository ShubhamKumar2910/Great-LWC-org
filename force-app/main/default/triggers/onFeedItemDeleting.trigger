trigger onFeedItemDeleting on FeedItem (before delete) {
    public static User userObj {
        public get {
            if(userObj==null) {
                userObj = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];   
            }
            return userObj;
        }
        private set;
    }

    for(FeedItem a: Trigger.old){
        if(!'Nomura - Integration'.equalsIgnoreCase(userObj.Profile.Name)) {
            a.addError('Chatter is not supported.'); 
        }
    }
}