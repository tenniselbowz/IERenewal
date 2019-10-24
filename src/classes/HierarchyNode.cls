public class HierarchyNode {
    Account node;
    public List<HierarchyNode> children;
 
   public HierarchyNode(Account acc) {
        node = acc;
        children = new List<HierarchyNode>();
    }
}