trigger ApttusQuoteProposalTrigger on Apttus_Proposal__Proposal__c (after update, before Update, before insert) 
{
    String NorthAmericaProposal_recordType =
        Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('North America Proposal').getRecordTypeId(); 

if(TriggerUtility.tau.get('Proposal').isaccessible()){
            TriggerUtility.tau.get('Proposal').increment();
    if(Trigger.isAfter)
    {
        If(Trigger.isUpdate) {
            Map<Id, Apttus_Proposal__Proposal__c> newMap = new Map<Id, Apttus_Proposal__Proposal__c>();
            Map<Id, Apttus_Proposal__Proposal__c> oldMap = new Map<Id, Apttus_Proposal__Proposal__c>();
            for(Apttus_Proposal__Proposal__c proposal : trigger.new)
            {
                if(proposal.recordTypeId == NorthAmericaProposal_recordType)
                {
                    newMap = Trigger.newMap;
                    oldMap = Trigger.oldMap;
                }
            }
            String newMapString = JSON.serialize(newMap);
            String oldMapString = JSON.serialize(newMap);
            if(QuoteProposalTriggerHandler.flag && !system.isBatch() && !system.isFuture())
            {
                QuoteProposalTriggerHandler.UpdatingCreditAuthorization(newMapString, oldMapString);            
            }    
        }
    }
    if(Trigger.isBefore)
    {
        If(Trigger.isUpdate) {
            
            QuoteProposalTriggerHandler.concatenateTKClauses(Trigger.newMap, Trigger.oldMap);
            
            
           ApttusQuoteProposalHandler.HandleBeforeUpdate(trigger.new);
            if(QuoteProposalTestHandler.flag){
                system.debug('enter here');
               QuoteProposalTestHandler.UpdateOpportunityRollup(Trigger.newmap, Trigger.oldmap);
            }
            
        }
        
        if(Trigger.isinsert)
        {
            ApttusQuoteProposalHandler.HandleBeforeInsert(trigger.new);
        }
        
    }
    
    
    if(trigger.isAfter)
    {       
        if(trigger.isUpdate) 
        {           
            ApttusQuoteProposalHandler.HandleAfterUpdate(Trigger.New, Trigger.oldMap);
            
          //  QuoteProposalTriggerHandler.syncQuotetoOpportunity(Trigger.newmap, Trigger.oldmap);//
            
            
        }
        
    }
 } else
    TriggerUtility.tau.get('Proposal').reset(); 
}