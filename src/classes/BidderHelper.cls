public class BidderHelper {
    
    public static void UpdateBiddervalues(set<String> oppIds){
        List<Opportunity> opptobeUpdated = new List<Opportunity>();
        Integer i = 0;
        for(Opportunity opp :[SELECT Id,Active_Bidder__c,(SELECT Bidder_Name__r.Owner.Name,Bidder_Name__r.Owner.User_Department__c,
                                                          Inactive__c,Opportunity__c FROM 
                                                          Bidders__r WHERE  Inactive__c=FALSE) FROM Opportunity WHERE Id IN :oppIds]){
            
            opp.Active_Bidder__c = ' ';
            for(Bidder__c b :opp.Bidders__r){
               
                i++;
                opp.Active_Bidder__c += 'Active Bider'+' '+i+':'+b.Bidder_Name__r.Owner.Name+' ('+b.Bidder_Name__r.Owner.User_Department__c+'), ';
                
            }
			
            opp.Active_Bidder__c = +opp.Active_Bidder__c.removeEnd(', ');
            
            opptobeUpdated.add(opp);
        }
        
        if(opptobeUpdated.size() > 0){
            update opptobeUpdated;    
        }  
    }
}