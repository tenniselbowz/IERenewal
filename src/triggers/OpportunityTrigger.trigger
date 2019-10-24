trigger OpportunityTrigger on Opportunity (after update, before insert, before update) {
    List<Opportunity> oppList = new List<opportunity>();
    if(trigger.isAfter) {
        if(trigger.isUpdate) {
            OpportunityTriggerHandler.handleAfterUpdate(trigger.newMap,trigger.oldMap);
            for(Opportunity opp : trigger.new){
                if(opp.Bid_Date__c !=  trigger.oldMap.get(opp.id).Bid_Date__c){
                	oppList.add(opp);    
                }  
            }
            if(oppList.size() > 0){
            	OpportunityTriggerHandler.updateBidderDate(oppList);    
            }
            
        }
        system.debug('Enterhere::');
    }

    if(trigger.isBefore) {
        if (trigger.isinsert) {
            
            OpportunityTriggerHandler.handleBeforeInsertUpdate(trigger.new);
            for(Opportunity opp : trigger.new){
               if(opp.Pricebook2Id == null )
                   opp.Pricebook2Id = '01s800000006K3p';//Standard Price Book

            }
        }
        if (trigger.isUpdate) {
            OpportunityTriggerHandler.handleBeforeInsertUpdate(trigger.new);
            
        }
        if(trigger.isinsert || trigger.isUpdate){
            OpportunityTriggerServices.updateRollupFields(trigger.new);
        }
    }
}