global Class TreeNode implements Comparable  {
         static string ROOT_NODE='ROOT_NODE';
         public Object text;
         public Object id;
         public Object parentId;
         public Object picklist;
	 public String parentDelimCodes;
         public List<TreeNode> children;
		 public TreeNode parent;
        
         TreeNode() {
        }

    	 public TreeNode(sobject sobj, String idField, String textField, String parentIdsField) {
         	text =sobj.get(textField);
         	id = sobj.get(idField);
             picklist = sobj.get('picklist__c');
		parentDelimCodes = (String)sobj.get(parentIdsField);
		
		if (parentDelimCodes != null) {
		    String[] codes = parentDelimCodes.split(':');
		    if (codes != null) {
				integer size = codes.size();
				parentId = codes[size -1 ];
		    }
		}
            children =  new List<TreeNode>();
        }
	
	public void addChildNode(TreeNode childNode) {
		this.children.add(childNode);
		childNode.parent = null; // otherwise json issue
	}
    
        public List<TreeNode> getChildren() {
          return children;
        }
    
        public boolean isRootNode() {
            if (this.text == ROOT_NODE)
                return true;
            else
                return false;
        }
	
	public boolean isTopLevelNode() {
            if (this.parentId == null || String.valueOf(String.valueOf(parentId)) == '')
                return true;
            else
                return false;
        }
    
        public static TreeNode getRootNode() {
            TreeNode rootNode = new TreeNode();
            rootNode.text= ROOT_NODE;
            rootNode.children = new List<TreeNode>();
            return rootNode;
        }     
	    global Integer compareTo(Object compareTo) {
	        TreeNode that = (TreeNode)compareTo;
            String thisName = (String) this.text;
            String thatName = (String) that.text;
	        return thisName.compareTo(thatName);       
	    } 
        public integer getSize() {
           integer size = 0;
           if (!this.isRootNode())
            	size++;
            
            if (children != null && children.size() > 0) {
                for (TreeNode child : children) {
                    size = size + child.getSize();
                }
            }
           return size;    
        }
        public List<TreeNode> getSortedTreeList() {
                List<TreeNode> sortedTreeList = new List<TreeNode>();

		// Add parent Ids to id field. Useful later
		system.debug('id = ' + id);
		if (parentDelimCodes != null) {
			this.id = parentDelimCodes + ':' + id;
		}
		system.debug('after id = ' + id);
                if (!isRootNode()) {
                    sortedTreeList.add(this);
                }    
                if (children != null && children.size() > 0) {
                    children.sort();
                    for (TreeNode child : children) {
                        sortedTreeList.addAll(child.getSortedTreeList());
                    }
                }
                return sortedTreeList;
        }    
        public void sortData() {
		// Add parent Ids to id field. Useful later
		system.debug('id = ' + id);
		if (parentDelimCodes != null) {
			this.id = parentDelimCodes + ':' + id;
		}
		system.debug('after id = ' + id);
		
                if (children != null && children.size() > 0) {
                    children.sort();
                    for (TreeNode childNode : children) {
                        childNode.sortData();
                    }
                }
        }     
    }