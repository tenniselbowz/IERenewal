public class opportunityRollupsBatchHelper {
   
    public static list<opportunity> opportunityRollupsUpdate(List<Opportunity> oppList)
    {
        set<id> userIds = new set<id>();
        set<String> contactIds = new set<String>();
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        System.debug('Oppoty List::::::::'+oppList);
        for(Opportunity opp :oppList)
        {
            for(OpportunityContactRole r : opp.OpportunityContactRoles)
            {
                contactIds.add(r.contactId);
            }  
            for(Bidder__c b: opp.Bidders__r)
            {
                userIds.add(b.ownerId);
            }
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Name, Account.Name FROM Contact WHERE Id IN :contactIds Order By Name]);
        Map<Id, User> userMap = new Map<Id, User>([SELECT id, Name, User_Department__c from User WHERE id IN : userIds]);
        for(Opportunity opp :oppList){
            Integer childCount = 0;
            opp.Contact_Rollup__c = '';
            for(OpportunityContactRole r : opp.OpportunityContactRoles){
                childCount++;
                if(childCount != opp.OpportunityContactRoles.size()){
                    opp.Contact_Rollup__c += contactMap.get(r.contactId).Name+
                        ' @ '+contactMap.get(r.contactId).Account.Name+' ('+r.Role+')'+'; ';
                }
                else{
                    opp.Contact_Rollup__c += contactMap.get(r.contactId).Name+
                        ' @ '+contactMap.get(r.contactId).Account.Name+' ('+r.Role+')';    
                }
            }
            opp.Product_Rollup__c = '';
            childCount = 0;
            for(OpportunityLineItem opli : opp.OpportunityLineItems){
                childCount++;
                if(childCount != opp.OpportunityLineItems.size()){
                    opp.Product_Rollup__c += opli.Product2.Name  +', '; 
                }else{
                    opp.Product_Rollup__c += opli.Product2.Name; 
                }
                
            }
            
            opp.Bidder_Rollup__c = '';
            childCount = 0;
            for(Bidder__c b : opp.Bidders__r){
                childCount++;
                String department = userMap.get(b.ownerId).User_Department__c;
                System.debug('Department::'+department);
               
                if(department == null){
                  department = '-';    
                }
                if(childCount != opp.Bidders__r.size()){
                    opp.Bidder_Rollup__c += b.Bidder_Name__r.Name+'-'+b.owner.Name+' ('+department+'), AWB='+b.Apparent_Winning_Bidder__c+'; ';
                }else{
                    opp.Bidder_Rollup__c += b.Bidder_Name__r.Name+'-'+b.owner.Name+' ('+department+'), AWB='+b.Apparent_Winning_Bidder__c;         
                }
                
            }
            if(opp.OpportunityContactRoles.size() > 0 || opp.Bidders__r.size() > 0 || opp.OpportunityLineItems.size() >0){
                opp.Edited__c = false;
                oppToBeUpdated.add(opp);     
            }
            
        }
        try{
            if(!oppToBeUpdated.isEmpty()){
                update oppToBeUpdated;   
            }
        }
        catch(Exception e){
            System.debug('Line Number::'+e.getLineNumber()+'\n StackTrace::'+e.getStackTraceString());
            System.debug('Error ::'+e.getMessage());
        } 
        return oppToBeUpdated;
    }
}