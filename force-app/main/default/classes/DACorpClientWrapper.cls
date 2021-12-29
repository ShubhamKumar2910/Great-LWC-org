public class DACorpClientWrapper {
	
	    public DACorpClientWrapper(Id eventObjId, String oldCPIdForEvent, String newCPIdForEvent){
            eventId = eventObjId;
            oldCPId = oldCPIdForEvent;
            newCPId = newCPIdForEvent;
            success = TRUE;
        }
        
        public Id eventId;
        public String oldCPId;
        public String newCPId;
        public Boolean success;
    

}