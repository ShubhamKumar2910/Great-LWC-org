public class TreeList {
    public TreeNode rootNode ;
    Map<String, TreeNode> nodeMap;
    List<TreeNode> unparentedNodes ;
    boolean isEmpty = false;

    public integer getSize() {
        return rootNode.getSize();
    }
    
    public List<TreeNode> getData() {
        return rootNode.getChildren();
    }
    
    public List<TreeNode> getSortedData() {
        rootNode.sortData();
        return rootNode.getChildren();
    }
    
    public boolean isEmpty() {
        return isEmpty;
    }
    public TreeList(List<Sobject> sobjs, String idField, String textField, String parentIdsField) {
        if (sobjs == null || sobjs.size() <= 0 )
            isEmpty = true;
        else {
            rootNode = TreeNode.getRootNode();
            nodeMap = new Map<String, TreeNode>();
            unparentedNodes = new List<TreeNode>();
            createTreeStructure(sobjs, idField, textField, parentIdsField);        
        }
    }
    
    private void createTreeStructure (List<Sobject> sobjs, String idField, String textField, String parentIdsField) {
        for (Sobject obj : sobjs) {
            TreeNode node = new TreeNode (obj, idField, textField, parentIdsField);
        nodeMap.put(String.valueOf(node.id), node);
        if (node.isTopLevelNode()) {
        rootNode.addChildNode(node);
        nodeMap.put(String.valueOf(node.id), node);
        }
        else {
        unparentedNodes.add(node);
        }
        }
        doParenting();
    }
    public List<TreeNode> getSortedTreeList() {
        return rootNode.getSortedTreeList();
    }
    
    private void doParenting() {
        if (unparentedNodes != null && unparentedNodes.size() > 0) {
        for (TreeNode unparentedNode : unparentedNodes) {
             Object parentId = unparentedNode.parentId;
             TreeNode parentNode = nodeMap.get(String.valueOf(parentId));
            if (parentNode != null) {
            parentNode.addChildNode(unparentedNode);
            system.debug('In doParenting Succesfully added child ' + unparentedNode.text + ' to parent ' + parentNode.text );
            }
            else {
            system.debug('Error: Unable to find parent for ' + unparentedNode.text + ' parentId = ' + parentId );
            }   
        }    
          }
      }
    
    //Usage
    public Static void printMarketSortedTreeList() {
        List<Sobject> objs = [select code__c, name, parent_codes__c from market__c];
        TreeList treelist = new TreeList(objs, 'code__c', 'name', 'parent_codes__c'); 
        system.debug('isEmpty  = ' + treelist.isEmpty());
        if (!treelist.isEmpty()) {
          system.debug('Size  = ' + treelist.getSize());  
            List<TreeNode> nodeList = treelist.getSortedTreeList();
          for (TreeNode node: nodeList) {
                system.debug(node.id +'>>>>'+ node.text +'>>>>'+ node.parentId );
            }  
        }
    }
    
    public Static void printAssetSortedTreeList() {
        List<Sobject> objs = [select code__c, name, parent_codes__c from AssetClass__c];
        TreeList treelist = new TreeList(objs, 'code__c', 'name', 'parent_codes__c');
        system.debug('isEmpty  = ' + treelist.isEmpty());
        if (!treelist.isEmpty()) {
          system.debug('Size  = ' + treelist.getSize());  
            List<TreeNode> nodeList = treelist.getSortedTreeList();
          for (TreeNode node: nodeList) {
                system.debug(node.id +'>>>>'+ node.text +'>>>>'+ node.parentId );
            }  
        }
    }    
    
    public Static void printSectordTreeList() {
        List<Sobject> objs = [select code__c, name, parent_codes__c from sector__c];
        TreeList treelist = new TreeList(objs, 'code__c', 'name', 'parent_codes__c');
        system.debug('isEmpty  = ' + treelist.isEmpty());
        if (!treelist.isEmpty()) {
          system.debug('Size  = ' + treelist.getSize());  
            List<TreeNode> nodeList = treelist.getSortedTreeList();
          for (TreeNode node: nodeList) {
                system.debug(node.id +'>>>>'+ node.text +'>>>>'+ node.parentId );
            }  
        }
    }     
}