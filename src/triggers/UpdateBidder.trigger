trigger UpdateBidder on Bidder__c (after insert, after update, after delete, after UnDelete) { 
    set<String> oppIds = new set<String>();
  if(trigger.isAfter &&trigger.isDelete){
        for(Bidder__c b :Trigger.old){
            oppIds.add(b.Opportunity__c);    
        }  
    }else {
    	for(Bidder__c b :Trigger.new){
            
            oppIds.add(b.Opportunity__c);    
        }       
    }
    if(oppIds.size() >0)
    {
        BidderHelper.UpdateBiddervalues(oppIds);
    }
}