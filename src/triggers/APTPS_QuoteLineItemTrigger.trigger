/*
    Trigger : APTPS_QuoteLineItemTrigger
    Description : Trigger is supposed to implement utility methods from helper class.
*/
trigger APTPS_QuoteLineItemTrigger on Apttus_Proposal__Proposal_Line_Item__c(/*before insert,*/after Insert, after update, before delete) {
if(TriggerUtility.tau.get('ProposalLineItem').isaccessible()){
            TriggerUtility.tau.get('ProposalLineItem').increment();

    if(trigger.isDelete){
        Map<Id, Apttus_Proposal__Proposal__c> props = new Map<Id, Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> qlis = [select Id, Apttus_Proposal__Proposal__c, Apttus_Proposal__Proposal__r.Warranty_Parts_Material_Amt__c, Apttus_Proposal__Proposal__r.Warranty_Parts_Material__c, Apttus_Proposal__Proposal__r.Warranty_Equipment_Amt__c, Apttus_Proposal__Proposal__r.Warranty_Equipment__c, Apttus_QPConfig__ClassificationHierarchy__c, Apttus_QPConfig__LineType__c from Apttus_Proposal__Proposal_Line_Item__c where Id in :trigger.old];
        for(Apttus_Proposal__Proposal_Line_Item__c qli : qlis){
            if(qli.Apttus_QPConfig__ClassificationHierarchy__c == 'Warranty (Parts & Material)' && qli.Apttus_QPConfig__LineType__c == 'Product/Service'){
                qli.Apttus_Proposal__Proposal__r.Warranty_Parts_Material_Amt__c = 0;
                qli.Apttus_Proposal__Proposal__r.Warranty_Parts_Material__c = 0;
                props.put(qli.Apttus_Proposal__Proposal__c, qli.Apttus_Proposal__Proposal__r);
            } else if(qli.Apttus_QPConfig__ClassificationHierarchy__c == 'Warranty (Equipment)' && qli.Apttus_QPConfig__LineType__c == 'Product/Service'){
                qli.Apttus_Proposal__Proposal__r.Warranty_Equipment_Amt__c = 0;
                qli.Apttus_Proposal__Proposal__r.Warranty_Equipment__c = 0;
                props.put(qli.Apttus_Proposal__Proposal__c, qli.Apttus_Proposal__Proposal__r);
            }
        }
        if(props.size()>0)
            update props.values();
    } else
        APTPS_QuoteLineItemTriggerHandler.setBlendedRateOnQuotes(trigger.new);
    
/*    
    if(trigger.isBefore) {
        if(trigger.isInsert) {
            APTPS_QuoteLineItemTriggerHandler.assignRecordTypeOnQuoteLineFromParentQuote(trigger.new);
        }
    }
    if(trigger.isAfter) {
        if(trigger.isInsert){
            APTPS_QuoteLineItemTriggerHandler.setConfigFinalizedDateOnQuotes(trigger.new); 
        } else if(trigger.isUpdate) {
            APTPS_QuoteLineItemTriggerHandler.setConfigFinalizedDateOnQuotes(trigger.new);
        } else if(trigger.isdelete) {
            APTPS_QuoteLineItemTriggerHandler.setConfigFinalizedDateOnQuotes(trigger.old);
        }
        
    } 
*/    
    } else
      TriggerUtility.tau.get('ProposalLineItem').reset();      
}