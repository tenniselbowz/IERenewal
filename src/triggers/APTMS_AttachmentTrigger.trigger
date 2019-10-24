trigger APTMS_AttachmentTrigger on Attachment (before insert) {
    
    Set<Id> attParentSet = new Set<Id>();
    for(Attachment att: Trigger.new){
        
        
        if(att.ParentId.getSobjectType() == Apttus_Proposal__Proposal__c.SobjectType){
            attParentSet.add(att.ParentId);
        }
    }
    
    Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
    for(Apttus_Proposal__Proposal__c proposal : [select id, name, Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id in : attParentSet]){
        
        proposalMap.put(proposal.id, proposal);
    }
    
    for(Attachment att: Trigger.new){
        
        if(proposalMap.containsKey(att.parentId)){
 
            String proposalName = proposalMap.get(att.parentId).Apttus_Proposal__Proposal_Name__c;
            
            proposalName = proposalName.replaceAll(':','_');

            String[] attName = att.name.split(proposalName);

            if(attName.size() > 1){
                att.name = proposalName + '_' +proposalMap.get(att.parentId).name + attName[attName.size()-1];
            }
     
        }
    }
}