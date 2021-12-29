public class CmpApprovalURLCtrl{  
   public static String ApprovalID {get; set;}  
   public static String ActorId {get; set;}  
    
    public static String urlStr{  
    get  
   {  
     return GenerateApprovalURL.generateApprovalURL(ApprovalID,ActorId);  
   }}  
 }