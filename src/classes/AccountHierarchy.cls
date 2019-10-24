public class AccountHierarchy {
    public String accountId;
    list<account> top_accts;
    public AccountHierarchy(ApexPages.StandardController controller)
    {
        accountId = controller.getId();
        top_accts= [select id, Name from account where Id = :accountId];
        system.debug('top_accts::'+top_accts);
    }
    
    public list<Opportunity> getOpportunityList()
    {
              Map<Id,HierarchyNode> nodes = new Map<Id,HierarchyNode>();
        Set<Id> parent_acc_ids = new Set<Id>();
        list<String> accountIds = new list<String>();
        for (Account a : top_accts) {
            nodes.put(a.Id, new HierarchyNode(a));
            accountIds.add(a.id);
            parent_acc_ids.add(a.Id);
        }
        
        while (parent_acc_ids.size() > 0) {
            Map<Id,Account> subordinate_accounts =
                new Map<Id,Account>([
                    SELECT Id, ParentID, Name
                    FROM Account
                    WHERE ParentId IN :parent_acc_ids
                ]);
            
            parent_acc_ids = subordinate_accounts.keySet();
            
            for (Account acc : subordinate_accounts.values()) {
                accountIds.add(acc.Id);
                HierarchyNode new_node = new HierarchyNode(acc);
                nodes.put(acc.id, new_node);
                HierarchyNode ref_node = nodes.get(acc.parentId);
                ref_node.children.add(new_node);
            }
        }
        system.debug('nodes:::' +nodes.values());
        system.debug('opps::'+[select id,Name,AccountID from opportunity where accountId IN :accountIds ]);
        return [select id,Name,AccountID, Account.Name, StageName, Amount,CloseDate,owner.Name from opportunity where accountId IN :accountIds ];
    }
   
    public static Map<Id,HierarchyNode> acclist {set;get;}
}