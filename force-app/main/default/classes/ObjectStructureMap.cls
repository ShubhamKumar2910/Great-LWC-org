public with sharing class ObjectStructureMap{

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;
        
        /**
        * @Change this to your sObject
        */
        public Account account;
        
        @AuraEnabled
        public String getnodeId() { return 'tree0-node' + nodeId.replace('.', '-'); }
		@AuraEnabled
	   public Integer getLevel() {return nodeId.countMatches('.') + 1; }
    	@AuraEnabled
        public Boolean[] getlevelFlag() { return levelFlag; }
        @AuraEnabled
        public Boolean[] getcloseFlag() { return closeFlag; }
        @AuraEnabled
        public String getnodeType() { return nodeType; }
        @AuraEnabled
        public Boolean getcurrentNode() { return currentNode; }


        /**
        * @Change this to your sObject
        */
        @auraEnabled
        public Account getaccount() { return account; }
        
        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }

        /**
        * @Change this to your sObject
        */
        public void setaccount( Account a ) { this.account = a; }

        /**
        * @Change the parameters to your sObject
        */
        public ObjectStructureMap( String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, Account a ){
            
            this.nodeId         = nodeId;
            this.levelFlag      = levelFlag; 
            this.closeFlag      = closeFlag;
            this.nodeType       = nodeType;
            this.currentNode    = currentNode;

            //Change this to your sObject  
            this.account = a;
        }
    }